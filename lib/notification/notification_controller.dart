import 'dart:developer';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class NotificationController {
  static Future<void> initializeLocalNotifications(
      {required bool debug}) async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'alerts',
            channelName: 'Alerts',
            channelDescription: 'Notification tests as alerts',
            playSound: true,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
            defaultColor: Colors.deepPurple,
            ledColor: Colors.deepPurple,
          ),
        ],
        debug: debug);
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        // This license key is necessary only to remove the watermark for
        // push notifications in release mode. To know more about it, please
        // visit http://awesome-notifications.carda.me#prices
        licenseKeys: null,
        debug: debug);
  }

  Future<void> localNotification() async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'alerts',
          title: 'Emojis are awesome too! ' +
              Emojis.activites_admission_tickets +
              Emojis.activites_balloon +
              Emojis.emotion_red_heart,
          body: "Emojis awesome body",
          bigPicture:
              'https://images.pexels.com/photos/14679216/pexels-photo-14679216.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
          notificationLayout: NotificationLayout.BigPicture,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'REPLY',
            label: 'Reply Message',
            requireInputText: true,
            actionType: ActionType.SilentAction,
          ),
        ]);
  }

  Future<void> localDownload() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'alerts',
        title: 'Downloading...',
        bigPicture:
            'https://images.pexels.com/photos/14679216/pexels-photo-14679216.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        notificationLayout: NotificationLayout.ProgressBar,
      ),
    );
  }

  Future<void> localMediaNotif() async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'alerts',
          title: 'Đã sai từ lúc đầu',
          body: "Bùi Anh Tuấn ft Trung Quân",
          notificationLayout: NotificationLayout.MediaPlayer,
          summary: 'Now playing',
          largeIcon:
              'https://avatar-ex-swe.nixcdn.com/song/2022/08/16/f/3/3/4/1660622960262_640.jpg',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MEDIA_PREV',
            icon: 'resource://drawable/previous',
            label: 'Previous',
            showInCompactView: false,
            enabled: true,
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'MEDIA_PAUSE',
            icon: 'resource://drawable/pause',
            label: 'Pause',
            showInCompactView: false,
            enabled: true,
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'MEDIA_NEXT',
            icon: 'resource://drawable/next',
            label: 'Next',
            showInCompactView: false,
            enabled: true,
            actionType: ActionType.SilentAction,
          ),
        ]);
  }

  Future<void> checkPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print("starting long task");
    await Future.delayed(Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    print("long task done");
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    // debugPrint('FCM Token:"$token"');
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    // debugPrint('Native Token:"$token"');
  }

  //! Get firebase token
  Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        final token = await AwesomeNotificationsFcm().requestFirebaseAppToken();
        if (kDebugMode) {
          print('==================FCM Token==================');
          print(token);
          print('======================================');
        }
        return token;
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }

  //! Listen notification
  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (receivedAction == null) return;

    EasyLoading.showToast("getInitialNotificationAction",
        toastPosition: EasyLoadingToastPosition.bottom);
    print('Notification action launched app: $receivedAction');
  }

  Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // inspect(receivedNotification);
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // inspect(receivedNotification);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      switch (receivedAction.buttonKeyPressed) {
        case 'MEDIA_PREV':
          // Handle media prev
          break;
        case 'MEDIA_PAUSE':
          // Handle media pause
          break;
        case 'MEDIA_NEXT':
          // Handle media next
          break;
      }
      await executeLongTaskInBackground();
    } else {
      EasyLoading.showToast("FCM message ne!",
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  static Future<void> executeLongTaskInBackground() async {
    if (kDebugMode) {
      print("starting long task");
    }
    await Future.delayed(const Duration(seconds: 4));
    if (kDebugMode) {
      print("long task done");
    }
  }
}
