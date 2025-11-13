import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/model/callerUserInfo_model.dart';
import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/review_list_model.dart';
import 'package:astro_partner_app/model/seassion_chat_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/model/session_model.dart';
import 'package:astro_partner_app/model/socket_detail_model.dart';
import 'package:astro_partner_app/model/socket_verify_model.dart';
import 'package:astro_partner_app/model/start_timer_chat_model.dart';
import 'package:astro_partner_app/model/update_note_model.dart';
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
    _webApiServices = WebApiServices();

    super.onInit();
  }

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
      print("!!!!!!!!!!!!!!!!!!!!pageUrl!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(finalUrl);
      print("!!!!!!!!!!!!!!!!!!!!pageUrl!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

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

  SessionDetailsModel? get sessionDetailsModel => _sessionDetailsModel;
  SessionDetailsModel? _sessionDetailsModel;

  var isSessionDetailsModelLoding = false.obs;

  Future<SessionDetailsModel> fetchSessionDetailsData({
    required String sessionId,
  }) async {
    try {
      isSessionDetailsModelLoding(true);
      _sessionDetailsModel = await _webApiServices!.getSessionDetailsModel(
        sessionId: sessionId,
      );
    } on Failure catch (e) {
      isSessionDetailsModelLoding(false);
      _setFailure(e);
    }
    isSessionDetailsModelLoding(false);
    return _sessionDetailsModel!;
  }

  EarningListModel? get mEarningListModel => _earningListModel;
  EarningListModel? _earningListModel;

  RxString nextPageUrlforEarningListModel = "".obs;
  RxList<EarningData> earningListData = <EarningData>[].obs;
  var isEarningListModelLoding = false.obs;

  Future<EarningListModel> fetchEarningListData({
    String? pageUrl,
    bool isPaginatHit = false,
  }) async {
    try {
      isEarningListModelLoding(true);

      final String finalUrl =
          pageUrl ?? "${GetBaseUrl + GetDomainUrl2}expert-earnings";

      _earningListModel = await _webApiServices!.getEarningListModel(
        pageUrl: finalUrl,
      );

      // Save next page URL
      nextPageUrlforEarningListModel(
        _earningListModel!.data!.earnings!.nextPageUrl ?? "",
      );

      // Reset list if not paginated
      if (!isPaginatHit) {
        earningListData.clear();
      }

      // Add earnings to list
      earningListData.addAll(_earningListModel!.data!.earnings!.data ?? []);

      print("@@@@@@@ Earning List Updated @@@@@@@");
    } on Failure catch (e) {
      isEarningListModelLoding(false);
      _setFailure(e);
    }

    isEarningListModelLoding(false);
    return _earningListModel!;
  }

  EarningDetailsModel? get earningDetailsModel => _earningDetailsModel;
  EarningDetailsModel? _earningDetailsModel;

  var isEarningDetailsModelLoding = false.obs;

  Future<EarningDetailsModel> fetchEarningDetailsModelData({
    required String earningId,
  }) async {
    try {
      isEarningDetailsModelLoding(true);
      _earningDetailsModel = await _webApiServices!.getEarningDetailsModel(
        earningId: earningId,
      );
    } on Failure catch (e) {
      isEarningDetailsModelLoding(false);
      _setFailure(e);
    }
    isEarningDetailsModelLoding(false);
    return _earningDetailsModel!;
  }

  UpdateNoteModel? get updateNoteModel => _updateNoteModel;
  UpdateNoteModel? _updateNoteModel;

  var isUpdateNoteModelLoding = false.obs;

  Future<UpdateNoteModel> fetchUpdateNoteData({
    required String sessionId,
    required String notes,
  }) async {
    try {
      isUpdateNoteModelLoding(true);
      _updateNoteModel = await _webApiServices!.getUpdateNoteModel(
        notes: notes,
        sessionId: sessionId,
      );
    } on Failure catch (e) {
      isUpdateNoteModelLoding(false);
      _setFailure(e);
    }
    isUpdateNoteModelLoding(false);
    return _updateNoteModel!;
  }

  UpdateNoteModel? getNoteModel;
  var isGetNoteModelLoading = false.obs;

  Future<UpdateNoteModel> fetchGetNoteData({required String sessionId}) async {
    try {
      isGetNoteModelLoading(true);
      getNoteModel = await _webApiServices!.getNotesModel(sessionId: sessionId);
    } on Failure catch (e) {
      isGetNoteModelLoading(false);
      _setFailure(e);
    }
    isGetNoteModelLoading(false);
    return getNoteModel!;
  }

  ProductListModel? get productListModel => _productListModel;
  ProductListModel? _productListModel;

  var isProductListModelLoding = false.obs;

  Future<ProductListModel> fetchProductListModeData({
    required String sessionId,
  }) async {
    try {
      isProductListModelLoding(true);
      _productListModel = await _webApiServices!.getProductListModel(
        sessionId: sessionId,
      );
    } on Failure catch (e) {
      isProductListModelLoding(false);
      _setFailure(e);
    }
    isProductListModelLoding(false);
    return _productListModel!;
  }

  // ignore: unused_field
  ProductListModel? _recommendProductModel;

  var isRecommendProductModelLoading = false.obs;

  Future<bool> fetchRecommendProductModelData({
    required String sessionId,
    required List<int> productIds,
  }) async {
    try {
      isRecommendProductModelLoading(true);
      _recommendProductModel = await _webApiServices!.getRecommendProductModel(
        productIds: productIds,
        sessionId: sessionId,
      );
    } on Failure catch (e) {
      isRecommendProductModelLoading(false);
      _setFailure(e);
    }
    isRecommendProductModelLoading(false);
    return true;
  }

  void _setFailure(Failure failure) {
    _failure = failure;
  }

  SessionChatModel? get sessionChatModel => _sessionChatModel;
  SessionChatModel? _sessionChatModel;

  var isSessionChatModelLoding = false.obs;

  Future<SessionChatModel> fetchSessionChatModelData({
    required String sessionId,
  }) async {
    try {
      isSessionChatModelLoding(true);
      _sessionChatModel = await _webApiServices!.getSessionChatModel(
        sessionId: sessionId,
      );
    } on Failure catch (e) {
      isSessionChatModelLoding(false);
      _setFailure(e);
    }
    isSessionChatModelLoding(false);
    return _sessionChatModel!;
  }

  ReviewListModel? get reviewListModel => _reviewListModel;
  ReviewListModel? _reviewListModel;

  var isReviewListModelLoding = false.obs;

  Future<ReviewListModel> fetchReviewListModelData() async {
    try {
      isReviewListModelLoding(true);
      _reviewListModel = await _webApiServices!.getReviewListModel();
    } on Failure catch (e) {
      isReviewListModelLoding(false);
      _setFailure(e);
    }
    isReviewListModelLoding(false);
    return _reviewListModel!;
  }

  var isEndingChat = false.obs;
  ApiResponse endChatResponse = ApiResponse();
  Future<ApiResponse> endChat({
    required int expertId,
    required int customerId,
    required int durationSeconds,
    String notes = "",
  }) async {
    try {
      isEndingChat(true);
      endChatResponse = await _webApiServices!.endChatAPI(
        expertId: expertId,
        customerId: customerId,
        durationSeconds: durationSeconds,
        notes: notes,
      );
    } on Failure catch (e) {
      isEndingChat(false);

      _setFailure(e);
    }
    isEndingChat(false);
    return endChatResponse;
  }

  SocketDetailsModel? get socketDetailsModel => _socketDetailsModel;
  SocketDetailsModel? _socketDetailsModel;

  var isSocketDetailsModelLoding = false.obs;

  Future<SocketDetailsModel> socketDetailsModelData() async {
    try {
      isSocketDetailsModelLoding(true);
      _socketDetailsModel = await _webApiServices!.getSocketDetailsModel();
    } on Failure catch (e) {
      isSocketDetailsModelLoding(false);
      _setFailure(e);
    }
    isSocketDetailsModelLoding(false);
    return _socketDetailsModel!;
  }

  SocketVerifyModel? get socketVerifyModel => _socketVerifyModel;
  SocketVerifyModel? _socketVerifyModel;

  var isSocketVerifyModelLoding = false.obs;

  Future<SocketVerifyModel> socketVerifyModelData({
    required String socketId,
    required String channelName,
  }) async {
    try {
      isSocketVerifyModelLoding(true);
      _socketVerifyModel = await _webApiServices!.getSocketVerifyModel(
        socketId: socketId,
        channelName: channelName,
      );
    } on Failure catch (e) {
      isSocketVerifyModelLoding(false);
      _setFailure(e);
    }
    isSocketVerifyModelLoding(false);
    return _socketVerifyModel!;
  }

  StartTimerChatModel? get startTimerChatModel => _startTimerChatModel;
  StartTimerChatModel? _startTimerChatModel;

  var isStartTimerChatModelLoding = false.obs;

  Future<StartTimerChatModel> startTimerChatModelData({
    required String sessionId,
    required String roomId,
  }) async {
    try {
      isStartTimerChatModelLoding(true);
      _startTimerChatModel = await _webApiServices!.getStartTimerChatModel(
        sessionId: sessionId,
        roomId: roomId,
      );
    } on Failure catch (e) {
      isStartTimerChatModelLoding(false);
      _setFailure(e);
    }
    isStartTimerChatModelLoding(false);
    return _startTimerChatModel!;
  }

  GetProfileModel? get expertOnOffModel => _expertOnOffModel;
  GetProfileModel? _expertOnOffModel;

  var isexpertOnOffModelLoding = false.obs;

  Future<GetProfileModel> expertOnOffModelData({
    required String available,
  }) async {
    try {
      isexpertOnOffModelLoding(true);
      _expertOnOffModel = await _webApiServices!.getExpertOnOffModel(
        available: available,
      );
    } on Failure catch (e) {
      isexpertOnOffModelLoding(false);
      _setFailure(e);
    }
    isexpertOnOffModelLoding(false);
    return _expertOnOffModel!;
  }

  CallerUserInfoModel? get userInfoModel => _userInfoModel;
  CallerUserInfoModel? _userInfoModel;

  var isuserInfoModelLoding = false.obs;

  Future<CallerUserInfoModel> userInfoModelData({
    required dynamic userId,
  }) async {
    try {
      isuserInfoModelLoding(true);
      _userInfoModel = await _webApiServices!.getuserInfoModel(userId: userId);
    } on Failure catch (e) {
      isuserInfoModelLoding(false);
      _setFailure(e);
    }
    isuserInfoModelLoding(false);
    return _userInfoModel!;
  }

  GetProfileModel? get callOnOffModel => _callOnOffModel;
  GetProfileModel? _callOnOffModel;

  var iscallOnOffModelLoding = false.obs;

  Future<GetProfileModel> callOnOffModelData({
    required String available,
  }) async {
    try {
      iscallOnOffModelLoding(true);
      _callOnOffModel = await _webApiServices!.getCallOnOffModel(
        available: available,
      );
    } on Failure catch (e) {
      iscallOnOffModelLoding(false);
      _setFailure(e);
    }
    iscallOnOffModelLoding(false);
    return _callOnOffModel!;
  }

  GetProfileModel? get chatOnOffModel => _chatOnOffModel;
  GetProfileModel? _chatOnOffModel;

  var ischatOnOffModelLoding = false.obs;

  Future<GetProfileModel> chatOnOffModelData({
    required String available,
  }) async {
    try {
      ischatOnOffModelLoding(true);
      _chatOnOffModel = await _webApiServices!.getChatOnOffModel(
        available: available,
      );
    } on Failure catch (e) {
      ischatOnOffModelLoding(false);
      _setFailure(e);
    }
    ischatOnOffModelLoding(false);
    return _chatOnOffModel!;
  }
}
