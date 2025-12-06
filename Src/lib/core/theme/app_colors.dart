import 'package:flutter/material.dart';


class AppColors{
  // Theme-aware colors
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? dark1 
        : white;
  }
  
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? dark2 
        : greyscale100;
  }
  static Color getText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? white
        : greyscale900;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? greyscale400
        : greyscale600;
  }

  static Color getTextThird(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? greyscale300
        : greyscale600;
  }

  static Color getModalBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark2
        : white;
  }

  static Color getAutoLayoutBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark2
        : greyscale50;
  }

  static Color getLine(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark4
        : greyscale200;
  }


  static const Color primary500 = Color(0xFFF89300);
  static const Color primary400 = Color(0xFFF9A933);
  static const Color primary300 = Color(0xFFFBBE66);
  static const Color primary200 = Color(0xFFFCD499);
  static const Color primary100 = Color(0xFFFEF4E6);

  static const Color secondary500 = Color(0xFFFFC107);
  static const Color secondary400 = Color(0xFFFFCD39);
  static const Color secondary300 = Color(0xFFFFDA6A);
  static const Color secondary200 = Color(0xFFFFE69C);
  static const Color secondary100 = Color(0xFFFFF9E6);

  //Alert & Status
  static const Color success = Color(0xFF12D18E);
  static const Color info = Color(0xFFF89300);
  static const Color warning = Color(0xFFF75555);
  static const Color disabled = Color(0xFFD8D8D8);
  static const Color disableButton = Color(0xFFC67600);

  //Greysacle
  static const Color greyscale900 = Color(0xFF212121);
  static const Color greyscale800 = Color(0xFF424242);
  static const Color greyscale700 = Color(0xFF616161);
  static const Color greyscale600 = Color(0xFF757575);
  static const Color greyscale500 = Color(0xFF9E9E9E);
  static const Color greyscale400 = Color(0xFFBDBDBD);
  static const Color greyscale300 = Color(0xFFE0E0E0);
  static const Color greyscale200 = Color(0xFFEEEEEE);
  static const Color greyscale100 = Color(0xFFF5F5F5);
  static const Color greyscale50 = Color(0xFFFAFAFA);

  //DarkColors

  static const Color dark1 = Color(0xFF181A20);
  static const Color dark2 = Color(0xFF1F222A);
  static const Color dark3 = Color(0xFF1F222A);
  static const Color dark4 = Color(0xFF35383F);

  //Others
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);
  static const Color red         = Color(0xFFF44336);
  static const Color pink        = Color(0xFFE91E63);
  static const Color purple      = Color(0xFF9C27B0);
  static const Color deepPurple  = Color(0xFF673AB7);
  static const Color indigo      = Color(0xFF3F51B5);
  static const Color blue        = Color(0xFF2196F3);
  static const Color lightBlue   = Color(0xFF03A9F4);
  static const Color cyan        = Color(0xFF00BCD4);
  static const Color teal        = Color(0xFF009688);
  static const Color green       = Color(0xFF4CAF50);
  static const Color lightGreen  = Color(0xFF8BC34A);
  static const Color lime        = Color(0xFFCDDC39);
  static const Color yellow      = Color(0xFFFFEB3B);
  static const Color amber       = Color(0xFFFFC107);
  static const Color orange      = Color(0xFFFF9800);
  static const Color deepOrange  = Color(0xFFFF5722);
  static const Color brown       = Color(0xFF795548);
  static const Color blueGrey    = Color(0xFF607D8B);

  //Background
  static const Color bgOrange    = Color(0xFFFFF8EE);
  static const Color bgGreen     = Color(0xFFF1FDF5);
  static const Color bgYellow    = Color(0xFFFFFCEB);
  static const Color bgBlue      = Color(0xFFF6F9FF);
  static const Color bgPurple    = Color(0xFFF9F8FF);
  static const Color bgTeal      = Color(0xFFF2FFFD);
  static const Color bgRed       = Color(0xFFFFF7F8);

  // ==== Transparent (alpha / overlay) ====
  static const Color trOrange    = Color(0x14F89300); // có thể set alpha
  static const Color trGreen     = Color(0x1412D18E);
  static const Color trYellow    = Color(0x14FFD300);
  static const Color trBlue      = Color(0x14246BFD);
  static const Color trPurple    = Color(0x146949FF);
  static const Color trTeal      = Color(0x14019883);
  static const Color trRed       = Color(0x14FF5A5F);
  static const Color trCyan      = Color(0x1400BCD4);
}