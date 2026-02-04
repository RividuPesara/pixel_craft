import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:typed_data';
import 'dart:math';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import '../constants/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  //canvas size
  static const int _gridWidth = 16;
  static const int _gridHeight = 16;

  //pixel data
  late List<List<Color?>> _pixels;

  //drawing state
  Color _currentColor = AppColors.primary;
  bool _isEraser = false;

  //history for undo/redo
  final List<List<List<Color?>>> _undoStack = [];
  final List<List<List<Color?>>> _redoStack = [];

  //color usage tracking for dynamic palette
  final Map<int, int> _colorUsage = {};

  //screenshot controller for saving
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initCanvas();
  }

  //initialize canvas with empty pixels
  void _initCanvas() {
    _pixels = List.generate(
      _gridHeight,
      (_) => List.generate(_gridWidth, (_) => null),
    );
    _undoStack.clear();
    _redoStack.clear();
    _colorUsage.clear();
  }

  //create deep copy of pixel grid
  List<List<Color?>> _copyPixels() {
    return List.generate(
      _gridHeight,
      (y) => List.generate(_gridWidth, (x) => _pixels[y][x]),
    );
  }

  //save current state to undo stack
  void _saveToHistory() {
    _undoStack.add(_copyPixels());
    if (_undoStack.length > 50) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  //undo last drawing action
  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_copyPixels());
    setState(() {
      _pixels = _undoStack.removeLast();
      _recalculateColorUsage();
    });
  }

  //redo previously undone action
  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_copyPixels());
    setState(() {
      _pixels = _redoStack.removeLast();
      _recalculateColorUsage();
    });
  }

  //clear all pixels from canvas
  void _clearCanvas() {
    _saveToHistory();
    setState(_initCanvas);
  }

  //rebuild color usage map from scratch
  void _recalculateColorUsage() {
    _colorUsage.clear();
    for (final row in _pixels) {
      for (final color in row) {
        if (color != null) {
          _colorUsage[color.value] = (_colorUsage[color.value] ?? 0) + 1;
        }
      }
    }
  }

  //handle drawing on canvas at touch position
  void _handleDraw(Offset position, double cellSize, Offset gridOffset) {
    final x = ((position.dx - gridOffset.dx) / cellSize).floor();
    final y = ((position.dy - gridOffset.dy) / cellSize).floor();

    if (x < 0 || x >= _gridWidth || y < 0 || y >= _gridHeight) return;

    final newColor = _isEraser ? null : _currentColor;
    if (_pixels[y][x] == newColor) return;

    _saveToHistory();
    setState(() {
      //update color usage
      final oldColor = _pixels[y][x];
      if (oldColor != null) {
        _colorUsage[oldColor.value] = (_colorUsage[oldColor.value] ?? 1) - 1;
        if (_colorUsage[oldColor.value]! <= 0)
          _colorUsage.remove(oldColor.value);
      }
      if (newColor != null) {
        _colorUsage[newColor.value] = (_colorUsage[newColor.value] ?? 0) + 1;
      }
      _pixels[y][x] = newColor;
    });
  }

  //save canvas as image to device gallery
  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      //capture the canvas
      final Uint8List? image = await _screenshotController.capture(
        pixelRatio: 4.0,
      );

      if (image == null) {
        _showMessage('Failed to capture image');
        setState(() => _isSaving = false);
        return;
      }

      if (kIsWeb) {
        //In web platform trigger download
        _downloadImageWeb(image);
        _showMessage('Downloaded!');
      } else {
        //mobile/Desktop platform save to gallery
        final hasPermission = await _checkAndRequestPermissions();
        if (!hasPermission) {
          _showMessage('Storage permission is required to save images');
          setState(() => _isSaving = false);
          return;
        }

        final result = await SaverGallery.saveImage(
          image,
          quality: 100,
          fileName: 'pixel_art_${DateTime.now().millisecondsSinceEpoch}.png',
          androidRelativePath: 'Pictures/PixelCraft',
          skipIfExists: false,
        );

        if (result.isSuccess) {
          _showMessage('Saved to gallery!');
        } else {
          _showMessage('Failed to save image');
        }
      }
    } catch (e) {
      _showMessage('Error: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  //download image for web platform
  void _downloadImageWeb(Uint8List imageBytes) {
    final blob = html.Blob([imageBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = 'pixel_art_${DateTime.now().millisecondsSinceEpoch}.png';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  //check and request storage permissions based on Android version
  Future<bool> _checkAndRequestPermissions() async {
    if (kIsWeb) {
      return true; // Web doesn't need permissions
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return true; //desktop platforms don't need permission
    }

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (sdkInt >= 33) {
        //Android 13+ uses photos permission
        final status = await Permission.photos.request();
        return status.isGranted;
      } else if (sdkInt >= 29) {
        //Android 10-12 doesn't need permission for saving
        return true;
      } else {
        //Android 9 and below needs storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }

    return false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyles.body(16)),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  //show color picker dialog
  void _showColorPicker() {
    Color pickedColor = _currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Pick Color', style: AppStyles.heading(28)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (c) => pickedColor = c,
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppStyles.body(22).copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentColor = pickedColor;
                _isEraser = false;
              });
              Navigator.pop(context);
            },
            child: Text(
              'Select',
              style: AppStyles.body(22).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  //get palette sorted by most used colors first
  List<Color> _getSortedPalette() {
    // Sort by usage (most used first)
    final sorted = _colorUsage.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Set<int> added = {};
    final List<Color> palette = [];

    // Add used colors
    for (final entry in sorted) {
      if (palette.length >= 12) break;
      added.add(entry.key);
      palette.add(Color(entry.key));
    }

    //fill with defaults
    for (final color in AppColors.defaultPalette) {
      if (palette.length >= 12) break;
      if (!added.contains(color.value)) {
        added.add(color.value);
        palette.add(color);
      }
    }

    return palette;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final sizes = AppSizes.getResponsiveSizes(screenSize.width);
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background grid
            CustomPaint(painter: _BackgroundGridPainter(), size: Size.infinite),

            // Layout
            isLandscape
                ? _buildLandscapeLayout(sizes)
                : _buildPortraitLayout(sizes),

            // Saving indicator
            if (_isSaving)
              Container(
                color: AppColors.background.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(ResponsiveSizes sizes) {
    return Column(
      children: [
        _buildToolbar(sizes, isVertical: false),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(sizes.spacing),
            child: _buildCanvas(sizes),
          ),
        ),
        _buildPalette(sizes, isVertical: false),
        SizedBox(height: sizes.spacing),
      ],
    );
  }

  Widget _buildLandscapeLayout(ResponsiveSizes sizes) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(sizes.spacing / 2),
          child: _buildToolbar(sizes, isVertical: true),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(sizes.spacing),
            child: _buildCanvas(sizes),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(sizes.spacing / 2),
          child: _buildPalette(sizes, isVertical: true),
        ),
      ],
    );
  }

  //toolbar
  Widget _buildToolbar(ResponsiveSizes sizes, {required bool isVertical}) {
    final buttons = [
      _ToolButton(
        icon: Icons.undo_rounded,
        onTap: _undo,
        enabled: _undoStack.isNotEmpty,
        sizes: sizes,
      ),
      _ToolButton(
        icon: Icons.redo_rounded,
        onTap: _redo,
        enabled: _redoStack.isNotEmpty,
        sizes: sizes,
      ),
      SizedBox(width: sizes.spacing, height: sizes.spacing),
      _ToolButton(
        icon: Icons.edit_rounded,
        onTap: () => setState(() => _isEraser = false),
        isActive: !_isEraser,
        sizes: sizes,
      ),
      _ToolButton(
        icon: Icons.backspace_rounded,
        onTap: () => setState(() => _isEraser = true),
        isActive: _isEraser,
        sizes: sizes,
      ),
      SizedBox(width: sizes.spacing, height: sizes.spacing),
      _ToolButton(
        icon: Icons.delete_outline_rounded,
        onTap: _clearCanvas,
        sizes: sizes,
      ),
      _ToolButton(
        icon: Icons.palette_rounded,
        onTap: _showColorPicker,
        sizes: sizes,
      ),
      _ToolButton(icon: Icons.save_rounded, onTap: _saveImage, sizes: sizes),
    ];

    if (isVertical) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons
            .map(
              (b) => Padding(
                padding: EdgeInsets.only(bottom: sizes.spacing / 2),
                child: b,
              ),
            )
            .toList(),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.spacing,
        vertical: sizes.spacing / 2,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons
              .map(
                (b) => Padding(
                  padding: EdgeInsets.only(right: sizes.spacing / 2),
                  child: b,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  //build drawable pixel canvas
  Widget _buildCanvas(ResponsiveSizes sizes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = min(
          constraints.maxWidth / _gridWidth,
          constraints.maxHeight / _gridHeight,
        );
        final canvasW = cellSize * _gridWidth;
        final canvasH = cellSize * _gridHeight;
        final offsetX = (constraints.maxWidth - canvasW) / 2;
        final offsetY = (constraints.maxHeight - canvasH) / 2;

        return GestureDetector(
          onPanStart: (d) =>
              _handleDraw(d.localPosition, cellSize, Offset(offsetX, offsetY)),
          onPanUpdate: (d) =>
              _handleDraw(d.localPosition, cellSize, Offset(offsetX, offsetY)),
          child: Stack(
            children: [
              CustomPaint(
                painter: _PixelCanvasPainter(
                  pixels: _pixels,
                  cellSize: cellSize,
                  offset: Offset(offsetX, offsetY),
                  gridWidth: _gridWidth,
                  gridHeight: _gridHeight,
                  shadowOffset: sizes.shadowOffset,
                ),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
              Positioned(
                left: offsetX,
                top: offsetY,
                child: Screenshot(
                  controller: _screenshotController,
                  child: CustomPaint(
                    painter: _PixelCanvasPainter(
                      pixels: _pixels,
                      cellSize: cellSize,
                      offset: Offset.zero,
                      gridWidth: _gridWidth,
                      gridHeight: _gridHeight,
                      shadowOffset: sizes.shadowOffset,
                    ),
                    size: Size(canvasW, canvasH),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build color palette selector
  Widget _buildPalette(ResponsiveSizes sizes, {required bool isVertical}) {
    final colors = _getSortedPalette();

    final currentIndicator = Container(
      width: sizes.paletteSize * 1.4,
      height: sizes.paletteSize * 1.4,
      margin: EdgeInsets.only(bottom: sizes.spacing),
      decoration: AppStyles.voxelBox(
        color: _isEraser ? AppColors.surface : _currentColor,
        shadowColor: AppColors.shadow,
        shadowOffset: 4,
        borderColor: AppColors.secondary,
      ),
      child: _isEraser
          ? Icon(
              Icons.backspace_rounded,
              color: AppColors.textMuted,
              size: sizes.iconSmall,
            )
          : null,
    );

    final swatches = colors
        .map(
          (c) => _ColorSwatch(
            color: c,
            size: sizes.paletteSize,
            isSelected: !_isEraser && _currentColor.value == c.value,
            onTap: () => setState(() {
              _currentColor = c;
              _isEraser = false;
            }),
          ),
        )
        .toList();

    if (isVertical) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            currentIndicator,
            ...swatches.map(
              (s) => Padding(
                padding: EdgeInsets.only(bottom: sizes.spacing / 2),
                child: s,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sizes.spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          currentIndicator,
          Wrap(
            alignment: WrapAlignment.center,
            spacing: sizes.spacing / 2,
            runSpacing: sizes.spacing / 2,
            children: swatches,
          ),
        ],
      ),
    );
  }
}

//toolbar button widget
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool isActive;
  final ResponsiveSizes sizes;

  const _ToolButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.isActive = false,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? AppColors.primary : AppColors.surface;
    final fgColor = isActive
        ? AppColors.background
        : enabled
        ? AppColors.secondary
        : AppColors.textDisabled;
    final shadowColor = isActive
        ? AppColors.primaryDark
        : AppColors.surfaceDark;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: sizes.toolbarButton,
        height: sizes.toolbarButton,
        decoration: AppStyles.voxelBox(
          color: bgColor,
          shadowColor: shadowColor,
          shadowOffset: 4,
        ),
        child: Icon(icon, size: sizes.iconMedium, color: fgColor),
      ),
    );
  }
}

//color palette swatch widget
class _ColorSwatch extends StatelessWidget {
  final Color color;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: AppStyles.voxelBox(
          color: color,
          shadowColor: AppColors.shadow,
          shadowOffset: 3,
          borderColor: isSelected ? AppColors.secondary : null,
        ),
      ),
    );
  }
}

//background grid pattern painter
class _BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 1;

    const spacing = 32.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//main canvas painter for pixel grid
class _PixelCanvasPainter extends CustomPainter {
  final List<List<Color?>> pixels;
  final double cellSize;
  final Offset offset;
  final int gridWidth;
  final int gridHeight;
  final double shadowOffset;

  _PixelCanvasPainter({
    required this.pixels,
    required this.cellSize,
    required this.offset,
    required this.gridWidth,
    required this.gridHeight,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      cellSize * gridWidth,
      cellSize * gridHeight,
    );

    // Shadow
    canvas.drawRect(
      rect.shift(Offset(shadowOffset, shadowOffset)),
      Paint()..color = AppColors.shadow,
    );

    // Background
    canvas.drawRect(rect, Paint()..color = AppColors.surfaceLight);

    // Pixels
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final color = pixels[y][x];
        if (color != null) {
          canvas.drawRect(
            Rect.fromLTWH(
              offset.dx + x * cellSize,
              offset.dy + y * cellSize,
              cellSize,
              cellSize,
            ),
            Paint()..color = color,
          );
        }
      }
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 0.5;

    for (int x = 0; x <= gridWidth; x++) {
      canvas.drawLine(
        Offset(offset.dx + x * cellSize, offset.dy),
        Offset(offset.dx + x * cellSize, offset.dy + gridHeight * cellSize),
        gridPaint,
      );
    }
    for (int y = 0; y <= gridHeight; y++) {
      canvas.drawLine(
        Offset(offset.dx, offset.dy + y * cellSize),
        Offset(offset.dx + gridWidth * cellSize, offset.dy + y * cellSize),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelCanvasPainter old) => true;
}
