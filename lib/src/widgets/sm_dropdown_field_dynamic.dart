import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    this.isExpanded = true,
  });

  final String formId;
  final String name;
  final List<DropdownMenuItem<T>> Function(dynamic depValue) itemsBuilder;
  final String? dependsOn;
  final String? label;
  final String? hint;
  final bool validateOnBlur;
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);
    
    final field = formState.fields[name];
    final focusNode = useFocusNode();
    final fieldKey = useMemoized(() => GlobalKey(debugLabel: 'form_field_$name'));
    final hasScheduledClear = useRef(false);

    // 监听依赖字段的值
    dynamic depValue;
    if (dependsOn != null) {
      depValue = formState.getValue(dependsOn!);
    }

    // 根据依赖字段的值动态生成选项
    final items = itemsBuilder(depValue);
    
    // 监听焦点变化
    useEffect(() {
      void listener() {
        if (!focusNode.hasFocus && validateOnBlur) {
          manager.validateField(name);
        }
        field?.onFocusChange?.call(focusNode.hasFocus);
      }

      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode]);
    
    // 注册字段的 GlobalKey
    useEffect(() {
      manager.registerFieldKey(name, fieldKey);
      return () => manager.unregisterFieldKey(name);
    }, [name, fieldKey]);
    
    if (field == null || !field.visible) {
      return const SizedBox.shrink();
    }
    
    final value = field.value as T?;
    final errorText = formState.getError(name);
    final disabled = field.disabled;

    // 检查当前值是否在选项中，如果不在则清除
    T? validValue = value;
    if (value != null && items.isNotEmpty && !items.any((item) => item.value == value)) {
      validValue = null;
      if (!hasScheduledClear.value) {
        hasScheduledClear.value = true;
        Future.microtask(() {
          manager.updateValue<T>(name, null);
          hasScheduledClear.value = false;
        });
      }
    }

    return Focus(
      focusNode: focusNode,
      key: fieldKey,
      child: InputDecorator(
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
            onChanged: disabled ? null : (newValue) {
              manager.updateValue<T>(name, newValue);
            },
            isExpanded: isExpanded,
            hint: hint != null ? Text(hint!) : null,
          ),
        ),
      ),
    );
  }
}
