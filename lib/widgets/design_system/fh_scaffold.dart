import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Keyboard-safe scaffold with tap-outside dismiss and optional soft brand bg.
class FhScaffold extends StatelessWidget {
  const FhScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor = AppColors.background,
    this.softBrandBackground = false,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;
  final bool softBrandBackground;
  final bool resizeToAvoidBottomInset;

  static const Color softBrand = Color(0xFFEAF7E4);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: softBrandBackground ? softBrand : backgroundColor,
        appBar: appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          child: body,
        ),
      ),
    );
  }
}

/// Status bar tuned for light brand headers.
void fhSetLightStatusBar({Color statusBarColor = FhScaffold.softBrand}) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
}
