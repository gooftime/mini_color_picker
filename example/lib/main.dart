import 'package:flutter/material.dart';
import 'package:mini_color_picker/mini_color_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  MiniColorPickerController _controller;
  MiniColorPickerController _controller2;
  MiniColorPickerController _controller3;

  @override
  void initState() {

    _controller = MiniColorPickerController();
    _controller2 = MiniColorPickerController();
    _controller3 = MiniColorPickerController();
    super.initState();
  }

  @override
  dispose() {
    _controller?.dispose();
    _controller2?.dispose();
    _controller3?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:

      Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Row(
                  children: <Widget>[

                    Container(
                      width: 30,
                      height: 200,
                      child: MiniColorPicker(
                        controller: _controller3,
                        minTransparency: 0,
                        maxTransparency: 1,
                        widgetDirection: MiniColorPickerDirection.vertical,
                        transparencyCalcSide: MiniColorPickerTransparencyCalcSide.right,
                      ),
                    ),
                    SizedBox(width: 20,),
                    StreamBuilder(
                      stream: _controller3.getBrushStream(),
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

                Row(
                  children: <Widget>[
                    StreamBuilder(
                      stream: _controller2.getBrushStream(),
                      initialData: MiniColorPickerBrush(),
                      builder: (_, AsyncSnapshot<MiniColorPickerBrush> asyncSnapshot) {
                        if(_controller2.dragging == false) {
                          return Container(
                            child: Icon(
                              Icons.brush,
                              size: 30,
                              color: asyncSnapshot.data.color,
                            )
                          );
                        }

                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: asyncSnapshot.data.color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: asyncSnapshot.data.transparency,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 20,),
                    Container(
                      width: 30,
                      height: 200,
                      child: MiniColorPicker(
                        controller: _controller2,
                        minTransparency: 3,
                        maxTransparency: 15,
                        widgetDirection: MiniColorPickerDirection.vertical,
                        transparencyCalcSide: MiniColorPickerTransparencyCalcSide.left,
                      ),
                    ),
                  ]
                ),

              ],
            ),

            Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _controller.getBrushStream(),
                  initialData: MiniColorPickerBrush(color: Colors.transparent, transparency: 1),
                  builder: (_, AsyncSnapshot<MiniColorPickerBrush> snapshot) {

                    return Container(
                      // height: 100,
                      // width: 100,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          snapshot.data.color.withOpacity(1-snapshot.data.transparency),
                          BlendMode.color
                        ),
                        child: Image.network('https://i.picsum.photos/id/451/200/200.jpg',),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20,),
                Container(
                  width: 200,
                  height: 30,
                  child: MiniColorPicker(
                    controller: _controller,
                    minTransparency: 0,
                    maxTransparency: 1,
                    widgetDirection: MiniColorPickerDirection.horizontal,
                    transparencyCalcSide: MiniColorPickerTransparencyCalcSide.top,
                    sizeDivider: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
