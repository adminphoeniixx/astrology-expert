enum ViewState { idle, busy }

enum HistoryFor { wallet, transaction, withdraw }

enum ValidationFor { login, signUp, mobile }

enum PaymentStatus { initiated, started, closed, idle }

enum OtpFor { login, signUp, forgotPassword, email }

enum RequestStatus {
  initial,
  loading,
  loaded,
  unauthorized,
  server,
  network,
  failure
}

enum ResponseStatus { unauthorized, server, network, failed }

enum UserStatus { unauthorized, authorized, processing }

enum AppStatus { update, maintenance, running }

enum ErrorAnimationType { shake }
