import 'form_field_model.dart';

/// 表单状态
class FormState {
  /// 所有字段
  final Map<String, FormFieldModel<dynamic>> fields;

  /// 表单是否已提交
  final bool submitted;

  /// 表单是否正在提交
  final bool submitting;

  /// 表单是否已验证
  final bool validated;

  /// 表单是否有效
  final bool isValid;

  /// 表单是否已修改
  final bool isDirty;

  /// 表单错误信息
  final Map<String, String?> errors;

  FormState({
    required this.fields,
    this.submitted = false,
    this.submitting = false,
    this.validated = false,
    this.isValid = true,
    this.isDirty = false,
    Map<String, String?>? errors,
  }) : errors = errors ?? {};

  /// 复制状态
  FormState copyWith({
    Map<String, FormFieldModel<dynamic>>? fields,
    bool? submitted,
    bool? submitting,
    bool? validated,
    bool? isValid,
    bool? isDirty,
    Map<String, String?>? errors,
  }) {
    return FormState(
      fields: fields ?? this.fields,
      submitted: submitted ?? this.submitted,
      submitting: submitting ?? this.submitting,
      validated: validated ?? this.validated,
      isValid: isValid ?? this.isValid,
      isDirty: isDirty ?? this.isDirty,
      errors: errors ?? this.errors,
    );
  }

  /// 获取字段值
  T? getValue<T>(String name) {
    final field = fields[name];
    if (field == null) return null;
    return field.value as T?;
  }

  /// 获取所有表单值
  Map<String, dynamic> getValues() {
    final values = <String, dynamic>{};
    for (final entry in fields.entries) {
      values[entry.key] = entry.value.value;
    }
    return values;
  }

  /// 检查字段是否有错误
  bool hasError(String name) {
    return errors[name] != null || fields[name]?.errorText != null;
  }

  /// 获取字段错误信息
  String? getError(String name) {
    // 优先返回 errors map 中的错误，如果不存在则返回字段的 errorText
    // 如果 errors[name] 存在且不为空，返回它
    if (errors.containsKey(name) && errors[name] != null) {
      return errors[name];
    }
    // 否则返回字段的 errorText（可能为 null）
    return fields[name]?.errorText;
  }
}
