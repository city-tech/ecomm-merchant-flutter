import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class SuccessPage extends StatefulWidget {
  final String token;

  const SuccessPage({Key? key, required this.token}) : super(key: key);

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  Map<String, dynamic> decodedToken = {};
  Map<String, dynamic>? transactionStatus;
  String? tokenError;
  String? apiError;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeTokenAndFetchStatus();
  }

  Future<void> _decodeTokenAndFetchStatus() async {
    try {
      // Decode Base64 token
      final decoded = utf8.decode(base64.decode(widget.token));
      final tokenInfo = jsonDecode(decoded) as Map<String, dynamic>;
      setState(() {
        decodedToken = tokenInfo;
      });

      final id = tokenInfo['id'] as String?;
      if (id == null || id.isEmpty) {
        setState(() {
          tokenError = 'Token does not contain an "id" field.';
          isLoading = false;
        });
        return;
      }

      // POST to merchant-status API
      final url = Uri.parse('${Constants.EXPO_PUBLIC_BASE_URL}/merchant-status');
      log('Calling merchant-status API: $url with id: $id');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      log('merchant-status response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          transactionStatus = jsonDecode(response.body) as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          apiError = 'API error ${response.statusCode}: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        tokenError = 'Failed to decode token or fetch status: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your payment has been processed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
              ),
              const SizedBox(height: 32),

              // Error from token decoding
              if (tokenError != null)
                Card(
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tokenError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              // Transaction Status from API
              if (transactionStatus != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 16),
                        ...transactionStatus!.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Flexible(
                                  child: Text(
                                    entry.value.toString(),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF4D4D4D)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // API error
              if (apiError != null)
                Card(
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      apiError!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5662FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Cart',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token copied to clipboard')),
                    );
                  },
                  child: const Text('Share Receipt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}