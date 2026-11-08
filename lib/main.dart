// ═════════════════════════════════════════════════════════════
//  main.dart - ETERNALTR4S WEB2APK
//  Universal WebView wrapper with config injection
// ═════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Map<String, dynamic> config = {
    'app_name': 'App',
    'target_url': 'https://example.com',
    'html_content': '',
    'control_id': '',
    'icon_url': '',
  };
  
  try {
    final configStr = await rootBundle.loadString('assets/config.json');
    config = jsonDecode(configStr);
  } catch (e) {
    debugPrint('Config load error: $e');
  }
  
  runApp(Web2ApkApp(config: config));
}

class Web2ApkApp extends StatelessWidget {
  final Map<String, dynamic> config;
  const Web2ApkApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config['app_name']?.toString() ?? 'App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: WebViewPage(config: config),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final Map<String, dynamic> config;
  const WebViewPage({super.key, required this.config});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      );

    _loadContent();
  }

  void _loadContent() {
    final html = widget.config['html_content']?.toString() ?? '';
    final url = widget.config['target_url']?.toString() ?? '';

    if (html.isNotEmpty) {
      _controller.loadHtmlString(html);
    } else if (url.isNotEmpty) {
      _controller.loadRequest(Uri.parse(url));
    } else {
      _controller.loadHtmlString(
        '<html><body style="background:#000;color:#fff;font-family:sans-serif;text-align:center;padding:50px;">'
        '<h1>Configuration Error</h1>'
        '<p>No URL or HTML content provided.</p>'
        '</body></html>',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (!_hasError)
              WebViewWidget(controller: _controller),
            if (_hasError)
              _buildErrorView(),
            if (_isLoading && !_hasError)
              _buildLoadingView(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF2D55),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Connection Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  _loadContent();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
