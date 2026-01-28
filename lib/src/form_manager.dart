import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'models/form_field_model.dart';
import 'models/form_state.dart' as form_models;

/// 表单管理器
class FormManager extends StateNotifier<form_models.FormState> {
  /// 字段的 GlobalKey 映射，用于滚动定位
  final Map<String, GlobalKey> _fieldKeys = {};
  FormManager({
    Map<String, FormFieldModel<dynamic>>? initialFields,
  }) : super(
          form_models.FormState(
            fields: initialFields ?? {},
          ),
        );

  /// 注册字段
  void registerField<T>(FormFieldModel<T> field) {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    // 将校验器转换为接受 dynamic 的类型
    final dynamicValidators = field.validators.map((validator) => (dynamic value) => validator(value as T?)).toList();
    final dynamicField = FormFieldModel<dynamic>(
      name: field.name,
      value: field.value,
      initialValue: field.initialValue,
      required: field.required,
      validators: dynamicValidators,
      label: field.label,
      hint: field.hint,
      dependencies: field.dependencies,
      onChanged: field.onChanged != null ? (dynamic value) => field.onChanged!(value as T?) : null,
      onFocusChange: field.onFocusChange,
    )
      ..validated = field.validated
      ..errorText = field.errorText
      ..disabled = field.disabled
      ..readOnly = field.readOnly;
    fields[field.name] = dynamicField;
    state = state.copyWith(fields: fields);
  }

  /// 注册多个字段
  void registerFields(Map<String, FormFieldModel<dynamic>> fields) {
    for (final field in fields.values) {
      // 由于字段已经是 dynamic 类型，直接注册
      final newFields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
      newFields[field.name] = field;
      state = state.copyWith(fields: newFields);
    }
  }

  /// 更新字段值
  void updateValue<T>(String name, T? value) {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    final field = fields[name];
    if (field == null) return;

    // 如果新值和旧值相同，不需要更新（避免不必要的状态更新和循环调用）
    if (field.value == value) {
      return;
    }

    // 更新字段值，先清除错误信息
    // 使用 updateValue: true 来确保即使 value 为 null 也能正确更新
    var updatedField = field.copyWith(
      value: value,
      clearErrorText: true, // 清除错误信息
      updateValue: true, // 明确标记要更新值
    );

    // 触发字段变化回调（在更新状态之前，避免在回调中再次触发更新）
    try {
      updatedField.onChanged?.call(value);
    } catch (e) {
      // 忽略回调中的错误，避免影响状态更新
      if (kDebugMode) {
        print('Error in onChanged callback for $name: $e');
      }
    }

    // 清除之前的错误
    final errors = Map<String, String?>.from(state.errors);
    errors.remove(name);

    // 如果字段已经校验过，立即重新校验以更新状态
    // 这样用户输入后可以立即看到错误信息的清除或更新
    String? newErrorText;
    if (field.validated) {
      // 执行同步校验器
      for (final validator in updatedField.validators) {
        final error = validator(updatedField.value);
        if (error != null) {
          newErrorText = error;
          break;
        }
      }

      // 更新字段的错误信息和校验状态
      if (newErrorText != null) {
        // 有新错误，设置错误信息
        updatedField = updatedField.copyWith(
          errorText: newErrorText,
          validated: true, // 保持已校验状态
        );
        errors[name] = newErrorText;
      } else {
        // 新值有效，确保错误信息被清除
        updatedField = updatedField.copyWith(
          clearErrorText: true,
          validated: true, // 保持已校验状态
        );
        // errors[name] 已经被移除，不需要额外处理
      }
    }
    // 如果字段未校验过，错误信息已经被清除，不需要额外处理
    // 字段会在失去焦点时（validateOnBlur）或提交时进行校验

    // 更新字段到 fields map
    fields[name] = updatedField;

    // 计算表单是否有效
    final isValid = _calculateIsValid(fields, errors);

    state = state.copyWith(
      fields: fields,
      errors: errors,
      isValid: isValid,
      isDirty: true,
    );

    // 处理字段联动
    _handleDependencies(name, value);
  }

  /// 校验单个字段
  Future<bool> validateField(String name) async {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    final field = fields[name];
    if (field == null) return true;

    String? errorText;

    // 执行同步校验器
    for (final validator in field.validators) {
      final error = validator(field.value);
      if (error != null) {
        errorText = error;
        break;
      }
    }

    // 更新字段状态
    final updatedField = field.copyWith(
      validated: true,
      errorText: errorText,
    );
    fields[name] = updatedField;

    // 更新错误信息
    final errors = Map<String, String?>.from(state.errors);
    if (errorText != null) {
      errors[name] = errorText;
    } else {
      errors.remove(name);
    }

    // 计算表单是否有效
    final isValid = _calculateIsValid(fields, errors);

    state = state.copyWith(
      fields: fields,
      errors: errors,
      isValid: isValid,
    );

    return errorText == null;
  }

