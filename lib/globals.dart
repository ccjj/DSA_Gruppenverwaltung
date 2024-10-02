import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'User/User.dart';
import 'chat/ChatMessage.dart';
GlobalKey talentKey = GlobalKey();
GlobalKey zauberKey = GlobalKey();
GetIt getIt = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late User cu;
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<bool> showAusdauer = ValueNotifier(true);
const appName = "Axxelerat.us";
var isTest = false;
StreamController<ChatMessage> messageController = StreamController<ChatMessage>.broadcast();
final ValueNotifier<bool> isChatVisible = ValueNotifier(false);
String webUserAgent = "";