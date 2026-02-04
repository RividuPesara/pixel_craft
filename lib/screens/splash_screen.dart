import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../constants/app_theme.dart';
import 'editor_screen.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  //fade transition to go navigate to editor screen
  void _navigateToEditor() {
    setState(() => _buttonPressed = true);
    Timer(const Duration(milliseconds: 150), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => const EditorScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sizes = AppSizes.getResponsiveSizes(screenWidth);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          const _FloatingBlocksBackground(),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sizes.spacing * 2),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _VoxelIcon(size: sizes.iconLarge),
                    SizedBox(height: sizes.spacing * 2),
                    _Title3D(fontSize: sizes.titleText),
                    SizedBox(height: sizes.spacing),
                    Text(
                      'CREATE · EDIT · SHARE',
                      style: AppStyles.caption(sizes.captionText),
                    ),
                    const Spacer(flex: 3),
                    _StartButton(
                      height: sizes.buttonHeight,
                      fontSize: sizes.headingText,
                      shadowOffset: sizes.shadowOffset,
                      isPressed: _buttonPressed,
                      onTap: _navigateToEditor,
                    ),
                    SizedBox(height: sizes.spacing * 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//icon widget
class _VoxelIcon extends StatelessWidget {
  final double size;

  const _VoxelIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 12,
      height: size + 12,
      child: Stack(
        children: [
          // Shadow layers
          for (int i = 5; i >= 1; i--)
            Positioned(
              left: i * 1.0,
              top: i * 1.0,
              child: Transform.rotate(
                angle: -0.15,
                child: Icon(
                  Icons.edit,
                  size: size,
                  color: i > 3
                      ? AppColors.secondaryDark
                      : AppColors.secondaryDark.withOpacity(0.7),
                ),
              ),
            ),
          // Main icon
          Transform.rotate(
            angle: -0.15,
            child: Icon(Icons.edit, size: size, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

//3D layered title text
class _Title3D extends StatelessWidget {
  final double fontSize;

  const _Title3D({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    const text = 'PIXEL\nCRAFT';

    return Stack(
      children: [
        // Far shadow
        Transform.translate(
          offset: const Offset(5, 5),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppStyles.title(
              fontSize,
            ).copyWith(color: AppColors.surfaceDark.withOpacity(0.6)),
          ),
        ),
        // Near shadow
        Transform.translate(
          offset: const Offset(2, 2),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppStyles.title(fontSize).copyWith(color: AppColors.border),
          ),
        ),
        // Main text
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppStyles.title(fontSize),
        ),
      ],
    );
  }
}

//start button
class _StartButton extends StatelessWidget {
  final double height;
  final double fontSize;
  final double shadowOffset;
  final bool isPressed;
  final VoidCallback onTap;

  const _StartButton({
    required this.height,
    required this.fontSize,
    required this.shadowOffset,
    required this.isPressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {},
      onTapUp: (_) => onTap(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          0,
          isPressed ? shadowOffset : 0,
          0,
        ),
        width: double.infinity,
        height: height,
        decoration: AppStyles.voxelBox(
          color: AppColors.primary,
          shadowColor: AppColors.primaryDark,
          shadowOffset: isPressed ? 0 : shadowOffset,
        ),
        alignment: Alignment.center,
        child: Text('START ART', style: AppStyles.button(fontSize)),
      ),
    );
  }
}

//background floating blocks
class _FloatingBlocksBackground extends StatefulWidget {
  const _FloatingBlocksBackground();

  @override
  State<_FloatingBlocksBackground> createState() =>
      _FloatingBlocksBackgroundState();
}

class _FloatingBlocksBackgroundState extends State<_FloatingBlocksBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FloatingBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();

    final random = Random();
    _blocks = List.generate(
      14,
      (_) => _FloatingBlock(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 25 + random.nextDouble() * 50,
        speed: 0.2 + random.nextDouble() * 0.4,
        opacity: 0.02 + random.nextDouble() * 0.04,
        rotation: random.nextDouble() * 0.4 - 0.2,
      ),
    );
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
      builder: (context, _) {
        return CustomPaint(
          painter: _FloatingBlocksPainter(
            blocks: _blocks,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

//the data model for floating block
class _FloatingBlock {
  final double x, y, size, speed, opacity, rotation;

  _FloatingBlock({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.rotation,
  });
}

//painter for rendering floating blocks
class _FloatingBlocksPainter extends CustomPainter {
  final List<_FloatingBlock> blocks;
  final double progress;

  _FloatingBlocksPainter({required this.blocks, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final block in blocks) {
      final paint = Paint()
        ..color = AppColors.secondary.withOpacity(block.opacity)
        ..style = PaintingStyle.fill;

      final yPos =
          ((block.y + progress * block.speed) % 1.2 - 0.1) * size.height;
      final xPos = block.x * size.width;

      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate(block.rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: block.size,
          height: block.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingBlocksPainter old) =>
      old.progress != progress;
}