  /// 校验所有字段
  Future<bool> validateAll() async {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    final errors = <String, String?>{};
    bool allValid = true;

    for (final entry in fields.entries) {
      final field = entry.value;
      String? errorText;

      // 执行同步校验器
      for (final validator in field.validators) {
        final error = validator(field.value);
        if (error != null) {
          errorText = error;
          allValid = false;
          break;
        }
      }

      // 更新字段状态
      fields[entry.key] = field.copyWith(
        validated: true,
        errorText: errorText,
      );

      if (errorText != null) {
        errors[entry.key] = errorText;
      }
    }

    final isValid = _calculateIsValid(fields, errors);

    state = state.copyWith(
      fields: fields,
      errors: errors,
      validated: true,
      isValid: isValid,
    );

    return allValid;
  }

  /// 注册字段的 GlobalKey
  void registerFieldKey(String name, GlobalKey key) {
    _fieldKeys[name] = key;
  }

  /// 注销字段的 GlobalKey
  void unregisterFieldKey(String name) {
    _fieldKeys.remove(name);
  }

  /// 获取第一个有错误的字段名称
  String? getFirstErrorFieldName() {
    // 先检查 errors map
    if (state.errors.isNotEmpty) {
      return state.errors.keys.first;
    }

    // 再检查字段的 errorText
    for (final entry in state.fields.entries) {
      if (entry.value.errorText != null) {
        return entry.key;
      }
    }

    // 检查必填但未填写的字段
    for (final entry in state.fields.entries) {
      final field = entry.value;
      if (field.required) {
        final value = field.value;
        if (value == null || (value is String && value.trim().isEmpty)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// 滚动到指定的字段
  void scrollToField(String name, {Duration duration = const Duration(milliseconds: 300)}) {
    final key = _fieldKeys[name];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: duration,
        curve: Curves.easeInOut,
        alignment: 0.1, // 滚动后字段位置在视口上方 10% 处
      );
    }
  }

  /// 滚动到第一个有错误的字段
  void scrollToFirstErrorField({Duration duration = const Duration(milliseconds: 300)}) {
    final firstErrorFieldName = getFirstErrorFieldName();
    if (firstErrorFieldName != null) {
      scrollToField(firstErrorFieldName, duration: duration);
    }
  }

  /// 提交表单
  Future<Map<String, dynamic>?> submit({
    required Future<Map<String, dynamic>?> Function(Map<String, dynamic> values) onSubmit,
    bool scrollToError = true, // 是否滚动到第一个错误字段
  }) async {
    // 先校验所有字段
    final isValid = await validateAll();
    if (!isValid) {
      // 如果校验失败，滚动到第一个错误字段
      if (scrollToError) {
        // 延迟一下，确保 UI 已经更新
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollToFirstErrorField();
        });
      }
      return null;
    }

    state = state.copyWith(submitting: true);

    try {
      final values = state.getValues();
      final result = await onSubmit(values);
      state = state.copyWith(
        submitted: true,
        submitting: false,
      );
      return result;
    } catch (e) {
      state = state.copyWith(submitting: false);
      rethrow;
    }
  }

  /// 重置表单
  void reset() {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    for (final field in fields.values) {
      field.reset();
    }

    state = form_models.FormState(
      fields: fields,
    );
  }

  /// 清除表单
  void clear() {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    for (final field in fields.values) {
      field.clear();
    }

    state = form_models.FormState(
      fields: fields,
    );
  }

  /// 设置字段错误
  void setFieldError(String name, String? error) {
    final errors = Map<String, String?>.from(state.errors);
    if (error != null) {
      errors[name] = error;
    } else {
      errors.remove(name);
    }

    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    final field = fields[name];
    if (field != null) {
      fields[name] = field.copyWith(errorText: error);
    }

    final isValid = _calculateIsValid(fields, errors);

    state = state.copyWith(
      fields: fields,
      errors: errors,
      isValid: isValid,
    );
  }

  /// 启用/禁用字段
  void setFieldEnabled(String name, bool enabled) {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    final field = fields[name];
    if (field == null) return;

    fields[name] = field.copyWith(disabled: !enabled);
    state = state.copyWith(fields: fields);
  }

  /// 批量更新表单值（patch）
  /// 一次性设置多个字段的值，并自动触发联动
  ///
  /// [values] 要更新的字段值映射
  /// [skipValidation] 是否跳过校验（默认 false，会清除错误信息但不进行校验）
  void patch(Map<String, dynamic> values, {bool skipValidation = false}) {
    if (values.isEmpty) return;

    // 获取所有字段的依赖关系，用于确定更新顺序
    // 先更新被依赖的字段，再更新依赖字段
    final fieldNames = _getUpdateOrder(values.keys.toList());

    // 批量更新字段值
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);
    final errors = Map<String, String?>.from(state.errors);
    final updatedFields = <String>{};

