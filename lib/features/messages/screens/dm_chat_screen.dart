import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';

class _Msg {
  final String text;
  final bool isMe;
  const _Msg(this.text, this.isMe);
}

class DmChatScreen extends StatefulWidget {
  final String uid;
  const DmChatScreen({super.key, required this.uid});

  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String _myUid = '';
  String _conversationId = '';

  static const _nameMap = {
    'user_003': 'Arjun Mehta',
    'user_004': 'Kavya Nair',
    'user_005': 'Rohit Verma',
    'user_006': 'Sneha Patel',
  };

  String get _otherName => _nameMap[widget.uid] ?? widget.uid;

  String _buildConversationId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _myUid = auth.currentUser?.uid ?? 'user_001';
    _conversationId = _buildConversationId(_myUid, widget.uid);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().listenToMessages(_conversationId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_Msg> _dummyMessages() {
    if (widget.uid == 'user_004') {
      return const [
        _Msg('Hey! Loved your post about building SECURE 👏', false),
        _Msg('Thank you! It\'s been quite a journey 😊', true),
        _Msg('We both follow #canvapainting — would love to collaborate sometime!', false),
        _Msg('Absolutely! That would be amazing 🎨', true),
      ];
    }
    return const [];
  }

  List<_Msg> _toDisplayMsgs(List<Map<String, dynamic>> providerMsgs) {
    return providerMsgs.map((m) => _Msg(
      (m['content'] as String?) ?? '',
      (m['fromUid'] as String?) == _myUid,
    )).toList();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      await context.read<MessageProvider>().sendMessage(
        conversationId: _conversationId,
        fromUid: _myUid,
        content: text,
      );
    } catch (e) {
      debugPrint('DM send error: $e');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final providerMsgs = context.watch<MessageProvider>().messages;
    final messages = providerMsgs.isNotEmpty
        ? _toDisplayMsgs(providerMsgs)
        : _dummyMessages();

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.7),
                  child: Text(
                    _otherName[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_otherName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Text('Online', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Say hello to $_otherName!',
                      style: TextStyle(color: AppColors.textSubFor(isDigital)),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _BubbleTile(msg: messages[i]),
                  ),
          ),
          _InputRow(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _BubbleTile extends StatelessWidget {
  final _Msg msg;
  const _BubbleTile({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.adaptivePrimary(isDigital) : AppColors.surfaceColor(isDigital),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isMe ? Colors.white : AppColors.textFor(isDigital), fontSize: 14, height: 1.4),
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputRow({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Material(
            color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onSend,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
