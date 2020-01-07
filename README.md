# mini_color_picker


Compact and simple color picker.


<img src="https://raw.githubusercontent.com/gooftime/mini_color_picker/master/example/gif/ezgif.com-resize.gif" />


### Using and description of arguments

```dart
MiniColorPickerController _controller;

@override
void initState() {
  // You don't need to set anything here.
  _controller = MiniColorPickerController();
  // controller has:
  //   Stream<MiniColorPickerBrush> getBrushStream()
  //   StreamController<MiniColorPickerBrush> get brushStream
  //   bool get dragging - indicate dragging
  //   double get transparency - actual transparency value
  //   Color get color - actual color value
  // when you set transparency or color - they will be added to the stream.

  super.initState();
}
@override
dispose() {
  _controller?.dispose(); // don't forget to dispose
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container( ///
            width: 30,    //  widget will expand so you need to wrap it with restricted container/box etc.
            height: 200,  ///
            child: MiniColorPicker(
              controller: _controller, // controller, required field

              color: Colors.red, // Just color

              // This field sets the direction of the gradient and determines
              // whether width or height will be divided by sizeDivider (see below).
              widgetDirection: MiniColorPickerDirection.vertical,

              // trancparency is a rough name for this field, it's just variables wich will be calculated
              // when user drag out of the color picker. Mostly it can be used for transparency,
              // but also you can use it (for example) as brush thickness or maybe even size of some widget.
              //
              // "Trancparency" value calculates as user drag from color picker to the
              // transparencyCalcSide up to 75% of screen size.
              transparency: 1,
              minTransparency: 0, // minimum value of "transparancy" will be at nearest point to color picker widget
              maxTransparency: 1, // will reach maximum value at the farthest point

              // Just side with the largest space from this widget. For example if you
              // place it in top with horizontal direction - best desicion will be "bottom".
              transparencyCalcSide: MiniColorPickerTransparencyCalcSide.right,

              // This field is responsible for size of gradient line regarding to gesture detector
              // wich fills all available space. By default gradient is half the size of the container,
              // if you will set it to 1, gradient will have same size as container,
              // but user will need to touch exactly on gradient to start onPanUpdate, while this reduction allows
              // to touch some around and UI will still respond.
              sizeDivider: 2,
            ),
          ),
          SizedBox(width: 20,),
          StreamBuilder(
            stream: _controller.getBrushStream(),
            initialData: MiniColorPickerBrush(),
            builder: (_, AsyncSnapshot<MiniColorPickerBrush> snapshot) {
              return Container(
                height: 100,
                width: 100,
                color: snapshot.data.color.withOpacity(1-snapshot.data.transparency),
              );
            },
          ),
        ],
      ),
    ),
  );
}
```
