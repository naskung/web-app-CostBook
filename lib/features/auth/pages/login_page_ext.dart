part of 'login_page.dart';

extension _LoginPageExt on _LoginPageState {
  bool _isMobile(BuildContext context) {
    return ResponsiveHelper.screenType(context) == ScreenType.mobile;
  }

  double _pagePadding(BuildContext context) {
    if (_isMobile(context)) return AppSizes.spaceMedium;
    return AppSizes.spaceLarge;
  }

  double _cardPadding(BuildContext context) {
    if (_isMobile(context)) return AppSizes.spaceLarge;
    return AppSizes.spaceXLarge;
  }

  Widget _content(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
      child: Column(
        children: [
          _brand(context),
          const SizedBox(height: AppSizes.spaceXLarge),
          _formCard(context),
        ],
      ),
    );
  }

  Widget _brand(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        _shopLogo(),
        const SizedBox(height: AppSizes.spaceMedium),
        Text('app.name'.tr, style: textTheme.headlineSmall?.copyWith(color: AppColors.onDark)),
        const SizedBox(height: AppSizes.spaceSmall),
        Text(
          'app.tagline'.tr,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.onDarkSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _shopLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Image.network(
        ApiConstants.companyLogoUrl,
        width: AppSizes.logoSize,
        height: AppSizes.logoSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultLogo(),
      ),
    );
  }

  Widget _defaultLogo() {
    return Container(
      width: AppSizes.logoSize,
      height: AppSizes.logoSize,
      color: AppColors.primary,
      child: const Icon(Icons.menu_book_rounded, color: AppColors.onPrimary, size: AppSizes.iconBox),
    );
  }

  Widget _formCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_cardPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title(context),
            const SizedBox(height: AppSizes.spaceXLarge),
            _emailField(),
            const SizedBox(height: AppSizes.spaceLarge),
            _passwordField(),
            const SizedBox(height: AppSizes.spaceMedium),
            _rememberMeTile(context),
            const SizedBox(height: AppSizes.spaceLarge),
            _submitArea(),
          ],
        ),
      ),
    );
  }

  Widget _submitArea() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.status == AppStatus.failure) _errorText(context, state.errorCode),
            AppButton(
              text: 'login.submit'.tr,
              isLoading: state.status == AppStatus.loading,
              onPressed: _onLogin,
            ),
          ],
        );
      },
    );
  }

  Widget _errorText(BuildContext context, String errorCode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Text(
        'error.$errorCode'.tr,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _title(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('login.title'.tr, style: textTheme.headlineSmall),
        const SizedBox(height: AppSizes.spaceSmall),
        Text('login.subtitle'.tr, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _emailField() {
    return AppTextField(
      label: 'login.email'.tr,
      hint: 'login.email_hint'.tr,
      controller: _emailController,
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: ValidatorUtil.email,
    );
  }

  Widget _passwordField() {
    return AppTextField(
      label: 'login.password'.tr,
      hint: 'login.password_hint'.tr,
      controller: _passwordController,
      icon: Icons.lock_outline,
      isPassword: true,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: ValidatorUtil.required,
      onSubmitted: (_) => _onLogin(),
    );
  }

  Widget _rememberMeTile(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => _onRememberMeChanged(!_rememberMe),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSmall),
          child: Row(
            children: [
              SizedBox.square(
                dimension: AppSizes.checkboxSize,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: _onRememberMeChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmall),
              Expanded(child: Text('login.remember_me'.tr, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        ),
      ),
    );
  }
}
