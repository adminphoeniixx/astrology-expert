// import 'dart:async';
// import 'package:astro_partner_app/controllers/home_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';

// class VideoPlayerHorizontalScreen extends StatefulWidget {
//   final int videoId;
//   final bool isLike;
//   final int likeCount;
//   final int customerId;
//   final String? videoUrl;
//   final String? thumbUrl;
//   final bool isReel;

//   const VideoPlayerHorizontalScreen({
//     super.key,
//     required this.isLike,
//     required this.likeCount,
//     required this.customerId,
//     required this.videoId,
//     required this.videoUrl,
//     required this.thumbUrl,
//     this.isReel = false,
//   });

//   @override
//   _VideoPlayerHorizontalScreenState createState() =>
//       _VideoPlayerHorizontalScreenState();
// }

// class _VideoPlayerHorizontalScreenState
//     extends State<VideoPlayerHorizontalScreen> {
//   final HomeController _homeController = Get.put(HomeController());

//   late VideoPlayerController controller;
//   late bool isLiked = widget.isLike; // State for like button
//   int likesCount = 0; // Example likes count
//   bool showControls = false; // State to manage overlay visibility
//   Timer? hideControlsTimer; // Timer to auto-hide controls
//   List<String> comments = []; // List to hold comments

//   @override
//   void initState() {
//     // _homeController.getVideoViewsData(
//     //     videoId: widget.videoId, videotype: "trending");
//     // _homeController.getCommentVideoModelData(
//     //     videoId: widget.videoId, videoType: "trending");
//     super.initState();
//     likesCount = widget.likeCount; // Initialize from widget property
//     controller = VideoPlayerController.network(widget.videoUrl!,
//         videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
//       ..addListener(() => setState(() {}))
//       ..setLooping(true)
//       ..initialize().then((_) {
//         controller.play();
//         setState(() {});
//       });

//     setPortrait(); // Lock orientation for reels
//   }

//   @override
//   void dispose() {
//     hideControlsTimer?.cancel(); // Cancel any active timers
//     setAllOrientations(); // Reset orientation to allow all modes
//     controller.dispose();
//     super.dispose();
//   }

//   Future setPortrait() async {
//     if (widget.isReel) {
//       await SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
//       );
//     }
//   }

//   Future setAllOrientations() async {
//     await SystemChrome.setPreferredOrientations(
//       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
//     );
//   }

//   void toggleLike() async {
//     // Store previous state to revert in case of failure
//     final previousLikeState = isLiked;
//     final previousLikesCount = likesCount;

//     setState(() {
//       isLiked = !isLiked; // Toggle the like state optimistically
//       likesCount += isLiked ? 1 : -1; // Adjust likes count
//     });

//     try {
//       // Call the API to like/unlike the post
//       final response = await _homeController.getPostLikeData(
//         videoId: widget.videoId,
//         customerId: widget.customerId,
//         videotype: "trending",
//       );

//       // Optionally update UI based on the response
//       if (response.status) {
//         debugPrint("Post liked/unliked successfully");
//       } else {
//         debugPrint("Failed to like/unlike the post: ${response.message}");
//         _revertLikeState(previousLikeState, previousLikesCount);
//       }
//     } catch (error) {
//       debugPrint("Error liking/unliking post: $error");
//       _revertLikeState(previousLikeState, previousLikesCount);
//     }
//   }

//   void _revertLikeState(bool previousLikeState, int previousLikesCount) {
//     // Revert to the previous state in case of error
//     setState(() {
//       isLiked = previousLikeState;
//       likesCount = previousLikesCount;
//     });
//   }

//   void togglePlayPause() {
//     if (controller.value.isPlaying) {
//       controller.pause();
//     } else {
//       controller.play();
//     }
//     setState(() {
//       showControls = true;
//     });

//     // Reset and restart the timer to hide controls after 3 seconds
//     hideControlsTimer?.cancel();
//     hideControlsTimer = Timer(const Duration(seconds: 3), () {
//       setState(() {
//         showControls = false;
//       });
//     });
//   }

