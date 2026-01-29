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
    
    // 如果字段不存在或不可见，返回空组件
    if (field == null || !field.visible) {
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
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validateOnBlur = true,
    this.autofocus = false,
    this.readOnly = false,
  });

  final String formId;
  final String name;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool validateOnBlur;
  final bool autofocus;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);
    
    final field = formState.fields[name];
    final value = field?.value as String? ?? '';
    
    // 在顶层使用 hook
    final controller = useTextEditingController(text: value);
    final focusNode = useFocusNode();
    final fieldKey = useMemoized(() => GlobalKey(debugLabel: 'form_field_$name'));
    
    // 标记是否正在程序化更新，避免循环
    final isUpdating = useRef(false);
    
    // 当外部值变化时更新 controller（只在值真正变化时）
    useEffect(() {
      if (!isUpdating.value && controller.text != value) {
        isUpdating.value = true;
        controller.text = value;
        isUpdating.value = false;
      }
      return null;
    }, [value]);
    
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
    
    final errorText = formState.getError(name);
    final disabled = field.disabled;

    return Focus(
      focusNode: focusNode,
      key: fieldKey,
      child: TextField(
        controller: controller,
        onChanged: disabled ? null : (newValue) {
          if (!isUpdating.value) {
            isUpdating.value = true;
            manager.updateValue<String>(name, newValue);
            isUpdating.value = false;
          }
        },
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        enabled: !disabled,
        readOnly: readOnly || field.readOnly,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
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
    this.decimal = false,
    this.autofocus = false,
    this.readOnly = false,
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
  final bool decimal;
  final bool autofocus;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);
    
    final field = formState.fields[name];
    final value = field?.value as num?;
    final textValue = value?.toString() ?? '';
    
    // 在顶层使用 hook
    final controller = useTextEditingController(text: textValue);
    final focusNode = useFocusNode();
    final fieldKey = useMemoized(() => GlobalKey(debugLabel: 'form_field_$name'));
    
    // 标记是否正在程序化更新
    final isUpdating = useRef(false);
    
    // 当外部值变化时更新 controller
    useEffect(() {
      final newText = value?.toString() ?? '';
      if (!isUpdating.value && controller.text != newText) {
        isUpdating.value = true;
        controller.text = newText;
        isUpdating.value = false;
      }
      return null;
    }, [value]);
    
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
    
    final errorText = formState.getError(name);
    final disabled = field.disabled;

    return Focus(
      focusNode: focusNode,
      key: fieldKey,
      child: TextField(
        controller: controller,
        onChanged: disabled
            ? null
            : (text) {
                if (!isUpdating.value) {
                  isUpdating.value = true;
                  final numValue = decimal ? double.tryParse(text) : int.tryParse(text);
                  if (numValue != null) {
                    manager.updateValue<num>(name, numValue);
                  } else if (text.isEmpty) {
                    manager.updateValue<num>(name, null);
                  }
                  isUpdating.value = false;
                }
              },
        keyboardType: TextInputType.numberWithOptions(
          decimal: decimal,
          signed: min != null && min! < 0,
        ),
        enabled: !disabled,
        readOnly: readOnly || field.readOnly,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
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
    this.isExpanded = true,
  });

  final String formId;
  final String name;
  final List<DropdownMenuItem<T>> items;
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
    
    // 用于追踪是否需要清除无效值（避免重复清除）
    final hasScheduledClear = useRef(false);
    
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
    
    // 检查当前值是否在选项中
    T? validValue = value;
    if (value != null && !items.any((item) => item.value == value)) {
      validValue = null;
      // 只调度一次清除操作
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

/// 复选框字段
class SmCheckboxField extends HookConsumerWidget {
  const SmCheckboxField({
    super.key,
    required this.formId,
    required this.name,
    this.label,
    this.tristate = false,
    this.validateOnBlur = true,
    this.contentPadding,
  });

  final String formId;
  final String name;
  final String? label;
  final bool tristate;
  final bool validateOnBlur;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);
    
    final field = formState.fields[name];
    final focusNode = useFocusNode();
    final fieldKey = useMemoized(() => GlobalKey(debugLabel: 'form_field_$name'));
    
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
    
    final value = field.value as bool?;
    final errorText = formState.getError(name);
    final disabled = field.disabled;

    return Focus(
      focusNode: focusNode,
      key: fieldKey,
      child: Padding(
        padding: contentPadding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: disabled ? null : () {
                if (tristate) {
                  // 三态切换: false -> true -> null -> false
                  final newValue = value == null ? false : (value ? null : true);
                  manager.updateValue<bool>(name, newValue);
                } else {
                  manager.updateValue<bool>(name, !(value ?? false));
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: tristate ? value : (value ?? false),
                    onChanged: disabled ? null : (newValue) {
                      manager.updateValue<bool>(name, newValue);
                    },
                    tristate: tristate,
                  ),
                  if (label != null) 
                    Flexible(child: Text(label!)),
                ],
              ),
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
        ),
      ),
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
    this.direction = Axis.vertical,
    this.contentPadding,
  });

  final String formId;
  final String name;
  final List<RadioOption<T>> options;
  final String? label;
  final bool validateOnBlur;
  final Axis direction;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);
    
    final field = formState.fields[name];
    final focusNode = useFocusNode();
    final fieldKey = useMemoized(() => GlobalKey(debugLabel: 'form_field_$name'));
    
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

    final radioItems = options.map((option) => RadioListTile<T>(
      title: Text(option.label),
      value: option.value,
      groupValue: value,
      onChanged: disabled ? null : (newValue) {
        manager.updateValue<T>(name, newValue);
      },
      contentPadding: contentPadding,
      dense: true,
    )).toList();

    return Focus(
      focusNode: focusNode,
      key: fieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (direction == Axis.vertical)
            ...radioItems
          else
            Wrap(
              children: radioItems.map((item) => SizedBox(
                width: 200,
                child: item,
              )).toList(),
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
      ),
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
