// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_bundle_js/payment.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Bundle JS',
//       home: const MyHomePage(title: 'Flutter Bundle JS'),
//       routes: {
//         '/WebViewExample': (context) => WebViewExample(),
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late WebViewController _controller;
//   final BUNDLE_URL =
//       'https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js';

//     final String htmlContent = '''
//     <html>
//     <body>
//       <h1>Hello from Flutter WebView!</h1>
//       <script>
//         window.addEventListener('message', (event) => {
//           console.log('Message received from Flutter: ', event.data);
//         });
//       </script>
//     </body>
//     </html>
//   ''';

//   @override
//   Widget build(BuildContext context) {

//     Future<void> _launchURL() async {
//       if (await canLaunch(BUNDLE_URL)) {
//         await launch(BUNDLE_URL);
//       } else {
//         throw 'Could not launch $BUNDLE_URL';
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(

//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

//         title: Text(widget.title),
//       ),
//       body: Center(

//         child: Column(

//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 60.0,
//               decoration: const BoxDecoration(
//                 color: Color.fromARGB(255, 241, 235, 179),
//               ),
//               child: const Center(

//                 child: Text('TEST Online Store',
//                     style: TextStyle(
//                         fontSize: 18)
//                     ),
//               ),
//             ),
//             const Divider(
//               color: Colors.grey, // Customize color
//               thickness: 1, // Line thickness
//             ),
//             const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Cart Items',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
//                 )),
//             const SizedBox(height: 20.0),
//             const Row(
//               children: [
//                 // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
//                 Text('Cup Set', style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(width: 10),
//                 Text('Rs 379')
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             const Row(
//               children: [
//                 // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
//                 Text('Speaker', style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(width: 10),
//                 Text('Rs 835')
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             Container(
//               height: 30,
//               decoration: const BoxDecoration(color: Colors.grey),
//               child: const Row(
//                 children: [
//                   Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(width: 10),
//                   Spacer(),
//                   Text('Rs 1214')
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 const Spacer(),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => WebViewExample()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Color.fromARGB(255, 255, 103, 15)),
//                   child: const Text(
//                     'Checkout',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }