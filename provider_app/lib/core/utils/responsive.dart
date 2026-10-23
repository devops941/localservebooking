import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
  bool get isSmallPhone => sw < 360;
  double rsp(double size) => (size * sw / 390).clamp(size * 0.82, size * 1.18);
  double rpx(double size) => (size * sw / 390).clamp(size * 0.80, size * 1.20);
  EdgeInsets get screenPad => EdgeInsets.symmetric(horizontal: sw * 0.042);
}
