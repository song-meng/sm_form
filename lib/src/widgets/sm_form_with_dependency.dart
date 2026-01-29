import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../form_manager.dart';
import '../models/form_field_model.dart' as form_models;
import '../models/form_state.dart' as form_state;
import '../models/form_dependency.dart';
import '../utils/field_converter.dart';

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

  @override
  void didUpdateWidget(SmFormWithDependency oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 formId 变化，重新初始化
    if (oldWidget.formId != widget.formId) {
      _initialized = false;
      _listenedDependencies.clear();
      _optionsProviders.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeForm();
      });
    }
  }

  void _initializeForm() {
    if (_initialized) return;

    // 使用 FieldConverter 批量转换并注册字段
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    final dynamicFields = FieldConverter.convertAll(widget.fields);
    manager.registerFields(dynamicFields);

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

        // 如果没有匹配的规则，检查是否需要清除值或隐藏
        if (matchedRule == null) {
          for (final rule in dependency.rules) {
            depValue = next.getValue(rule.dependsOn);
            final prevDepValue = previous.getValue(rule.dependsOn);

            // 只在值变化时处理
            if (depValue != prevDepValue && !rule.condition(depValue)) {
              final manager = ref.read(formManagerProvider(widget.formId).notifier);

              // 如果之前满足条件现在不满足，需要还原状态
              if (rule.visible == true) {
                // 之前显示，现在隐藏
                manager.setFieldVisible(dependency.fieldName, false);
                if (rule.clearValue) {
                  manager.updateValue(dependency.fieldName, null);
                }
              }
              if (rule.required == true) {
                // 之前必填，现在取消必填
                _updateFieldRequired(dependency.fieldName, false);
              }
            }
          }
        } else {
          _applyRule(dependency.fieldName, matchedRule, depValue);
        }
      },
    );
  }

  void _updateFieldRequired(String fieldName, bool required) {
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    final formState = ref.read(formManagerProvider(widget.formId));
    final field = formState.fields[fieldName];
    if (field != null && field.required != required) {
      final updatedField = field.copyWith(required: required);
      manager.registerField<dynamic>(updatedField);
    }
  }

  void _applyRule(
    String fieldName,
    FormDependencyRule rule,
    dynamic depValue,
  ) {
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    ref.read(formManagerProvider(widget.formId));

    // 更新显示/隐藏
    if (rule.visible != null) {
      manager.setFieldVisible(fieldName, rule.visible!);
      if (!rule.visible! && rule.clearValue) {
        // 隐藏时清除值
        manager.updateValue(fieldName, null);
      }
    }

    // 更新必填状态
    if (rule.required != null) {
      _updateFieldRequired(fieldName, rule.required!);
    }

    // 更新字段值
    if (rule.updateValue != null) {
      final newValue = rule.updateValue!(depValue);
      manager.updateValue(fieldName, newValue);
    } else if (rule.clearValue && rule.visible != false) {
      // 只有在不是因为隐藏而清除值时才执行
      // 隐藏时的清除已经在上面处理了
    }

    // 存储选项更新函数（用于动态选项）
    if (rule.updateOptions != null) {
      _optionsProviders[fieldName] = rule.updateOptions!;
      // 通知组件更新
      if (mounted) {
        setState(() {});
      }
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
