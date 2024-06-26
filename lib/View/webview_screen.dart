import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:powerwall_booster_beta/View/setting_screen.dart';
import 'package:powerwall_booster_beta/Model/api_client.dart';
import 'package:powerwall_booster_beta/model/token_provider.dart';

const _clientId = 'ownerapi';
const _redirectUri = 'https://auth.tesla.com/void/callback';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = false;
  bool isWebViewVisible = true;
  String codeVerifier = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              isLoading = false;
            });

            if (url.startsWith(_redirectUri)) {
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];
              if (code != null) {
                debugPrint('Authorization code: $code');
                try {
                  final token = await getToken(code, codeVerifier);
                  debugPrint('Access Token: ${token.accessToken}');

                  // アクセストークンをProviderにセット
                  context.read<TokenProvider>().accessToken = token.accessToken;

                  // WebViewを非表示にしてローディング画面を表示
                  setState(() {
                    isWebViewVisible = false;
                    isLoading = true;
                  });

                  // 画面遷移
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingScreen(),
                    ),
                  );

                  // 画面遷移後にトークンが正しくセットされていることを確認
                  debugPrint(
                      'Updated Access Token: ${Provider.of<TokenProvider>(context, listen: false).accessToken}');

                  // ローディング画面を非表示に
                  setState(() {
                    isLoading = false;
                  });
                } catch (e) {
                  debugPrint('Failed to get token: $e');
                  // WebViewを再表示してエラーメッセージを表示する
                  setState(() {
                    isWebViewVisible = true;
                    isLoading = false;
                  });
                }
              } else {
                debugPrint('Authorization failed');
              }
            }
          },
        ),
      );
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    codeVerifier = generateRandomString(86);
    final codeChallenge = generateCodeChallenge(codeVerifier);

    final url = Uri.https('auth.tesla.com', '/oauth2/v3/authorize', {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      isLoading = false;
    });

    _controller.loadRequest(Uri.parse(url.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (isLoading)
          LinearProgressIndicator(
            color: Colors.blueAccent,
          ),
        Expanded(
            child: isWebViewVisible ? _buildWebView() : _buildLoadingScreen()),
      ],
    );
  }

  Widget _buildWebView() {
    return WebViewWidget(controller: _controller);
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    final base64Url = base64UrlEncode(digest.bytes).replaceAll('=', '');
    return base64Url;
  }
}
