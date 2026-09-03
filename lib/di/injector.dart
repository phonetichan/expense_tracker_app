import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injector.config.dart';

final _getIt = GetIt.instance;

T inject<T extends Object>({
  String? instanceName,
  Type? type,
}) =>
    _getIt.get<T>(
      instanceName: instanceName,
      type: type,
    );

T register<T extends Object>(
    T instance, {
      String? instanceName,
    }) =>
    _getIt.registerSingleton<T>(
      instance,
      instanceName: instanceName,
    );

@InjectableInit()
Future<GetIt> configureDependencies() async => _getIt.init();
