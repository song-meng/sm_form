import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../form_manager.dart';
import '../models/form_field_model.dart' as form_models;

/// 表单组件
class SmForm extends ConsumerStatefulWidget {
  /// 表单 ID（用于区分多个表单）
  final String formId;

  /// 表单字段配置
  final Map<String, form_models.FormFieldModel> fields;

  /// 表单子组件
  final Widget child;

  /// 表单初始化完成回调
  final VoidCallback? onInitialized;

  const SmForm({
    super.key,
    required this.formId,
    required this.fields,
    required this.child,
    this.onInitialized,
  });

  @override
  ConsumerState<SmForm> createState() => _SmFormState();
}

class _SmFormState extends ConsumerState<SmForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    // 将字段转换为 dynamic 类型并注册
    for (final entry in widget.fields.entries) {
      final field = entry.value;
      // 使用类型擦除的方式转换字段
      final dynamicField = _convertToDynamicField(field);
      // 使用 registerField 方法注册
      manager.registerField<dynamic>(dynamicField);
    }
    widget.onInitialized?.call();
  }

  /// 将 FormFieldModel 转换为 FormFieldModel<dynamic>
  form_models.FormFieldModel<dynamic> _convertToDynamicField(
    form_models.FormFieldModel field,
  ) {
    // 创建一个新的校验器列表，将每个校验器包装成接受 dynamic 的函数
    final dynamicValidators = <form_models.FormFieldValidator<dynamic>>[];

    // 使用类型擦除：将整个 field 视为 dynamic 来访问 validators
    final fieldDynamic = field as dynamic;
    final validatorsList = fieldDynamic.validators as List;

    for (final validator in validatorsList) {
      // 将校验器包装成接受 dynamic 的函数
      // 使用 Function 类型来避免类型检查
      final validatorFunc = validator as Function;
      dynamicValidators.add((dynamic value) {
        try {
          final result = validatorFunc(value);
          return result as String?;
        } catch (e) {
          // 如果类型转换失败，返回 null（不显示错误）
          return null;
        }
      });
    }

    return form_models.FormFieldModel<dynamic>(
      name: field.name,
      value: field.value,
      initialValue: field.initialValue,
      required: field.required,
      validators: dynamicValidators,
      label: field.label,
      hint: field.hint,
      dependencies: field.dependencies,
      onChanged: field.onChanged != null
          ? (dynamic value) {
              try {
                final onChangedFunc = field.onChanged as Function;
                onChangedFunc(value);
              } catch (e) {
                // 忽略类型转换错误
              }
            }
          : null,
      onFocusChange: field.onFocusChange,
    )
      ..validated = field.validated
      ..errorText = field.errorText
      ..disabled = field.disabled
      ..readOnly = field.readOnly;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
