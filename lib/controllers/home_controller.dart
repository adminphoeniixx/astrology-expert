import 'dart:async';

import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/model/callerUserInfo_model.dart';
import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/model/partner_info_model.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/review_list_model.dart';
import 'package:astro_partner_app/model/seassion_chat_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/model/session_model.dart';
import 'package:astro_partner_app/model/socket_detail_model.dart';
import 'package:astro_partner_app/model/socket_verify_model.dart';
import 'package:astro_partner_app/model/start_timer_chat_model.dart';
import 'package:astro_partner_app/model/update_mentence_model.dart';
import 'package:astro_partner_app/model/update_note_model.dart';
import 'package:astro_partner_app/services/web_api_services.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/utils/request_failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static const int _firestoreWhereInLimit = 10;

  WebApiServices? _webApiServices;
  late int stateCode;
  late Failure _failure;
  Failure get failure => _failure;

  @override
  void onInit() {
    _webApiServices = WebApiServices();
    // getUpdateMentenceModelData();
    super.onInit();
  }

  SessionsModel? get mSessionsModel => _sessionsModel;
  SessionsModel? _sessionsModel;
  RxString nextPageUrl = "".obs;
  RxString nextPageUrlforCommingSession = "".obs;
  final List<SessionsData> _allSessionListData = <SessionsData>[];
  RxList<SessionsData> sessionListData = <SessionsData>[].obs;
  final Map<String, _FreeChatAiState> _freeChatAiStateByRoomId =
      <String, _FreeChatAiState>{};
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _freeChatSessionSubscriptions =
      <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
  bool _pendingSessionRefresh = false;
  int _sessionFetchVersion = 0;
  String _lastSessionServiceType = "all";
  var isSessionsModelLoding = false.obs;
  var isSessionPaginationLoading = false.obs;

  UpdateMentenceModel? _updateMentenceModel;

  UpdateMentenceModel? get mUpdateMentenceModel => _updateMentenceModel;

  var isUpdateMentenceModelLoding = false.obs;

  Future<UpdateMentenceModel?> getUpdateMentenceModelData() async {
    try {
      isUpdateMentenceModelLoding(true);
      _updateMentenceModel = await _webApiServices!.getUpdateMentenceModelApi();
      isUpdateMentenceModelLoding(false);
      return _updateMentenceModel;
    } on Failure catch (e) {
      isUpdateMentenceModelLoding(false);
      _setFailure(e);
      return null;
    }
  }

  Future<SessionsModel> fetchSessionData({
    String? pageUrl,
    bool isPaginatHit = false,
    String? serviceType, // 🔹 String instead of int
  }) async {
    if (isPaginatHit && isSessionPaginationLoading.value) {
      return _sessionsModel ?? SessionsModel();
    }
    if (!isPaginatHit && isSessionsModelLoding.value) {
      _pendingSessionRefresh = true;
      return _sessionsModel ?? SessionsModel();
    }
    if (!isPaginatHit) {
      _lastSessionServiceType = serviceType ?? _lastSessionServiceType;
    }
    final fetchVersion = ++_sessionFetchVersion;
    try {
      if (isPaginatHit) {
        isSessionPaginationLoading(true);
      } else {
        isSessionsModelLoding(true);
        _freeChatAiStateByRoomId.clear();
      }
      final String finalUrl =
          pageUrl ??
          "${GetBaseUrl + GetDomainUrl}sessions${serviceType != null ? "?service_type=$serviceType" : ""}";
      print("!!!!!!!!!!!!!!!!!!!!pageUrl!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(finalUrl);
      print("!!!!!!!!!!!!!!!!!!!!pageUrl!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      _sessionsModel = await _webApiServices!.getSessionsModel(
        pageUrl: finalUrl,
      );
      final sessions = _sessionsModel?.data?.sessions;
      nextPageUrl(sessions?.nextPageUrl?.toString() ?? "");
      if (!isPaginatHit) {
        _allSessionListData.clear();
        sessionListData.clear();
      }
      _allSessionListData.addAll(sessions?.data ?? <SessionsData>[]);
      _applyFreeChatAiFilter();
      _syncFreeChatAiStatusForSessions(fetchVersion);
      print("@@@@@@@CC@@@@@@@@");
    } on Failure catch (e) {
      _setFailure(e);
    } catch (e) {
      print("fetchSessionData error: $e");
    } finally {
      if (isPaginatHit) {
        isSessionPaginationLoading(false);
      } else {
        isSessionsModelLoding(false);
        if (_pendingSessionRefresh) {
          _pendingSessionRefresh = false;
          Future.microtask(() {
            fetchSessionData(serviceType: _lastSessionServiceType);
          });
        }
      }
    }
    return _sessionsModel ?? SessionsModel();
  }

  bool isFreeChatAiActive(String roomId) {
    return _freeChatAiStateByRoomId[roomId]?.isAiActive == true;
  }

  Future<bool> canExpertOpenFreeChat(String roomId, {String? sessionId}) async {
    if (roomId.isEmpty) return true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('free_chat_session')
          .doc(roomId)
          .get();

      final data = snapshot.data();
      final aiState = _freeChatAiStateFromData(data);
      _freeChatAiStateByRoomId[roomId] = aiState;
      _applyFreeChatAiFilter();
      if (!aiState.isAiActive) return true;
      return !_matchesSessionId(aiState.sessionId, sessionId);
    } catch (_) {
      return true;
    }
  }

  Future<void> _loadFreeChatAiStatusForSessions() async {
    final roomIds = _freeChatRoomIdsFromSessions();
    if (roomIds.isEmpty) return;

    for (var i = 0; i < roomIds.length; i += _firestoreWhereInLimit) {
      final chunk = roomIds.sublist(
        i,
        (i + _firestoreWhereInLimit) > roomIds.length
            ? roomIds.length
            : i + _firestoreWhereInLimit,
      );

      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('free_chat_session')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        final seenRoomIds = <String>{};

        for (final doc in snapshot.docs) {
          seenRoomIds.add(doc.id);
          _freeChatAiStateByRoomId[doc.id] = _freeChatAiStateFromData(
            doc.data(),
          );
        }

        for (final roomId in chunk) {
          if (!seenRoomIds.contains(roomId)) {
            _freeChatAiStateByRoomId[roomId] = _FreeChatAiState.inactive();
          }
        }
      } catch (_) {
        for (final roomId in chunk) {
          _freeChatAiStateByRoomId[roomId] = _FreeChatAiState.inactive();
        }
      }
    }
  }

  Future<void> _syncFreeChatAiStatusForSessions(int fetchVersion) async {
    await _loadFreeChatAiStatusForSessions();
    if (fetchVersion != _sessionFetchVersion) return;
    _listenToFreeChatAiStatusForSessions(fetchVersion);
    _applyFreeChatAiFilter();
  }

  void _listenToFreeChatAiStatusForSessions(int fetchVersion) {
    for (final subscription in _freeChatSessionSubscriptions) {
      subscription.cancel();
    }
    _freeChatSessionSubscriptions.clear();

    final roomIds = _freeChatRoomIdsFromSessions();

    if (roomIds.isEmpty) return;

    for (var i = 0; i < roomIds.length; i += _firestoreWhereInLimit) {
      final chunk = roomIds.sublist(
        i,
        (i + _firestoreWhereInLimit) > roomIds.length
            ? roomIds.length
            : i + _firestoreWhereInLimit,
      );

      final subscription = FirebaseFirestore.instance
          .collection('free_chat_session')
          .where(FieldPath.documentId, whereIn: chunk)
          .snapshots()
          .listen(
            (snapshot) {
              if (fetchVersion != _sessionFetchVersion) return;
              final seenRoomIds = <String>{};

              for (final doc in snapshot.docs) {
                seenRoomIds.add(doc.id);
                _freeChatAiStateByRoomId[doc.id] = _freeChatAiStateFromData(
                  doc.data(),
                );
              }

              for (final roomId in chunk) {
                if (!seenRoomIds.contains(roomId)) {
                  _freeChatAiStateByRoomId[roomId] =
                      _FreeChatAiState.inactive();
                }
              }

              _applyFreeChatAiFilter();
            },
            onError: (_) {
              if (fetchVersion != _sessionFetchVersion) return;
              for (final roomId in chunk) {
                _freeChatAiStateByRoomId[roomId] = _FreeChatAiState.inactive();
              }
              _applyFreeChatAiFilter();
            },
          );

      _freeChatSessionSubscriptions.add(subscription);
    }
  }

  List<String> _freeChatRoomIdsFromSessions() {
    return _allSessionListData
        .where(_isFreeChatSession)
        .map((session) => session.roomId?.toString() ?? "")
        .where((roomId) => roomId.isNotEmpty)
        .toSet()
        .toList();
  }

  bool _isFreeChatSession(SessionsData session) {
    return session.serviceType?.toString() == "1";
  }

  _FreeChatAiState _freeChatAiStateFromData(Map<String, dynamic>? data) {
    if (data == null) return _FreeChatAiState.inactive();
    return _FreeChatAiState(
      isAiActive: data['ai_active'] == true,
      sessionId: data['session_id']?.toString(),
    );
  }

  bool _matchesSessionId(String? firestoreSessionId, String? apiSessionId) {
    if (firestoreSessionId == null || firestoreSessionId.isEmpty) return false;
    if (apiSessionId == null || apiSessionId.isEmpty) return false;
    return firestoreSessionId == apiSessionId;
  }

  void _applyFreeChatAiFilter() {
    final visibleSessions = <SessionsData>[];

    for (final session in _allSessionListData) {
      if (!_isFreeChatSession(session)) {
        visibleSessions.add(session);
        continue;
      }

      final roomId = session.roomId?.toString() ?? "";
      if (roomId.isEmpty) {
        visibleSessions.add(session);
        continue;
      }

      visibleSessions.add(session);
    }

    sessionListData.assignAll(visibleSessions);
  }

  @override
  void onClose() {
    for (final subscription in _freeChatSessionSubscriptions) {
      subscription.cancel();
    }
    super.onClose();
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

  ParterInfoModel? get parterInfoModel => _parterInfoModel;
  ParterInfoModel? _parterInfoModel;

  var isParterInfoModelLoding = false.obs;

  Future<ParterInfoModel> parterInfoModelData({
    required dynamic userId2,
  }) async {
    try {
      isParterInfoModelLoding(true);
      _parterInfoModel = await _webApiServices!.getParterInfoModel(
        userId2: userId2,
      );
    } on Failure catch (e) {
      isParterInfoModelLoding(false);
      _setFailure(e);
    }
    isParterInfoModelLoding(false);
    return _parterInfoModel!;
  }
}

class _FreeChatAiState {
  final bool isAiActive;
  final String? sessionId;

  const _FreeChatAiState({required this.isAiActive, this.sessionId});

  factory _FreeChatAiState.inactive() {
    return const _FreeChatAiState(isAiActive: false);
  }
}
