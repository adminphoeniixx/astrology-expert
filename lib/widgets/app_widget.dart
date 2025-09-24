// ignore_for_file: depend_on_referenced_packages
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/size_const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

Widget text(
  String text, {
  var fontSize = textSizeMedium,
  textColor = textColorPrimary,
  var fontFamily = productSans,
  var fontWeight = FontWeight.normal,
  var isCentered = false,
  var maxLine = 50,
  var lineThrough = false,
  var latterSpacing = 0.0,
  var textAllCaps = false,
  var isLongText = false,
}) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: fontSize,
      // fontStyle: FontStyle.italic,
      fontWeight: fontWeight,
      decoration: lineThrough
          ? TextDecoration.lineThrough
          : TextDecoration.none,
      height: 1.5,
      letterSpacing: latterSpacing,
    ),
  );
}

Widget circularProgress() {
  return const Center(child: CircularProgressIndicator(color: primaryColor));
}

Widget customeImageWidget({
  required String imageUrl,
  BoxFit fit = BoxFit.fill,
}) {
  return CachedNetworkImage(
    fit: BoxFit.fill,
    imageUrl: imageUrl,
    placeholder: (context, url) => const SizedBox(),
    errorWidget: (context, url, error) =>
        const Icon(Icons.error, color: primaryColor),
  );
}

Widget appBotton({
  Color? buttonColor = primaryColor,
  Color? txtColor = white,
  Color? buttonBorderColor = primaryColor,
  String txt = "Submit",
  bool addMargin = false,
  double width = double.infinity,
  double height = 58,
  VoidCallback? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      margin: addMargin
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
          : EdgeInsets.zero,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: buttonColor,
        border: Border.all(color: buttonBorderColor!),
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
      ),
      child: Center(
        child: text(
          txt,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          textColor: txtColor,
        ),
      ),
    ),
  );
}

Widget appBotton3({
  Color? buttonColor = primaryColor,
  Color? txtColor = white,
  Color? buttonBorderColor = primaryColor,
  String txt = "Submit",
  bool addMargin = false,
  double width = double.infinity,
  double height = 58,
  VoidCallback? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      margin: addMargin
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
          : EdgeInsets.zero,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: buttonColor,
        border: Border.all(color: buttonBorderColor!),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Center(
        child: text(
          txt,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          textColor: txtColor,
        ),
      ),
    ),
  );
}

Widget appBottonTwo({
  Color? buttonColor = primaryColor,
  Color? txtColor = white,
  String txt = "Submit",
  bool addMargin = false,
  double width = double.infinity,
  double height = 58,
  VoidCallback? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      margin: addMargin
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
          : EdgeInsets.zero,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            text(
              txt,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              textColor: txtColor,
            ),
            Icon(Icons.arrow_forward_ios_outlined, color: txtColor, size: 15),
          ],
        ),
      ),
    ),
  );
}

Widget appStartBotton({
  Color? buttonColor = primaryColor,
  Color? txtColor = white,
  String txt = "Submit",
  bool addMargin = false,
  VoidCallback? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: addMargin
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
          : EdgeInsets.zero,
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: const BorderRadius.all(Radius.circular(34.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          text(
            txt,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            textColor: txtColor,
          ),
          // SvgPicture.asset(startButtonIcon)
        ],
      ),
    ),
  );
}

