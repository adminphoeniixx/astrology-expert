import 'package:get/get.dart';

class LoaderController extends GetxController {
  bool _isApiCallProcess = false;
  bool get isApiCallProcess => _isApiCallProcess;
  @override
  void onInit() {
    setLoadingStatus(false);
    super.onInit();
  }
  setLoadingStatus(bool status) {
    _isApiCallProcess = status;
  }
}
