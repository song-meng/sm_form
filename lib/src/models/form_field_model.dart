/// 表单字段模型
class FormFieldModel<T> {
  /// 字段名称（唯一标识）
  final String name;

  /// 字段值
  T? value;

  /// 初始值
  final T? initialValue;

  /// 是否必填
  final bool required;

  /// 校验规则列表
  final List<FormFieldValidator<T>> validators;

  /// 是否已校验
  bool validated = false;

  /// 校验错误信息
  String? errorText;

  /// 是否禁用
  bool disabled = false;

  /// 是否只读
  bool readOnly = false;

  /// 字段标签
  final String? label;

  /// 字段提示信息
  final String? hint;

  /// 依赖的字段名称列表（用于联动）
  final List<String> dependencies;

  /// 字段变化回调
  final ValueChanged<T?>? onChanged;

  /// 字段焦点变化回调
  final ValueChanged<bool>? onFocusChange;

  FormFieldModel({
    required this.name,
    T? value,
    this.initialValue,
    this.required = false,
    this.validators = const [],
    this.label,
    this.hint,
    this.dependencies = const [],
    this.onChanged,
    this.onFocusChange,
  }) : value = value ?? initialValue {
    // value 已经在初始化列表中设置：如果传入了 value 就使用 value，否则使用 initialValue
  }

  /// 复制字段模型
  FormFieldModel<T> copyWith({
    String? name,
    T? value,
    T? initialValue,
    bool? required,
    List<FormFieldValidator<T>>? validators,
    bool? validated,
    String? errorText,
    bool? disabled,
    bool? readOnly,
    String? label,
    String? hint,
    List<String>? dependencies,
    ValueChanged<T?>? onChanged,
    ValueChanged<bool>? onFocusChange,
    bool clearErrorText = false, // 新增参数：是否清除错误信息
    bool updateValue = false, // 新增参数：是否更新值（用于区分 null 和不更新）
  }) {
    // 确定要使用的值
    final newValue = updateValue ? value : (value ?? this.value);

    // 如果 updateValue 为 true，传入 null 作为 initialValue，避免构造函数覆盖 value
    final model = FormFieldModel<T>(
      name: name ?? this.name,
      value: newValue,
      initialValue: updateValue ? null : (initialValue ?? this.initialValue),
      required: required ?? this.required,
      validators: validators ?? this.validators,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      dependencies: dependencies ?? this.dependencies,
      onChanged: onChanged ?? this.onChanged,
      onFocusChange: onFocusChange ?? this.onFocusChange,
    )
      ..validated = validated ?? this.validated
      ..disabled = disabled ?? this.disabled
      ..readOnly = readOnly ?? this.readOnly;

    // 如果 updateValue 为 true，确保值被正确设置
    // 即使 newValue 是 null，也要使用它（而不是 initialValue）
    if (updateValue) {
      model.value = newValue;
    }

    // 处理 errorText：如果 clearErrorText 为 true 或 errorText 不为 null，则更新
    if (clearErrorText) {
      model.errorText = null;
    } else {
      model.errorText = errorText ?? this.errorText;
    }

    return model;
  }

  /// 重置字段
  void reset() {
    value = initialValue;
    validated = false;
    errorText = null;
  }

  /// 清除值
  void clear() {
    value = null;
    validated = false;
    errorText = null;
  }
}

/// 字段值变化回调
typedef ValueChanged<T> = void Function(T value);

/// 字段校验器
typedef FormFieldValidator<T> = String? Function(T? value);

/// 异步字段校验器
typedef AsyncFormFieldValidator<T> = Future<String?> Function(T? value);
