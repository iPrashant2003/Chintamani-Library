import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ai/data/ai_chat_repository.dart';
import '../features/branch/providers/branch_provider.dart';
import '../theme/app_colors.dart';

class FloatingAiChatbot extends ConsumerStatefulWidget {
  const FloatingAiChatbot({super.key});

  @override
  ConsumerState<FloatingAiChatbot> createState() => _FloatingAiChatbotState();
}

class _FloatingAiChatbotState extends ConsumerState<FloatingAiChatbot>
    with SingleTickerProviderStateMixin {
  static Offset? _savedPosition;
  Offset _position = const Offset(-1, -1);
  bool _isDragging = false;
  double _dragDistance = 0.0;
  bool _isExpanded = false;
  bool _isHoveredOrActive = false;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      role: 'model',
      text:
          'Namaste! I am ChintaMani AI, your library intelligence assistant. Ask me anything about hall seating, lockers, dues, or library timings.',
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isTyping) return;

    HapticFeedback.lightImpact();
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', text: query));
      _isTyping = true;
    });
    _scrollToBottom();

    final activeBranch = ref.read(activeBranchProvider);
    final repo = ref.read(aiChatRepositoryProvider);

    try {
      final reply = await repo.sendMessage(
        message: query,
        history: _messages,
        branchId: activeBranch.id,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: 'model', text: reply));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'model',
            text:
                'Unable to contact server. Please verify your internet connection or try again shortly.',
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;

    const launcherSize = 56.0;
    const minX = 16.0;
    final maxX = screenSize.width - launcherSize - 16.0;
    final minY = padding.top + 16.0;
    final maxY = screenSize.height - launcherSize - 90.0;

    // Initialize default bottom-right position
    if (_position.dx < 0 || _position.dy < 0) {
      if (_savedPosition != null) {
        _position = Offset(
          _savedPosition!.dx.clamp(minX, maxX),
          _savedPosition!.dy.clamp(minY, maxY),
        );
      } else {
        _position = Offset(maxX, maxY - 30);
      }
    }

    return Stack(
      children: [
        // ── FLOATING DRAGGABLE LAUNCHER ──
        if (!_isExpanded)
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanStart: (details) {
                _isDragging = true;
                _dragDistance = 0.0;
                setState(() => _isHoveredOrActive = true);
              },
              onPanUpdate: (details) {
                _dragDistance += details.delta.distance;
                setState(() {
                  final newX = (_position.dx + details.delta.dx).clamp(minX, maxX);
                  final newY = (_position.dy + details.delta.dy).clamp(minY, maxY);
                  _position = Offset(newX, newY);
                  _savedPosition = _position;
                });
              },
              onPanEnd: (details) {
                _isDragging = false;
                setState(() => _isHoveredOrActive = false);
                // Distinguish drag from tap: if moved under 8 pixels, treat as a tap
                if (_dragDistance < 8.0) {
                  HapticFeedback.mediumImpact();
                  setState(() => _isExpanded = true);
                }
              },
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _isExpanded = true);
              },
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHoveredOrActive = true),
                onExit: (_) => setState(() => _isHoveredOrActive = false),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (_isHoveredOrActive || _isDragging) ? 1.0 : 0.45,
                  child: Container(
                    width: launcherSize,
                    height: launcherSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF14121A),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFD4AF37),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // ── EXPANDED CHAT PANEL MODAL ──
        if (_isExpanded)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Container(
                    width: (screenSize.width - 32).clamp(280.0, 440.0),
                    height: (screenSize.height * 0.75).clamp(380.0, 640.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0E14),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(),

                        // Conversation message list
                        Expanded(child: _buildMessagesList()),

                        // Quick prompt chips
                        _buildQuickChips(),

                        // Input field bar
                        _buildInputBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16151E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1C1A24),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ChintaMani AI Assistant',
                  style: TextStyle(
                    color: Color(0xFFF3E5AB),
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Gemini 1.5 • Live Grounded',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close AI Chat',
            icon: const Icon(Icons.close_rounded, color: Color(0xFFD4AF37), size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isExpanded = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1924),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ChintaMani AI is thinking...',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        final msg = _messages[index];
        final isUser = msg.role == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFF2C2416)
                  : const Color(0xFF16151E),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(
                color: isUser
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isUser ? const Color(0xFFFDE68A) : AppColors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickChips() {
    final chips = [
      'Available seats today?',
      'Unassigned Lockers count',
      'Library timings & rules',
      'Director helpline',
    ];

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return ActionChip(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            backgroundColor: const Color(0xFF16151E),
            side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            label: Text(
              chip,
              style: const TextStyle(color: Color(0xFFF3E5AB), fontSize: 11),
            ),
            onPressed: () => _sendMessage(chip),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14131B),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Ask ChintaMani AI...',
                hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF1A1924),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: const CircleBorder(),
            ),
            icon: const Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 20),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