//   // void showCommentSection() {
//   //   _homeController.getCommentVideoModelData(
//   //       videoId: widget.videoId, videoType: "trending");
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.black.withOpacity(0.8),
//   //     shape: const RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //     ),
//   //     builder: (context) => CommentSectionWidget(
//   //       customerId: widget.customerId,
//   //       videoId: widget.videoId,
//   //       // comments: comments,
//   //       // onAddComment: (newComment) {
//   //       //   setState(() {
//   //       //     comments.add(newComment);
//   //       //   });
//   //       // },
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: false,
//       appBar: AppBar(
//         toolbarHeight: 40,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//             onPressed: () async {
//               print("tap");

//               Navigator.pop(context);
//               await SystemChrome.setPreferredOrientations(
//                 [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
//               );
//             },
//             icon: const Icon(Icons.arrow_back, color: Colors.white)),
//       ),
//       body: Stack(
//         children: [
//           GestureDetector(
//             onTap: togglePlayPause,
//             child: controller.value.isInitialized
//                 ? Align(
//                   alignment: Alignment.topCenter,
//                     child: AspectRatio(
//                       aspectRatio: controller
//                           .value.aspectRatio, // Maintain video aspect ratio
//                       child: FittedBox(
//                         fit: BoxFit.contain, // Adjust to avoid distortion
//                         child: SizedBox(
//                           width: controller.value.size.width,
//                           height: controller.value.size.height,
//                           child: VideoPlayer(controller),
//                         ),
//                       ),
//                     ),
//                   )
//                 : const Center(child: CircularProgressIndicator()),
//           ),
//           // Play/Pause Icon Overlay
//           if (showControls)
//             Center(
//               child: Icon(
//                 controller.value.isPlaying
//                     ? Icons.pause_circle_filled
//                     : Icons.play_circle_filled,
//                 color: Colors.white,
//                 size: 80,
//               ),
//             ),
//           // Like, Comment, Share overlay
//           // Positioned(
//           //   right: 10,
//           //   bottom: 80,
//           //   child: Column(
//           //     mainAxisAlignment: MainAxisAlignment.end,
//           //     children: [
//           //       // Like Button
//           //       // GestureDetector(
//           //       //   onTap: toggleLike,
//           //       //   child: Column(
//           //       //     children: [
//           //       //       Icon(
//           //       //         isLiked
//           //       //             ? Icons.favorite
//           //       //             : Icons.favorite_outline_rounded,
//           //       //         color: isLiked ? Colors.red : Colors.white,
//           //       //         size: 35,
//           //       //       ),
//           //       //       const SizedBox(height: 5),
//           //       //       int.parse(likesCount.toString()) == 0
//           //       //           ? const SizedBox()
//           //       //           : Text(
//           //       //               likesCount.toString(),
//           //       //               style: const TextStyle(color: Colors.white),
//           //       //             ),
//           //       //     ],
//           //       //   ),
//           //       // ),
//           //       const SizedBox(height: 20),
//           //       // Comment Button
//           //       // GestureDetector(
//           //       //   onTap: showCommentSection,
//           //       //   child: Column(
//           //       //     children: [
//           //       //       const Icon(Icons.comment, color: Colors.white, size: 35),
//           //       //       const SizedBox(height: 5),
//           //       //       int.parse(_homeController.mCommentVideoModel!.data!.length
//           //       //                   .toString()) ==
//           //       //               0
//           //       //           ? const SizedBox()
//           //       //           : Text(
//           //       //               _homeController.mCommentVideoModel!.data!.length
//           //       //                   .toString(),
//           //       //               style: const TextStyle(color: Colors.white),
//           //       //             ),
//           //       //     ],
//           //       //   ),
//           //       // ),
//           //       const SizedBox(height: 20),
//           //       // Share Button
//           //       // GestureDetector(
//           //       //   onTap: () async {
//           //       //     try {
//           //       //       final response = await _homeController.getSaveVideosData(
//           //       //         videoId: widget.videoId,
//           //       //         customerId: widget.customerId,
//           //       //         videotype: "trending",
//           //       //       );
//           //       //       if (response.status) {
//           //       //         // Show success message
//           //       //         // ignore: use_build_context_synchronously
//           //       //         ScaffoldMessenger.of(context).showSnackBar(
//           //       //           const SnackBar(
//           //       //             content: Text("Video saved successfully!"),
//           //       //             backgroundColor: Colors.green,
//           //       //           ),
//           //       //         );
//           //       //       } else {
//           //       //         // Show error message
//           //       //         // ignore: use_build_context_synchronously
//           //       //         ScaffoldMessenger.of(context).showSnackBar(
//           //       //           SnackBar(
//           //       //             content: Text(
//           //       //                 "Failed to save video: ${response.message}"),
//           //       //             backgroundColor: Colors.red,
//           //       //           ),
//           //       //         );
//           //       //       }
//           //       //     } catch (error) {
//           //       //       // Show error message
//           //       //       ScaffoldMessenger.of(context).showSnackBar(
//           //       //         const SnackBar(
//           //       //           content:
//           //       //               Text("An error occurred while saving the video."),
//           //       //           backgroundColor: Colors.red,
//           //       //         ),
//           //       //       );
//           //       //     }
//           //       //   },
//           //       //   child: const Column(
//           //       //     children: [
//           //       //       Icon(Icons.save_alt_rounded,
//           //       //           color: Colors.white, size: 35),
//           //       //       SizedBox(height: 5),
//           //       //       Text(
//           //       //         "Saved",
//           //       //         style: TextStyle(color: Colors.white),
//           //       //       ),
//           //       //     ],
//           //       //   ),
//           //       // ),
//           //     ],
//           //   ),
//           // ),

