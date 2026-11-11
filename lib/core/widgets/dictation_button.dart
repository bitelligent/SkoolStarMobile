import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_controller.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';

/// Microphone button for a [DictationController]: tap to speak, tap again to
/// stop. While listening it pulses in the brand colour. Explanations
/// (permission refused, nothing heard…) appear as a snackbar.
class DictationButton extends StatefulWidget {
  const DictationButton({required this.controller, this.size = 38, super.key});

  final DictationController controller;
  final double size;

  @override
  State<DictationButton> createState() => _DictationButtonState();
}

class _DictationButtonState extends State<DictationButton>
    with SingleTickerProviderStateMixin {
  // Created eagerly: a lazy `late final` would first be built inside
  // dispose(), where looking up the ticker mode is illegal.
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant DictationButton old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  void _onChange() {
    final c = widget.controller;
    if (c.isListening) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
    final message = c.takeMessage();
    if (message != null && mounted) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    // Hidden once the device is known to have no recogniser.
    if (!c.isAvailable) return const SizedBox.shrink();

    final listening = c.isListening;
    final starting = c.state == DictationState.starting;
    final brand = context.brand.primary;

    return Semantics(
      button: true,
      label: listening ? 'Stop voice input' : 'Start voice input',
      child: Tooltip(
        message: listening ? 'Stop' : 'Speak',
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (listening)
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, _) => Container(
                    width: widget.size * (1 + 0.35 * _pulse.value),
                    height: widget.size * (1 + 0.35 * _pulse.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brand.withValues(alpha: 0.22 * (1 - _pulse.value)),
                    ),
                  ),
                ),
              Material(
                color: listening ? brand : Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: starting ? null : c.toggle,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: starting
                        ? const Padding(
                            padding: EdgeInsets.all(11),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            listening
                                ? Icons.stop_rounded
                                : Icons.mic_none_rounded,
                            size: 20,
                            color: listening
                                ? Colors.white
                                : AppColors.iconSubtle,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
