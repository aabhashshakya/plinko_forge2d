///Created by Aabhash Shakya on 6/14/25
import 'package:flutter/material.dart';
///Created by Aabhash Shakya on 3/13/25
import 'package:flutter/material.dart';
import 'dart:ui';

class BlurredDropdownItem {
  final dynamic value;
  final String displayName;

  BlurredDropdownItem({required this.value, required this.displayName});
}

enum BlurredDropdownMenuAlignment { left, right }

class BlurredDropdown extends StatefulWidget {
  final Color backgroundColor;
  final double? width;
  final BlurredDropdownMenuAlignment alignment;
  final bool matchDropDownMenuWidth;
  final List<BlurredDropdownItem> dropdownItems;
  final double blurRadius;
  final double menuItemBlurRadius;
  final dynamic initialSelectedItem;
  final Function(dynamic) onSelectionChanged;

  const BlurredDropdown({required this.dropdownItems,
    required this.initialSelectedItem,
    this.alignment = BlurredDropdownMenuAlignment.left,
    required this.onSelectionChanged,
    this.matchDropDownMenuWidth = true,
    this.backgroundColor = Colors.grey,
    this.width,
    this.blurRadius = 10,
    this.menuItemBlurRadius = 3});

  @override
  _BlurredDropdownState createState() => _BlurredDropdownState();
}

class _BlurredDropdownState<T> extends State<BlurredDropdown>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late BlurredDropdownItem selectedItem;

  //animation
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.dropdownItems
        .firstWhere((e) => e.value == widget.initialSelectedItem);

    //animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Smooth animation duration
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.1), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Widget positionedLocaled({required BlurredDropdownMenuAlignment alignment,
    required bool matchDropDownMenuWidth, required Widget child
  }) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    final RenderBox renderBox =
    _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    if (isRTL) {
      return Positioned(
          left: alignment == BlurredDropdownMenuAlignment.right
              ? offset.dx
              : null,
          top: offset.dy + size.height + 5,
          width: widget.matchDropDownMenuWidth ? size.width : null,
          right: (widget.alignment == BlurredDropdownMenuAlignment.left
              ? MediaQuery
              .of(context)
              .size
              .width - (offset.dx + size.width)
              : null),
          child: child);
    } else {
      return Positioned(
          left: (widget.alignment == BlurredDropdownMenuAlignment.left
              ? offset.dx
              : null),
          right: widget.alignment == BlurredDropdownMenuAlignment.right
              ? MediaQuery
              .of(context)
              .size
              .width - (offset.dx + size.width)
              : null,
          top: offset.dy + size.height + 5,
          width: widget.matchDropDownMenuWidth ? size.width : null,
          child: child);
      // }
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showDropdown();
    } else {
      _removeDropdown();
    }
  }

  void _showDropdown() {
    _overlayEntry = OverlayEntry(
      builder: (context) =>
          Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Blurred Background
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _removeDropdown,
                    child: Container(
                      color: Colors.black.withOpacity(0),
                    ),
                  ),
                ),
                // Dropdown Menu
                positionedLocaled(
                  //match the width of menu items to the current selection container
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: widget.menuItemBlurRadius,
                              sigmaY: widget.menuItemBlurRadius),
                          // Blur effect
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: widget.blurRadius,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: widget.dropdownItems.map((item) {
                                return InkWell(
                                  onTap: () {
                                    setState(() => selectedItem = item);
                                    widget.onSelectionChanged(item.value);
                                    _removeDropdown(immediate: true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      // Semi-transparent
                                    ),
                                    child: FittedBox(
                                      child: Text(item.displayName,
                                          style:
                                          const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ), alignment: widget.alignment, matchDropDownMenuWidth: widget.matchDropDownMenuWidth,
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(); // Start animation
  }

  void _removeDropdown({bool immediate = false}) {
    if (immediate) {
      //remove without animation
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  void dispose() {
    _removeDropdown(immediate: true);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = Container(
      width: widget.width,
      padding: const EdgeInsets.only(left: 10, right: 4, top: 3, bottom: 3),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: widget.blurRadius),
        ],
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(selectedItem.displayName,
                  maxLines: 1, style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          const Icon(
            size: 20,
            Icons.arrow_drop_down,
            color: Colors.white,
          )
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            key: _buttonKey,
            onTap: _toggleDropdown,
            child: widget.width == null
                ? IntrinsicWidth(
              child: child,
            )
                : child),
      ],
    );
  }

}


