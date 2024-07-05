import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';


class SimpleApp2 extends StatefulWidget {
  const SimpleApp2({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SimpleApp2> createState() => SimpleApp2State();
}


class SimpleApp2State extends State<SimpleApp2> {
  final cookieManager = WebviewCookieManager();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _setCookies();
  }

   Future<void> _setCookies() async {
    // Récupérer les cookies de la session
    final sessionCookie = await _secureStorage.read(key: 'session_cookie');
    final accestoken = await _secureStorage.read(key: 'access_token');
    final cookies = await cookieManager.getCookies('http://localhost:8080');
    print(cookies);
    if (sessionCookie != null) {
      /*await cookieManager.setCookies([
        Cookie('KEYCLOAK_IDENTITY_LEGACY', sessionCookie)
          ..domain = 'localhost'
          ..path = '/realms/emeria/'
          ..httpOnly = false
          ..secure = false
      ]);*/
    }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: WebView(
        initialUrl: 'http://localhost:8000',
        javascriptMode: JavascriptMode.unrestricted,
         onPageFinished: (url) async {
            final cookies = await cookieManager.getCookies('http://localhost:8000');
            for (var cookie in cookies) {
              print(cookie);
            }
          
         },
        onWebViewCreated: (WebViewController webViewController){
          _controller = webViewController;
        }
      )
        
        
    );
  }
}
