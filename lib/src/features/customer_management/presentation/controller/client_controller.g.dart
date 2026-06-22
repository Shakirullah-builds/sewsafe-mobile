// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientsListHash() => r'ed325b35fc0de70bc0646995576e1aa87458f8e2';

/// See also [clientsList].
@ProviderFor(clientsList)
final clientsListProvider = AutoDisposeFutureProvider<List<Client>>.internal(
  clientsList,
  name: r'clientsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClientsListRef = AutoDisposeFutureProviderRef<List<Client>>;
String _$clientControllerHash() => r'ee82e6912b960ee8112f7ca8dead7acbb456513e';

/// See also [ClientController].
@ProviderFor(ClientController)
final clientControllerProvider =
    AutoDisposeAsyncNotifierProvider<ClientController, void>.internal(
      ClientController.new,
      name: r'clientControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clientControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ClientController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
