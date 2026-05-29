import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';

class MessageProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _messages = [];
  final bool _isLoading = false;

  StreamSubscription? _convSub;
  StreamSubscription? _reqSub;
  StreamSubscription? _msgSub;

  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get requests => _requests;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  void startListening(String uid) {
    _convSub?.cancel();
    _convSub = _fs.getConversations(uid).listen(
      (list) {
        _conversations = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('MessageProvider conversations error: $e'),
    );

    _reqSub?.cancel();
    _reqSub = _fs.getDMRequests(uid).listen(
      (list) {
        _requests = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('MessageProvider requests error: $e'),
    );
  }

  void listenToMessages(String conversationId) {
    _msgSub?.cancel();
    _messages = [];
    _msgSub = _fs.getMessages(conversationId).listen(
      (list) {
        _messages = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('MessageProvider messages error: $e'),
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String fromUid,
    required String content,
  }) async {
    try {
      await _fs.sendMessage(
        conversationId: conversationId,
        fromUid: fromUid,
        content: content,
      );
    } catch (e) {
      debugPrint('MessageProvider.sendMessage error: $e');
    }
  }

  Future<void> acceptRequest(String conversationId) async {
    try {
      await _fs.acceptDMRequest(conversationId);
    } catch (e) {
      debugPrint('MessageProvider.acceptRequest error: $e');
    }
  }

  Future<void> ignoreRequest(String conversationId) async {
    try {
      await _fs.ignoreDMRequest(conversationId);
    } catch (e) {
      debugPrint('MessageProvider.ignoreRequest error: $e');
    }
  }

  @override
  void dispose() {
    _convSub?.cancel();
    _reqSub?.cancel();
    _msgSub?.cancel();
    super.dispose();
  }
}
