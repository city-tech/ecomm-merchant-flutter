import 'package:flutter/material.dart';
import 'package:flutter_bundle_js/payment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bundle JS',
      home: const MyHomePage(title: 'Flutter Bundle JS'),
      routes: {
        '/WebViewExample': (context) => WebViewExample(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _controller;
  final BUNDLE_URL =
      'https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    Future<void> _launchURL() async {
      if (await canLaunch(BUNDLE_URL)) {
        await launch(BUNDLE_URL);
      } else {
        throw 'Could not launch $BUNDLE_URL';
      }
    }

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60.0,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 241, 235, 179),
              ),
              child: const Center(
                // Wrap the Text with Center
                child: Text('TEST Online Store',
                    style: TextStyle(
                        fontSize: 18) // Optional: You can set text styling here
                    ),
              ),
            ),
            const Divider(
              color: Colors.grey, // Customize color
              thickness: 1, // Line thickness
            ),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cart Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                )),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
                Text('Cup Set', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('Rs 379')
              ],
            ),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
                Text('Speaker', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('Rs 835')
              ],
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 30,
              decoration: const BoxDecoration(color: Colors.grey),
              child: const Row(
                children: [
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Spacer(),
                  Text('Rs 1214')
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WebViewExample()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 103, 15)),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