    for (final fieldName in fieldNames) {
      if (!values.containsKey(fieldName)) continue;

      final field = fields[fieldName];
      if (field == null) continue;

      final newValue = values[fieldName];

      // 如果新值和旧值相同，跳过
      if (field.value == newValue) continue;

      // 更新字段值
      var updatedField = field.copyWith(
        value: newValue,
        clearErrorText: true,
        updateValue: true,
      );

      // 触发字段变化回调
      try {
        updatedField.onChanged?.call(newValue);
      } catch (e) {
        if (kDebugMode) {
          print('Error in onChanged callback for $fieldName: $e');
        }
      }

      // 清除错误信息
      errors.remove(fieldName);

      // 如果不需要跳过校验且字段已校验过，进行校验
      if (!skipValidation && field.validated) {
        String? newErrorText;
        for (final validator in updatedField.validators) {
          final error = validator(updatedField.value);
          if (error != null) {
            newErrorText = error;
            break;
          }
        }

        if (newErrorText != null) {
          updatedField = updatedField.copyWith(
            errorText: newErrorText,
            validated: true,
          );
          errors[fieldName] = newErrorText;
        } else {
          updatedField = updatedField.copyWith(
            clearErrorText: true,
            validated: true,
          );
        }
      }

      fields[fieldName] = updatedField;
      updatedFields.add(fieldName);
    }

    // 计算表单是否有效
    final isValid = _calculateIsValid(fields, errors);

    // 更新状态
    state = state.copyWith(
      fields: fields,
      errors: errors,
      isValid: isValid,
      isDirty: true,
    );

    // 处理字段联动（按照依赖顺序处理）
    for (final fieldName in fieldNames) {
      if (updatedFields.contains(fieldName)) {
        final value = values[fieldName];
        _handleDependencies(fieldName, value);
      }
    }
  }

  /// 获取字段更新顺序（考虑依赖关系）
  /// 返回一个列表，按照依赖顺序排列，被依赖的字段在前
  List<String> _getUpdateOrder(List<String> fieldNames) {
    if (fieldNames.isEmpty) return [];

    // 构建依赖图
    final dependencyGraph = <String, Set<String>>{};
    final allFields = state.fields;

    for (final fieldName in fieldNames) {
      final field = allFields[fieldName];
      if (field != null) {
        dependencyGraph[fieldName] = field.dependencies.where((dep) => fieldNames.contains(dep)).toSet();
      } else {
        dependencyGraph[fieldName] = {};
      }
    }

    // 拓扑排序
    final result = <String>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(String fieldName) {
      if (visited.contains(fieldName)) return;
      if (visiting.contains(fieldName)) {
        // 检测到循环依赖，直接添加（避免死循环）
        return;
      }

      visiting.add(fieldName);
      final dependencies = dependencyGraph[fieldName] ?? {};
      for (final dep in dependencies) {
        if (fieldNames.contains(dep)) {
          visit(dep);
        }
      }
      visiting.remove(fieldName);
      visited.add(fieldName);
      result.add(fieldName);
    }

    for (final fieldName in fieldNames) {
      visit(fieldName);
    }

    return result;
  }

  /// 处理字段联动
  void _handleDependencies(String changedFieldName, dynamic value) {
    final fields = Map<String, FormFieldModel<dynamic>>.from(state.fields);

    // 查找依赖此字段的其他字段
    for (final entry in fields.entries) {
      final field = entry.value;
      if (field.dependencies.contains(changedFieldName)) {
        // 触发依赖字段的变化回调
        // 注意：这里调用的是依赖字段的 onChanged，传入的是依赖字段自己的值
        // 而不是变化字段的值，这样可以避免循环调用
        try {
          field.onChanged?.call(field.value);
        } catch (e) {
          // 忽略回调中的错误，避免影响其他字段
          if (kDebugMode) {
            print('Error in dependency callback for ${entry.key}: $e');
          }
        }
      }
    }
  }

  /// 计算表单是否有效
  bool _calculateIsValid(
    Map<String, FormFieldModel<dynamic>> fields,
    Map<String, String?> errors,
  ) {
    if (errors.isNotEmpty) return false;

    for (final field in fields.values) {
      if (field.required && (field.value == null || (field.value is String && (field.value as String).trim().isEmpty))) {
        return false;
      }
    }

    return true;
  }
}

/// 表单管理器 Provider
final formManagerProvider = StateNotifierProvider.family<FormManager, form_models.FormState, String>(
  (ref, formId) => FormManager(),
);
