import 'package:astro_partner_app/model/session_model.dart';
import 'package:astro_partner_app/services/web_api_services.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/utils/request_failure.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  WebApiServices? _webApiServices;
  late int stateCode;
  late Failure _failure;
  Failure get failure => _failure;

  @override
  void onInit() {
    // _homeModel = HomeModel();
    _webApiServices = WebApiServices();

    super.onInit();
  }

  // SessionsModel? get sessionsModel => _sessionsModel;
  // SessionsModel? _sessionsModel;

  // var isSessionsModelLoding = false.obs;

  // Future<SessionsModel> fetchSessionData({required String serviceType}) async {
  //   try {
  //     isSessionsModelLoding(true);
  //     _sessionsModel = await _webApiServices!.getSessionsModel(
  //       serviceType: serviceType,
  //     );
  //   } on Failure catch (e) {
  //     isSessionsModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isSessionsModelLoding(false);
  //   return _sessionsModel!;
  // }

  SessionsModel? get mSessionsModel => _sessionsModel;
  SessionsModel? _sessionsModel;
  RxString nextPageUrl = "".obs;
  RxString nextPageUrlforCommingSession = "".obs;
  RxList<SessionsData> sessionListData = <SessionsData>[].obs;
  var isSessionsModelLoding = false.obs;

  Future<SessionsModel> fetchSessionData({
    String? pageUrl,
    bool isPaginatHit = false,
    String? serviceType, // 🔹 String instead of int
  }) async {
    try {
      isSessionsModelLoding(true);
      final String finalUrl =
          pageUrl ??
          "${GetBaseUrl + GetDomainUrl}sessions${serviceType != null ? "?service_type=$serviceType" : ""}";

      _sessionsModel = await _webApiServices!.getSessionsModel(
        pageUrl: finalUrl,
      );
      nextPageUrl(_sessionsModel!.data!.sessions!.nextPageUrl ?? "");
      if (!isPaginatHit) {
        sessionListData.clear();
      }
      for (var element in _sessionsModel!.data!.sessions!.data!) {
        sessionListData.add(element);
      }
      print("@@@@@@@CC@@@@@@@@");
    } on Failure catch (e) {
      isSessionsModelLoding(false);
      _setFailure(e);
    }
    isSessionsModelLoding(false);
    return _sessionsModel!;
  }

  // Future<HomeModel> getHomeDataForCheck(Map<String, String> authHeader) async {
  //   try {
  //     isHomeLoding(true);
  //     _homeModel = await _webApiServices!.getHomeDataForCheck(authHeader);
  //   } on Failure catch (e) {
  //     isHomeLoding(false);
  //     _setFailure(e);
  //   }
  //   isHomeLoding(false);
  //   return _homeModel!;
  // }

  // HoroscopeListModel? get horoscopeListModel => _horoscopeListModel;
  // HoroscopeListModel? _horoscopeListModel;
  // var ishoroscopeListModeloding = false.obs;
  // Future<HoroscopeListModel> getHoroscope() async {
  //   try {
  //     ishoroscopeListModeloding(true);
  //     _horoscopeListModel = await _webApiServices!.getHoroscope();
  //   } on Failure catch (e) {
  //     ishoroscopeListModeloding(false);
  //     _setFailure(e);
  //   }
  //   ishoroscopeListModeloding(false);
  //   return _horoscopeListModel!;
  // }

  // ServiceTypesModel? get serviceTypesModel => _serviceTypesModel;
  // ServiceTypesModel? _serviceTypesModel;
  // RxString nextPageUrl = "".obs;
  // // RxList<dynamic> servicesTypeListData = [].obs;
  // RxBool isServicesTypeLoding = false.obs;

  // Future<ServiceTypesModel> getAllServicesTypeData(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + SERVICE_TYPE,
  //     bool isPaginatHit = false}) async {
  //   try {
  //     isServicesTypeLoding(true);
  //     _serviceTypesModel =
  //         await _webApiServices!.getAllServicesTypeData(pageUrl: pageUrl);
  //     nextPageUrl(_serviceTypesModel!.data!.nextPageUrl ?? "");
  //     // if (!isPaginatHit) {
  //     //   servicesTypeListData.clear();
  //     // }
  //     // for (var element in _serviceTypesModel!.data!.serviceData!) {
  //     //   servicesTypeListData.add(element);
  //     // }
  //   } on Failure catch (e) {
  //     isServicesTypeLoding(false);
  //     _setFailure(e);
  //   }
  //   isServicesTypeLoding(false);
  //   return _serviceTypesModel!;
  // }

  // ExpertsDataModel? get expertsDataModel => _expertsDataModel;
  // ExpertsDataModel? _expertsDataModel;
  // RxString nextExtertPageUrl = "".obs;
  // RxList<dynamic> expertListData = [].obs;
  // var isExpertDataLoding = false.obs;

  // Future<ExpertsDataModel> getAllExpertsData(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + GET_EXPERTS,
  //     bool isPaginatHit = false,
  //     required int serviceId}) async {
  //   try {
  //     isExpertDataLoding(true);
  //     _expertsDataModel = await _webApiServices!
  //         .getAllExpertsData(pageUrl: pageUrl, serviceId: serviceId);
  //     nextExtertPageUrl(_expertsDataModel!.data!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       expertListData.clear();
  //     }
  //     for (var element in _expertsDataModel!.data!.expertData!) {
  //       expertListData.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isExpertDataLoding(false);
  //     _setFailure(e);
  //   }
  //   print("###########Response false#############");
  //   print(serviceId);
  //   print(pageUrl);
  //   isExpertDataLoding(false);
  //   return _expertsDataModel!;
  // }

  // SlotsDataModel? get slotsDataModel => _slotsDataModel;
  // SlotsDataModel? _slotsDataModel;
  // var isSlotsDataLoding = false.obs;

  // Future<SlotsDataModel> getSlotsData(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + GET_SLOTS,
  //     required int serviceId,
  //     required int expertId,
  //     required String date}) async {
  //   try {
  //     isSlotsDataLoding(true);
  //     _slotsDataModel = await _webApiServices!.getSlotsData(
  //         pageUrl: pageUrl,
  //         serviceId: serviceId,
  //         expertId: expertId,
  //         date: date);
  //   } on Failure catch (e) {
  //     isSlotsDataLoding(false);
  //     _setFailure(e);
  //   }
  //   isSlotsDataLoding(false);
  //   return _slotsDataModel!;
  // }

  // ServiceOrderModel? get serviceOrderModel => _serviceOrderModel;
  // ServiceOrderModel? _serviceOrderModel;
  // var serviceOrderloading = false.obs;

  // Future<ServiceOrderModel> serviceOrderPlacedApi(
  //     {required int serviceId,
  //     required int serviceTypeId,
  //     required int expertId,
  //     required List<int> slots,
  //     required int audioSlots,
  //     required String date,
  //     required String fullName,
  //     required String birthTime,
  //     required String dateOfBirth,
  //     required String placeOfBirth,
  //     required String birthTmeAccuracy,
  //     required String partnerName,
  //     required String partnerdob,
  //     required String partnerBirthTime,
  //     required String partnerBirthPlace,
  //     required String audioQuestion,
  //     required String partnerbirthTmeAccuracy,
  //     required List<File> files}) async {
  //   try {
  //     serviceOrderloading(true);
  //     _serviceOrderModel = await _webApiServices!.serviceOrderPlacedApi(
  //         partnerbirthTmeAccuracy: partnerbirthTmeAccuracy,
  //         files: files,
  //         birthTime: birthTime,
  //         date: date,
  //         slots: slots,
  //         audioSlots: audioSlots,
  //         dateOfBirth: dateOfBirth,
  //         expertId: expertId,
  //         fullName: fullName,
  //         placeOfBirth: placeOfBirth,
  //         serviceId: serviceId,
  //         birthTmeAccuracy: birthTmeAccuracy,
  //         serviceTypeId: serviceTypeId,
  //         audioQuestion: audioQuestion,
  //         partnerBirthPlace: partnerBirthPlace,
  //         partnerBirthTime: partnerBirthTime,
  //         partnerName: partnerName,
  //         partnerdob: partnerdob);
  //   } on Failure catch (e) {
  //     serviceOrderloading(false);
  //     _setFailure(e);
  //   }
  //   serviceOrderloading(false);
  //   return _serviceOrderModel!;
  // }

  // Future<ServiceOrderModel> applyeCoupon(
  //     {required int orderId, required String couponCode}) async {
  //   try {
  //     serviceOrderloading(true);
  //     _serviceOrderModel = await _webApiServices!
  //         .applyeCoupon(couponCode: couponCode, orderId: orderId);
  //   } on Failure catch (e) {
  //     serviceOrderloading(false);
  //     _setFailure(e);
  //   }
  //   serviceOrderloading(false);
  //   return _serviceOrderModel!;
  // }

  // Future<ServiceOrderModel> removeCoupon(
  //     {required int orderId, required String couponCode}) async {
  //   try {
  //     serviceOrderloading(true);
  //     _serviceOrderModel = await _webApiServices!
  //         .removeCoupon(couponCode: couponCode, orderId: orderId);
  //   } on Failure catch (e) {
  //     serviceOrderloading(false);
  //     _setFailure(e);
  //   }
  //   serviceOrderloading(false);
  //   return _serviceOrderModel!;
  // }

  // Future<CheckPaymentStatusModel> checkPaymentStatus(
  //     {required String merchantId,
  //     required String transactionId,
  //     required String saltIndex}) async {
  //   return await _webApiServices!.checkPaymentStatus(
  //       merchantId: merchantId,
  //       saltIndex: saltIndex,
  //       transactionId: transactionId);
  // }

  // Future<ApiResponse> changePaymentStatus(
  //     {required int orderId,
  //     required String transactionId,
  //     required String status,
  //     required String paymentMode,
  //     required String totalMinutes,
  //     required String paymentType,
  //     File? screenshot}) async {
  //   return await _webApiServices!
  //       .changePaymentStatus(
  //           orderId: orderId,
  //           paymentMode: paymentMode,
  //           status: status,
  //           totalMinutes: totalMinutes,
  //           paymentType: paymentType,
  //           screenshot: screenshot,
  //           transactionId: transactionId)
  //       .whenComplete(() {
  //     isServicesTypeLoding(true);
  //     getAllServicesTypeData();
  //   });
  // }

  // Future<JoinSessionModel> joinSessions({required String sessionId}) async {
  //   return await _webApiServices!.joinSessions(sessionId: sessionId);
  // }

  // Future<AudioModel> joinAudioSessions({required String sessionId}) async {
  //   return await _webApiServices!.joinAudioSessions(sessionId: sessionId);
  // }

  // Future<ChatSessionModel> joinChatSessions({required String sessionId}) async {
  //   return await _webApiServices!.joinChatSessions(sessionId: sessionId);
  // }

  // AudioTimeRecodeModel? get audioTimeRecodeModel => _audioTimeRecodeModel;
  // AudioTimeRecodeModel? _audioTimeRecodeModel;
  // var audioTimeRecodeModelloading = false.obs;

  // Future<AudioTimeRecodeModel> getAudioRecodingTime(
  //     {required int serviceId, required int expertId}) async {
  //   try {
  //     audioTimeRecodeModelloading(true);
  //     _audioTimeRecodeModel = await _webApiServices!
  //         .getAudioRecodingTime(expertId: expertId, serviceId: serviceId);
  //   } on Failure catch (e) {
  //     audioTimeRecodeModelloading(false);
  //     _setFailure(e);
  //   }
  //   audioTimeRecodeModelloading(false);
  //   return _audioTimeRecodeModel!;
  // }

  // PodCastVideoModel? get mPodCastVideoModel => _podCastVideoModel;
  // PodCastVideoModel? _podCastVideoModel;
  // RxString nextPageUrlPodCastVideoModel = "".obs;
  // RxList<PodcastData> podCastVideoModellst = <PodcastData>[].obs;
  // var isPodCastVideoModelLoding = false.obs;

  // Future<PodCastVideoModel> getPodCastVideo(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + PODCAST_VIDEO_GET,
  //     bool isPaginatHit = false}) async {
  //   try {
  //     if (!isPaginatHit) {
  //       isPodCastVideoModelLoding(true);
  //     }
  //     _podCastVideoModel =
  //         await _webApiServices!.getPodCastVideo(pageUrl: pageUrl);
  //     nextPageUrlPodCastVideoModel(
  //         _podCastVideoModel!.videos!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       podCastVideoModellst.clear();
  //     }
  //     for (var element in _podCastVideoModel!.videos!.data!) {
  //       podCastVideoModellst.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isPodCastVideoModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isPodCastVideoModelLoding(false);
  //   return _podCastVideoModel!;
  // }

  // PodCastVideoModel? get mTrandingVideoModel => _trandingVideoModel;
  // PodCastVideoModel? _trandingVideoModel;
  // RxString nextPageUrlTrandingVideoModel = "".obs;
  // RxList<PodcastData> trandingVideoModellst = <PodcastData>[].obs;
  // var isTrandingVideoModelLoding = false.obs;

  // Future<PodCastVideoModel> getTrandingVideo(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + TREDINF_VIDEO_GET,
  //     bool isPaginatHit = false}) async {
  //   try {
  //     if (!isPaginatHit) {
  //       isTrandingVideoModelLoding(true);
  //     }
  //     _trandingVideoModel =
  //         await _webApiServices!.getTrandingVideo(pageUrl: pageUrl);
  //     nextPageUrlTrandingVideoModel(
  //         _trandingVideoModel!.videos!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       trandingVideoModellst.clear();
  //     }
  //     for (var element in _trandingVideoModel!.videos!.data!) {
  //       trandingVideoModellst.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isTrandingVideoModelLoding(false);
  //     _setFailure(e);
  //   }
  //   print("false ho gay");
  //   isTrandingVideoModelLoding(false);
  //   return _trandingVideoModel!;
  // }

  // PodCastVideoModel? get mYoutubeVideoModel => _youtubeVideoModel;
  // PodCastVideoModel? _youtubeVideoModel;
  // RxString nextYoutubeVideoModelModel = "".obs;
  // RxList<PodcastData> youtubeVideoModellst = <PodcastData>[].obs;
  // var isYoutubeVideoModelLoding = false.obs;

  // Future<PodCastVideoModel> getYoutubeVideo(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + YOUTUBE_VIDEO_GET,
  //     bool isPaginatHit = false}) async {
  //   try {
  //     if (!isPaginatHit) {
  //       isYoutubeVideoModelLoding(true);
  //     }
  //     _youtubeVideoModel =
  //         await _webApiServices!.getYoutubeVideo(pageUrl: pageUrl);
  //     nextYoutubeVideoModelModel(_youtubeVideoModel!.videos!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       youtubeVideoModellst.clear();
  //     }
  //     for (var element in _youtubeVideoModel!.videos!.data!) {
  //       youtubeVideoModellst.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isYoutubeVideoModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isYoutubeVideoModelLoding(false);
  //   return _youtubeVideoModel!;
  // }

  // CouponListModel? get couponListModel => _couponListModel;
  // CouponListModel? _couponListModel;
  // RxString nextCouponListModel = "".obs;
  // RxList<CouponsData> couponList = <CouponsData>[].obs;
  // var isCouponListModelLoding = false.obs;

  // Future<CouponListModel> getCouponList(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + COUPON_LIST,
  //     bool isPaginatHit = false}) async {
  //   try {
  //     isCouponListModelLoding(true);
  //     _couponListModel = await _webApiServices!.getCouponList(pageUrl: pageUrl);
  //     nextCouponListModel(_couponListModel!.coupons!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       couponList.clear();
  //     }
  //     for (var element in _couponListModel!.coupons!.data!) {
  //       couponList.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isCouponListModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isCouponListModelLoding(false);
  //   return _couponListModel!;
  // }

  void _setFailure(Failure failure) {
    _failure = failure;
  }

  // LiveChatListModel? get liveChatListModel => _liveChatListModel;
  // LiveChatListModel? _liveChatListModel;
  // RxString nextChatListPageUrl = "".obs;
  // RxList<ChatListData> chatListData = <ChatListData>[].obs;
  // var isliveChatListLoding = false.obs;

  // Future<LiveChatListModel> getLiveChatListModelData(
  //     {String pageUrl = GetBaseUrl + GetDomainUrl + GET_EXPERTS_LIST,
  //     bool isPaginatHit = false}) async {
  //   print("!!!!!!!!!!!!!!!!!element!!!!!!!!!!!!!!!!!!");
  //   print(pageUrl);
  //   try {
  //     isliveChatListLoding(true);
  //     _liveChatListModel =
  //         await _webApiServices!.getLiveChatListModelApi(pageUrl: pageUrl);
  //     nextChatListPageUrl(_liveChatListModel!.data!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       chatListData.clear();
  //     }
  //     for (var element in _liveChatListModel!.data!.data!) {
  //       chatListData.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isliveChatListLoding(false);
  //     _setFailure(e);
  //   }
  //   print("###########Response false LiveChatListModel#############");
  //   isliveChatListLoding(false);
  //   return _liveChatListModel!;
  // }

  // FreeChatModel? get freeChatModel => _freeChatModel;
  // FreeChatModel? _freeChatModel;
  // RxString nextFreeChatPageUrl = "".obs;
  // RxList<dynamic> freechatListData = [].obs;
  // var isFreeChatModelLoding = false.obs;

  // Future<FreeChatModel> getFreeChatModelData({
  //   String pageUrl = GetBaseUrl + GetDomainUrl + freeChat,
  //   bool isPaginatHit = false,
  // }) async {
  //   print("!!!!!!!!!!!!!!!!!isFreeChatModelLoding!!!!!!!!!!!!!!!!!!");
  //   print(pageUrl);
  //   try {
  //     isFreeChatModelLoding(true);
  //     _freeChatModel =
  //         await _webApiServices!.getFreeChatModelApi(pageUrl: pageUrl);
  //     nextFreeChatPageUrl(_freeChatModel!.data!.nextPageUrl ?? "");
  //     if (!isPaginatHit) {
  //       freechatListData.clear();
  //     }
  //     for (var element in _freeChatModel!.data!.data!) {
  //       freechatListData.add(element);
  //     }
  //   } on Failure catch (e) {
  //     isFreeChatModelLoding(false);
  //     _setFailure(e);
  //   }
  //   print("###########Response false isFreeChatModelLoding#############");
  //   isFreeChatModelLoding(false);
  //   return _freeChatModel!;
  // }

  // AstroWalletBalanceModel? _astroWalletBalanceModel;
  // AstroWalletBalanceModel? get mAstroWalletBalanceModel =>
  //     _astroWalletBalanceModel;

  // var isAstroWalletBalanceModelLoding = false.obs;

  // Future<AstroWalletBalanceModel> getAstroWalletBalanceModelData() async {
  //   try {
  //     isAstroWalletBalanceModelLoding(true);
  //     _astroWalletBalanceModel =
  //         await _webApiServices!.getAstroWalletBalanceModelApi();
  //   } on Failure catch (e) {
  //     isAstroWalletBalanceModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isAstroWalletBalanceModelLoding(false);
  //   return _astroWalletBalanceModel!;
  // }

  // WalletLedgerModel? _walletLedgerModel;

  // WalletLedgerModel? get mWalletLedgerModel => _walletLedgerModel;

  // var isWalletLedgerModelLoding = false.obs;

  // Future<WalletLedgerModel> getWalletLedgerModelData() async {
  //   try {
  //     isWalletLedgerModelLoding(true);
  //     _walletLedgerModel = await _webApiServices!.getWalletLedgerModelApi();
  //   } on Failure catch (e) {
  //     isWalletLedgerModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isWalletLedgerModelLoding(false);
  //   return _walletLedgerModel!;
  // }

  // CreateWalletModel? _createWalletModel;

  // CreateWalletModel? get mCreateWalletModel => _createWalletModel;

  // var isCreateWalletModelLoding = false.obs;

  // Future<CreateWalletModel> getCreateWalletModelData(
  //     {required int amount, required dynamic dateTime}) async {
  //   try {
  //     isCreateWalletModelLoding(true);
  //     _createWalletModel = await _webApiServices!
  //         .getCreateWalletModelApi(amount: amount, dateTime: dateTime);
  //   } on Failure catch (e) {
  //     isCreateWalletModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isCreateWalletModelLoding(false);
  //   return _createWalletModel!;
  // }

  // ApiResponse? _confirmWalletModel;

  // ApiResponse? get mConfirmWalletModel => _confirmWalletModel;

  // var isConfirmWalletModelLoding = false.obs;

  // Future<ApiResponse> getConfirmWalletModelData(
  //     {required dynamic transactionId,
  //     required dynamic cfOrderId,
  //     required String paymentMode,
  //     File? screenshot,
  //     required String paymentType,
  //     required dynamic status}) async {
  //   try {
  //     isConfirmWalletModelLoding(true);
  //     _confirmWalletModel = await _webApiServices!.getConfirmWalletModelApi(
  //         paymentMode: paymentMode,
  //         paymentType: paymentType,
  //         screenshot: screenshot,
  //         cfOrderId: cfOrderId,
  //         status: status,
  //         transactionId: transactionId);
  //   } on Failure catch (e) {
  //     isConfirmWalletModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isConfirmWalletModelLoding(false);
  //   return _confirmWalletModel!;
  // }

  // ChatAstrologerModel? _chatAstrologerModel;

  // ChatAstrologerModel? get mChatAstrologerModel => _chatAstrologerModel;

  // var isChatAstrologerModelLoding = false.obs;

  // Future<ChatAstrologerModel> getChatAstrologerModelData(
  //     {required dynamic astrologerId,
  //     required dynamic customerId,
  //     required dynamic date,
  //     required dynamic time}) async {
  //   try {
  //     isChatAstrologerModelLoding(true);
  //     _chatAstrologerModel = await _webApiServices!.getChatAstrologerModelApi(
  //         astrologerId: astrologerId,
  //         customerId: customerId,
  //         date: date,
  //         time: time);
  //   } on Failure catch (e) {
  //     isChatAstrologerModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isChatAstrologerModelLoding(false);
  //   return _chatAstrologerModel!;
  // }

  // AstrologerProfileModel? _astrologerProfileModel;

  // AstrologerProfileModel? get mAstrologerProfileModel =>
  //     _astrologerProfileModel;

  // var isAstrologerProfileModelLoding = false.obs;

  // Future<AstrologerProfileModel> getAstrologerProfileModelData(
  //     {required int astroId}) async {
  //   try {
  //     isAstrologerProfileModelLoding(true);
  //     _astrologerProfileModel =
  //         await _webApiServices!.getAstrologerProfileModelApi(astroId: astroId);
  //   } on Failure catch (e) {
  //     isAstrologerProfileModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isAstrologerProfileModelLoding(false);
  //   return _astrologerProfileModel!;
  // }

  // ReviewListModel? _reviewListModel;

  // ReviewListModel? get mReviewListModel => _reviewListModel;

  // var isReviewListModelLoding = false.obs;

  // Future<ReviewListModel> getReviewListModelData(
  //     {required int astroId, required String orderType}) async {
  //   try {
  //     isReviewListModelLoding(true);
  //     _reviewListModel = await _webApiServices!
  //         .getReviewListModelApi(astroId: astroId, orderType: orderType);
  //   } on Failure catch (e) {
  //     isReviewListModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isReviewListModelLoding(false);
  //   return _reviewListModel!;
  // }

  // ApiResponse? _postReview;

  // ApiResponse? get mPostReview => _postReview;

  // var isPostReviewLoding = false.obs;

  // Future<ApiResponse> getPostReviewData(
  //     {required int astroId,
  //     required double rating,
  //     required String comment,
  //     required int customerId,
  //     required String dateTime,
  //     required String type,
  //     required int productId}) async {
  //   try {
  //     isPostReviewLoding(true);
  //     _postReview = await _webApiServices!.getPostReviewApi(
  //         productId: productId,
  //         type: type,
  //         astroId: astroId,
  //         comment: comment,
  //         customerId: customerId,
  //         dateTime: dateTime,
  //         rating: rating);
  //   } on Failure catch (e) {
  //     isPostReviewLoding(false);
  //     _setFailure(e);
  //   }
  //   isPostReviewLoding(false);
  //   return _postReview!;
  // }

  // ApiResponse? _postLike;

  // ApiResponse? get mPostLike => _postLike;

  // var isPostLikeLoding = false.obs;

  // Future<ApiResponse> getPostLikeData({
  //   required int videoId,
  //   required int customerId,
  //   required String videotype,
  // }) async {
  //   try {
  //     isPostLikeLoding(true);
  //     _postLike = await _webApiServices!.getPostLikeApi(
  //         videotype: videotype, customerId: customerId, videoId: videoId);
  //   } on Failure catch (e) {
  //     getLikeVideoModelData();
  //     isPostLikeLoding(false);
  //     _setFailure(e);
  //   }

  //   isPostLikeLoding(false);
  //   return _postLike!;
  // }

  // SupportChatModel? _supportChatModel;

  // SupportChatModel? get mSupportChatModel => _supportChatModel;

  // var isSupportChatModelLoding = false.obs;

  // Future<SupportChatModel> getSupportChatModelData({
  //   required dynamic customerId,
  // }) async {
  //   try {
  //     isSupportChatModelLoding(true);
  //     _supportChatModel = await _webApiServices!.getSupportChatModelApi(
  //       customerId: customerId,
  //     );
  //   } on Failure catch (e) {
  //     isSupportChatModelLoding(false);
  //     _setFailure(e);
  //   }
  //   isSupportChatModelLoding(false);
  //   return _supportChatModel!;
  // }

  // // ApiResponse? _videoViews;

  // // ApiResponse? get mVideoViews => _videoViews;

  // // var isVideoViewsLoding = false.obs;

  // // Future<ApiResponse> getVideoViewsData({
  // //   required int videoId,
  // //   required String videotype,
  // // }) async {
  // //   try {
  // //     isVideoViewsLoding(true);
  // //     _videoViews = await _webApiServices!
  // //         .getVideoViewsApi(videotype: videotype, videoId: videoId);
  // //   } on Failure catch (e) {
  // //     isVideoViewsLoding(false);
  // //     _setFailure(e);
  // //   }
  // //   getTrandingVideo();
  // //   getPodCastVideo();
  // //   getYoutubeVideo();
  // //   isVideoViewsLoding(false);
  // //   return _videoViews!;
  // // }

  // VideoBannerModel? _videoBannerModel;

  // VideoBannerModel? get mVideoBannerModel => _videoBannerModel;

  // var isVideoBannerModelLoding = false.obs;

  // Future<VideoBannerModel> getVideoBannerModelData() async {
  //   try {
  //     isVideoBannerModelLoding(true);
  //     _videoBannerModel = await _webApiServices!.getVideoBannerModelApi();
  //   } on Failure catch (e) {
  //     isVideoBannerModelLoding(false);
  //     _setFailure(e);
  //   }

  //   // isVideoViewsLoding(false);
  //   return _videoBannerModel!;
  // }

  // ApiResponse? _saveVideos;

  // ApiResponse? get mSaveVideos => _saveVideos;

  // var isSaveVideosLoding = false.obs;

  // Future<ApiResponse> getSaveVideosData({
  //   required int videoId,
  //   required int customerId,
  //   required String videotype,
  // }) async {
  //   try {
  //     isSaveVideosLoding(true);
  //     _saveVideos = await _webApiServices!.getSaveVideosApi(
  //         videotype: videotype, customerId: customerId, videoId: videoId);
  //   } on Failure catch (e) {
  //     isSaveVideosLoding(false);
  //     _setFailure(e);
  //   }
  //   getSavedVideoModelData();

  //   isSaveVideosLoding(false);
  //   return _saveVideos!;
  // }

  // LikeVideoModel? _likeVideoModel;

  // LikeVideoModel? get mLikeVideoModel => _likeVideoModel;

  // var isLikeVideoModelLoding = false.obs;

  // Future<LikeVideoModel> getLikeVideoModelData() async {
  //   try {
  //     isLikeVideoModelLoding(true);
  //     _likeVideoModel = await _webApiServices!.getLikeVideoModelApi();
  //   } on Failure catch (e) {
  //     isLikeVideoModelLoding(false);
  //     _setFailure(e);
  //   }

  //   isLikeVideoModelLoding(false);
  //   return _likeVideoModel!;
  // }

  // SavedVideoModel? _savedVideoModel;

  // SavedVideoModel? get mSavedVideoModel => _savedVideoModel;

  // var isSavedVideoModelLoding = false.obs;

  // Future<SavedVideoModel> getSavedVideoModelData() async {
  //   try {
  //     isSavedVideoModelLoding(true);
  //     _savedVideoModel = await _webApiServices!.getSavedVideoModelApi();
  //   } on Failure catch (e) {
  //     isSavedVideoModelLoding(false);
  //     _setFailure(e);
  //   }

  //   isSavedVideoModelLoding(false);
  //   return _savedVideoModel!;
  // }

  // ApiResponse? _postCmmentVideos;

  // ApiResponse? get mPostCommentVideos => _postCmmentVideos;

  // var isPostCommentVideosLoding = false.obs;

  // Future<ApiResponse> getPostCommentVideosData(
  //     {required int videoId,
  //     required int customerId,
  //     required String videotype,
  //     required String commentText}) async {
  //   try {
  //     isPostCommentVideosLoding(true);
  //     _postCmmentVideos = await _webApiServices!.getPostCommentVideosApi(
  //         commentText: commentText,
  //         videotype: videotype,
  //         customerId: customerId,
  //         videoId: videoId);
  //   } on Failure catch (e) {
  //     isPostCommentVideosLoding(false);
  //     _setFailure(e);
  //   }
  //   // getCommentVideoModelData(videoId: videoId, videoType: videotype);

  //   isPostCommentVideosLoding(false);
  //   return _postCmmentVideos!;
  // }

  // // CommentVideoModel? _commentVideoModel;

  // // CommentVideoModel? get mCommentVideoModel => _commentVideoModel;

  // // var isCommentVideoModelLoding = false.obs;

  // // Future<CommentVideoModel> getCommentVideoModelData(
  // //     {required String videoType, required int videoId}) async {
  // //   try {
  // //     isCommentVideoModelLoding(true);
  // //     _commentVideoModel = await _webApiServices!
  // //         .getCommentVideoModelApi(videoId: videoId, videoType: videoType);
  // //   } on Failure catch (e) {
  // //     isCommentVideoModelLoding(false);
  // //     _setFailure(e);
  // //   }

  // //   isCommentVideoModelLoding(false);
  // //   return _commentVideoModel!;
  // // }

  // ApiResponse? _sessionCheck;

  // ApiResponse? get mSessionCheck => _sessionCheck;

  // var isSessionCheckLoding = false.obs;
  // Future<ApiResponse> getSessionCheckData({
  //   required int sessionId,
  // }) async {
  //   try {
  //     isSessionCheckLoding(true);
  //     _sessionCheck =
  //         await _webApiServices!.getSessionCheckApi(sessionId: sessionId);
  //   } on Failure catch (e) {
  //     isSessionCheckLoding(false);
  //     _setFailure(e);
  //   }

  //   isSessionCheckLoding(false);
  //   return _sessionCheck!;
  // }

  // ApiResponse? _freeChatCheck;

  // ApiResponse? get mfreeChatCheck => _freeChatCheck;

  // var isfreeChatCheckLoding = false.obs;
  // Future<ApiResponse> getfreeChatCheckData({
  //   required String roomId,
  //   required String startTime,
  //   required String endTime,
  // }) async {
  //   try {
  //     isfreeChatCheckLoding(true);
  //     _freeChatCheck = await _webApiServices!.getfreeChatCheckApi(
  //         endTime: endTime, roomId: roomId, startTime: startTime);
  //   } on Failure catch (e) {
  //     isfreeChatCheckLoding(false);
  //     _setFailure(e);
  //   }

  //   isfreeChatCheckLoding(false);
  //   return _freeChatCheck!;
  // }

  // AllBannerModel? _allBannerModel;

  // AllBannerModel? get mAllBannerModel => _allBannerModel;

  // var isAllBannerModelLoding = false.obs;

  // Future<AllBannerModel?> getAllBannerModelData() async {
  //   try {
  //     isAllBannerModelLoding(true);
  //     _allBannerModel = await _webApiServices!.getAllBannerModelApi();
  //     isAllBannerModelLoding(false);
  //     return _allBannerModel;
  //   } on Failure catch (e) {
  //     isAllBannerModelLoding(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // ApiResponse? _vastuForm;

  // ApiResponse? get mvastuForm => _vastuForm;

  // var isvastuFormLoding = false.obs;
  // Future<ApiResponse> getvastuFormData({
  //   required String name,
  //   required String phone,
  //   required String email,
  //   required String propertyType,
  //   required String dob,
  //   required String address,
  //   required String propertyArea,
  //   required String noOfFloors,
  //   required String specificConcernsType,
  //   required String specificConcernsArea,
  //   required String bad,
  //   required String consultDatetime,
  //   required List<File> imagePath,
  // }) async {
  //   try {
  //     isvastuFormLoding(true);
  //     _vastuForm = await _webApiServices!.getvastuFormApi(
  //         imagePath: imagePath,
  //         address: address,
  //         bad: bad,
  //         consultDatetime: consultDatetime,
  //         dob: dob,
  //         email: email,
  //         name: name,
  //         noOfFloors: noOfFloors,
  //         phone: phone,
  //         propertyArea: propertyArea,
  //         propertyType: propertyType,
  //         specificConcernsArea: specificConcernsArea,
  //         specificConcernsType: specificConcernsType);
  //   } on Failure catch (e) {
  //     isvastuFormLoding(false);
  //     _setFailure(e);
  //   }

  //   isvastuFormLoding(false);
  //   return _vastuForm!;
  // }

  // UpdateMentenceModel? _updateMentenceModel;

  // UpdateMentenceModel? get mUpdateMentenceModel => _updateMentenceModel;

  // var isUpdateMentenceModelLoding = false.obs;

  // Future<UpdateMentenceModel?> getUpdateMentenceModelData() async {
  //   try {
  //     isUpdateMentenceModelLoding(true);
  //     _updateMentenceModel = await _webApiServices!.getUpdateMentenceModelApi();
  //     isUpdateMentenceModelLoding(false);
  //     return _updateMentenceModel;
  //   } on Failure catch (e) {
  //     isUpdateMentenceModelLoding(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // PopUpModel? _popUpModel;

  // PopUpModel? get mPopUpModel => _popUpModel;

  // var isPopUpModelLoding = false.obs;

  // Future<PopUpModel?> getPopUpModelData() async {
  //   try {
  //     isPopUpModelLoding(true);
  //     _popUpModel = await _webApiServices!.getPopUpModelApi();
  //     isPopUpModelLoding(false);
  //     return _popUpModel;
  //   } on Failure catch (e) {
  //     isPopUpModelLoding(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // CallImageUploadModel? _callImageUploadModel;

  // CallImageUploadModel? get mCallImageUploadModel => _callImageUploadModel;

  // var isCallImageUploadModelLoding = false.obs;

  // Future<CallImageUploadModel?> getCallImageUploadModelData({
  //   required dynamic sessionId,
  //   required dynamic roomId,
  //   required dynamic imagePath,
  // }) async {
  //   try {
  //     isCallImageUploadModelLoding(true);
  //     _callImageUploadModel = await _webApiServices!.getCallImageUploadModelApi(
  //         imagePath: imagePath, roomId: roomId, sessionId: sessionId);
  //     isCallImageUploadModelLoding(false);
  //     return _callImageUploadModel;
  //   } on Failure catch (e) {
  //     isCallImageUploadModelLoding(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // ApiResponse? _sentFreeChatEmail;

  // ApiResponse? get mSentFreeChatEmail => _sentFreeChatEmail;

  // var isSentFreeChatEmail = false.obs;

  // Future<ApiResponse?> sentfreeChatEmail(
  //     {required String customerId,
  //     required String userName,
  //     required String message,
  //     required String sessionId,
  //     required String astrologerId,
  //     required String astrologerName}) async {
  //   try {
  //     isSentFreeChatEmail(true);
  //     _sentFreeChatEmail = await _webApiServices!.sentfreeChatEmail(
  //         astrologerId: astrologerId,
  //         astrologerName: astrologerName,
  //         customerId: customerId,
  //         message: message,
  //         sessionId: sessionId,
  //         userName: userName);
  //     isSentFreeChatEmail(false);
  //     return _sentFreeChatEmail;
  //   } on Failure catch (e) {
  //     isSentFreeChatEmail(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // ApiResponse? _sentSupportChatEmail;

  // ApiResponse? get mSentSupportChatEmail => _sentSupportChatEmail;

  // var isSentSupportChatEmail = false.obs;

  // Future<ApiResponse?> sendSupportChatEmail(
  //     {required String customerId,
  //     required String userName,
  //     required String message,
  //     required String sessionId,
  //     required String supportId,
  //     required String supportName}) async {
  //   try {
  //     isSentSupportChatEmail(true);
  //     _sentSupportChatEmail = await _webApiServices!.sendSupportChatEmail(
  //         supportId: supportId,
  //         supportName: supportName,
  //         customerId: customerId,
  //         message: message,
  //         sessionId: sessionId,
  //         userName: userName);
  //     isSentSupportChatEmail(false);
  //     return _sentSupportChatEmail;
  //   } on Failure catch (e) {
  //     isSentSupportChatEmail(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // // ServiceOrderModel? _serviceApplyWalletModel;

  // // ServiceOrderModel? get mServiceApplyWalletModel =>
  // //     _serviceApplyWalletModel;

  // // var isServiceApplyWalletModelLoding = false.obs;

  // Future<ServiceOrderModel?> getServiceApplyWalletModelData({
  //   required int orderId,
  // }) async {
  //   try {
  //     // serviceOrderloading(true);
  //     _serviceOrderModel = await _webApiServices!
  //         .getServiceApplyWalletModelApi(orderId: orderId);
  //     serviceOrderloading(true);

  //     serviceOrderloading(false);
  //     return _serviceOrderModel;
  //   } on Failure catch (e) {
  //     serviceOrderloading(true);

  //     serviceOrderloading(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // // ServiceRemoveWalletModel? _serviceRemoveWalletModel;

  // // ServiceRemoveWalletModel? get mServiceRemoveWalletModel =>
  // //     _serviceRemoveWalletModel;

  // // var isServiceRemoveWalletModelLoding = false.obs;

  // Future<ServiceOrderModel?> getServiceRemoveWalletModelData({
  //   required int orderId,
  // }) async {
  //   try {
  //     _serviceOrderModel = await _webApiServices!
  //         .getServiceRemoveWalletModelApi(orderId: orderId);
  //     serviceOrderloading(true);

  //     serviceOrderloading(false);
  //     return _serviceOrderModel;
  //   } on Failure catch (e) {
  //     serviceOrderloading(true);

  //     serviceOrderloading(false);
  //     _setFailure(e);
  //     return null;
  //   }
  // }

  // //   ProductData? _productData;

  // // ProductData? get mProductData => _productData;

  // // var isProductDataLoding = false.obs;

  // Future<ProductDetailsModel> getProductDetailsData({required int id}) async {
  //   return await _webApiServices!.getProductDetailsData(id: id);
  // }
}
