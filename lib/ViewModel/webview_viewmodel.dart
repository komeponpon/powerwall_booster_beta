//リファクタリング用

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:powerwall_booster_beta/View/setting_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:powerwall_booster_beta/model/token_provider.dart';
import 'package:powerwall_booster_beta/model/api_client.dart';
import 'package:powerwall_booster_beta/utils/crypto_utils.dart';

const _clientId = 'ownerapi';
const _redirectUri = 'https://auth.tesla.com/void/callback';

class WebViewViewModel extends ChangeNotifier {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = false;
  String codeVerifier = '';
  String initialUrl = '';
  BuildContext? context; // Add this line

  WebViewController? get webViewController =>
      _controller.isCompleted ? _controller.future as WebViewController : null;

  Future<void> loadUrl(BuildContext context) async {
    this.context = context; // Add this line
    codeVerifier = CryptoUtils.generateRandomString(86);
    final codeChallenge = CryptoUtils.generateCodeChallenge(codeVerifier);

    final url = Uri.https('auth.tesla.com', '/oauth2/v3/authorize', {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500));

    isLoading = false;
    notifyListeners();

    initialUrl = url.toString();
  }

  Future<void> handleAuthorizationCode(
      BuildContext context, String code) async {
    try {
      final token = await getToken(code, codeVerifier);
      context.read<TokenProvider>().accessToken = token.accessToken;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Failed to get token: $e');
    }
  }

  void setController(WebViewController controller) {
    _controller.complete(controller);
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
