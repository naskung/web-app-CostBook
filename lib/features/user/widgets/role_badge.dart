import 'package:flutter/material.dart';

import 'package:costbook/core/constants/user_role.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return AppBadge(text: role.labelKey.tr, color: _color(), backgroundColor: _background());
  }

  Color _color() {
    if (role == UserRole.owner) return AppColors.primaryDark;
    if (role == UserRole.manager) return AppColors.info;
    return AppColors.textSecondary;
  }

  Color _background() {
    if (role == UserRole.owner) return AppColors.primarySoft;
    if (role == UserRole.manager) return AppColors.infoSoft;
    return AppColors.neutralSoft;
  }
}
