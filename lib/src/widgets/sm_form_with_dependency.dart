import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../form_manager.dart';
import '../models/form_field_model.dart' as form_models;
import '../models/form_state.dart' as form_state;
import '../models/form_dependency.dart';

/// 支持联动的表单组件
class SmFormWithDependency extends ConsumerStatefulWidget {
  /// 表单 ID（用于区分多个表单）
  final String formId;

  /// 表单字段配置
  final Map<String, form_models.FormFieldModel> fields;

  /// 表单联动配置
  final List<FormFieldDependency>? dependencies;

  /// 表单子组件
  final Widget child;

  /// 表单初始化完成回调
  final VoidCallback? onInitialized;

  const SmFormWithDependency({
    super.key,
    required this.formId,
    required this.fields,
    required this.child,
    this.dependencies,
    this.onInitialized,
  });

  @override
  ConsumerState<SmFormWithDependency> createState() => _SmFormWithDependencyState();
}

class _SmFormWithDependencyState extends ConsumerState<SmFormWithDependency> {
  // 存储字段的选项提供函数（用于动态更新选项）
  final Map<String, List<dynamic> Function(dynamic)> _optionsProviders = {};
  bool _initialized = false;
  // 跟踪已经设置监听的依赖字段名称，避免重复监听
  final Set<String> _listenedDependencies = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    // 初始化基础表单
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    for (final entry in widget.fields.entries) {
      final field = entry.value;
      final dynamicField = _convertToDynamicField(field);
      manager.registerField<dynamic>(dynamicField);
    }

    _initialized = true;
    widget.onInitialized?.call();
  }

  void _setupDependency(FormFieldDependency dependency) {
    // 监听依赖字段的变化
    ref.listen<form_state.FormState>(
      formManagerProvider(widget.formId),
      (previous, next) {
        if (previous == null) return;

        // 检查每个规则，找到第一个匹配的规则
        FormDependencyRule? matchedRule;
        dynamic depValue;

        for (final rule in dependency.rules) {
          depValue = next.getValue(rule.dependsOn);
          final prevDepValue = previous.getValue(rule.dependsOn);

          // 如果依赖字段的值变化了，且满足条件
          if (depValue != prevDepValue && rule.condition(depValue)) {
            matchedRule = rule;
            break; // 只应用第一个匹配的规则
          }
        }

        // 如果没有匹配的规则，检查是否需要清除值
        if (matchedRule == null) {
          // 检查所有依赖字段，如果都不满足条件，可能需要清除值
          for (final rule in dependency.rules) {
            depValue = next.getValue(rule.dependsOn);
            if (!rule.condition(depValue) && rule.clearValue) {
              final manager = ref.read(formManagerProvider(widget.formId).notifier);
              manager.updateValue(dependency.fieldName, null);
            }
          }
        } else if (depValue != null) {
          _applyRule(dependency.fieldName, matchedRule, depValue);
        }
      },
    );
  }

  void _applyRule(
    String fieldName,
    FormDependencyRule rule,
    dynamic depValue,
  ) {
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    final formState = ref.read(formManagerProvider(widget.formId));

    // 更新显示/隐藏
    if (rule.visible != null) {
      manager.setFieldEnabled(fieldName, rule.visible!);
      if (!rule.visible! && rule.clearValue) {
        // 隐藏时清除值
        manager.updateValue(fieldName, null);
      }
    }

    // 更新必填状态
    if (rule.required != null) {
      final field = formState.fields[fieldName];
      if (field != null) {
        final updatedField = field.copyWith(required: rule.required);
        manager.registerField<dynamic>(updatedField);
      }
    }

    // 更新字段值
    if (rule.updateValue != null) {
      final newValue = rule.updateValue!(depValue);
      manager.updateValue(fieldName, newValue);
    } else if (rule.clearValue) {
      // 如果规则要求清除值
      manager.updateValue(fieldName, null);
    }

    // 存储选项更新函数（用于动态选项）
    if (rule.updateOptions != null) {
      _optionsProviders[fieldName] = rule.updateOptions!;
      // 通知组件更新（通过状态变化）
      setState(() {});
    }
  }

  /// 获取字段的动态选项
  List<dynamic>? getFieldOptions(String fieldName, dynamic depValue) {
    final provider = _optionsProviders[fieldName];
    if (provider != null) {
      return provider(depValue);
    }
    return null;
  }

  /// 将 FormFieldModel 转换为 FormFieldModel<dynamic>
  form_models.FormFieldModel<dynamic> _convertToDynamicField(
    form_models.FormFieldModel field,
  ) {
    final dynamicValidators = <form_models.FormFieldValidator<dynamic>>[];

    final fieldDynamic = field as dynamic;
    final validatorsList = fieldDynamic.validators as List;

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
    // 在 build 方法中设置联动监听（ref.listen 只能在这里使用）
    if (_initialized && widget.dependencies != null && widget.dependencies!.isNotEmpty) {
      for (final dependency in widget.dependencies!) {
        // 只设置一次监听，避免重复
        if (!_listenedDependencies.contains(dependency.fieldName)) {
          _setupDependency(dependency);
          _listenedDependencies.add(dependency.fieldName);
        }
      }
    }

    return widget.child;
  }
}
