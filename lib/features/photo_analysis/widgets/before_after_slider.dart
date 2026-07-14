import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Slider de comparação antes/depois (PROMPT 13).
///
/// Revela a foto "antes" sobre a "depois" conforme o controle desliza.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    required this.beforePath,
    required this.afterPath,
    super.key,
  });

  final String beforePath;
  final String afterPath;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(widget.afterPath), fit: BoxFit.cover),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _value.clamp(0.0, 1.0),
                        child: SizedBox(
                          width: w,
                          child: Image.file(File(widget.beforePath),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (w * _value) - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Slider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Antes', style: TextStyle(color: AppColors.textSecondary)),
            Text('Depois', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}
