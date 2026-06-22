import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Hook socket events for incoming messages
    final sockets = Provider.of<SocketService>(context, listen: false);
    sockets.on('message:receive', _onMessageReceived);

    // Initial welcome message
    _messages.add(
      ChatMessage(
        messageId: 'welcome',
        senderId: 'host',
        senderName: 'Restaurant Host',
        senderRole: 'admin',
        messageText: 'Hello! How can we assist you with your dining experience today?',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    final sockets = Provider.of<SocketService>(context, listen: false);
    sockets.off('message:receive');
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessageReceived(dynamic data) {
    if (data is Map<String, dynamic>) {
      setState(() {
        _messages.add(ChatMessage.fromMap(data));
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;

    final api = Provider.of<ApiService>(context, listen: false);
    final sockets = Provider.of<SocketService>(context, listen: false);

    final newMessage = ChatMessage(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: api.currentUser?.userId ?? 'usr_guest',
      senderName: api.currentUser?.name ?? 'Guest User',
      senderRole: 'customer',
      messageText: _msgController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });
    _msgController.clear();
    _scrollToBottom();

    // Emit via WebSocket
    sockets.emit('message:send', newMessage.toMap());

    // Auto simulated reply from host for offline testing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              messageId: 'reply_${DateTime.now().millisecondsSinceEpoch}',
              senderId: 'host',
              senderName: 'Restaurant Host',
              senderRole: 'admin',
              messageText: 'Thank you for your message! Our host is looking into it.',
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trans = Provider.of<TranslationService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(trans.translate('live_chat'), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        elevation: 0,
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderRole == 'customer';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe 
                        ? AppTheme.primaryColor 
                        : (isDark ? AppTheme.darkCard : Colors.grey.shade200),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg.senderName,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                          ),
                        if (!isMe) const SizedBox(height: 4),
                        Text(
                          msg.messageText,
                          style: TextStyle(
                            color: isMe ? Colors.white : (isDark ? Colors.white90 : Colors.black80),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: trans.translate('chat_hint'),
                      hintStyle: const TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
