import 'package:flutter/material.dart';

//this class helps to adjust elements to screen size
class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? _screenWidth;
  static double? _screenHeight;
  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;

  static double get blockSizeHorizontal {
    return _screenWidth! / 100;
  }

  static double get blockSizeVertical {
    return _screenHeight! / 100;
  }

  static double get safeBlockHorizontal {
    return (_screenWidth! - _safeAreaHorizontal!) / 100;
  }

  static double get safeBlockVertical {
    return (_screenHeight! - _safeAreaVertical!) / 100;
  }

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    if (_mediaQueryData != null) {
      _screenWidth = _mediaQueryData!.size.width;
      _screenHeight = _mediaQueryData!.size.height;
      _safeAreaHorizontal =
          _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
      _safeAreaVertical =
          _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    }
  }
}