class CustomTextFormField extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic text;
  final dynamic maxLine;
  final dynamic fontWeight;
  final dynamic borderRadius;
  final Widget? icon;
  final bool? readOnly;
  final TextEditingController? mController;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  const CustomTextFormField({
    super.key,
    var this.fontSize = textSizeMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.text = "",
    var this.readOnly = false,
    var this.mController,
    var this.onTap,
    var this.fontWeight = FontWeight.normal,
    var this.maxLine = 1,
    var this.borderRadius = 30.0,
    var this.onChanged,
    this.icon,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      readOnly: widget.readOnly!,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${widget.text}';
        }
        return null;
      },
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        errorBorder: borderWidget(),
        prefixIcon: widget.icon,
        prefixIconConstraints: const BoxConstraints(maxWidth: 60),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        // labelText: widget.text,
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      maxLines: widget.maxLine,
      // maxLength: widget.maxLine,
      style: TextStyle(
        color: textColorSecondary,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(color: white, width: 1.5),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class SearchCustomTextFormField extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic text;
  final dynamic maxLine;
  final dynamic fontWeight;
  final Widget? icon;
  final TextEditingController? mController;
  const SearchCustomTextFormField({
    super.key,
    var this.fontSize = textSizeMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.text = "",
    var this.mController,
    var this.fontWeight = FontWeight.normal,
    var this.maxLine = 1,
    this.icon,
  });

  @override
  State<SearchCustomTextFormField> createState() =>
      _SearchCustomTextFormFieldState();
}

class _SearchCustomTextFormFieldState extends State<SearchCustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${widget.text}';
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        errorBorder: borderWidget(),
        prefixIcon: widget.icon,
        prefixIconConstraints: const BoxConstraints(maxWidth: 60),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        // labelText: widget.text,
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      maxLines: widget.maxLine,
      // maxLength: widget.maxLine,
      style: TextStyle(
        color: textColorSecondary,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: boxBorderColor, width: 1),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class CustomNumberTextFormField extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic fontWeight;
  final dynamic borderRadius;

  final ValueChanged<PhoneNumber>? onChanged;
  final dynamic text;
  final dynamic maxLine;
  final Widget? icon;
  final TextEditingController? mController;
  const CustomNumberTextFormField({
    super.key,
    var this.fontSize = textSizeMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.fontWeight = FontWeight.normal,
    var this.text = "",
    var this.mController,
    var this.maxLine = 1,
    var this.borderRadius = 30.0,
    var this.onChanged,
    this.icon,
  });

  @override
  State<CustomNumberTextFormField> createState() =>
      _CustomNumberTextFormFieldState();
}

class _CustomNumberTextFormFieldState extends State<CustomNumberTextFormField> {
  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      showCountryFlag: false,
      onChanged: widget.onChanged,
      disableLengthCheck: true,
      pickerDialogStyle: PickerDialogStyle(
        searchFieldCursorColor: textLightColorPrimary,
        searchFieldInputDecoration: InputDecoration(
          fillColor: textLightColorPrimary,
          filled: true,
          errorBorder: searchborderWidget(),
          suffixIcon: const Icon(Icons.search, color: white),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
          hintText: "Search country",
          hintStyle: TextStyle(
            color: textColorSecondary,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            fontFamily: productSans,
          ),
          // labelText: widget.text,
          enabledBorder: searchborderWidget(),
          focusedErrorBorder: searchborderWidget(),
          focusedBorder: searchborderWidget(),
        ),
        backgroundColor: black,
        countryCodeStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        countryNameStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
      ),
      dropdownTextStyle: TextStyle(
        color: textColorSecondary,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
      controller: widget.mController,
      keyboardType: TextInputType.number,
      validator: (value) {
        // String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
        // RegExp regExp = RegExp(pattern);
        if (value!.number.isEmpty) {
          return 'Please enter valid ${widget.text}';
        }
        return null;
      },
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        errorBorder: borderWidget(),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      initialCountryCode: 'IN',
      style: TextStyle(
        color: textColorSecondary,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(color: white, width: 1.5),
    );
  }

  OutlineInputBorder searchborderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(color: textColorSecondary, width: 1.5),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class CustomTextFormField2 extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic text;
  final dynamic maxLine;
  final dynamic fontWeight;
  final dynamic borderRadius;
  final Widget? icon;
  final bool? readOnly;
  final TextEditingController? mController;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  const CustomTextFormField2({
    super.key,
    var this.fontSize = textSizeMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.text = "",
    var this.readOnly = false,
    var this.mController,
    var this.onTap,
    var this.fontWeight = FontWeight.normal,
    var this.maxLine = 1,
    var this.borderRadius = 30.0,
    var this.onChanged,
    this.icon,
  });

