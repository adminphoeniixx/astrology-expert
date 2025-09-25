// ignore_for_file: constant_identifier_names
const String http = "http";
const String https = "https";
const String GetDomainUrl = "/api/expert/";
const String GetDomainUrl2 = "/api/";

const String UPIGateway = "/upi/";
const String GetBaseUrl = "https://vedamroots.com";
const String CART_KEY = "4e10a25f22210f4d4001bce18306f59e/";
const String SIGN_UP = "register";
const String GET_USER = "get-user";
const String LOGIN = "login";
const String VERIFY_OTP = "verify-otp";
const String RESEND_OTP = "resend-otp";
const String GET_STATE = "get-states";
const String SEND_OTP = "send-otp";
const String EDIT_PROFILE = "edit-profile";
const String NEW_PASSWORD = "new-password";
const String GET_CHART = "get-chart";
const String GET_HOME = "home";
const String LOGIN_WITH_OTP = "send-otp";
const String VERIFY_LOGIN_WITH_OTP = "verify-login";
const String NEW_REGISTER = "newregister";
const String SERVICE_DETAILS = "service-details";
const String PRDUCTS = "products";
const String SERVICEORDERPLACED = "service/order/create";
const String PRDUCTS_DETAILS = "product-details";
const String SERVICE_TYPE = "service-types";
const String GET_EXPERTS = "get-experts";
const String GET_SLOTS = "get-slots";
const String CONFORM_ORDER = "service/order/confirm";
const String UPPCOMMING_SESSIONS = "sessions/upcomming/get";
const String JOIN_SESSION = "sessions/upcomming/join";
const String JOIN_AUDIO_SESSION = "sessions/audio/get";
const String JOIN_CHAT_SESSION = "sessions/chat/join";
const String GET_AUDIO_TIME = "get-audio-times";
const String GET_LIVE_CHAT = "get-experts-list";

const String GET_ORDER_LIST = "service/order/get";

const String GET_USER_PROFILE = "expert-profile";
const String EDIT_USER_PROFILE = "editprofile";

const String TREDINF_VIDEO_GET = "treding/get";
const String PODCAST_VIDEO_GET = "podcast/get";
const String YOUTUBE_VIDEO_GET = "youtube/get";

const String COUPON_LIST = "coupons/get";
const String COUPON_APPLY = "service/order/apply-coupon";
const String COUPON_REMOVE = "service/order/remove-coupon";
const String GET_EXPERTS_LIST = "get-experts-list";

const String PRODUCT_ADDTO_CART = "product/cart/add";
const String PRODUCT_GET_CART = "product/cart/get";
const String PRODUCT_REMOVE_ITEM_FROM_CART = "product/cart/remove";
const String STORE_COUPON_APPLY = "product/order/apply-coupon";
const String STORE_COUPON_REMOVE = "product/order/remove-coupon";
const String PRODUCTORDERPLACED = "product/order/create";
const String PRODUCTORDERCONFORM = "product/order/confirm";
const String PRODUCT_CATEGORY = "get-categories";
const String GET_HOROSCOPE = "get-horoscope";
const String PRODUCT_SEARCH = "products-search";
const String UPLOAD_MEDIA_API = "upload-media-api";
const String ADDRESS_STORE = 'address/store';
const String ADDRESS_EDIT = 'address/edit';
const String ADDRESS_DELETE = 'address/remove';
const String GET_ADDRESS_STORE = 'address/get';
const String astroWalletBalance = "wallet/balance";
const String walletLegderList = "wallet/ledger";
const String createwallet = "wallet/order-create";
const String confirmwallet = "wallet/order-confirm";
const String GET_PRODUCTS_ORDER_DETAILS = 'product/order/get-details';
const String GET_SEVICES_ORDER_DETAILS = 'service/order/get-details';
const String chatfreeAstro = "free-chat-support";
const String supportChat = "customer-support-chat";
const String postReview = "review/store";
const String videoLike = "video/likes";
const String videoView = "video/view";
const String videoBanner = "content-banner";
const String likevideos = "get-likes-video";
const String savevideos = "get-saved-video";
const String commentVideo = "video/get-comment";
const String savedVideo = "video/saved-video";
const String comment = "video/save-comment";
const String allBanner = 'new-banner';
const String vastuForm = "vastu-form/store";
const String updateMentence = "maintenance/setting";
const String popUp = "pop-up";
const String sessionCheck = "sessions/check";
const String freeChatCheck = "free-chat-support/save-time";
const String callImageUpload = 'session-images';
const String serviceApplyWallet = 'service/order/apply-wallet';
const String serviceRemoveWallet = 'service/order/remove-wallet';
const String productApplyWallet = 'apply-wallet';
const String productRemoveWallet = 'remove-wallet';
const String deleteUserAccount = 'delete';
const String freeChat = 'get-experts-list-free-chat';
const String freeChatEmail = 'free-chat-email';
const String supportChatEmail = 'support-chat-email';

String astroProfileDetails({required int astroId}) {
  return "get-expert-profile/$astroId";
}

String reviewlist({required int astroId, required String orderType}) {
  return "review/get/$orderType/$astroId";
}

const int httpsCode_200 = 200;
const int httpsCode_201 = 201;
const int httpsCode_404 = 404;
const int httpsCode_401 = 401;
const int httpsCode_500 = 500;
const int httpsCode_502 = 502;
const int httpsCode_504 = 504;
