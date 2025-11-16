import 'package:flauncher/widgets/animation_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double>? onChanged;
  final FocusNode? focusNode;
  final bool showLabels;
  final double height;

  // Constants for consistent sizing
  static const double _labelWidth = 40.0;
  static const double _labelSpacing = 8.0;
  static const double _thumbSize = 24.0;
  static const double _trackHeight = 8.0;

  const TVSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 10,
    this.onChanged,
    this.focusNode,
    this.showLabels = true,
    this.height = 48.0,
  }) : super(key: key);

  @override
  State<TVSlider> createState() => _TVSliderState();
}

class _TVSliderState extends State<TVSlider> with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late MicroInteractionController _interactionController;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _interactionController = MicroInteractionController(this);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _interactionController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _interactionController.animateFocus();
    } else {
      _interactionController.animateUnfocus();
    }
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // Handle left/right for value adjustment
        final step = (widget.max - widget.min) / widget.divisions;
        double newValue = widget.value;

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          newValue = (widget.value - step).clamp(widget.min, widget.max);
        } else {
          newValue = (widget.value + step).clamp(widget.min, widget.max);
        }

        widget.onChanged?.call(newValue);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Move focus away on up/down
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _focusNode.previousFocus();
        } else {
          _focusNode.nextFocus();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _buildSliderContent() {
    final progress = (widget.value - widget.min) / (widget.max - widget.min);

    return Container(
      height: widget.height,
      child: Row(
        children: [
          if (widget.showLabels) ...[
            SizedBox(
              width: TVSlider._labelWidth,
              child: Text(
                '${widget.min.round()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: TVSlider._labelSpacing),
          ],
          Expanded(
            child: Focus(
              canRequestFocus: false, // Prevent internal focus
              child: Container(
                height: TVSlider._trackHeight,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TVSlider._trackHeight / 2),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                child: TweenAnimationBuilder<double>(
                  duration: PremiumAnimations.medium,
                  tween: Tween<double>(begin: 0.0, end: progress),
                  curve: PremiumAnimations.easeOut,
                  builder: (context, animatedProgress, child) {
                    return FractionallySizedBox(
                      widthFactor: animatedProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(TVSlider._trackHeight / 2),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.showLabels) ...[
            SizedBox(width: TVSlider._labelSpacing),
            SizedBox(
              width: TVSlider._labelWidth,
              child: Text(
                '${widget.max.round()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          _buildSliderContent(),
          // Custom thumb overlay
          Positioned(
            left: widget.showLabels ? TVSlider._labelWidth + TVSlider._labelSpacing : 0.0,
            right: widget.showLabels ? TVSlider._labelWidth + TVSlider._labelSpacing : 0.0,
            top: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              duration: PremiumAnimations.medium,
              tween: Tween<double>(
                begin: 0.0,
                end: (widget.value - widget.min) / (widget.max - widget.min) * 2 - 1,
              ),
              curve: PremiumAnimations.easeOut,
              builder: (context, alignmentValue, child) {
                return Align(
                  alignment: Alignment(alignmentValue, 0),
                  child: AnimatedBuilder(
                    animation: _interactionController.scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _interactionController.scaleAnimation.value,
                        child: AnimatedContainer(
                          duration: PremiumAnimations.medium,
                          curve: PremiumAnimations.easeOut,
                          width: TVSlider._thumbSize,
                          height: TVSlider._thumbSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _focusNode.hasFocus
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
