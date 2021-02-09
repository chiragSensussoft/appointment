import 'package:flutter/material.dart';

class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
        begin: const Offset(0.0, 0.0),
        end: const Offset(-0.2, 0.0)
    ).animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller.animateTo(.0);
        else if (_controller.value >= .5 || data.primaryVelocity < -2500)
          _controller.animateTo(1.0);
        else
          _controller.animateTo(.0);
      },

      child: new Stack(
        children: <Widget>[
          Container(child: SlideTransition(position: animation, child: widget.child)),

          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: new Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.only(right: 8),
                              child: new Row(
                                children: widget.menuItems.map((child) {
                                  return Expanded(
                                    child: Container(child: child),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}