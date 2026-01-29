import '../models/form_field_model.dart';

/// 字段转换工具类
class FieldConverter {
  /// 将 FormFieldModel<T> 转换为 FormFieldModel<dynamic>
  /// 这是为了在表单管理器中统一处理不同类型的字段
  static FormFieldModel<dynamic> toDynamic<T>(FormFieldModel<T> field) {
    // 创建一个新的校验器列表，将每个校验器包装成接受 dynamic 的函数
    final dynamicValidators = <FormFieldValidator<dynamic>>[];

    for (final validator in field.validators) {
      dynamicValidators.add((dynamic value) {
        try {
          return validator(value as T?);
        } catch (e) {
          // 如果类型转换失败，返回 null（不显示错误）
          return null;
        }
      });
    }

    return FormFieldModel<dynamic>(
      name: field.name,
      value: field.value,
      initialValue: field.initialValue,
      required: field.required,
      validators: dynamicValidators,
      label: field.label,
      hint: field.hint,
      dependencies: field.dependencies,
      visible: field.visible,
      onChanged: field.onChanged != null
          ? (dynamic value) {
              try {
                field.onChanged!(value as T?);
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

  /// 批量转换字段为 dynamic 类型
  static Map<String, FormFieldModel<dynamic>> convertAll(
    Map<String, FormFieldModel> fields,
  ) {
    final result = <String, FormFieldModel<dynamic>>{};
    for (final entry in fields.entries) {
      result[entry.key] = _convertField(entry.value);
    }
    return result;
  }

  /// 内部方法：使用类型擦除转换单个字段
  static FormFieldModel<dynamic> _convertField(FormFieldModel field) {
    final fieldDynamic = field as dynamic;
    final validatorsList = fieldDynamic.validators as List;

    final dynamicValidators = <FormFieldValidator<dynamic>>[];
    for (final validator in validatorsList) {
      final validatorFunc = validator as Function;
      dynamicValidators.add((dynamic value) {
        try {
          final result = validatorFunc(value);
          return result as String?;
        } catch (e) {
          return null;
        }
      });
    }

    return FormFieldModel<dynamic>(
      name: field.name,
      value: field.value,
      initialValue: field.initialValue,
      required: field.required,
      validators: dynamicValidators,
      label: field.label,
      hint: field.hint,
      dependencies: field.dependencies,
      visible: field.visible,
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
}
