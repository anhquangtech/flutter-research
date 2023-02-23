import 'package:flutter/material.dart';
import 'package:flutterresearch/notification/notification_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeLocalNotifications(debug: true);
  await NotificationController.initializeRemoteNotifications(debug: true);
  await NotificationController.getInitialNotificationAction();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notifController = NotificationController();

  // This widget is the root of your application.
  @override
  void initState() {
    notifController.checkPermission();
    notifController.requestFirebaseToken();
    notifController.startListeningNotificationEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final notifController = NotificationController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                notifController.localNotification();
              },
              child: const Icon(Icons.circle_notifications),
            ),
            ElevatedButton(
              onPressed: () {
                notifController.localDownload();
              },
              child: const Icon(Icons.download),
            ),
            ElevatedButton(
              onPressed: () {
                notifController.localMediaNotif();
              },
              child: const Icon(Icons.music_video),
            ),
          ],
        ),
      ),
    );
  }
}
