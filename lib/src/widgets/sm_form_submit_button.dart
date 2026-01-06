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

  const SmFormSubmitButton({
    super.key,
    required this.formId,
    this.onSubmit,
    this.text = '提交',
    this.style,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));
    final manager = ref.read(formManagerProvider(formId).notifier);

    final isSubmitting = formState.submitting;
    final isValid = formState.isValid;

    Future<void> handleSubmit() async {
      if (onSubmit == null) return;

      try {
        final result = await manager.submit(onSubmit: onSubmit!);
        onSuccess?.call(result);
      } catch (e) {
        onError?.call(e);
      }
    }

    return ElevatedButton(
      onPressed: (isSubmitting || !isValid) ? null : handleSubmit,
      style: style,
      child: isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
