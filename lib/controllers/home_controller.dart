import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/review_list_model.dart';
import 'package:astro_partner_app/model/seassion_chat_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/model/session_model.dart';
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
}
