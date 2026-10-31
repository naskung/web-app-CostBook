import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/helpers/snackbar_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';
import 'package:costbook/features/cost/widgets/cost_item_dialog.dart';
import 'package:costbook/features/cost/widgets/cost_presets_dialog.dart';
import 'package:costbook/features/settings/bloc/settings_bloc.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/shared/widgets/atoms/app_button.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_loading.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';
import 'package:costbook/shared/widgets/atoms/money_text.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';
import 'package:costbook/shared/widgets/molecules/error_view.dart';
import 'package:costbook/shared/widgets/molecules/notice_banner.dart';
import 'package:costbook/shared/widgets/molecules/section_card.dart';
import 'package:costbook/shared/widgets/organisms/page_content.dart';

part 'cost_page_ext.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  final _batchController = TextEditingController();
  final _markupController = TextEditingController();
  final _sellPriceController = TextEditingController();

  @override
  void dispose() {
    _batchController.dispose();
    _markupController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  void _syncControllers(CostSheetModel sheet) {
    if (int.tryParse(_batchController.text) != sheet.batchQuantity) {
      _batchController.text = sheet.batchQuantity.toString();
    }
    if (MoneyUtil.parse(_sellPriceController.text) != sheet.sellPrice) {
      _sellPriceController.text = sheet.sellPrice.toString();
    }
  }

  Future<void> _addItem(String type) async {
    final bloc = context.read<CostBloc>();
    final result = await CostItemDialog.show(
      context,
      item: CostItemModel(type: type, name: ''),
      presets: bloc.state.presets,
    );
    if (result == null) return;
    bloc.add(CostItemAdded(result.item));
    if (result.remember) bloc.add(CostPresetSaved(CostPresetModel.fromItem(result.item)));
  }

  Future<void> _editItem(CostItemModel item) async {
    final bloc = context.read<CostBloc>();
    final result = await CostItemDialog.show(context, item: item, presets: bloc.state.presets);
    if (result != null) bloc.add(CostItemChanged(oldItem: item, newItem: result.item));
  }

  void _onSaveResult(BuildContext context, CostState state) {
    if (state.saveStatus == AppStatus.success) {
      SnackbarHelper.showSuccess(context, 'common.saved'.tr);
      return;
    }
    SnackbarHelper.showError(context, 'error.${state.saveErrorCode}'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CostBloc, CostState>(
          listenWhen: (previous, current) => current.sheet != null && previous.sheet != current.sheet,
          listener: (context, state) => _syncControllers(state.sheet ?? const CostSheetModel(productId: '')),
        ),
        BlocListener<CostBloc, CostState>(
          listenWhen:
              (previous, current) =>
                  previous.saveStatus == AppStatus.loading && current.saveStatus != AppStatus.loading,
          listener: _onSaveResult,
        ),
      ],
      child: BlocBuilder<CostBloc, CostState>(builder: _content),
    );
  }

  Widget _content(BuildContext context, CostState state) {
    if (state.status == AppStatus.initial || state.status == AppStatus.loading) return const AppLoading();
    if (state.status == AppStatus.failure) {
      return ErrorView(
        message: 'error.${state.errorCode}'.tr,
        retryLabel: 'common.retry'.tr,
        onRetry: () => context.read<CostBloc>().add(CostPageOpened()),
      );
    }
    if (state.products.isEmpty) return _noProducts(context, state);
    return PageContent(
      children: [
        _productPicker(context, state),
        if (state.isDirty) NoticeBanner(message: 'cost.unsaved'.tr),
        _sheetArea(context, state),
      ],
    );
  }
}
