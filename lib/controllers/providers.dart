import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_service.dart';

import '../services/coupon_service.dart';
import '../services/merchandising_service.dart';


import '../services/settings_service.dart';
import '../services/websocket_service.dart';
import '../models/app_info.dart';

// Services
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());





final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService(ref.read(apiServiceProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.read(apiServiceProvider));
});

final merchandisingServiceProvider = Provider<MerchandisingService>((ref) {
  return MerchandisingService(ref.read(apiServiceProvider));
});

final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  return ref.read(settingsServiceProvider).getAppInfo();
});

// UI Keys
final cartIconKeyProvider = Provider((ref) => GlobalKey());

final homeDataProvider = FutureProvider((ref) async {
  return ref.read(merchandisingServiceProvider).getHomeData();
});

final wsServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});
