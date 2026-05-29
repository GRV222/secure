import 'package:flutter/material.dart';
import '../../../models/token_model.dart';
import '../../../models/user_model.dart';

class WalletProvider extends ChangeNotifier {
  TokenModel? _tokenModel;
  final bool _isLoading = false;
  String? _error;

  TokenModel? get tokenModel => _tokenModel;
  double get shreeCoinBalance => _tokenModel?.shreeCoinBalance ?? 0.0;
  double get daCoinBalance => _tokenModel?.daCoinBalance ?? 0.0;
  double get shreedaBalance => _tokenModel?.shreedaBalance ?? 0.0;
  double get totalDaDonated => _tokenModel?.totalDaDonated ?? 0.0;
  List<Map<String, dynamic>> get transactions => const [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadWallet(UserModel user) {
    _tokenModel = TokenModel(
      uid: user.uid,
      shreeCoinBalance: user.shreeCoinBalance,
      daCoinBalance: user.daCoinBalance,
      shreedaBalance: user.shreedaBalance,
      totalDaDonated: user.totalDaDonated,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void updateTokenModel(TokenModel model) {
    _tokenModel = model;
    notifyListeners();
  }
}