  @override
  State<CustomTextFormField2> createState() => _CustomTextFormField2State();
}

class _CustomTextFormField2State extends State<CustomTextFormField2> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      readOnly: widget.readOnly!,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${widget.text}';
        }
        return null;
      },
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        errorBorder: borderWidget(),
        prefixIcon: widget.icon,
        prefixIconConstraints: const BoxConstraints(maxWidth: 60),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        // labelText: widget.text,
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      maxLines: widget.maxLine,
      // maxLength: widget.maxLine,
      style: TextStyle(
        color: white,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(color: textColorSecondary, width: 1.5),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class CustomNumberTextFormField2 extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic fontWeight;
  final dynamic borderRadius;

  final ValueChanged<PhoneNumber>? onChanged;
  final dynamic text;
  final dynamic maxLine;
  final Widget? icon;
  final TextEditingController? mController;
  const CustomNumberTextFormField2({
    super.key,
    var this.fontSize = textSizeMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.fontWeight = FontWeight.normal,
    var this.text = "",
    var this.mController,
    var this.maxLine = 1,
    var this.borderRadius = 30.0,
    var this.onChanged,
    this.icon,
  });

  @override
  State<CustomNumberTextFormField2> createState() =>
      _CustomNumberTextFormField2State();
}

class _CustomNumberTextFormField2State
    extends State<CustomNumberTextFormField2> {
  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      showCountryFlag: false,
      onChanged: widget.onChanged,
      disableLengthCheck: true,
      pickerDialogStyle: PickerDialogStyle(
        searchFieldCursorColor: textLightColorPrimary,
        searchFieldInputDecoration: InputDecoration(
          fillColor: textLightColorPrimary,
          filled: true,
          errorBorder: searchborderWidget(),
          suffixIcon: const Icon(Icons.search, color: white),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
          hintText: "Search country",
          hintStyle: TextStyle(
            color: textColorSecondary,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            fontFamily: productSans,
          ),
          // labelText: widget.text,
          enabledBorder: searchborderWidget(),
          focusedErrorBorder: searchborderWidget(),
          focusedBorder: searchborderWidget(),
        ),
        backgroundColor: Colors.transparent,
        countryCodeStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        countryNameStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
      ),
      dropdownTextStyle: TextStyle(
        color: textColorSecondary,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
      controller: widget.mController,
      keyboardType: TextInputType.number,
      validator: (value) {
        // String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
        // RegExp regExp = RegExp(pattern);
        if (value!.number.isEmpty) {
          return 'Please enter valid ${widget.text}';
        }
        return null;
      },
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        errorBorder: borderWidget(),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      initialCountryCode: 'IN',
      style: TextStyle(
        color: white,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(color: textColorSecondary, width: 1.5),
    );
  }

  OutlineInputBorder searchborderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(color: textColorSecondary, width: 1.5),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class CustomOTPTextFormField extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic fontWeight;
  final dynamic text;
  final dynamic timerText;
  final dynamic maxLine;
  final Icon? icon;
  final TextEditingController? mController;
  const CustomOTPTextFormField({
    super.key,
    var this.fontSize = textSizeSMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.fontWeight = FontWeight.normal,
    var this.text = "",
    var this.timerText = "",
    var this.mController,
    var this.maxLine = 1,
    this.icon,
  });

  @override
  State<CustomOTPTextFormField> createState() => _CustomOTPTextFormFieldState();
}

