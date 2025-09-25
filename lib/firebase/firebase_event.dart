import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseProvider {
  late FirebaseAnalytics _analytics;

  FirebaseProvider.initializer() {
    _analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver(analytics: _analytics);
  }

  Future<void> registerButtonClicked({
    required String name,
  }) async {
    await _analytics.logEvent(
      name: 'register_button_clicked',
      parameters: <String, Object>{
        'Name': name,
      },
    );
  }

  Future<void> loginButtonClicked({required String email}) async {
    await _analytics.logEvent(
      name: 'login_button_clicked',
      parameters: <String, Object>{
        'Email': email,
      },
    );
  }

  Future<void> passwordResetClicked({required int userId}) async {
    await _analytics.logEvent(
      name: 'password_reset_clicked',
      parameters: <String, Object>{
        'user_id': userId,
      },
    );
  }

  Future<void> otpButtonClicked({required String mobile}) async {
    await _analytics.logEvent(
      name: 'otp_button_clicked',
      parameters: <String, Object>{
        'Mobile': mobile,
      },
    );
  }

  Future<void> otpVerified() async {
    await _analytics.logEvent(
      name: 'otp_verified',
      parameters: <String, Object>{
        'status': "verified",
      },
    );
  }

  Future<void> shareWithFriends(
      {required String link, required int userId}) async {
    await _analytics.logEvent(
      name: 'share_with_friend',
      parameters: <String, Object>{'link': link, "user_id": userId},
    );
  }

  Future<void> signOut({required int userId}) async {
    await _analytics.logEvent(
      name: 'user_sign_Out',
      parameters: <String, Object>{
        'userId': userId,
      },
    );
  }
}

class FirebaseService {
  Future<void> firebaseSocketException(
      {dynamic apiCall, dynamic userId, dynamic message, dynamic email}) async {
    await FirebaseCrashlytics.instance.recordError(
        "ApiCall:- $apiCall, UserId:- $userId, UserEmail:- $email", null,
        reason: "firebaseSocketException:- $message", fatal: false);
  }

  Future<void> firebaseFormatException(
      {dynamic apiCall, dynamic userId, dynamic message, dynamic email}) async {
    await FirebaseCrashlytics.instance.recordError(
        "ApiCall:- $apiCall, UserId:- $userId, UserEmail:- $email", null,
        reason: "firebaseFormatException:- $message", fatal: false);
  }

  Future<void> firebaseHttpException(
      {dynamic apiCall, dynamic userId, dynamic message, dynamic email}) async {
    await FirebaseCrashlytics.instance.recordError(
        "ApiCall:- $apiCall, UserId:- $userId, UserEmail:- $email", null,
        reason: "firebaseHttpException:- $message", fatal: false);
  }

  Future<void> firebaseDioError(
      {dynamic apiCall,
      dynamic userId,
      dynamic message,
      dynamic code,
      dynamic email}) async {
    await FirebaseCrashlytics.instance.recordError(
        "ApiCall:- $apiCall, UserId:- $userId, UserEmail:- $email", null,
        reason: "firebaseDioError:- $message", fatal: false);
  }

  Future<void> firebaseJsonError(
      {dynamic apiCall,
      dynamic userId,
      dynamic message,
      dynamic stackTrace}) async {
    await FirebaseCrashlytics.instance.recordError(
        "ApiCall:- $apiCall, UserId:- $userId,", stackTrace,
        reason: "firebaseDioError:- $message", fatal: false);
  }
}
