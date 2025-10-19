import 'package:get/get.dart';
import '../controller/chat_controller.dart';

class ChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
