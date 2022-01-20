import 'dart:ui';

import 'package:flutter/material.dart';

Rect getFoucsRect(BuildContext context) {
  const lrPadding = 30.0;
  var width = MediaQuery.of(context).size.width - 2 * lrPadding;
  return Rect.fromLTWH(lrPadding, 100, width, 160);
}

bool isContained(Rect containing, Rect contained) {
  var res = containing.contains(contained.topLeft) &&
      containing.contains(contained.bottomRight);

  return res;
}
