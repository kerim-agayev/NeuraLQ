import 'package:flutter/material.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color primary;
  final Color secondary;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primary = const Color(0xFF00F5FF),
    this.secondary = const Color(0xFFBF00FF),
    this.height = 56,
    this.borderRadius = 12,
    this.isLoading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [widget.primary, widget.secondary],
              begin: Alignment(
                -1 + (_controller.value * 2),
                -1,
              ),
              end: Alignment(
                1 + (_controller.value * 2),
                1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