class _CustomOTPTextFormFieldState extends State<CustomOTPTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: [LengthLimitingTextInputFormatter(4)],
      controller: widget.mController,
      keyboardType: TextInputType.number,
      validator: (value) {
        String pattern = r'(^(?:[+0]9)?[0-9]{4}$)';
        RegExp regExp = RegExp(pattern);
        if (value!.isEmpty || regExp.hasMatch('+91$value')) {
          return 'Please enter ${widget.text}';
        }
        return null;
      },
      // autofocus: false,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        errorBorder: borderWidget(),
        prefixIcon: widget.icon,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: text(
            widget.timerText,
            textColor: primaryColor,
            fontSize: widget.fontSize,
            fontFamily: productSans,
            fontWeight: widget.fontWeight,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        // labelText: widget.text,
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      maxLines: widget.maxLine,
      // maxLength: widget.maxLine,
      style: TextStyle(
        color: textColorSecondary,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: boxBorderColor, width: 1),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

// class TopBannerWidget extends StatefulWidget {
//   const TopBannerWidget({super.key});

//   @override
//   State<TopBannerWidget> createState() => _TopBannerWidgetState();
// }

// class _TopBannerWidgetState extends State<TopBannerWidget> {
//   int _currentPage = 0;
//   Timer? _timer;
//   final PageController _pageController = PageController(initialPage: 0);
//   final HomeController _homeController = Get.put(HomeController());

//   bool end = false;

//   @override
//   void initState() {
//     if (_homeController.mAllBannerModel!.data!
//             .where((item) => item.type == "Home Top")
//             .toList()
//             .length >
//         1) {
//       _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//         if (_currentPage ==
//             _homeController.mAllBannerModel!.data!
//                     .where((item) => item.type == "Home Top")
//                     .toList()
//                     .length -
//                 1) {
//           setState(() {
//             end = true;
//           });
//         } else if (_currentPage == 0) {
//           setState(() {
//             end = false;
//           });
//         }
//         if (end == false) {
//           setState(() {
//             _currentPage++;
//           });
//         } else {
//           setState(() {
//             _currentPage--;
//           });
//         }
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//         setState(() {});
//       });
//     }
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timer?.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: Column(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height / 8.3,
//             child: PageView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _homeController.mAllBannerModel!.data!
//                   .where((item) => item.type == "Home Top")
//                   .toList()
//                   .length, // Get the length of the filtered list
//               controller: _pageController,
//               itemBuilder: (BuildContext context, int itemIndex) {
//                 var filteredData = _homeController.mAllBannerModel!.data!
//                     .where((item) => item.type == "Home Top")
//                     .toList();

//                 // Access the filtered item
//                 var bannerData = filteredData[itemIndex];

//                 return GestureDetector(
//                   onTap: () {
//                     if (bannerData.navigationType == null) {
//                     } else if (bannerData.navigationType == "product") {
//                       _homeController
//                           .getProductDetailsData(
//                               id: int.parse(
//                                   bannerData.navigationTypeId.toString()))
//                           .then(
//                         (value) {
//                           print(
//                               "!!!!!!!!!!!!!!!!!!!!!!getProductDetailsData!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//                           if (value.data != null) {
//                             Get.to(
//                                 ProductDetailsScreen(productData: value.data!));
//                           } else {
//                             Get.snackbar(value.status, value.message);
//                           }
//                         },
//                       );
//                     } else if (bannerData.navigationType ==
//                         "product_category") {
//                       Get.to(CategoryProductsScreen(
//                           id: int.parse(
//                               bannerData.navigationTypeId.toString())));
//                     } else if (bannerData.navigationType ==
//                         "consultation_page") {
//                       Get.to(Get.offAll(const MyHomePage(
//                         tabItem: TabItem.consultTab,
//                       )));
//                     }
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 2),
//                     width: MediaQuery.of(context).size.width,
//                     decoration: const BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.all(Radius.circular(10.0))),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10.0),
//                       child: CachedNetworkImage(
//                         fit: BoxFit.fill,
//                         imageUrl: bannerData.image ??
//                             "", // Use the image URL for "Mantra"
//                         placeholder: (context, url) => const SizedBox(),
//                         errorWidget: (context, url, error) => const Icon(
//                           Icons.error,
//                           color: white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           _homeController.mAllBannerModel!.data!
//                       .where((item) => item.type == "Home Top")
//                       .toList()
//                       .length <=
//                   1
//               ? const SizedBox()
//               : DotsIndicator(
//                   decorator: DotsDecorator(
//                       activeColor: white,
//                       size: const Size.square(9.0),
//                       activeSize: const Size(18.0, 9.0),
//                       activeShape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5.0))),
//                   dotsCount: _homeController.mAllBannerModel!.data!
//                       .where((item) => item.type == "Home Top")
//                       .toList()
//                       .length,
//                   position: _currentPage,
//                 ),
//         ],
//       ),
//     );
//   }
// }

// class MiddleBannerWidget extends StatefulWidget {
//   final AllBannerModel? allBannerModel;
//   const MiddleBannerWidget({super.key, required this.allBannerModel});

//   @override
//   State<MiddleBannerWidget> createState() => _MiddleBannerWidgetState();
// }

// class _MiddleBannerWidgetState extends State<MiddleBannerWidget> {
//   int _currentPage = 0;
//   Timer? _timer;
//   final PageController _pageController = PageController(initialPage: 0);
//   bool end = false;

//   @override
//   void initState() {
//     if (widget.allBannerModel!.data!
//             .where((item) => item.type == "Home Middle")
//             .toList()
//             .length >
//         1) {
//       _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//         if (_currentPage ==
//             widget.allBannerModel!.data!
//                     .where((item) => item.type == "Home Middle")
//                     .toList()
//                     .length -
//                 1) {
//           setState(() {
//             end = true;
//           });
//         } else if (_currentPage == 0) {
//           setState(() {
//             end = false;
//           });
//         }
//         if (end == false) {
//           setState(() {
//             _currentPage++;
//           });
//         } else {
//           setState(() {
//             _currentPage--;
//           });
//         }
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//         setState(() {});
//       });
//     }
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timer?.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: Column(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height / 8.3,
//             child: PageView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: widget.allBannerModel!.data!
//                   .where((item) => item.type == "Home Middle")
//                   .toList()
//                   .length, // Get the length of the filtered list
//               controller: _pageController,
//               itemBuilder: (BuildContext context, int itemIndex) {
//                 var filteredData = widget.allBannerModel!.data!
//                     .where((item) => item.type == "Home Middle")
//                     .toList();

//                 // Access the filtered item
//                 var bannerData = filteredData[itemIndex];

//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 2),
//                   width: MediaQuery.of(context).size.width,
//                   decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.all(Radius.circular(10.0))),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: CachedNetworkImage(
//                       fit: BoxFit.fill,
//                       imageUrl: bannerData.image ??
//                           "", // Use the image URL for "Mantra"
//                       placeholder: (context, url) => const SizedBox(),
//                       errorWidget: (context, url, error) => const Icon(
//                         Icons.error,
//                         color: black,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MiddleBannerWidget extends StatefulWidget {
//   final String type;
//   final AllBannerModel allBannerModel;

//   const MiddleBannerWidget(
//       {super.key, required this.allBannerModel, required this.type});

//   @override
//   State<MiddleBannerWidget> createState() => _MiddleBannerWidgetState();
// }

// class _MiddleBannerWidgetState extends State<MiddleBannerWidget> {
//   // ignore: unused_field
//   int _currentIndex = 0;
//   final CarouselSliderController _carouselController =
//       CarouselSliderController();
//   final HomeController _homeController = Get.put(HomeController());

//   @override
//   Widget build(BuildContext context) {
//     var filteredBanners = widget.allBannerModel.data
//             ?.where((item) => item.type == widget.type)
//             .toList() ??
//         [];

//     if (filteredBanners.isEmpty) {
//       return const SizedBox(); // Return empty if no banners
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: Column(
//         children: [
//           CarouselSlider.builder(
//             carouselController: _carouselController,
//             itemCount: filteredBanners.length,
//             options: CarouselOptions(
//               height: MediaQuery.of(context).size.height / 8.3,
//               autoPlay: true, // ✅ Auto-play enabled (removes Timer.periodic)
//               autoPlayInterval: const Duration(seconds: 5), // ✅ Adjust delay
//               autoPlayCurve: Curves.easeInOut,
//               viewportFraction: 1.0,
//               enlargeCenterPage: true,
//               onPageChanged: (index, reason) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//             ),
//             itemBuilder: (context, index, realIndex) {
//               var bannerData = filteredBanners[index];

//               return GestureDetector(
//                   onTap: () {
//                     if (bannerData.navigationType == null) {
//                       return;
//                     } else if (bannerData.navigationType == "product") {
//                       print(
//                           "!!!!!!!!!!!!!!!!!!!!!!!!product id!!!!!!!!!!!!!!!!!!!!!!!!!");
//                       print(bannerData.navigationTypeId.toString());
//                       _homeController
//                           .getProductDetailsData(
//                               id: int.parse(
//                                   bannerData.navigationTypeId.toString()))
//                           .then(
//                         (value) {
//                           print(
//                               "!!!!!!!!!!!!!!!!!!!!!!!!product id!!!!!!!!!!!!!!!!!!!!!!!!!");

//                           // Get.to(ProductDetailsScreen(productData: value!));
//                           changeScreen(
//                             context,
//                             ProductDetailsScreen(productData: value.data!),
//                           );
//                         },
//                       );
//                     } else if (bannerData.navigationType ==
//                         "product_category") {
//                       Get.to(CategoryProductsScreen(
//                           id: int.parse(
//                               bannerData.navigationTypeId.toString())));
//                     } else if (bannerData.navigationType ==
//                         "consultation_page") {
//                       Get.to(Get.offAll(const MyHomePage(
//                         tabItem: TabItem.consultTab,
//                       )));
//                     }
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                         horizontal: 0), // No margin for full width
//                     width: double
//                         .infinity, // Use double.infinity instead of MediaQuery
//                     decoration: BoxDecoration(
//                       color: Colors.transparent,
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(10.0)),
//                       // Optional: Add subtle shadow
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10.0),
//                       child: CachedNetworkImage(
//                         fit: BoxFit
//                             .cover, // Changed from fill to cover for better aspect ratio
//                         imageUrl: bannerData.image ?? "",
//                         placeholder: (context, url) => Container(
//                           height: double.infinity,
//                           width: double.infinity,
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           height: double.infinity,
//                           width: double.infinity,
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: Icon(
//                               Icons.broken_image,
//                               color: Colors.white,
//                               size: 40,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ));
//             },
//           ),
// // Pagination Indicator
// Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: filteredBanners.asMap().entries.map((entry) {
//     return GestureDetector(
//       onTap: () => _carouselController.animateToPage(entry.key),
//       child: Container(
//         width: _currentIndex == entry.key ? 12.0 : 8.0,
//         height: _currentIndex == entry.key ? 12.0 : 8.0,
//         margin:
//             const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: _currentIndex == entry.key ? black : Colors.grey,
//         ),
//       ),
//     );
//   }).toList(),
// ),
//         ],
//       ),
//     );
//   }
// }

// class BottomBannerWidget extends StatefulWidget {
//   const BottomBannerWidget({super.key});

//   @override
//   State<BottomBannerWidget> createState() => _BottomBannerWidgetState();
// }

// class _BottomBannerWidgetState extends State<BottomBannerWidget> {
//   int _currentPage = 0;
//   Timer? _timer;
//   final PageController _pageController = PageController(initialPage: 0);
//   final HomeController _homeController = Get.put(HomeController());

//   bool end = false;

//   @override
//   void initState() {
//     if (_homeController.mAllBannerModel!.data!
//             .where((item) => item.type == "Home Bottom")
//             .toList()
//             .length >
//         1) {
//       _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//         if (_currentPage ==
//             _homeController.mAllBannerModel!.data!
//                     .where((item) => item.type == "Home Bottom")
//                     .toList()
//                     .length -
//                 1) {
//           setState(() {
//             end = true;
//           });
//         } else if (_currentPage == 0) {
//           setState(() {
//             end = false;
//           });
//         }
//         if (end == false) {
//           setState(() {
//             _currentPage++;
//           });
//         } else {
//           setState(() {
//             _currentPage--;
//           });
//         }
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//         setState(() {});
//       });
//     }
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timer?.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: Column(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height / 8.3,
//             child: PageView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _homeController.mAllBannerModel!.data!
//                   .where((item) => item.type == "Home Bottom")
//                   .toList()
//                   .length, // Get the length of the filtered list
//               controller: _pageController,
//               itemBuilder: (BuildContext context, int itemIndex) {
//                 var filteredData = _homeController.mAllBannerModel!.data!
//                     .where((item) => item.type == "Home Bottom")
//                     .toList();
//                 // Access the filtered item
//                 var bannerData = filteredData[itemIndex];
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 2),
//                   width: MediaQuery.of(context).size.width,
//                   decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.all(Radius.circular(10.0))),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: CachedNetworkImage(
//                       fit: BoxFit.fill,
//                       imageUrl: bannerData.image ??
//                           "", // Use the image URL for "Mantra"
//                       placeholder: (context, url) => const SizedBox(),
//                       errorWidget: (context, url, error) => const Icon(
//                         Icons.error,
//                         color: black,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://error404.fun/img/illustrations/09.png'),
            Text(
              kDebugMode
                  ? errorDetails.summary.toString()
                  : 'Oups! Something went wrong!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kDebugMode ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              kDebugMode
                  ? 'https://docs.flutter.dev/testing/errors'
                  : "We encountered an error and we've notified our engineering team about it. Sorry for the inconvenience caused.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSimpleTextFormField extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic text;
  final dynamic maxLine;
  final bool isRequired;
  final TextEditingController? mController;
  const CustomSimpleTextFormField({
    super.key,
    var this.fontSize = textSizeMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.text = "",
    var this.mController,
    var this.maxLine = 1,
    this.isRequired = true,
  });

  @override
  State<CustomSimpleTextFormField> createState() =>
      _CustomSimpleTextFormFieldState();
}

class _CustomSimpleTextFormFieldState extends State<CustomSimpleTextFormField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 62.0,
      // decoration: BoxDecoration(
      //     color: colorPrimaryLight,
      //     borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      //     border: Border.all(color: colorPrimaryLight)),
      child: TextFormField(
        controller: widget.mController,
        validator: (value) {
          if (value!.isEmpty && widget.isRequired) {
            return 'Please enter ${widget.text}';
          }
          return null;
        },
        decoration: InputDecoration(
          fillColor: white,
          filled: true,
          errorBorder: borderWidget(),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
          hintText: widget.text,
          hintStyle: TextStyle(
            color: textColorSecondary,
            fontSize: widget.fontSize,
            fontFamily: productSans,
          ),
          // labelText: widget.text,
          enabledBorder: borderWidget(),
          focusedErrorBorder: borderWidget(),
          focusedBorder: borderWidget(),
        ),
        maxLines: widget.maxLine,
        // maxLength: widget.maxLine,
        style: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontFamily: productSans,
        ),
      ),
    );
  }

  UnderlineInputBorder borderWidget() {
    return UnderlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class HtmlViewWidget extends StatelessWidget {
  final String data;
  const HtmlViewWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 100,
      child: text(
        data,
        // customImageRenders: {
        //   networkSourceMatcher(domains: ["flutter.dev"]):
        //       (context, attributes, element) {
        //     return const FlutterLogo(size: 36);
        //   },
        //   networkSourceMatcher(): networkImageRender(
        //     headers: {"Custom-Header": "some-value"},
        //     altWidget: (alt) => Text(alt ?? ""),
        //     loadingWidget: () => const SizedBox(),
        //   ),
        //   (attr, _) => attr["src"] != null && attr["src"]!.startsWith("/wiki"):
        //       networkImageRender(
        //           // ignore: prefer_interpolation_to_compose_strings
        //           mapUrl: (url) => "https://upload.wikimedia.org" + url!),
        // },
      ),
    );
  }
}

