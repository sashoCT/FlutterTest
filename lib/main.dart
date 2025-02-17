import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign global key to navigator
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  static const platform = MethodChannel('geochannel');
  String? ctId;
  PermissionStatus? alwaysLocationPermissionStatus;
  PermissionStatus? whenInUseLocationPermissionStatus;

  int _counter = 0;
  late CleverTapPlugin _clevertapPlugin;
  @override
  void initState() {
    print("initState");
    super.initState();
    _init();
    _incrementCounter();
    CleverTapPlugin.setDebugLevel(3);
    activateCleverTapFlutterPluginHandlers();
    CleverTapPlugin.registerForPush();
    //var initialUrl = CleverTapPlugin.getInitialUrl();
  }

  void activateCleverTapFlutterPluginHandlers() {
    _clevertapPlugin = CleverTapPlugin();
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);
  }

  void pushClickedPayloadReceived(Map<String, dynamic> notificationPayload) {
    print("pushClickedPayloadReceived called");
    print("on Push Click Payload = $notificationPayload");
    showAlert("Alert", "$notificationPayload");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _init();
    });
  }

  void _init() {
    _fetchCTId();
    _fetchLocationPermissionStatuses();
  }

  void showAlert(String title, String message) {
    showDialog(
      context: navigatorKey.currentContext!, // Use global key's context
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          if (ctId != null)
            ListTile(
                title: const Text('CleverTap Id'),
                subtitle: Text(ctId!),
                trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ctId!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Copied CleverTap Id to clipboard')));
                    })),
          if (whenInUseLocationPermissionStatus != null)
            ListTile(
                title: const Text('1. When In Use Location Permission Status'),
                subtitle: Text(whenInUseLocationPermissionStatus.toString()),
                trailing: whenInUseLocationPermissionStatus!.isGranted
                    ? null
                    : OutlinedButton(
                        onPressed: () => Permission.location.request(),
                        child: const Text('Request'))),
          if (whenInUseLocationPermissionStatus?.isGranted == true &&
              alwaysLocationPermissionStatus != null)
            ListTile(
                title: const Text('2. Always Location Permission Status'),
                subtitle: Text(alwaysLocationPermissionStatus.toString()),
                trailing: alwaysLocationPermissionStatus!.isGranted
                    ? null
                    : whenInUseLocationPermissionStatus?.isGranted == true
                        ? OutlinedButton(
                            onPressed: () =>
                                Permission.locationAlways.request(),
                            child: const Text('Request'))
                        : const Text('Grant When In Use First')),
          if (alwaysLocationPermissionStatus?.isGranted == true)
            Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('3. CleverTap GeofenceSDK',
                      style: Theme.of(context).textTheme.titleLarge),
                  OutlinedButton(
                      onPressed: _initGeofenceSDK,
                      child: const Text('Init & Trigger Location')),
                  OutlinedButton(
                      onPressed: _triggerLocation,
                      child: const Text('Trigger Location')),
                  OutlinedButton(
                      onPressed: _deactivateGeofenceSDK,
                      child: const Text('Deactivate')),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Future<void> _fetchCTId() async {
    final newId = await CleverTapPlugin.getCleverTapID();
    setState(() {
      ctId = newId;
    });
  }

  Future<void> _fetchLocationPermissionStatuses() async {
    final whenInUseStatus = await Permission.location.status;
    final alwaysStatus = await Permission.locationAlways.status;

    setState(() {
      whenInUseLocationPermissionStatus = whenInUseStatus;
      alwaysLocationPermissionStatus = alwaysStatus;
    });
  }

  Future<void> _initGeofenceSDK() async {
    await platform.invokeMethod('initGeofenceSDK');
  }

  Future<void> _deactivateGeofenceSDK() async {
    await platform.invokeMethod('deactivateGeofenceSDK');
  }

  Future<void> _triggerLocation() async {
    await platform.invokeMethod('triggerLocation');
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      CleverTapPlugin.recordEvent("Product Viewed", {});
      CleverTapPlugin.setDebugLevel(3);
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   // This method is rerun every time setState is called, for instance as done
  //   // by the _incrementCounter method above.
  //   //
  //   // The Flutter framework has been optimized to make rerunning build methods
  //   // fast, so that you can just rebuild anything that needs updating rather
  //   // than having to individually change instances of widgets.
  //   return Scaffold(
  //     appBar: AppBar(
  //       // TRY THIS: Try changing the color here to a specific color (to
  //       // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
  //       // change color while the other colors stay the same.
  //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //       // Here we take the value from the MyHomePage object that was created by
  //       // the App.build method, and use it to set our appbar title.
  //       title: Text(widget.title),
  //     ),
  //     body: Center(
  //       // Center is a layout widget. It takes a single child and positions it
  //       // in the middle of the parent.
  //       child: Column(
  //         // Column is also a layout widget. It takes a list of children and
  //         // arranges them vertically. By default, it sizes itself to fit its
  //         // children horizontally, and tries to be as tall as its parent.
  //         //
  //         // Column has various properties to control how it sizes itself and
  //         // how it positions its children. Here we use mainAxisAlignment to
  //         // center the children vertically; the main axis here is the vertical
  //         // axis because Columns are vertical (the cross axis would be
  //         // horizontal).
  //         //
  //         // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
  //         // action in the IDE, or press "p" in the console), to see the
  //         // wireframe for each widget.
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           const Text(
  //             'You have pushed the button this many times:',
  //           ),
  //           Text(
  //             '$_counter',
  //             style: Theme.of(context).textTheme.headlineMedium,
  //           ),
  //         ],
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: _incrementCounter,
  //       tooltip: 'Increment',
  //       child: const Icon(Icons.add),
  //     ), // This trailing comma makes auto-formatting nicer for build methods.
  //   );
  // }
}
