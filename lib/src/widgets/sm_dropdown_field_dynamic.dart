import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'sm_form_field.dart';
import '../form_manager.dart';

/// 支持动态选项的下拉选择字段
class SmDropdownFieldDynamic<T> extends HookConsumerWidget {
  const SmDropdownFieldDynamic({
    super.key,
    required this.formId,
    required this.name,
    required this.itemsBuilder,
    this.dependsOn,
    this.label,
    this.hint,
    this.validateOnBlur = true,
  });

  final String formId;
  final String name;
  final List<DropdownMenuItem<T>> Function(dynamic depValue) itemsBuilder;
  final String? dependsOn;
  final String? label;
  final String? hint;
  final bool validateOnBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听依赖字段的值
    dynamic depValue;
    if (dependsOn != null) {
      final formState = ref.watch(formManagerProvider(formId));
      depValue = formState.getValue(dependsOn!);
    }

    // 根据依赖字段的值动态生成选项
    final items = itemsBuilder(depValue);

    return SmFormField<T>(
      formId: formId,
      name: name,
      validateOnBlur: validateOnBlur,
      builder: (context, value, errorText, onChanged, disabled) {
        // 检查当前值是否在选项中，如果不在则清除
        T? validValue = value;
        if (value != null && !items.any((item) => item.value == value)) {
          // 当前值不在新选项中，清除它
          validValue = null;
          // 使用 Future.microtask 避免在 build 期间更新状态
          Future.microtask(() {
            ref.read(formManagerProvider(formId).notifier).updateValue<T>(name, null);
          });
        }

        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            border: const OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: validValue,
              items: items,
              onChanged: disabled ? null : onChanged,
              isExpanded: true,
              hint: hint != null ? Text(hint!) : null,
            ),
          ),
        );
      },
    );
  }
}