Widget topicHeader({String? title, double height = 1.0, double width = 100.0}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(height: height, width: width, color: black),
      const SizedBox(width: 8.0),
      text(
        title ?? "",
        fontSize: 18.0,
        fontFamily: productSans,
        fontWeight: FontWeight.w500,
      ),
      const SizedBox(width: 8.0),
      Container(height: height, width: width, color: black),
    ],
  );
}

Widget bottomSheetBackButton() {
  return GestureDetector(
    onTap: () {
      Get.back();
    },
    child: Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.close, color: white),
        ),
      ),
    ),
  );
}

String greeting() {
  if (DateTime.now().hour < 12) {
    return 'Good Morning';
  } else if (DateTime.now().hour < 18) {
    return 'Good Afternoon';
  } else {
    return 'Good Night';
  }
}

class CustomInerTextFormField extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic text;
  final dynamic maxLine;
  final dynamic fontWeight;
  final Widget? icon;
  final bool? readOnly;
  final TextEditingController? mController;
  final VoidCallback? onTap;
  const CustomInerTextFormField({
    super.key,
    var this.fontSize = textSizeSMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.text = "",
    var this.readOnly = false,
    var this.mController,
    var this.onTap,
    var this.fontWeight = FontWeight.normal,
    var this.maxLine = 1,
    this.icon,
  });

  @override
  State<CustomInerTextFormField> createState() =>
      _CustomInerTextFormFieldState();
}

