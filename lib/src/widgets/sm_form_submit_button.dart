import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../form_manager.dart';

/// 表单提交按钮
class SmFormSubmitButton extends ConsumerWidget {
  /// 表单 ID
  final String formId;

  /// 提交回调
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> values)? onSubmit;

  /// 按钮文本
  final String text;

  /// 按钮样式
  final ButtonStyle? style;

  /// 提交成功回调
  final void Function(Map<String, dynamic>? result)? onSuccess;

  /// 提交失败回调
  final void Function(Object error)? onError;
  
  /// 验证失败回调
  final VoidCallback? onValidationFailed;
  
  /// 是否在提交前验证（默认 true）
  /// 设置为 false 时，isValid 不会影响按钮状态，只在提交时验证
  final bool validateBeforeSubmit;
  
  /// 加载指示器
  final Widget? loadingIndicator;
  
  /// 子组件（如果提供则忽略 text）
  final Widget? child;

  const SmFormSubmitButton({
    super.key,
    required this.formId,
    this.onSubmit,
    this.text = '提交',
    this.style,
    this.onSuccess,
    this.onError,
    this.onValidationFailed,
    this.validateBeforeSubmit = true,
    this.loadingIndicator,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);

    final isSubmitting = formState.submitting;
    
    // 只有在需要提交前验证且表单已经过验证时才考虑 isValid
    // 这样新表单不会因为 isValid 为 true（未验证时的默认值）而误导
    final bool canSubmit;
    if (validateBeforeSubmit && formState.validated) {
      canSubmit = formState.isValid && !isSubmitting;
    } else {
      // 未验证过的表单始终允许点击提交（会触发验证）
      canSubmit = !isSubmitting;
    }

    Future<void> handleSubmit() async {
      if (onSubmit == null) return;

      try {
        final result = await manager.submit(onSubmit: onSubmit!);
        if (result != null) {
          onSuccess?.call(result);
        } else {
          // 验证失败
          onValidationFailed?.call();
        }
      } catch (e) {
        onError?.call(e);
      }
    }

    return ElevatedButton(
      onPressed: canSubmit ? handleSubmit : null,
      style: style,
      child: isSubmitting
          ? loadingIndicator ?? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child ?? Text(text),
    );
  }
}
