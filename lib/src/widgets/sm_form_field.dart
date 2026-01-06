import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../form_manager.dart';

/// 表单字段组件
class SmFormField<T> extends HookConsumerWidget {
  /// 表单 ID
  final String formId;

  /// 字段名称
  final String name;

  /// 字段构建器
  final Widget Function(
    BuildContext context,
    T? value,
    String? errorText,
    void Function(T?) onChanged,
    bool disabled,
  ) builder;

  /// 是否在失去焦点时自动校验
  final bool validateOnBlur;

  const SmFormField({
    super.key,
    required this.formId,
    required this.name,
    required this.builder,
    this.validateOnBlur = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);
    final focusNode = useFocusNode();
    final fieldKey = useMemoized(() => GlobalKey(debugLabel: 'form_field_$name'));

    final field = formState.fields[name];
    if (field == null) {
      return const SizedBox.shrink();
    }

    // 安全地获取值，进行类型转换
    final value = field.value as T?;
    final errorText = formState.getError(name);
    final disabled = field.disabled;

    // 监听焦点变化
    useEffect(() {
      void listener() {
        if (!focusNode.hasFocus && validateOnBlur) {
          manager.validateField(name);
        }
        field.onFocusChange?.call(focusNode.hasFocus);
      }

      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode]);

    // 注册字段的 GlobalKey 到管理器，用于滚动定位
    useEffect(() {
      manager.registerFieldKey(name, fieldKey);
      return () {
        manager.unregisterFieldKey(name);
      };
    }, [name, fieldKey]);

    void onChanged(T? newValue) {
      manager.updateValue<T>(name, newValue);
    }

    return Focus(
      focusNode: focusNode,
      key: fieldKey,
      child: builder(context, value, errorText, onChanged, disabled),
    );
  }
}

/// 文本输入字段
class SmTextField extends HookConsumerWidget {
  const SmTextField({
    super.key,
    required this.formId,
    required this.name,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validateOnBlur = true,
  });

  final String formId;
  final String name;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool validateOnBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmFormField<String>(
      formId: formId,
      name: name,
      validateOnBlur: validateOnBlur,
      builder: (context, value, errorText, onChanged, disabled) {
        final controller = useTextEditingController(text: value ?? '');

        // 当外部值变化时更新 controller
        useEffect(() {
          if (controller.text != (value ?? '')) {
            controller.text = value ?? '';
          }
          return null;
        }, [value]);

        return TextField(
          controller: controller,
          onChanged: disabled ? null : onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          enabled: !disabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

/// 数字输入字段
class SmNumberField extends HookConsumerWidget {
  const SmNumberField({
    super.key,
    required this.formId,
    required this.name,
    this.label,
    this.hint,
    this.min,
    this.max,
    this.prefixIcon,
    this.suffixIcon,
    this.validateOnBlur = true,
  });

  final String formId;
  final String name;
  final String? label;
  final String? hint;
  final num? min;
  final num? max;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool validateOnBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmFormField<num>(
      formId: formId,
      name: name,
      validateOnBlur: validateOnBlur,
      builder: (context, value, errorText, onChanged, disabled) {
        final controller = useTextEditingController(
          text: value?.toString() ?? '',
        );

        // 当外部值变化时更新 controller
        useEffect(() {
          final newText = value?.toString() ?? '';
          if (controller.text != newText) {
            controller.text = newText;
          }
          return null;
        }, [value]);

        return TextField(
          controller: controller,
          onChanged: disabled
              ? null
              : (text) {
                  final numValue = num.tryParse(text);
                  if (numValue != null) {
                    onChanged(numValue);
                  } else if (text.isEmpty) {
                    onChanged(null);
                  }
                },
          keyboardType: TextInputType.number,
          enabled: !disabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

/// 下拉选择字段
class SmDropdownField<T> extends HookConsumerWidget {
  const SmDropdownField({
    super.key,
    required this.formId,
    required this.name,
    required this.items,
    this.label,
    this.hint,
    this.validateOnBlur = true,
  });

  final String formId;
  final String name;
  final List<DropdownMenuItem<T>> items;
  final String? label;
  final String? hint;
  final bool validateOnBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

/// 复选框字段
class SmCheckboxField extends HookConsumerWidget {
  const SmCheckboxField({
    super.key,
    required this.formId,
    required this.name,
    this.label,
    this.tristate = false,
    this.validateOnBlur = true,
  });

  final String formId;
  final String name;
  final String? label;
  final bool tristate;
  final bool validateOnBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmFormField<bool>(
      formId: formId,
      name: name,
      validateOnBlur: validateOnBlur,
      builder: (context, value, errorText, onChanged, disabled) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: value ?? false,
                  onChanged: disabled ? null : onChanged,
                  tristate: tristate,
                ),
                if (label != null) Text(label!),
              ],
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  errorText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 单选按钮组字段
class SmRadioGroupField<T> extends HookConsumerWidget {
  const SmRadioGroupField({
    super.key,
    required this.formId,
    required this.name,
    required this.options,
    this.label,
    this.validateOnBlur = true,
  });

  final String formId;
  final String name;
  final List<RadioOption<T>> options;
  final String? label;
  final bool validateOnBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmFormField<T>(
      formId: formId,
      name: name,
      validateOnBlur: validateOnBlur,
      builder: (context, value, errorText, onChanged, disabled) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ...options.map((option) => RadioListTile<T>(
                  title: Text(option.label),
                  value: option.value,
                  groupValue: value,
                  onChanged: disabled ? null : onChanged,
                )),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  errorText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 单选选项
class RadioOption<T> {
  final T value;
  final String label;

  const RadioOption({
    required this.value,
    required this.label,
  });
}