class _CustomInerTextFormFieldState extends State<CustomInerTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      readOnly: widget.readOnly!,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${widget.text}';
        }
        return null;
      },
      onTap: widget.onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        errorBorder: borderWidget(),
        prefixIcon: widget.icon,
        prefixIconConstraints: const BoxConstraints(maxWidth: 60),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        // labelText: widget.text,
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      maxLines: widget.maxLine,
      // maxLength: widget.maxLine,
      style: TextStyle(
        color: white,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: textLightColorThersery, width: 1),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

class CustomInerTextFormField2 extends StatefulWidget {
  final dynamic fontSize;
  final dynamic textColor;
  final dynamic fontFamily;
  final dynamic text;
  final dynamic maxLine;
  final dynamic fontWeight;
  final Widget? icon;
  final bool? readOnly;
  final TextEditingController? mController;
  final VoidCallback? onTap;
  const CustomInerTextFormField2({
    super.key,
    var this.fontSize = textSizeSMedium,
    var this.textColor = textColorSecondary,
    var this.fontFamily = productSans,
    var this.text = "",
    var this.readOnly = false,
    var this.mController,
    var this.onTap,
    var this.fontWeight = FontWeight.normal,
    var this.maxLine = 1,
    this.icon,
  });
  @override
  State<CustomInerTextFormField2> createState() =>
      _CustomInerTextFormField2State();
}

class _CustomInerTextFormField2State extends State<CustomInerTextFormField2> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      readOnly: widget.readOnly!,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${widget.text}';
        }
        return null;
      },
      onTap: widget.onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        errorBorder: borderWidget(),

        suffixIcon: widget.icon,
        suffixIconConstraints: const BoxConstraints(maxWidth: 30),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 4, 8),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColorSecondary,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: productSans,
        ),
        // labelText: widget.text,
        enabledBorder: borderWidget(),
        focusedErrorBorder: borderWidget(),
        focusedBorder: borderWidget(),
      ),
      maxLines: widget.maxLine,
      // maxLength: widget.maxLine,
      style: TextStyle(
        color: white,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        fontFamily: productSans,
      ),
    );
  }

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: textLightColorThersery, width: 1),
    );
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}
