/// 表单字段模型
class FormFieldModel<T> {
  /// 字段名称（唯一标识）
  final String name;

  /// 字段值
  T? value;

  /// 初始值
  final T? initialValue;

  /// 是否必填
  bool required;

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

  /// 是否可见（用于联动显示/隐藏）
  bool visible = true;

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
    this.visible = true,
    this.onChanged,
    this.onFocusChange,
  }) : value = value ?? initialValue;

  /// 复制字段模型
  /// 
  /// [clearErrorText] 是否清除错误信息
  /// [updateValue] 是否强制更新值（用于区分 "不传值" 和 "传入 null"）
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
    bool? visible,
    String? label,
    String? hint,
    List<String>? dependencies,
    ValueChanged<T?>? onChanged,
    ValueChanged<bool>? onFocusChange,
    bool clearErrorText = false,
    bool updateValue = false,
  }) {
    // 确定要使用的值
    final T? newValue = updateValue ? value : (value ?? this.value);

    final model = FormFieldModel<T>(
      name: name ?? this.name,
      value: newValue,
      // 如果 updateValue 为 true，不传 initialValue，避免构造函数用 initialValue 覆盖 null 值
      initialValue: updateValue ? null : (initialValue ?? this.initialValue),
      required: required ?? this.required,
      validators: validators ?? this.validators,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      dependencies: dependencies ?? this.dependencies,
      visible: visible ?? this.visible,
      onChanged: onChanged ?? this.onChanged,
      onFocusChange: onFocusChange ?? this.onFocusChange,
    );
    
    // 设置可变属性
    model.validated = validated ?? this.validated;
    model.disabled = disabled ?? this.disabled;
    model.readOnly = readOnly ?? this.readOnly;
    model.visible = visible ?? this.visible;
    
    // 如果 updateValue 为 true，确保值被正确设置（即使是 null）
    if (updateValue) {
      model.value = newValue;
    }

    // 处理 errorText
    if (clearErrorText) {
      model.errorText = null;
    } else if (errorText != null) {
      model.errorText = errorText;
    } else {
      model.errorText = this.errorText;
    }

    return model;
  }

  /// 重置字段（返回新的 FormFieldModel 实例）
  FormFieldModel<T> reset() {
    return copyWith(
      value: initialValue,
      validated: false,
      clearErrorText: true,
      updateValue: true,
    );
  }

  /// 清除值（返回新的 FormFieldModel 实例）
  FormFieldModel<T> clear() {
    return copyWith(
      value: null,
      validated: false,
      clearErrorText: true,
      updateValue: true,
    );
  }
  
  @override
  String toString() {
    return 'FormFieldModel(name: $name, value: $value, required: $required, visible: $visible, validated: $validated, errorText: $errorText)';
  }
}

/// 字段值变化回调
typedef ValueChanged<T> = void Function(T value);

/// 字段校验器
typedef FormFieldValidator<T> = String? Function(T? value);

/// 异步字段校验器
typedef AsyncFormFieldValidator<T> = Future<String?> Function(T? value);
