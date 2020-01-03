part of mini_color_picker;


enum MiniColorPickerDirection {
  horizontal,
  vertical
}

enum MiniColorPickerTransparencyCalcSide {
   top,
   bottom,
   left,
   right
}

class MiniColorPickerBrush {
  final Color color;
  final double transparency;
  MiniColorPickerBrush({this.color = Colors.black45, this.transparency = 0});
}


class MiniColorPickerController {
  double _transparency;
  Color _color;
  double minTransparency, maxTransparency;
  StreamController<MiniColorPickerBrush> _brushStream;
  bool _dragging;

  MiniColorPickerController({double transparency = 1,
        Color color = Colors.red,
        this.minTransparency = 0,
        this.maxTransparency = 1,
  }){
    this._transparency = transparency;
    this._color = color;
    this._dragging = false;
  }


  StreamController<MiniColorPickerBrush> get brushStream {
    _brushStream ??= StreamController<MiniColorPickerBrush>.broadcast();
    return _brushStream;
  }

  bool get dragging => _dragging;
  set dragging(bool value) {
    _dragging = value;
    _brushStream?.add(MiniColorPickerBrush(color: _color, transparency: _transparency));
  }

  double get transparency => _transparency;
  set transparency(double value) {
    if(value < minTransparency)
      _transparency = minTransparency;
    else if(value > maxTransparency)
      _transparency = maxTransparency;
    else
      _transparency = value;

    _brushStream?.add(MiniColorPickerBrush(color: _color, transparency: _transparency));
  }

  Color get color => _color;
  set color(Color value) {
    _color = value;
    _brushStream?.add(MiniColorPickerBrush(color: _color, transparency: _transparency));
  }


  void updateTransparency(double value) {
    _transparency += value;
  }

  Stream<MiniColorPickerBrush> getBrushStream() async* {
    _brushStream ??= StreamController<MiniColorPickerBrush>.broadcast();
    yield* _brushStream.stream;
  }

  dispose() {
    _brushStream?.close();
  }
}

