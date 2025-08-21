import 'package:cricyard/resources/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessageUtil {
  static void showToast({
    required String message,
    ToastType toastType = ToastType.info,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int durationInSeconds = 3,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: durationInSeconds,
      backgroundColor: _getBackgroundColor(toastType),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static Color? _getBackgroundColor(ToastType toastType) {
    switch (toastType) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
      case ToastType.general:
        return Colors.grey[900];
      default:
        return AppColors.info;
    }
  }
}

enum ToastType { success, error, warning, info, general }
