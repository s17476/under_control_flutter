import 'package:flutter/material.dart';

//this class helps to adjust elements size to different screen sizes
class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? _screenWidth;
  static double? _screenHeight;
  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;

  static bool get isSmallScreen => _screenWidth! < 800;

  static bool get isMediumScreen =>
      _screenWidth! >= 800 && _screenWidth! < 1200;

  static bool get isLagreScreen => _screenWidth! >= 1200;

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
