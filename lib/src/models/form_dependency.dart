/// 字段依赖规则
class FormDependencyRule {
  /// 依赖的字段名称
  final String dependsOn;

  /// 条件函数：返回 true 时应用此规则
  final bool Function(dynamic value) condition;

  /// 选项更新函数：根据依赖字段的值返回新的选项列表
  final List<dynamic> Function(dynamic value)? updateOptions;

  /// 是否显示字段
  final bool? visible;

  /// 是否必填
  final bool? required;

  /// 字段值更新函数：根据依赖字段的值更新当前字段的值
  final dynamic Function(dynamic value)? updateValue;

  /// 是否清除字段值（当条件不满足时）
  final bool clearValue;

  const FormDependencyRule({
    required this.dependsOn,
    required this.condition,
    this.updateOptions,
    this.visible,
    this.required,
    this.updateValue,
    this.clearValue = false,
  });
}

/// 字段联动配置
class FormFieldDependency {
  /// 字段名称
  final String fieldName;

  /// 依赖规则列表（按优先级排序，第一个匹配的规则会被应用）
  final List<FormDependencyRule> rules;

  const FormFieldDependency({
    required this.fieldName,
    required this.rules,
  });
}

/// 联动规则构建器（用于简化规则创建）
class DependencyRuleBuilder {
  final String fieldName;
  String? _currentDependsOn;
  final List<FormDependencyRule> _rules = [];

  DependencyRuleBuilder({
    required this.fieldName,
  });

  /// 指定依赖的字段
  DependencyRuleBuilder dependsOn(String fieldName) {
    _currentDependsOn = fieldName;
    return this;
  }

  /// 当依赖字段的值等于指定值时
  DependencyRuleBuilder whenValue(dynamic value) {
    if (_currentDependsOn == null) {
      throw StateError('Must call dependsOn() before whenValue()');
    }
    _rules.add(FormDependencyRule(
      dependsOn: _currentDependsOn!,
      condition: (depValue) => depValue == value,
    ));
    return this;
  }

  /// 当依赖字段的值在指定列表中时
  DependencyRuleBuilder whenValueIn(List<dynamic> values) {
    if (_currentDependsOn == null) {
      throw StateError('Must call dependsOn() before whenValueIn()');
    }
    _rules.add(FormDependencyRule(
      dependsOn: _currentDependsOn!,
      condition: (depValue) => values.contains(depValue),
    ));
    return this;
  }

  /// 当条件满足时
  DependencyRuleBuilder when(bool Function(dynamic value) condition) {
    if (_currentDependsOn == null) {
      throw StateError('Must call dependsOn() before when()');
    }
    _rules.add(FormDependencyRule(
      dependsOn: _currentDependsOn!,
      condition: condition,
    ));
    return this;
  }

  /// 更新选项
  DependencyRuleBuilder thenUpdateOptions(List<dynamic> Function(dynamic value) updateOptions) {
    if (_rules.isNotEmpty) {
      final lastRule = _rules.last;
      _rules[_rules.length - 1] = FormDependencyRule(
        dependsOn: lastRule.dependsOn,
        condition: lastRule.condition,
        updateOptions: updateOptions,
        visible: lastRule.visible,
        required: lastRule.required,
        updateValue: lastRule.updateValue,
        clearValue: lastRule.clearValue,
      );
    }
    return this;
  }

  /// 显示字段
  DependencyRuleBuilder thenShow() {
    if (_rules.isNotEmpty) {
      final lastRule = _rules.last;
      _rules[_rules.length - 1] = FormDependencyRule(
        dependsOn: lastRule.dependsOn,
        condition: lastRule.condition,
        updateOptions: lastRule.updateOptions,
        visible: true,
        required: lastRule.required,
        updateValue: lastRule.updateValue,
        clearValue: lastRule.clearValue,
      );
    }
    return this;
  }

  /// 隐藏字段
  DependencyRuleBuilder thenHide() {
    if (_rules.isNotEmpty) {
      final lastRule = _rules.last;
      _rules[_rules.length - 1] = FormDependencyRule(
        dependsOn: lastRule.dependsOn,
        condition: lastRule.condition,
        updateOptions: lastRule.updateOptions,
        visible: false,
        required: lastRule.required,
        updateValue: lastRule.updateValue,
        clearValue: true, // 隐藏时默认清除值
      );
    }
    return this;
  }

  /// 设置为必填
  DependencyRuleBuilder thenRequire() {
    if (_rules.isNotEmpty) {
      final lastRule = _rules.last;
      _rules[_rules.length - 1] = FormDependencyRule(
        dependsOn: lastRule.dependsOn,
        condition: lastRule.condition,
        updateOptions: lastRule.updateOptions,
        visible: lastRule.visible,
        required: true,
        updateValue: lastRule.updateValue,
        clearValue: lastRule.clearValue,
      );
    }
    return this;
  }

  /// 更新字段值
  DependencyRuleBuilder thenUpdateValue(dynamic Function(dynamic value) updateValue) {
    if (_rules.isNotEmpty) {
      final lastRule = _rules.last;
      _rules[_rules.length - 1] = FormDependencyRule(
        dependsOn: lastRule.dependsOn,
        condition: lastRule.condition,
        updateOptions: lastRule.updateOptions,
        visible: lastRule.visible,
        required: lastRule.required,
        updateValue: updateValue,
        clearValue: lastRule.clearValue,
      );
    }
    return this;
  }

  /// 清除字段值
  DependencyRuleBuilder thenClearValue() {
    if (_rules.isNotEmpty) {
      final lastRule = _rules.last;
      _rules[_rules.length - 1] = FormDependencyRule(
        dependsOn: lastRule.dependsOn,
        condition: lastRule.condition,
        updateOptions: lastRule.updateOptions,
        visible: lastRule.visible,
        required: lastRule.required,
        updateValue: lastRule.updateValue,
        clearValue: true,
      );
    }
    return this;
  }

  /// 构建字段依赖配置
  FormFieldDependency build() {
    return FormFieldDependency(
      fieldName: fieldName,
      rules: List.unmodifiable(_rules),
    );
  }
}

/// 表单联动配置构建器
class FormDependencyBuilder {
  final List<FormFieldDependency> _dependencies = [];

  /// 为指定字段添加依赖规则
  DependencyRuleBuilder field(String fieldName) {
    return DependencyRuleBuilder(fieldName: fieldName);
  }

  /// 添加字段依赖配置
  FormDependencyBuilder add(FormFieldDependency dependency) {
    _dependencies.add(dependency);
    return this;
  }

  /// 构建依赖配置列表
  List<FormFieldDependency> build() {
    return List.unmodifiable(_dependencies);
  }
}

/// 便捷方法：创建表单联动配置构建器
FormDependencyBuilder formDependencies() {
  return FormDependencyBuilder();
}
