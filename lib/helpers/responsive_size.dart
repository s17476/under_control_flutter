import 'package:under_control_flutter/helpers/size_config.dart';

mixin ResponsiveSize {
  double responsiveSize(
      {required double small, double? medium, double? large}) {
    if (SizeConfig.isSmallScreen) {
      return SizeConfig.blockSizeHorizontal * small;
    } else if (SizeConfig.isMediumScreen) {
      return SizeConfig.blockSizeHorizontal * (medium ?? small);
    } else {
      return SizeConfig.blockSizeHorizontal * (large ?? medium ?? small);
    }
  }

  double responsiveSizeVertical(
      {required double small, double? medium, double? large}) {
    if (SizeConfig.isSmallScreen) {
      return SizeConfig.blockSizeVertical * small;
    } else if (SizeConfig.isMediumScreen) {
      return SizeConfig.blockSizeVertical * (medium ?? small);
    } else {
      return SizeConfig.blockSizeVertical * (large ?? medium ?? small);
    }
  }

  bool isLargeScreen() {
    return SizeConfig.isLagreScreen;
  }
}
