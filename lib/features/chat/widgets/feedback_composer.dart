import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// Inline reply input used at the bottom of an expanded feedback topic.
/// Owns its own `TextEditingController` so each tile has independent
/// draft state and losing focus doesn't blow it away.
class FeedbackComposer extends StatefulWidget {
  const FeedbackComposer({
    required this.onSend,
    required this.enabled,
    this.hint = 'Reply to parent…',
    super.key,
  });

  final Future<bool> Function(String text) onSend;
  final bool enabled;
  final String hint;

  @override
  State<FeedbackComposer> createState() => _FeedbackComposerState();
}

class _FeedbackComposerState extends State<FeedbackComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncCanSend);
  }

  void _syncCanSend() {
    final can = _controller.text.trim().isNotEmpty;
    if (can != _canSend) setState(() => _canSend = can);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncCanSend)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!widget.enabled || !_canSend) return;
    final text = _controller.text;
    final ok = await widget.onSend(text);
    if (!mounted) return;
    if (ok) {
      _controller.clear();
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              enabled: !disabled,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 10,
                ),
                hintText: widget.hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          _SendButton(
            enabled: widget.enabled && _canSend,
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        gradient: enabled ? AppGradients.primary : null,
        color: enabled ? null : AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              Icons.send_rounded,
              size: 18,
              color: enabled ? Colors.white : AppColors.iconSubtle,
            ),
          ),
        ),
      ),
    );
  }
}
