import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:powerwall_booster_beta/viewmodel/setting_viewmodel.dart';
import 'package:powerwall_booster_beta/utils/date_utils.dart' as pw_date_utils;
import 'package:powerwall_booster_beta/view/welcome_screen.dart';
import 'package:powerwall_booster_beta/model/token_provider.dart';

// カラー設定
const Color kAccentColor = Color.fromARGB(255, 32, 169, 27);
const Color kBackgroundColor = Color.fromARGB(255, 0, 0, 0);
const Color kTextColorPrimary = Color(0xFFECEFF1);
const Color kTextColorSecondary = Color(0xFFB0BEC5);
const Color kButtonColorPrimary = Color(0xFFECEFF1);
const Color kButtonTextColorPrimary = Color(0xFF455A64);
const Color kIconColor = Color(0xFF455A64);

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingViewModel(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          bottomOpacity: 0.0,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        body: Consumer<SettingViewModel>(
          builder: (context, viewModel, child) {
            final DateTime minDateTime = DateTime.now();
            final DateTime maxDateTime = minDateTime.add(Duration(days: 14));
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/PW.png',
                    width: 350,
                    height: 450,
                  ),
                  _buildBackupLevelSW(context, viewModel),
                  _buildBackupLevelSL(viewModel),
                  _buildBackupLevelT(
                      context, viewModel, minDateTime, maxDateTime),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // スイッチ
  Widget _buildBackupLevelSW(BuildContext context, SettingViewModel viewModel) {
    final accessToken = context.watch<TokenProvider>().accessToken;
    return ListTile(
      title: Text(
        'バックアップ蓄電率（始）',
        style: TextStyle(
          color: Color.fromARGB(255, 237, 210, 8),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: CupertinoSwitch(
        value: viewModel.switchValue,
        onChanged: (newValue) {
          viewModel.updateSwitchValue(newValue, context);
        },
      ),
    );
  }

  // 蓄電率スライダー
  Widget _buildBackupLevelSL(SettingViewModel viewModel) {
    double maxSliderValue = 100;
    int divisions = (maxSliderValue / 5).round(); // 5% increments

    return Column(
      children: [
        Slider(
          value: viewModel.backupReservePercent,
          min: 0,
          max: maxSliderValue,
          divisions: divisions,
          onChanged: (double value) {
            viewModel.updateBackupReservePercent(value);
          },
          activeColor: Colors.white,
          inactiveColor: Colors.grey,
        ),
        Text(
          '${viewModel.backupReservePercent.toInt()}%',
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  // DateTimePicker
  Widget _buildBackupLevelT(BuildContext context, SettingViewModel viewModel,
      DateTime minDateTime, DateTime maxDateTime) {
    return ListTile(
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              pw_date_utils.DateUtils.showDateTimePicker(
                context,
                viewModel.selectedDateTime,
                maxDateTime,
                (date) {
                  viewModel.updateSelectedDateTime(date);
                },
              );
            },
            child: Row(
              children: [
                Text(
                  pw_date_utils.DateUtils.formattedDateTime(
                      viewModel.selectedDateTime),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
            style: TextButton.styleFrom(
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
            ),
          ),
        ],
      ),
    );
  }
}
