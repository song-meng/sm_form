import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'form_manager.dart';
import 'models/form_dependency.dart';
import 'models/form_state.dart' as form_state;

/// 表单联动管理器
class FormDependencyManager {
  final String formId;
  final WidgetRef ref;
  final List<FormFieldDependency> dependencies;

  FormDependencyManager({
    required this.formId,
    required this.ref,
    required this.dependencies,
  });

  /// 初始化联动
  void initialize() {
    final manager = ref.read(formManagerProvider(formId).notifier);

    // 为每个依赖字段设置监听
    for (final dependency in dependencies) {
      _setupDependencyListener(dependency, manager);
    }
  }

  /// 设置依赖监听
  void _setupDependencyListener(
    FormFieldDependency dependency,
    FormManager manager,
  ) {
    // 监听依赖字段的变化
    ref.listen<form_state.FormState>(
      formManagerProvider(formId),
      (previous, next) {
        if (previous == null) return;

        // 检查依赖字段的值是否变化
        for (final rule in dependency.rules) {
          final depValue = next.getValue(rule.dependsOn);
          final prevDepValue = previous.getValue(rule.dependsOn);

          if (depValue != prevDepValue && rule.condition(depValue)) {
            _applyRule(dependency.fieldName, rule, depValue, manager, next);
          }
        }
      },
    );
  }

  /// 应用联动规则
  void _applyRule(
    String fieldName,
    FormDependencyRule rule,
    dynamic depValue,
    FormManager manager,
    form_state.FormState formState,
  ) {
    // 更新选项
    if (rule.updateOptions != null) {
      // 这里需要重新注册字段，但为了简化，我们通过其他方式处理
      // 实际应用中，选项更新应该在字段组件中处理
    }

    // 更新显示/隐藏
    if (rule.visible != null) {
      manager.setFieldEnabled(fieldName, rule.visible!);
    }

    // 更新必填状态
    if (rule.required != null) {
      // 需要重新注册字段来更新必填状态
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
    }
  }
}
