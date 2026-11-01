import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

// เนื้อหาของทุกหน้า: เลื่อนขึ้นลงได้ / header = แถบบนที่ติดอยู่กับที่ตอนเลื่อน (เช่น ปุ่มกลับ)
// เลื่อนลงเกิน scrollTopThreshold → มีปุ่มลูกศรมุมขวาล่าง (เหนือปุ่มแชท) กดแล้วเลื่อนกลับขึ้นบนสุด
class PageContent extends StatefulWidget {
  const PageContent({
    super.key,
    required this.children,
    this.centerChild,
    this.header,
    this.maxWidth = AppSizes.contentMaxWidth,
  });

  final List<Widget> children;
  final Widget? centerChild;
  final Widget? header;
  final double maxWidth;

  static const Duration scrollTopDuration = Duration(milliseconds: 400);
  static const Duration fadeDuration = Duration(milliseconds: 200);

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  final _controller = ScrollController();
  bool _isScrolled = false;
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _controller.offset > 0;
    final showTopButton = _controller.offset > AppSizes.scrollTopThreshold;
    if (isScrolled == _isScrolled && showTopButton == _showTopButton) return;
    setState(() {
      _isScrolled = isScrolled;
      _showTopButton = showTopButton;
    });
  }

  void _scrollToTop() {
    _controller.animateTo(0, duration: PageContent.scrollTopDuration, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final padding = _padding(context);
    final header = widget.header;
    return Stack(
      children: [
        Column(
          children: [
            if (header != null) _stickyHeader(header, padding),
            Expanded(child: _scrollView(padding, hasHeader: header != null)),
          ],
        ),
        Positioned(right: AppSizes.scrollTopRight, bottom: AppSizes.scrollTopBottom, child: _topButton()),
      ],
    );
  }

  // แถบบนติดอยู่กับที่ — เลื่อนแล้วมีเส้นบาง ๆ ด้านล่าง ให้รู้ว่าเนื้อหาเลื่อนอยู่ข้างใต้
  Widget _stickyHeader(Widget header, double padding) {
    return AnimatedContainer(
      duration: PageContent.fadeDuration,
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: _isScrolled ? AppColors.border : AppColors.transparent)),
      ),
      child: _limitWidth(header),
    );
  }

  Widget _scrollView(double padding, {required bool hasHeader}) {
    final centerChild = widget.centerChild;
    final bottom = padding + AppSizes.chatLauncherSpace;
    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(padding, hasHeader ? 0 : padding, padding, centerChild != null ? 0 : bottom),
          sliver: SliverToBoxAdapter(
            child: _limitWidth(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children)),
          ),
        ),
        if (centerChild != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(padding: EdgeInsets.only(bottom: bottom), child: _limitWidth(centerChild)),
          ),
      ],
    );
  }

  Widget _topButton() {
    return IgnorePointer(
      ignoring: !_showTopButton,
      child: AnimatedScale(
        scale: _showTopButton ? 1 : 0,
        duration: PageContent.fadeDuration,
        child: FloatingActionButton.small(
          heroTag: null,
          tooltip: 'common.scroll_top'.tr,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
          onPressed: _scrollToTop,
          child: const Icon(Icons.keyboard_arrow_up),
        ),
      ),
    );
  }

  Widget _limitWidth(Widget child) {
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: widget.maxWidth), child: child));
  }

  double _padding(BuildContext context) {
    if (ResponsiveHelper.screenType(context) == ScreenType.mobile) return AppSizes.spaceMedium;
    return AppSizes.spaceLarge;
  }
}
