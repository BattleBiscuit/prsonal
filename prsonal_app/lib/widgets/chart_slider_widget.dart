import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class ChartSlider extends StatefulWidget {
  const ChartSlider({super.key, required this.pages, required this.titles});

  final List<Widget> pages;
  final List<String> titles;

  @override
  State<ChartSlider> createState() => _ChartSliderState();
}

class _ChartSliderState extends State<ChartSlider> {
  final PageController _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Column(
      children: [
        Text(
          widget.titles[_page],
          style: TextStyle(
            color: colors.text1,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageView(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            children: widget.pages,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pages.length,
            (i) => GestureDetector(
              onTap: () {
                _ctrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                key: const Key('chart-slider-dot'),
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _page == i ? colors.accent : colors.text3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
