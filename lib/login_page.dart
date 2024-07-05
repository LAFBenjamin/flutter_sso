import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sso/keyckloakAuthWrapper/keycloak_auth_wrapper.dart';
import 'package:flutter_sso/my_home_page.dart';
import 'package:flutter_sso/simple_app_inapp_2.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

import 'simple_app_2.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final String _clientId = 'mobile';
  final String _redirectUrl = 'myapp://callback';
  final String _issuer = 'http://localhost:8080//realms/emeria';
  final String _discoveryUrl = 'http://localhost:8080/realms/emeria/.well-known/openid-configuration';
  final List<String> _scopes = ['openid', 'profile', 'email'];

  

  String? _username;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Keycloak Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_username != null) Text('Bonjour $_username'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login with Keycloak'),
            ),
            ElevatedButton(
              onPressed: () async {
                await loginWebView(context);
              },
              child: Text('Login Keycloak webview'),
            ),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'Simple app 1')),
                );
              },
              child: Text('Open WebView'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SimpleApp2(title: 'simple app 2')),
                );
              },
              child: Text('Open simple app 2'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SimpleAppInApp2(title: 'simple app 2')),
                );
              },
              child: Text('Open simple app 2 inappwebview'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginWebView(BuildContext context) async {
    final KeycloakAuth keycloakAuth = KeycloakAuth(
      clientId: _clientId,
      redirectUrl: _redirectUrl,
      issuer: _issuer,
      scopes: _scopes,
    );
    final tokenResponse = await keycloakAuth.authenticate(context);
      if (tokenResponse != null) {
        print('Access Token: ${tokenResponse.accessToken}');
        print('Refresh Token: ${tokenResponse.refreshToken}');

        final idToken = _parseIdToken(tokenResponse.idToken!);
        setState(() {
          _username = idToken['preferred_username'];
        });
      } else {
        print('Authentication failed');
      }
  }

  Future<void> _login() async {
    try {
      AuthorizationTokenResponse? result = await autorizeAndExchangeCode();
      if (result != null) {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken);
        
        print(result.accessToken);
        final idToken = _parseIdToken(result.idToken!);
        setState(() {
          _username = idToken['preferred_username'];
        });
      }
    } catch (e) {
      print('Login failed: $e');
    }
  }

  Future<AuthorizationTokenResponse?> autorizeAndExchangeCode() async {
    final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        _clientId,
        _redirectUrl,
        discoveryUrl: _discoveryUrl,
        scopes: _scopes,
      ),
    );
    return result;
  }
}


Map<String, dynamic> _parseIdToken(String idToken) {
    final parts = idToken.split('.');
    assert(parts.length == 3);

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid ID token');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }

