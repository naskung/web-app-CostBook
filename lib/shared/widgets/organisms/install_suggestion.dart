import 'package:flutter/material.dart';

import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/helpers/web_app_helper.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/organisms/install_banner.dart';
import 'package:costbook/shared/widgets/organisms/install_guide_dialog.dart';

// แถบแนะนำให้เพิ่ม CostBook ไว้ที่หน้าจอ (บนสุดของทุกหน้า)
// ไม่แสดงเมื่อ: เปิดแบบแอปอยู่แล้ว / กด "ไม่ต้องแนะนำอีก" แล้ว (จำไว้ในเครื่อง) / ไม่ได้เปิดจาก home server
class InstallSuggestion extends StatefulWidget {
  const InstallSuggestion({super.key});

  @override
  State<InstallSuggestion> createState() => _InstallSuggestionState();
}

class _InstallSuggestionState extends State<InstallSuggestion> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!WebAppHelper.canSuggest) return;
    final isDismissed = await WebAppHelper.isDismissed();
    if (!mounted || isDismissed) return;
    setState(() => _isVisible = true);
  }

  Future<void> _add() async {
    final isInstalled = await InstallGuideDialog.start(context);
    if (isInstalled && mounted) setState(() => _isVisible = false);
  }

  Future<void> _dismiss() async {
    setState(() => _isVisible = false);
    await WebAppHelper.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    final padding = ResponsiveHelper.pagePadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
          child: InstallBanner(onAdd: _add, onDismiss: _dismiss),
        ),
      ),
    );
  }
}
