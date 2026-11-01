import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/features/user/bloc/profile_bloc.dart';
import 'package:costbook/features/user/bloc/user_list_bloc.dart';
import 'package:costbook/features/user/models/user_model.dart';
import 'package:costbook/features/user/widgets/reset_password_dialog.dart';
import 'package:costbook/features/user/widgets/role_badge.dart';
import 'package:costbook/features/user/widgets/user_avatar.dart';
import 'package:costbook/features/user/widgets/user_form_dialog.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/organisms/app_data_table.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';
import 'package:costbook/shared/widgets/organisms/page_toolbar.dart';

part 'user_list_page_ext.dart';

// จัดการผู้ใช้ของร้าน (เฉพาะเจ้าของร้าน — คนอื่นเปิดมาเจอ error forbidden จาก API)
class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserListBloc, UserListState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus == AppStatus.success,
          listener: (context, state) {
            SnackbarHelper.showSuccess(context, 'common.saved'.tr);
            context.read<ProfileBloc>().add(ProfileRequested());
          },
        ),
        BlocListener<UserListBloc, UserListState>(
          listenWhen:
              (previous, current) =>
                  previous.resetStatus == AppStatus.loading && current.resetStatus == AppStatus.success,
          listener: (context, state) => SnackbarHelper.showSuccess(context, 'user.reset_password_done'.tr),
        ),
      ],
      child: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          final stateView = _stateView(context, state);
          return PageContent(
            header: _backButton(context),
            centerChild: stateView,
            children: [
              if (stateView == null) ...[_toolbar(context), _table(context, state.users)],
            ],
          );
        },
      ),
    );
  }
}
