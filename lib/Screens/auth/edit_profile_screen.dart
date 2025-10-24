// ignore_for_file: avoid_print

import 'dart:io';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final UserController _authController = Get.put(UserController());

  TextEditingController nametextEditingController = TextEditingController();
  TextEditingController genderextEditingController = TextEditingController();
  TextEditingController mobiletextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController birthtextEditingController = TextEditingController();
  TextEditingController citytextEditingController = TextEditingController();

  // late FirebaseMessaging messaging;

  // DateTime? _selectedDate;
  String? genderDropdownvalue;
  // StatesData? stateDropdownvalue;
  List<String> genderItems = ['Male', 'Female'];
  @override
  void initState() {
    // messaging = FirebaseMessaging.instance;
    setdata();
    super.initState();
  }

  setdata() async {
    setState(() {
      nametextEditingController.text =
          _authController.getprofile!.data!.name ?? "NA";
      genderextEditingController.text =
          _authController.getprofile!.data!.gender ?? "NA";
      mobiletextEditingController.text =
          _authController.getprofile!.data!.mobile ?? "NA";
      emailtextEditingController.text =
          _authController.getprofile!.data!.email ?? "NA";
    });
  }

  @override
  void dispose() {
    _authController.isVerifyOtpLoding(false);

    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool isEdited = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // headerWidget(context),
              const SizedBox(height: 48),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: white),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),

              Obx(() {
                if (_authController.isGetProfileModelLoding.value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          text(
                            _authController.getprofile!.data!.name ?? "",
                            fontSize: 28.0,
                            fontWeight: FontWeight.w500,
                            textColor: white,
                          ),
                          text(
                            _authController.getprofile!.data!.mobile ?? "",
                            fontSize: 20.0,
                            textColor: white,
                            fontWeight: FontWeight.w500,
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     if (isEdited) {
                          //       setState(() {
                          //         isEdited = false;
                          //       });
                          //     } else {
                          //       setState(() {
                          //         isEdited = true;
                          //       });
                          //     }
                          //   },
                          //   child: Container(
                          //     margin: const EdgeInsets.symmetric(
                          //         vertical: 8, horizontal: 8),
                          //     decoration: BoxDecoration(
                          //         border: Border.all(
                          //           color:
                          //               isEdited ? black : textLightColorSecondary,
                          //         ),
                          //         borderRadius:
                          //             const BorderRadius.all(Radius.circular(48))),
                          //     child: Padding(
                          //       padding:
                          //           const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          //       child: text('Edit Profile',
                          //           fontSize: 15.0,
                          //           textColor:
                          //               isEdited ? black : textLightColorSecondary),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    enabled: isEdited,
                                    controller: nametextEditingController,
                                    style: const TextStyle(
                                      fontFamily: productSans,
                                      color: white,
                                    ),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                        16,
                                        15,
                                        4,
                                        8,
                                      ),
                                      labelStyle: TextStyle(
                                        color: white,
                                        fontFamily: productSans,
                                      ),
                                      hintStyle: TextStyle(
                                        color: textColorSecondary,
                                        fontFamily: productSans,
                                      ),
                                      labelText: "Full Name",
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 60,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: !isEdited
                                        ? TextFormField(
                                            enabled: false,
                                            controller:
                                                genderextEditingController,
                                            style: const TextStyle(
                                              fontFamily: productSans,
                                              color: white,
                                            ),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                    16,
                                                    15,
                                                    4,
                                                    8,
                                                  ),
                                              labelStyle: TextStyle(
                                                color: white,
                                                fontFamily: productSans,
                                              ),
                                              hintStyle: TextStyle(
                                                color: textColorSecondary,
                                                fontFamily: productSans,
                                              ),
                                              labelText: "Gender",
                                              border: UnderlineInputBorder(),
                                            ),
                                          )
                                        : DropdownButtonFormField(
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                    16,
                                                    15,
                                                    4,
                                                    8,
                                                  ),
                                              labelStyle: TextStyle(
                                                color: white,
                                                fontFamily: productSans,
                                              ),
                                              hintStyle: TextStyle(
                                                color: textColorSecondary,
                                                fontFamily: productSans,
                                              ),
                                              labelText: "Gender",
                                              border: UnderlineInputBorder(),
                                            ),
                                            value: genderDropdownvalue,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: white,
                                            ),
                                            dropdownColor: const Color(
                                              0xFF221d25,
                                            ), // Yaha background color set karo
                                            items: genderItems.map((
                                              String items,
                                            ) {
                                              return DropdownMenuItem(
                                                value: items,
                                                child: Text(
                                                  items,
                                                  style: const TextStyle(
                                                    fontFamily: productSans,
                                                    color: white,
                                                  ),
                                                ),
                                              );
                                            }).toList(),

                                            onChanged: (String? newValue) {
                                              setState(() {
                                                genderDropdownvalue = newValue!;
                                              });
                                            },
                                          ),
                                  ),
                                  const SizedBox(height: 10),

                                  TextFormField(
                                    controller: citytextEditingController,
                                    style: const TextStyle(
                                      fontFamily: productSans,
                                      color: white,
                                    ),
                                    enabled: isEdited,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                        16,
                                        15,
                                        4,
                                        8,
                                      ),
                                      labelStyle: TextStyle(
                                        color: white,
                                        fontFamily: productSans,
                                      ),
                                      hintStyle: TextStyle(
                                        color: textColorSecondary,
                                        fontFamily: productSans,
                                      ),
                                      labelText: "City",
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // !isEdited
                                  //     ?
                                  // TextFormField(
                                  //   controller: statetextEditingController,
                                  //   style: const TextStyle(fontFamily: productSans),
                                  //   enabled: isEdited,
                                  //   decoration: const InputDecoration(
                                  //     contentPadding:
                                  //         EdgeInsets.fromLTRB(16, 15, 4, 8),
                                  //     labelStyle: TextStyle(
                                  //         color: black, fontFamily: productSans),
                                  //     hintStyle: TextStyle(
                                  //         color: textColorSecondary,
                                  //         fontFamily: productSans),
                                  //     labelText: "State",
                                  //   ),
                                  // ),

                                  // : DropdownButtonFormField(
                                  //     validator: (value) {
                                  //       if (value == null) {
                                  //         return 'Please select your state';
                                  //       }
                                  //       return null;
                                  //     },
                                  //     decoration: InputDecoration(
                                  //       enabled: !isEdited,
                                  //       contentPadding:
                                  //           const EdgeInsets.fromLTRB(
                                  //               16, 15, 4, 8),
                                  //       labelStyle: const TextStyle(
                                  //           color: colorPrimary,
                                  //           fontFamily: productSans),
                                  //       hintStyle: const TextStyle(
                                  //           color: textColorSecondary,
                                  //           fontFamily: productSans),
                                  //       labelText: "State",
                                  //     ),
                                  //     // style: const TextStyle(
                                  //     //     color: textColorSecondary,
                                  //     //     fontSize: textSizeMedium,
                                  //     //     fontFamily: productSans),
                                  //     // value: stateDropdownvalue,
                                  //     icon:
                                  //         const Icon(Icons.keyboard_arrow_down),
                                  //     items: _authController.mStatesModel!.data
                                  //         .map((StatesData items) {
                                  //       return DropdownMenuItem(
                                  //         value: items,
                                  //         child: Text(items.name),
                                  //       );
                                  //     }).toList(),
                                  //     onChanged: (StatesData? newValue) {
                                  //       setState(() {
                                  //         stateDropdownvalue = newValue!;
                                  //       });
                                  //     },
                                  //   ),
                                  // const SizedBox(height: 10),
                                  TextFormField(
                                    controller: mobiletextEditingController,
                                    style: const TextStyle(
                                      fontFamily: productSans,
                                      color: white,
                                    ),
                                    enabled: isEdited,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                        16,
                                        15,
                                        4,
                                        8,
                                      ),
                                      labelStyle: TextStyle(
                                        color: white,
                                        fontFamily: productSans,
                                      ),
                                      hintStyle: TextStyle(
                                        color: textColorSecondary,
                                        fontFamily: productSans,
                                      ),
                                      labelText: "Phone Number",
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: emailtextEditingController,
                                    style: const TextStyle(
                                      fontFamily: productSans,
                                      color: white,
                                    ),
                                    enabled: isEdited,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                        16,
                                        15,
                                        4,
                                        8,
                                      ),
                                      labelStyle: TextStyle(
                                        color: white,
                                        fontFamily: productSans,
                                      ),
                                      hintStyle: TextStyle(
                                        color: textColorSecondary,
                                        fontFamily: productSans,
                                      ),
                                      labelText: "Email ID",
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.center,
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  // Obx(() {
                                  //   if (_authController
                                  //       .isUserEditProfileLoading.value) {
                                  //     return Padding(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           vertical: 48),
                                  //       child: appBotton(
                                  //         txt: "Processing",
                                  //         buttonColor:
                                  //             const Color(0xFF221d25),
                                  //         height: 48,
                                  //         txtColor: white,
                                  //         width: 295,
                                  //       ),
                                  //     );
                                  //   } else {
                                  //     return isEdited
                                  //         ? appBotton(
                                  //             onPressed: () async {
                                  //               // UserData userData =
                                  //               //     await BasePrefs.readData();
                                  //               print(_selectedDate!
                                  //                   .toIso8601String());
                                  //               print(await messaging
                                  //                   .getToken());
                                  //               print(_authController
                                  //                   .signUpModel!
                                  //                   .user!
                                  //                   .gender!);
                                  //               SignUpModel signUpModel = await _authController.editUserProfile(
                                  //                   city:
                                  //                       citytextEditingController
                                  //                           .text,
                                  //                   birthday: _selectedDate!
                                  //                       .toIso8601String(),
                                  //                   gender:
                                  //                       genderDropdownvalue!,
                                  //                   email:
                                  //                       emailtextEditingController
                                  //                           .text,
                                  //                   name:
                                  //                       nametextEditingController
                                  //                           .text);
                                  //               if (signUpModel.status!) {
                                  //                 Get.back();
                                  //                 Get.snackbar("Save User",
                                  //                     signUpModel.message!,
                                  //                     backgroundColor:
                                  //                         black,
                                  //                     colorText: white);
                                  //                 // _authController.getUserData();
                                  //               } else {
                                  //                 Get.snackbar(
                                  //                     "Edit Profile",
                                  //                     signUpModel.message!,
                                  //                     backgroundColor:
                                  //                         errorBg,
                                  //                     colorText: white);
                                  //               }
                                  //             },
                                  //             txt: "Submit",
                                  //             buttonColor:
                                  //                 const Color(0xFF221d25),
                                  //             height: 48,
                                  //             txtColor: white,
                                  //             width: 295,
                                  //           )
                                  //         : const SizedBox();
                                  //   }
                                  // }),
                                  // appBotton(
                                  //   txt: "Submit",
                                  //   buttonColor: const Color(0xFF221d25),
                                  //   height: 48,
                                  //   txtColor: white,
                                  //   width: 295,
                                  // ),
                                  // const SizedBox(height: 20),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     showDeleteAccountDialog(context);
                                  //   },
                                  //   child: text(
                                  //     "Delete account",
                                  //     fontFamily: productSans,
                                  //     textColor: white,
                                  //   ),
                                  // ),
                                  //   ],
                                  // ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF221d25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: text(
            "Confirm Account Deletion",
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            fontFamily: productSans,
            textColor: white,
          ),
          content: text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            fontSize: 16.0,
            fontFamily: productSans,
            textColor: white,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: text(
                "Cancel",
                textColor: textColorSecondary,
                fontSize: 16.0,
                fontFamily: productSans,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color for delete button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // deleteAccount();
              },
              child: text(
                "Delete",
                fontSize: 16.0,
                textColor: white,
                fontFamily: productSans,
              ),
            ),
          ],
        );
      },
    );
  }

  // Future<void> deleteAccount() async {
  //   try {
  //     _authController.deleteUser().then((onValue) {
  //       if (onValue.status!) {
  //         BasePrefs.clearPrefs().then((value) {
  //           Get.offAll(() => const SpleshScreen());
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint("Error deleting account: $e");
  //   }
  // }

  SizedBox headerWidget(BuildContext context) {
    return SizedBox(
      height: 240.0,
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 160.0,
            decoration: const BoxDecoration(
              color: white,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey,
              //     offset: Offset(0.0, 1.0), //(x,y)
              //     blurRadius: 6.0,
              //   ),
              // ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 28.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: textColorPrimary),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Center(
                  child: text(
                    "",
                    textColor: white,
                    fontFamily: productSans,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () async {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                setState(() {
                  _image = image;
                });
                uplodeImage(File(_image!.path));
              },
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 6.0,
                    ),
                  ],
                  border: Border.all(color: white, width: 4),
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                ),
                child:
                    // : ClipRRect(
                    //     borderRadius: BorderRadius.circular(80),
                    //     child:
                    //  _image == null
                    //     ? _authController
                    //                 .signUpModel!.user!.profilePhotoUrl ==
                    //             null
                    //         ? Image.network(
                    //             "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png",
                    //             fit: BoxFit.cover,
                    //           )
                    //         : CachedNetworkImage(
                    //             imageUrl: _authController.signUpModel!.user!
                    //                     .profilePhotoUrl ??
                    //                 "",
                    //             placeholder: (context, url) =>
                    //                 const CircularProgressIndicator(),
                    //             fit: BoxFit.fill,
                    //             errorWidget: (context, url, error) =>
                    //                 Image.network(
                    //               "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png",
                    //               fit: BoxFit.fill,
                    //             ),
                    //           )
                    ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                // : Image.file(File(_image!.path), fit: BoxFit.cover),
                //  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isProgress = false;

  void uplodeImage(File file) {
    debugPrint("Hit upload image");
    setState(() {
      isProgress = true;
    });
    // _authController.addUserImage(file).then((value) {
    //   if (value.status == "success") {
    //     _authController.isUserdataLoding(false);
    //     _authController.getUserData();
    //     setState(() {
    //       isProgress = false;
    //     });
    //     Get.snackbar(
    //       "Image Upload",
    //       "complete",
    //       colorText: white,
    //       backgroundColor: Colors.green,
    //       icon: const Icon(Icons.close_rounded, color: Colors.white),
    //       snackPosition: SnackPosition.BOTTOM,
    //     );
    //   } else {
    //     setState(() {
    //       isProgress = false;
    //     });
    //     Get.snackbar(
    //       "Error",
    //       "check your image again",
    //       colorText: white,
    //       backgroundColor: Colors.red,
    //       icon: const Icon(Icons.close_rounded, color: Colors.white),
    //       snackPosition: SnackPosition.BOTTOM,
    //     );
    //   }
    // });
  }
}
