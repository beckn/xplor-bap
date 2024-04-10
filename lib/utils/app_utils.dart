import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:xplor/utils/app_colors.dart';
import 'package:xplor/utils/extensions/font_style/font_styles.dart';

import '../config/services/app_services.dart';
import 'app_dimensions.dart';

class AppUtils {
  static get closeKeyword {
    FocusScope.of(AppServices.navState.currentContext!).unfocus();
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.errorColor,
      padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.mediumXL, horizontal: AppDimensions.medium),
      content: (message.contains("Exception:")
              ? message.replaceAll("Exception:", "")
              : message)
          .titleBold(size: 14.sp, color: AppColors.white),
    ));
  }

  static String getErrorMessage(String message) {
    return message.contains("Exception: ")
        ? message.replaceAll("Exception: ", "")
        : message;
  }

  static void showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: 'Alert'.titleBold(size: 16.sp),
        ),
        content: 'Are you sure want to exit from application?'
            .titleSemiBold(size: 14.sp),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child:
                'No'.titleSemiBold(size: 14.sp, color: AppColors.primaryColor),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child:
                'Yes'.titleSemiBold(size: 14.sp, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}
