import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    const MaterialApp(
      home: WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {

  late WebViewController _webViewController;
  final _cookieManager = CookieManager();
  final url = 'https://www.google.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        onProgress: (int progress) {
          print('WebView is loading (progress : $progress%)');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          // 取得cookie
          var cookies = await _webViewController.runJavascriptReturningResult(
            'document.cookie',
          );
          print("Old cookies: ${cookies}");
          /*
          // 方法一：利用JS設定新的 cookie
          await _webViewController.runJavascriptReturningResult(
            'document.cookie = "Cookie_New=value1; expires=Thu, 01 Jan 2023 00:00:00 UTC; domain=.google.com; path=/;"',
          );
          // 查看cookies是否設定成功
          cookies = await _webViewController.runJavascriptReturningResult(
            'document.cookie',
          );
          print("New cookies 1: ${cookies}");
          */

          // 方法二：利用CookieManager設置新的 cookie
          await _cookieManager.setCookie(
            const WebViewCookie(
              name: "Cookie_New",
              value: "value2",
              domain: ".google.com",
            ),
          );
          // 查看cookies是否設定成功
          cookies = await _webViewController.runJavascriptReturningResult(
            'document.cookie',
          );
          print("New cookies 2: ${cookies}");

          // 刪除特定的 cookie，利用設置cookie過期日期
          await _webViewController.runJavascriptReturningResult(
            'document.cookie = "Cookie_New=; expires=Thu, 01 Jan 1970 00:00:00 UTC; domain=.google.com; path=/;"',
          );

          // 查看cookies是否刪除成功
          cookies = await _webViewController.runJavascriptReturningResult(
            'document.cookie',
          );
          print("New cookies 3: ${cookies}");
        },

        child: const Icon(Icons.web_rounded),
      ),
    );
  }
}