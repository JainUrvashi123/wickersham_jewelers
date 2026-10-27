import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wickersham_jewelers/core/navigation/navigator_service.dart';
import 'package:wickersham_jewelers/models/quote_model.dart';
import 'package:wickersham_jewelers/viewmodels/auth_viewmodel.dart';
import 'package:wickersham_jewelers/views/quote_detail_view.dart';
import 'package:wickersham_jewelers/views/admin_enquiry_detail_view.dart';

import '../viewmodels/quote_viewmodel.dart';

// Top level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for iOS/Android 13+
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Set background messaging handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications for foreground messages
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle when user taps on a local notification
      debugPrint('Notification clicked: ${response.payload}');
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          final designId = data['design_id']?.toString() ??
                           data['quote_id']?.toString() ??
                           data['designId']?.toString() ??
                           data['quoteId']?.toString() ??
                           data['enquiry_id']?.toString() ??
                           data['enquiryId']?.toString() ??
                           data['id']?.toString();
          if (designId != null && designId.isNotEmpty) {
            _navigateToQuoteDetail(designId);
          }
        } catch (e) {
          debugPrint('Error parsing notification click payload: $e');
        }
      }
    });

    // Create a high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground messages handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      // Re-fetch quotes/enquiries list to update the drawer badge in real-time!
      final context = NavigatorService.navigatorKey.currentContext;
      if (context != null) {
        try {
          final authVM = Provider.of<AuthViewModel>(context, listen: false);
          final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
          if (authVM.user != null) {
            if (authVM.user!.userType == '1') {
              quoteVM.fetchAdminDesigns(authVM);
            } else {
              quoteVM.fetchQuotes(authVM);
            }
          }
        } catch (e) {
          debugPrint('Error re-fetching lists on message: $e');
        }
      }

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        
        // Show local notification for foreground messages
        _localNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Terminated state handler (when app is opened via a notification from terminated state)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state by notification: ${initialMessage.messageId}');
      _handleNotificationClick(initialMessage);
    }

    // Background state handler (when app is opened via a notification from background state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background state by notification: ${message.messageId}');
      _handleNotificationClick(message);
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('Handling notification click: ${message.data}');
    final designId = message.data['design_id']?.toString() ??
                     message.data['quote_id']?.toString() ??
                     message.data['designId']?.toString() ??
                     message.data['quoteId']?.toString() ??
                     message.data['enquiry_id']?.toString() ??
                     message.data['enquiryId']?.toString() ??
                     message.data['id']?.toString();
    if (designId != null && designId.isNotEmpty) {
      _navigateToQuoteDetail(designId);
    }
  }

  void _navigateToQuoteDetail(String designId) {
    final context = NavigatorService.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigator context is null, cannot navigate.');
      return;
    }
    
    try {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final user = authVM.user;
      if (user == null) {
        debugPrint('No user is logged in, cannot navigate to detail screen.');
        return;
      }
      final isAdmin = user.userType == '1';
      final quote = QuoteModel.dummy(designId);
      
      if (isAdmin) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminEnquiryDetailView(quote: quote),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuoteDetailView(quote: quote),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to quote detail from notification: $e');
    }
  }
}
