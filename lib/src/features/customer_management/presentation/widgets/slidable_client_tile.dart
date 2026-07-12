import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SlidableClientTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const SlidableClientTile({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  State<SlidableClientTile> createState() => _SlidableClientTileState();
}

class _SlidableClientTileState extends State<SlidableClientTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragExtent = 0.0;
  
  // Maximum drag extent to reveal the delete button
  final double _maxDragExtent = -80.0;
  // Threshold to trigger auto-delete confirmation dialog
  final double _triggerThreshold = -180.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(() {
      setState(() {
        _dragExtent = _controller.value * _maxDragExtent;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
      // Clamp drag extent between the force trigger threshold and 0.0
      if (_dragExtent > 0.0) _dragExtent = 0.0;
      if (_dragExtent < _triggerThreshold) _dragExtent = _triggerThreshold;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent <= _triggerThreshold) {
      // Force swipe triggers the deletion confirmation
      _controller.value = 1.0; // keep it fully revealed visually
      widget.onDelete();
      _snapClosed();
      return;
    }

    // Determine snapping behavior based on drag extent and velocity
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity < -300) {
      // Fast swipe left -> snap open
      _snapOpen();
    } else if (velocity > 300) {
      // Fast swipe right -> snap closed
      _snapClosed();
    } else if (_dragExtent < _maxDragExtent / 2) {
      // Dragged past halfway -> snap open
      _snapOpen();
    } else {
      // Dragged less than halfway -> snap closed
      _snapClosed();
    }
  }

  void _snapOpen() {
    _controller.animateTo(
      1.0,
      curve: Curves.easeOutCubic,
    );
  }

  void _snapClosed() {
    _controller.animateTo(
      0.0,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background red delete button (revealed under the slidable child)
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.h), // Align with standard card list margins
            decoration: BoxDecoration(
              color: Colors.red[600],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _snapClosed();
                      widget.onDelete();
                    },
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    child: Container(
                      width: 80.w,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 24.r,
                          ),
                          4.verticalSpace,
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.spMin,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Foreground widget (slidable client card)
        GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0.0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
