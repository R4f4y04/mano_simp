import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<DropdownAction> actions;

  const CustomDropdownButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.actions,
  }) : super(key: key);

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  late OverlayEntry _overlayEntry;

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry.remove();
    }
    super.dispose();
  }

  void _showDropdown() {
    setState(() {
      _isOpen = true;
    });
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
  }

  void _hideDropdown() {
    if (_isOpen) {
      _overlayEntry.remove();
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _hideDropdown();
    } else {
      _showDropdown();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    // Calculate available height for dropdown
    final double maxHeight = 150.0; // Maximum height for dropdown

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
              0, size.height + 2), // Position below the button with small gap
          child: Material(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: widget.color, width: 1.0),
              ),
              constraints: BoxConstraints(
                maxHeight: maxHeight, // Limit maximum height
              ),
              child: SingleChildScrollView(
                // Make content scrollable if it exceeds the maxHeight
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Actions list
                    ...widget.actions.map((action) => InkWell(
                          onTap: () {
                            _hideDropdown();
                            action.onPressed();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            margin: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Text(
                              action.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownAction {
  final String label;
  final VoidCallback onPressed;

  DropdownAction({
    required this.label,
    required this.onPressed,
  });
}
