import 'package:flutter/material.dart';
import '../services/cache_service.dart';

class ViewModeProvider extends ChangeNotifier {
  bool _isGridView = false;
  final CacheService _cacheService = CacheService();
  bool _isInitialized = false;

  bool get isGridView => _isGridView;
  bool get isListView => !_isGridView;
  bool get isInitialized => _isInitialized;

  
  Future<void> loadViewModePreference() async {
    _isGridView = await _cacheService.loadViewMode();
    _isInitialized = true;
    notifyListeners();
  }

  // Toggle between list and grid view
  Future<void> toggleViewMode() async {
    _isGridView = !_isGridView;
    await _cacheService.saveViewMode(_isGridView);
    notifyListeners();
  }

  Future<void> setViewMode(bool isGrid) async {
    _isGridView = isGrid;
    await _cacheService.saveViewMode(_isGridView);
    notifyListeners();
  }
}