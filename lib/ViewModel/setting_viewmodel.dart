import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:powerwall_booster_beta/model/token_provider.dart';
import 'package:powerwall_booster_beta/model/api_repository.dart';
import 'package:provider/provider.dart';

class SettingViewModel extends ChangeNotifier {
  bool switchValue = false;
  double backupReservePercent = 0.0;
  DateTime selectedDateTime = DateTime.now();
  Timer? _reserveTimer;

  void disposeTimer() {
    _reserveTimer?.cancel();
  }

  void updateSwitchValue(bool newValue, BuildContext context) async {
    switchValue = newValue;
    notifyListeners();

    if (newValue) {
      final now = DateTime.now();
      final accessToken = context.read<TokenProvider>().accessToken;

      if (selectedDateTime.isBefore(now) ||
          selectedDateTime.isAtSameMomentAs(now)) {
        await _handleBatteryReserveSetting(accessToken, context);
        switchValue = false;
        notifyListeners();
      } else {
        final duration = selectedDateTime.difference(now);
        _reserveTimer?.cancel();
        _reserveTimer = Timer(duration, () async {
          if (context.mounted) {
            await _handleBatteryReserveSetting(accessToken, context);
            switchValue = false;
            notifyListeners();
          }
        });
      }
    }
  }

  void updateBackupReservePercent(double value) {
    backupReservePercent = (value / 5).roundToDouble() * 5;
    notifyListeners();
  }

  void updateSelectedDateTime(DateTime date) {
    selectedDateTime = date;
    notifyListeners();
  }

  Future<void> _handleBatteryReserveSetting(
      String accessToken, BuildContext context) async {
    final apiRepository = ApiRepository.withOptions(
      baseUrl: 'https://owner-api.teslamotors.com',
      dioOptions: BaseOptions(
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    final authorization = 'Bearer $accessToken';

    try {
      final productsResponse = await apiRepository.getProducts(authorization);

      if (productsResponse.response.isNotEmpty) {
        final energySiteId = productsResponse.response[0].energySiteId;
        await apiRepository.setBatteryReserve(
          energySiteId,
          authorization,
          backupReservePercent.toInt(),
        );

        final siteInfoResponse =
            await apiRepository.getSiteInfo(energySiteId, authorization);
      } else {
        debugPrint('Response is empty');
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('DioException: ${e.message}, Response: ${e.response}');
      }
      debugPrint('APIの呼び出しエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('APIの呼び出しエラーが発生しました:$e'),
        ),
      );
    }
  }
}
