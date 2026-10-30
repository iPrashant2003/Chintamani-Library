import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ai/data/ai_chat_repository.dart';
import '../features/branch/providers/branch_provider.dart';
import '../theme/app_colors.dart';

// ─── Structured message renderer ────────────────────────────────────────────
/// Parses AI reply text and renders rich inline spans:
///  **bold**, `code`, • bullets, numbered lists, section headers (## / ###)
class _StructuredText extends StatelessWidget {
  final String text;
  final Color baseColor;
  final double fontSize;

  const _StructuredText({
    required this.text,
    this.baseColor = const Color(0xFFE2E8F0),
    this.fontSize = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Section header: ## or ###
      if (trimmed.startsWith('### ') || trimmed.startsWith('## ')) {
        final headerText = trimmed.replaceFirst(RegExp(r'^#{2,3}\s*'), '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            headerText,
            style: TextStyle(
              color: const Color(0xFFE8C97A),
              fontSize: fontSize + 0.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ));
        continue;
      }

      // Bullet point: • or - or *
      if (trimmed.startsWith('• ') ||
          trimmed.startsWith('- ') ||
          trimmed.startsWith('* ')) {
        final bulletText = trimmed.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 6),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC9A84C),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(child: _InlineRich(text: bulletText, baseColor: baseColor, fontSize: fontSize)),
            ],
          ),
        ));
        continue;
      }

      // Numbered list: "1. " or "2. " etc.
      final numberedMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(trimmed);
      if (numberedMatch != null) {
        final num = numberedMatch.group(1)!;
        final content = numberedMatch.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  '$num.',
                  style: TextStyle(
                    color: const Color(0xFFC9A84C),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: _InlineRich(text: content, baseColor: baseColor, fontSize: fontSize)),
            ],
          ),
        ));
        continue;
      }

      // Normal paragraph line
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: _InlineRich(text: trimmed, baseColor: baseColor, fontSize: fontSize),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

/// Renders inline bold (**text**) and code (`text`) within a single line.
class _InlineRich extends StatelessWidget {
  final String text;
  final Color baseColor;
  final double fontSize;

  const _InlineRich({required this.text, required this.baseColor, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|`(.+?)`');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(color: baseColor, fontSize: fontSize, height: 1.45),
        ));
      }
      if (match.group(1) != null) {
        // Bold
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: const Color(0xFFF3E5AB),
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ));
      } else if (match.group(2) != null) {
        // Code
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A2E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3)),
            ),
            child: Text(
              match.group(2)!,
              style: TextStyle(
                color: const Color(0xFFE8C97A),
                fontSize: fontSize - 0.5,
                fontFamily: 'monospace',
                height: 1.3,
              ),
            ),
          ),
        ));
      }
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(color: baseColor, fontSize: fontSize, height: 1.45),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ─── Floating AI Chatbot Widget ─────────────────────────────────────────────

class FloatingAiChatbot extends ConsumerStatefulWidget {
  const FloatingAiChatbot({super.key});

  @override
  ConsumerState<FloatingAiChatbot> createState() => _FloatingAiChatbotState();
}

