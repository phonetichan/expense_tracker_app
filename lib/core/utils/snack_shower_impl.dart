import 'package:expense_tracker_app/main.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/snack_shower.dart';
import '../../presentation/utils/snackbar_utils.dart';

@LazySingleton(as: ISnackShower)
class SnackShowerImpl implements ISnackShower {
  @override
  void error({required String message}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      SnackBarUtils.showError(context, message);
    }
  }

  @override
  void info({required String message}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // SnackBarUtils doesn't have an 'info' specific style in your code yet, 
      // so we use showError or you can add showInfo to SnackBarUtils.
      SnackBarUtils.showError(context, message);
    }
  }

  @override
  void success({required String message}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      SnackBarUtils.showSuccess(context, message);
    }
  }
}
