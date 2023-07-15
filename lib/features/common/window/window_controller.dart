import 'package:flutter/material.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

part 'window_controller.g.dart';

// TODO improve
@Riverpod(keepAlive: true)
class WindowController extends _$WindowController
    with WindowListener, AppLogger {
  @override
  Future<bool> build() async {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(868, 768),
      minimumSize: Size(868, 648),
      center: true,
    );
    await windowManager.setPreventClose(true);
    await windowManager.waitUntilReadyToShow(
      windowOptions,
      () async {
        if (ref.read(prefsControllerProvider).general.silentStart) {
          loggy.debug("silent start is enabled, hiding window");
          await windowManager.hide();
        }
      },
    );
    windowManager.addListener(this);

    ref.onDispose(() {
      loggy.debug("disposing");
      windowManager.removeListener(this);
    });
    return windowManager.isVisible();
  }

  Future<void> show() async {
    await windowManager.show();
    state = const AsyncData(true);
  }

  Future<void> hide() async {
    await windowManager.close();
  }

  @override
  Future<void> onWindowClose() async {
    await windowManager.hide();
    state = const AsyncData(false);
  }
}
