import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/haptic_service.dart';
import 'widgets.dart';

class WhatsAppChatScreen extends StatefulWidget {
  const WhatsAppChatScreen({super.key});

  @override
  State<WhatsAppChatScreen> createState() => _WhatsAppChatScreenState();
}

class _WhatsAppChatScreenState extends State<WhatsAppChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Namaste! Send me a voice note or type your query about any government scheme. I will reply in your language.',
      'time': '10:00 AM',
    }
  ];
  
  bool _isTyping = false;
  int _flowStep = 0;

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    HapticService.light();

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': _getCurrentTime(),
      });
      _isTyping = true;
    });
    
    _textController.clear();
    _scrollToBottom();
    
    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      setState(() {
        _isTyping = false;
        String responseText = "";
        
        if (_flowStep == 0) {
          responseText = "Based on your query, you are eligible for the PM Kisan Samman Nidhi scheme! You qualify for ₹2000 in your linked bank account. Type APPLY to proceed.";
          _flowStep++;
        } else if (_flowStep == 1) {
          responseText = "Processing your application using your registered Aadhaar... ✅\n\nSuccess! Your application #49820 is submitted.";
          _flowStep++;
        } else {
          responseText = "I am still here to help! Send another voice note or text message about any other schemes.";
          _flowStep = 0;
        }
        
        _messages.add({
          'isUser': false,
          'text': responseText,
          'time': _getCurrentTime(),
        });
      });
      HapticService.medium();
      _scrollToBottom();
    });
  }
  
  String _getCurrentTime() {
    final now = DateTime.now();
    int hr = now.hour;
    int min = now.minute;
    String ampm = hr >= 12 ? 'PM' : 'AM';
    if (hr > 12) hr -= 12;
    if (hr == 0) hr = 12;
    String minStr = min < 10 ? '0$min' : '$min';
    return '$hr:$minStr $ampm';
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
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // WhatsApp background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF008069), // WhatsApp green
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const AnimatedLogo(size: 32, isAnimated: true),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sahaayak BharatBot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('Online • Official Assistant', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  
                  final msg = _messages[index];
                  final isUser = msg['isUser'] as bool;
                  return _buildMessageBubble(msg['text'], msg['time'], isUser);
                },
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sahaayak BharatBot is typing', style: TextStyle(color: Color(0xFF008069), fontWeight: FontWeight.w600, fontSize: 13, fontStyle: FontStyle.italic)),
            const SizedBox(width: 8),
            _buildDot(0),
            _buildDot(200),
            _buildDot(400),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(color: Color(0xFF008069), shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), delay: delay.ms, duration: 400.ms);
  }

  Widget _buildMessageBubble(String text, String time, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFD9FDD3) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isUser ? const Radius.circular(16) : Radius.zero,
            topRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('Sahaayak BharatBot', style: TextStyle(color: Color(0xFF008069), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            Text(
              text,
              style: const TextStyle(fontSize: 15, color: Color(0xFF111B21), height: 1.3),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1, duration: 300.ms),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFFF0F2F5),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF54656F), size: 28),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(color: Color(0xFF8696A0)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF00A884),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _textController.text.trim().isEmpty ? Icons.mic_rounded : Icons.send_rounded, 
                  color: Colors.white, 
                  size: 24
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
