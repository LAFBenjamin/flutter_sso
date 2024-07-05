import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class KeycloakAuth {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String clientId;
  final String redirectUrl;
  final String issuer;
  final List<String> scopes;

  KeycloakAuth({
    required this.clientId,
    required this.redirectUrl,
    required this.issuer,
    required this.scopes,
  });

  Future<TokenResponse?> authenticate(BuildContext context) async {
    final String initialUrl = '$issuer/protocol/openid-connect/auth'
        '?client_id=$clientId'
        '&redirect_uri=$redirectUrl'
        '&response_type=code'
        '&scope=${scopes.join(' ')}';

    final authorizationCode = await _showWebView(context, initialUrl);

    if (authorizationCode != null) {
      return _exchangeCodeForToken(authorizationCode);
    } else {
      return null;
    }
  }

  Future<String?> _showWebView(BuildContext context, String initialUrl) async {
    final Completer<String?> codeCompleter = Completer();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Login')),
          body: WebView(
            initialUrl: initialUrl,
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith(redirectUrl)) {
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];
                codeCompleter.complete(code);
                Navigator.of(context).pop();
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        ),
      ),
    );

    return codeCompleter.future;
  }

  Future<TokenResponse?> _exchangeCodeForToken(String authorizationCode) async {
    try {
      final TokenResponse? tokenResponse = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          authorizationCode: authorizationCode,
          issuer: issuer,
          scopes: scopes,
        ),
      );
      return tokenResponse;
    } catch (e) {
      print('Failed to exchange code for token: $e');
    }
  }
}
