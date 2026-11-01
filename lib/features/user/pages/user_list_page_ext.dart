part of 'user_list_page.dart';

extension _UserListPageExt on UserListPage {
  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
        child: TextButton.icon(
          onPressed: () => context.go(AppRoutes.profile),
          icon: const Icon(Icons.arrow_back),
          label: Text('user.back'.tr),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return PageToolbar(
      actions: [
        FilledButton.icon(
          onPressed: () => UserFormDialog.show(context, const UserModel()),
          icon: const Icon(Icons.person_add_alt),
          label: Text('user.add'.tr),
        ),
      ],
      children: [Text('user.subtitle'.tr, style: Theme.of(context).textTheme.bodySmall)],
    );
  }

  Widget? _stateView(BuildContext context, UserListState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure && state.errorCode == 'forbidden') {
      return EmptyView(message: 'error.forbidden'.tr, icon: Icons.lock_outline);
    }
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<UserListBloc>().add(UsersRequested()),
      );
    }
    return null;
  }

  Widget _table(BuildContext context, List<UserModel> users) {
    final myId = context.select<ProfileBloc, String>((bloc) => bloc.state.user.id);
    return AppDataTable(
      columns: [
        AppDataColumn(label: 'user.name'.tr, flex: 5),
        AppDataColumn(label: 'user.role'.tr, flex: 2),
        AppDataColumn(label: 'user.status'.tr, flex: 2),
        const AppDataColumn(label: '', flex: 2, alignEnd: true),
      ],
      onRowTap: (index) => _edit(context, users[index], myId),
      rows: [
        for (final user in users)
          [
            _nameCell(context, user, isSelf: user.id == myId),
            RoleBadge(role: user.role),
            _statusBadge(user),
            _actions(context, user, myId),
          ],
      ],
    );
  }

  void _edit(BuildContext context, UserModel user, String myId) {
    UserFormDialog.show(context, user, isSelf: user.id == myId);
  }

  Widget _nameCell(BuildContext context, UserModel user, {required bool isSelf}) {
    final textTheme = Theme.of(context).textTheme;
    final name = isSelf ? 'user.you'.trParams({'name': user.displayName}) : user.displayName;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(user: user),
        const SizedBox(width: AppSizes.spaceMedium),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(user.email, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(UserModel user) {
    if (user.isActive) {
      return AppBadge(text: 'user.active'.tr, color: AppColors.success, backgroundColor: AppColors.successSoft);
    }
    return AppBadge(text: 'user.inactive'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft);
  }

  Widget _actions(BuildContext context, UserModel user, String myId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'common.edit'.tr,
          onPressed: () => _edit(context, user, myId),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'user.reset_password'.tr,
          onPressed: () => ResetPasswordDialog.show(context, user),
          icon: const Icon(Icons.lock_reset),
        ),
      ],
    );
  }
}
