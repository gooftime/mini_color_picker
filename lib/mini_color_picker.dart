library mini_color_picker;


import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:core';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;


part 'controller.dart';

// https://www.davidanaya.io/flutter/combine-multiple-gestures.html

class MiniColorPicker extends StatefulWidget {
  final MiniColorPickerController controller;
  final double minTransparency, maxTransparency;
  final Color color;
  final double transparency;
  final MiniColorPickerTransparencyCalcSide transparencyCalcSide;
  final MiniColorPickerDirection widgetDirection;
  final double sizeDivider;

  MiniColorPicker({
    Key key,
    @required this.controller,
    this.color = Colors.red,
    this.transparency = 1,
    this.minTransparency = 0,
    this.maxTransparency = 1,
    this.transparencyCalcSide = MiniColorPickerTransparencyCalcSide.top,
    this.widgetDirection = MiniColorPickerDirection.horizontal,
    this.sizeDivider = 2,
  }) : super(key: key);

  @override
	_MiniColorPickerState createState() => _MiniColorPickerState();
}






class _MiniColorPickerState extends State<MiniColorPicker> {

  GlobalKey _gradientKey = GlobalKey();
  img.Image _gradientSnapshot;

  MiniColorPickerController _controller;

  @override
  initState() {
    _controller = widget.controller; //  ?? MiniColorPickerController()
    _controller.color = widget.color;
    _controller.minTransparency = widget.minTransparency;
    _controller.maxTransparency = widget.maxTransparency;
    _controller.transparency = widget.transparency ?? _controller.minTransparency;
    super.initState();
  }
  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }



  Future<img.Image> _loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint = _gradientKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();
    ByteData imageBytes = await capture.toByteData(format: ui.ImageByteFormat.png);
    capture.dispose();

    return img.decodeImage(imageBytes.buffer.asUint8List());
  }

  void _calculateTransparency(DragUpdateDetails _dragUpdateDetails) async {

    double space;

    RenderBox box = _gradientKey.currentContext.findRenderObject();
    Offset globalPosition = _dragUpdateDetails.globalPosition;
    Offset localPosition = box.globalToLocal(globalPosition);
    Offset boxPosition = box.localToGlobal(Offset.zero);


    if(widget.transparencyCalcSide == MiniColorPickerTransparencyCalcSide.top) {
      space = boxPosition.dy  * .75;
      if(localPosition.dy < 0) {
        _controller.transparency = localPosition.dy.abs() / space * _controller.maxTransparency;
      }
    } else if(widget.transparencyCalcSide == MiniColorPickerTransparencyCalcSide.bottom) {
      space = ( MediaQuery.of(context).size.height - boxPosition.dy - box.size.height ) * .75;
      if(localPosition.dy > 0) {
        _controller.transparency = localPosition.dy / space * _controller.maxTransparency;
      }
    } else if(widget.transparencyCalcSide == MiniColorPickerTransparencyCalcSide.left) {
      space = boxPosition.dx  * .75;
      if(localPosition.dx < 0) {
        _controller.transparency = localPosition.dx.abs() / space * _controller.maxTransparency;
      }
    } else if(widget.transparencyCalcSide == MiniColorPickerTransparencyCalcSide.right) {
      space = ( MediaQuery.of(context).size.width - boxPosition.dx - box.size.width ) * .75;
      if(localPosition.dx > 0) {
        _controller.transparency = localPosition.dx / space * _controller.maxTransparency;
      }
    } else {
      throw 'select brush direction';
    }
  }


  /*
    nicely commented to remember what's going on here later :]

    the goal is simply to restrict pixel searcher to gradient container (hereinafter "box")
    in case when touch interaction is out of the box.

    to do that we
      - get box starting points and size, after which calculate minimum Y&X and maximum Y&X
      allowed global position for pixel searcher to be in the box;
      - after that we convert the resulting restricted global position to local position of container
      and calculate color of received pixel;
  */
  void _calculatePixel(DragUpdateDetails _dragUpdateDetails) async {

    _gradientSnapshot ??= await _loadSnapshotBytes(); // create and get snapshot image from gradient

    Offset globalPosition = _dragUpdateDetails.globalPosition;
    RenderBox box = _gradientKey.currentContext.findRenderObject(); // getting position for gradient container ()
    Offset boxPosition = box.localToGlobal(Offset.zero); // get starting points of the box

    // getting MAX and MIN values of the gradient Container
    // +5 and -5 are offsets for borders and rounded angles
    double minX = boxPosition.dx + 5;
    double maxX = boxPosition.dx + box.size.width - 5;

    double minY = boxPosition.dy + 5;
    double maxY = boxPosition.dy + box.size.height - 5;

    // calculating restricted in box global position
    double restrictedX;
    double restrictedY;

    if(globalPosition.dx < minX)
      restrictedX = minX;
    else if(globalPosition.dx > maxX)
      restrictedX = maxX;
    else
      restrictedX = globalPosition.dx;

    if(globalPosition.dy < minY)
      restrictedY = minY;
    else if(globalPosition.dy > maxY)
      restrictedY = maxY;
    else
      restrictedY = globalPosition.dy;

    // convert final coordinates to local position
    Offset restrictedOffset = Offset(restrictedX, restrictedY);
    Offset localPosition = box.globalToLocal(restrictedOffset);

    int pixel32 = _gradientSnapshot.getPixelSafe(localPosition.dx.toInt(), localPosition.dy.toInt());
    int hex = abgrToArgb(pixel32);

    // print('globalPosition: $globalPosition');
    // print('localPosition: ${box.globalToLocal(globalPosition)}');
    // print('restrictedOffset: $restrictedOffset');
    // print('localPositionRestricted: $localPosition');
    // print('_dragUpdateDetails.localPosition: ${_dragUpdateDetails.localPosition}');
    // print('_dragUpdateDetails.delta: ${_dragUpdateDetails.delta}');

    _controller.color = Color(hex);
  }

  // image lib uses uses KML color format, convert #AABBGGRR to regular #AARRGGBB
  int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }


  LinearGradient gradientContainer() {
    return widget.widgetDirection == MiniColorPickerDirection.vertical ?
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.yellow, Colors.red, Colors.green, Colors.blue, Colors.white, Colors.black]
      ) :
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.white, Colors.black]
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _controller.dragging = true,
      onPanEnd: (d) => _controller.dragging = false,
      onPanCancel: () => _controller.dragging = false,
      onPanUpdate: (details) {
        _calculateTransparency(details);
        _calculatePixel(details);
      },
      child: Container(
        // color: Colors.yellow[300],
        child: Center(
          child: RepaintBoundary(
            key: _gradientKey,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  height: widget.widgetDirection == MiniColorPickerDirection.horizontal ?
                    constraints.maxHeight/widget.sizeDivider : constraints.maxHeight,
                  width: widget.widgetDirection == MiniColorPickerDirection.vertical ?
                    constraints.maxWidth/widget.sizeDivider : constraints.maxWidth,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    gradient: gradientContainer()
                  )
                );
              }
            ),
          )
        )
      ),
    );
  }
}