//           // Back Button
//           // GestureDetector(
//           //   onTap: () async {
//           //     print("tap");
//           //     Navigator.pop(context);
//           //     await SystemChrome.setPreferredOrientations(
//           //       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
//           //     );
//           //   },
//           //   child: Container(
//           //     margin: EdgeInsets.all(28),
//           //     height: 40,
//           //     width: 40,
//           //     color: Colors.red,
//           //     child: const Icon(Icons.arrow_back, color: Colors.white),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

// // class CommentSectionWidget extends StatefulWidget {
// //   // final List<String> comments;
// //   // final Function(String) onAddComment;
// //   final int customerId;
// //   final int videoId;

// //   const CommentSectionWidget({
// //     Key? key,
// //     // required this.comments,
// //     // required this.onAddComment,
// //     required this.customerId,
// //     required this.videoId,
// //   }) : super(key: key);

// //   @override
// //   State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
// // }

// // class _CommentSectionWidgetState extends State<CommentSectionWidget> {
// //   final HomeController _homeController = Get.put(HomeController());
// //   final TextEditingController _commentController = TextEditingController();

// //   @override
// //   void dispose() {
// //     _commentController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: EdgeInsets.only(
// //         left: 20,
// //         right: 20,
// //         top: 35,
// //         bottom: MediaQuery.of(context).viewInsets.bottom + 16,
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           text("Comments", textColor: white, fontFamily: productSans),
// //           const SizedBox(
// //             height: 20,
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               shrinkWrap: true,
// //               itemCount: _homeController.mCommentVideoModel!.data!.length,
// //               itemBuilder: (context, index) {
// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
// //                   child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.center,
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       CircleAvatar(
// //                         backgroundColor: Colors.black,
// //                         child: SvgPicture.asset(userIcon),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Expanded(
// //                         child: Text(
// //                           _homeController
// //                               .mCommentVideoModel!.data![index].comment
// //                               .toString(),
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontFamily: productSans,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),

// //           // Add Comment Field
// //           TextField(
// //             controller: _commentController,
// //             style: const TextStyle(color: Colors.white),
// //             decoration: InputDecoration(
// //               hintText: "Add a comment...",
// //               hintStyle: const TextStyle(color: Colors.grey),
// //               filled: true,
// //               fillColor: Colors.white.withOpacity(0.1),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(20),
// //                 borderSide: BorderSide.none,
// //               ),
// //               suffixIcon: IconButton(
// //                 icon: const Icon(Icons.send, color: Colors.white),
// //                 onPressed: () async {
// //                   final newComment = _commentController.text.trim();
// //                   if (newComment.isNotEmpty) {
// //                     // API Call to post comment
// //                     try {
// //                       await _homeController.getPostCommentVideosData(
// //                         commentText: newComment,
// //                         customerId: widget.customerId,
// //                         videoId: widget.videoId,
// //                         videotype: "trending",
// //                       );
// //                       // Update UI on success
// //                       // widget.onAddComment(newComment);
// //                       _commentController.clear();
// //                       Navigator.pop(context);
// //                     } catch (e) {
// //                       // Handle error
// //                       print("Failed to post comment: $e");
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                             content: Text("Failed to post comment.")),
// //                       );
// //                     }
// //                   }
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
