import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeritAd WebApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            // Thêm listener cho refresh
            controller.runJavaScript('''
              document.addEventListener('touchstart', function(e) {
                window.flutter_inappwebview.callHandler('onTouchStart', window.pageYOffset);
              });
              
              document.addEventListener('touchend', function(e) {
                window.flutter_inappwebview.callHandler('onTouchEnd', window.pageYOffset);
                if (window.pageYOffset < -50) {
                  location.reload();
                }
              });
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          // Xử lý điều hướng
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation to: ${request.url}');
            // Cho phép tất cả các điều hướng
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'refresh') {
            controller.reload();
          }
        },
      )
      ..loadRequest(
        Uri.parse('https://meritad.ng/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: true,
        bottom: false,
        left: false,
        right: false,
        child: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}