import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jewelry_model.dart';

class CompareViewModel extends ChangeNotifier {
  List<JewelryItem> _compareList = [];
  String? _userId;

  List<JewelryItem> get compareList => _compareList;

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _loadCompareList();
    }
  }

  Future<void> _loadCompareList() async {
    _compareList.clear();
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'compare_list_$_userId';
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(jsonString);
          _compareList = jsonList.map((json) => JewelryItem.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error loading compare list: $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveCompareList() async {
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'compare_list_$_userId';
      final jsonList = _compareList.map((item) => item.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    }
  }

  bool isInCompare(String productId) {
    return _compareList.any((item) => item.productId == productId);
  }

  void addToCompare(JewelryItem item) {
    if (!isInCompare(item.productId)) {
      _compareList.add(item);
      _saveCompareList();
      notifyListeners();
    }
  }

  void removeFromCompare(String productId) {
    _compareList.removeWhere((item) => item.productId == productId);
    _saveCompareList();
    notifyListeners();
  }

  void clearCompare() {
    _compareList.clear();
    if (_userId != null) {
      _saveCompareList();
    }
    notifyListeners();
  }
}
