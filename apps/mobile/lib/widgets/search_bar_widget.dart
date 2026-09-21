import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search by name, phone or code...',
    required this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChange(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onTextChange,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        cursorColor: AppColors.primaryGreen,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    widget.onClear?.call();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
