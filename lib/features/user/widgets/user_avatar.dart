import 'package:flutter/material.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/name_util.dart';
import 'package:costbook/features/user/models/user_model.dart';

// รูปโปรไฟล์วงกลม / ยังไม่มีรูป หรือโหลดไม่ได้ → วงกลมสีส้มกับตัวอักษรย่อของชื่อ
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = AppSizes.avatarSize});

  final UserModel user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(child: SizedBox.square(dimension: size, child: user.hasAvatar ? _photo() : _initial(context)));
  }

  Widget _photo() {
    return Image.network(
      ApiConstants.userAvatarUrl(user.id, user.avatarVersion),
      headers: ApiClient.authHeaders,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _initial(context),
    );
  }

  Widget _initial(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.all(size / 4),
        child: FittedBox(
          child: Text(
            NameUtil.initialOf(user.displayName),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary),
          ),
        ),
      ),
    );
  }
}
