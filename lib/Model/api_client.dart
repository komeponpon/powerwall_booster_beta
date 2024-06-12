import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

//codeVerifierをもとにしたトークン取得処理
const _clientId = 'ownerapi';
const _redirectUri = 'https://auth.tesla.com/void/callback';

class TokenResponse {
  final String accessToken;

  TokenResponse({required this.accessToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
    );
  }
}

Future<TokenResponse> getToken(String code, String codeVerifier) async {
  final response = await http.post(
    Uri.https('auth.tesla.com', '/oauth2/v3/token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'grant_type': 'authorization_code',
      'client_id': _clientId,
      'code': code,
      'code_verifier': codeVerifier,
      'redirect_uri': _redirectUri,
    }),
  );

  if (response.statusCode == 200) {
    final jsonMap = json.decode(response.body);
    return TokenResponse.fromJson(jsonMap);
  } else {
    throw Exception(
        'Failed to get token. Server responded with status code: ${response.statusCode}, message: ${response.body}');
  }
}

//retrofitのインターフェースを定義
@RestApi(baseUrl: "https://owner-api.teslamotors.com")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/users/{id}")
  Future<User> getUser(@Path("id") int id);
}

class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
    );
  }
}
