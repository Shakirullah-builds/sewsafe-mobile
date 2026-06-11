# SewSafe Infrastructure Guide: Production Auth Setup (Porkbun + Resend + Supabase)

This document serves as the single source of truth for configuring production-ready email authentication, password recovery, and native mobile deep linking for the SewSafe mobile application. 

---

## Architectural Overview

To deliver a reliable, secure experience that ensures tailor measurement profiles are backed up without hitting free-tier limits, the authentication infrastructure uses three tightly decoupled services:

1. **Porkbun (Domain Registrar):** Owns and manages the authoritative DNS records for the application's domain name (`sewsafe.app`).
2. **Resend (Email Service Provider):** Acts as our hardened SMTP (Simple Mail Transfer Protocol) relay, responsible for sending out transactional emails (Sign-up OTPs and Password Reset tokens).
3. **Supabase Auth (Backend Services):** Manages user sessions, secure password hashing, and generates the underlying security tokens passed to the SMTP engine.

---

## Step 1: Purchasing the Domain (Porkbun)

1. Navigate to **porkbun.com** and register an account.
2. Search for your target domain (`sewsafe.app`).
3. Proceed to checkout and purchase the domain. 
   * *Note: The `.app` top-level domain is strictly owned by Google and fundamentally requires SSL/HTTPS to operate on the web. Porkbun includes WHOIS privacy and SSL certificates for free.*
4. Go to your **Domain Management** dashboard to confirm the domain is active.

---

## Step 2: Domain Provisioning in Resend

1. Log into your **Resend Dashboard** (`resend.com`).
2. From the left sidebar navigation, click on **Domains** and select **Add Domain**.
3. Input your exact domain name (`sewsafe.app`) and select your closest server region (e.g., `us-east-1`).
4. Click **Add**. Resend will instantly generate a table of required **DNS Records** (typically 1 MX record and 2 TXT records). Leave this tab open.

---

## Step 3: Authoritative DNS Mapping (Porkbun to Resend)

To prove to the email ecosystem that Resend has legitimate authority to send emails on behalf of your domain, you must map the cryptographic keys from Resend directly into Porkbun's DNS Zone Editor.

1. Open your **Porkbun Domain Management** page.
2. Locate your domain, and click on the **DNS** link/gear icon to open the **Manage DNS Records** console.
3. For each row displayed in your Resend dashboard, add a corresponding record in Porkbun:

### Record 1: DKIM (DomainKeys Identified Mail)
* **Type:** `TXT`
* **Host/Subdomain:** Copy the specific subdomain slug from Resend (usually looks like `resend._domainkey`).
* **Value/Answer:** Paste the long alphanumeric cryptographic string provided by Resend.

### Record 2: SPF (Sender Policy Framework)
* **Type:** `TXT`
* **Host/Subdomain:** Leave blank or input `@` (representing the root domain).
* **Value/Answer:** `v=spf1 include:amazonses.com ~all` (or the specific record string explicitly displayed by Resend).

### Record 3: Inbound MX (Mail Exchanger)
* **Type:** `MX`
* **Host/Subdomain:** Copy the inbound slug from Resend (e.g., `bounces`).
* **Value/Answer:** Paste the target mail endpoint (e.g., `feedback-smtp.us-east-1.amazonses.com`).
* **Priority:** `10`

4. Once all records are saved in Porkbun, go back to the **Resend** tab and click **Verify DNS Records**. 
   * *DNS Propagation Warning: It can take anywhere from 5 to 60 minutes for global nameservers to cache these updates. If verification fails initially, wait a few minutes and retry.*

---

## Step 4: Generating SMTP SMTP API Keys

Once the domain status switches to a green **Verified** badge inside Resend:

1. Click on **API Keys** in the Resend left sidebar.
2. Click **Create API Key**.
3. Name the key `SewSafe Supabase SMTP`, assign it **Full Access** permission, and restrict it to your newly verified domain.
4. Click **Add** and **copy the generated string (`re_...`) immediately**. It will never be displayed to you again.

---

## Step 5: Connecting the Relay to Supabase

1. Open your **Supabase Project Dashboard**.
2. Navigate to **Authentication** > **Emails** from the left-hand navigation.
3. Scroll down to the **SMTP Settings** panel and toggle **Enable Custom SMTP** to **ON**.
4. Populate the fields exactly as follows:

| Field Name | Expected Input Value |
| :--- | :--- |
| **SMTP Host** | `smtp.resend.com` |
| **SMTP Port** | `465` (Secure SSL) *or `587` (TLS)* |
| **SMTP Username** | `resend` (Type this exactly, in lowercase) |
| **SMTP Password** | *Paste the long `re_...` API key copied from Step 4* |
| **Sender Email** | `no-reply@yourdomain.app` (Must match your verified domain) |
| **Sender Name** | `SewSafe` |

5. Click **Save Changes** at the bottom of the screen. Supabase will now bypass its global default mailer limits (2 emails/hour) and route all structural transactions cleanly through Resend.

---

## Step 6: Configuring URL Allow-Lists for Deep Linking

When a user triggers a password reset or clicks an email confirmation link, the system redirects them to an external web browser. To ensure the mobile browser hands the session back to our native Flutter environment, Supabase must whitelist our custom URL scheme.

1. In the Supabase Dashboard, navigate to **Authentication** > **URL Configuration**.
2. Locate the **Redirect URLs** block and click **Add URL**.
3. Input the exact application URL scheme compiled inside your Flutter code:
```text
   sewsafe://login