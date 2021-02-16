import 'package:flutter/material.dart';


class SimpleAccountMenu extends StatefulWidget {
  final List<Widget> icons;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final ValueChanged<int> onChange;
  final text;
  final int selectedIndex;

  const SimpleAccountMenu({
    Key key,
    this.icons,
    this.borderRadius,
    this.backgroundColor = const Color(0xFFF67C0B9),
    this.iconColor = Colors.black,
    this.onChange,
    this.text,
    this.selectedIndex
  })  : assert(icons != null),
        super(key: key);
  @override
  _SimpleAccountMenuState createState() => _SimpleAccountMenuState();
}

class _SimpleAccountMenuState extends State<SimpleAccountMenu>
    with SingleTickerProviderStateMixin {
  GlobalKey _key;
  bool isMenuOpen = false;
  Offset buttonPosition;
  Size buttonSize;
  OverlayEntry _overlayEntry;
  BorderRadius _borderRadius;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _borderRadius = widget.borderRadius ?? BorderRadius.circular(4);
    _key = LabeledGlobalKey("button_icon");
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  findButton() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry.remove();
    _animationController.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    _animationController.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry);
    isMenuOpen = !isMenuOpen;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: _key,
        child: Container(
          width: 100,
          // height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              // alignment: Alignment.center,
              child: Text(widget.text,textAlign: TextAlign.center,style: TextStyle(fontSize: 16),),
            ),
            Container(
              child: Icon(Icons.language),
            ),
          ],
        ),
        // color: Colors.white,
        ),
        onTap: () {
          if (isMenuOpen) {
            closeMenu();
          } else {
            openMenu();
          }
        },
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height,
          left: buttonPosition.dx,
          width: buttonSize.width,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                // Align(
                //   alignment: Alignment.topCenter,
                //   child: ClipPath(
                //     clipper: ArrowClipper(),
                //     child: Container(
                //       width: 17,
                //       height: 17,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 5,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Theme(
                        data: ThemeData(
                          iconTheme: IconThemeData(
                            color: widget.iconColor,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                              widget.icons.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                widget.onChange(index);
                                closeMenu();
                              },
                              child: Container(
                                height: 35,
                                width: 100,
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: index == widget.selectedIndex ? Colors.grey[100] : Colors.white,
                                ),
                                child: Container(
                                  width: buttonSize.width,
                                  child: widget.icons[index],
                                ),
                              ),
                            );
                          },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