class _FloatingAiChatbotState extends ConsumerState<FloatingAiChatbot>
    with TickerProviderStateMixin {
  static Offset? _savedPosition;
  Offset _position = const Offset(-1, -1);
  bool _isDragging = false;
  double _dragDistance = 0.0;
  bool _isExpanded = false;
  bool _isHoveredOrActive = false;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const _goldPrimary = Color(0xFFD4AF37);
  static const _goldLight = Color(0xFFF3E5AB);
  static const _surface1 = Color(0xFF0F0D18);
  static const _surface2 = Color(0xFF16141F);
  static const _surface3 = Color(0xFF1C1A28);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _messages.add(ChatMessage(
      role: 'model',
      text: 'Namaste! I am **ChintaMani AI**, your library intelligence assistant.\n\n'
          'I can help you with:\n'
          '• Seat availability & shift information\n'
          '• Locker status and assignments\n'
          '• Library timings & rules\n'
          '• Fee dues & renewals\n'
          '• Director contact & helpline\n\n'
          'What would you like to know?',
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
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
            text: '**Connection error.**\n\nUnable to reach the server. Please check your internet connection and try again.',
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

    const launcherSize = 58.0;
    const minX = 12.0;
    final maxX = screenSize.width - launcherSize - 12.0;
    final minY = padding.top + 12.0;
    final maxY = screenSize.height - launcherSize - 100.0;

    if (_position.dx < 0 || _position.dy < 0) {
      if (_savedPosition != null) {
        _position = Offset(
          _savedPosition!.dx.clamp(minX, maxX),
          _savedPosition!.dy.clamp(minY, maxY),
        );
      } else {
        _position = Offset(maxX, maxY - 20);
      }
    }

    return Stack(
      children: [
        // ── FLOATING LAUNCHER ──
        if (!_isExpanded)
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanStart: (d) {
                _isDragging = true;
                _dragDistance = 0.0;
                setState(() => _isHoveredOrActive = true);
              },
              onPanUpdate: (d) {
                _dragDistance += d.delta.distance;
                setState(() {
                  _position = Offset(
                    (_position.dx + d.delta.dx).clamp(minX, maxX),
                    (_position.dy + d.delta.dy).clamp(minY, maxY),
                  );
                  _savedPosition = _position;
                });
              },
              onPanEnd: (d) {
                _isDragging = false;
                setState(() => _isHoveredOrActive = false);
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
                  duration: const Duration(milliseconds: 250),
                  opacity: (_isHoveredOrActive || _isDragging) ? 1.0 : 0.5,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (ctx, child) => Transform.scale(
                      scale: _isHoveredOrActive ? 1.0 : _pulseAnimation.value * 0.05 + 0.97,
                      child: child,
                    ),
                    child: _buildLauncher(launcherSize),
                  ),
                ),
              ),
            ),
          ),

        // ── EXPANDED CHAT PANEL ──
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Tap backdrop to close
                HapticFeedback.lightImpact();
                setState(() => _isExpanded = false);
              },
              child: Material(
                color: Colors.black.withValues(alpha: 0.6),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent panel tap from closing
                      child: _buildChatPanel(screenSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLauncher(double size) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1A2C), Color(0xFF12101A)],
            ),
            border: Border.all(
              color: _goldPrimary.withValues(alpha: 0.85),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: _goldPrimary.withValues(alpha: 0.4),
                blurRadius: 18,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(11),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.auto_awesome_rounded,
              color: _goldPrimary,
              size: 26,
            ),
          ),
        ),
        // AI badge
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0F0D18), width: 1.5),
            ),
            child: const Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatPanel(Size screenSize) {
    return Container(
      width: (screenSize.width - 24).clamp(300.0, 450.0),
      height: (screenSize.height * 0.78).clamp(420.0, 660.0),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surface1,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _goldPrimary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: _goldPrimary.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            _buildPremiumHeader(),
            Expanded(child: _buildMessagesList()),
            _buildQuickChips(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1730),
            _surface2,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: _goldPrimary.withValues(alpha: 0.18), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Gold hairline top accent
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _goldPrimary.withValues(alpha: 0.6),
                    Colors.white.withValues(alpha: 0.8),
                    _goldPrimary.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              // Logo ring
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF23203A), Color(0xFF1A1730)],
                  ),
                  border: Border.all(color: _goldPrimary.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _goldPrimary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.auto_awesome, color: _goldPrimary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ChintaMani AI',
                      style: TextStyle(
                        color: _goldLight,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF34D399),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF34D399).withValues(alpha: 0.7),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Online • Gemini 1.5 Flash • Live Grounded',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Clear + Close buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_messages.length > 1)
                    Tooltip(
                      message: 'Clear conversation',
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _messages.clear();
                            _messages.add(ChatMessage(
                              role: 'model',
                              text: 'Conversation cleared. How can I help you?',
                            ));
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isExpanded = false);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, color: _goldPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: _surface1,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          // Typing indicator
          if (index == _messages.length && _isTyping) {
            return _buildTypingIndicator();
          }

          final msg = _messages[index];
          final isUser = msg.role == 'user';
          return _buildMessageBubble(msg, isUser, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isUser, int index) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 7, bottom: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surface3,
                  border: Border.all(color: _goldPrimary.withValues(alpha: 0.4)),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.auto_awesome, color: _goldPrimary, size: 12),
                ),
              ),
            ],
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: msg.text));
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isUser ? 260 : 310,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isUser ? 14 : 14,
                    vertical: isUser ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2A2010), Color(0xFF201808)],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_surface3, _surface2],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: Border.all(
                      color: isUser
                          ? _goldPrimary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.07),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          msg.text,
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        )
                      : _StructuredText(text: msg.text, fontSize: 12.5),
                ),
              ),
            ),
            if (isUser)
              Padding(
                padding: const EdgeInsets.only(left: 7, bottom: 2),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _goldPrimary.withValues(alpha: 0.15),
                    border: Border.all(color: _goldPrimary.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.person_rounded, size: 14, color: _goldPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 33),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _surface2,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BouncingDot(delay: 0),
              const SizedBox(width: 4),
              _BouncingDot(delay: 150),
              const SizedBox(width: 4),
              _BouncingDot(delay: 300),
              const SizedBox(width: 10),
              const Text(
                'Thinking…',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChips() {
    final chips = [
      ('💺', 'Available seats?'),
      ('🔒', 'Locker status'),
      ('🕐', 'Library timings'),
      ('🎓', 'Admission process'),
      ('💡', 'Study tips'),
      ('📞', 'Director contact'),
      ('💳', 'Fee & dues info'),
      ('📶', 'Wi-Fi & facilities'),
    ];

    return Container(
      height: 42,
      color: _surface1,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final (emoji, label) = chips[i];
          return GestureDetector(
            onTap: () => _sendMessage(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _surface3,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _goldPrimary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      color: _goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      decoration: BoxDecoration(
        color: _surface2,
        border: Border(top: BorderSide(color: _goldPrimary.withValues(alpha: 0.12))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _surface3,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Ask ChintaMani AI anything…',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (v) {
                  _sendMessage(v);
                  _focusNode.requestFocus();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _sendMessage(_textController.text),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8C97A), Color(0xFFC9A84C), Color(0xFFA07830)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _goldPrimary.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: _isTyping
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated bouncing dot for typing indicator ──────────────────────────────
class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
