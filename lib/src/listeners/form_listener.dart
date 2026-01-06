import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/form_state.dart';
import '../form_manager.dart';

/// 表单监听器
class FormListener {
  /// 监听表单值变化
  static void listenToValueChanges(
    WidgetRef ref,
    String formId,
    void Function(String name, dynamic value) onValueChanged,
  ) {
    ref.listen<FormState>(
      formManagerProvider(formId),
      (previous, next) {
        if (previous == null) return;

        // 检查每个字段的值是否发生变化
        for (final entry in next.fields.entries) {
          final name = entry.key;
          final field = entry.value;
          final previousField = previous.fields[name];

          if (previousField?.value != field.value) {
            onValueChanged(name, field.value);
          }
        }
      },
    );
  }

  /// 监听表单错误变化
  static void listenToErrorChanges(
    WidgetRef ref,
    String formId,
    void Function(String name, String? error) onErrorChanged,
  ) {
    ref.listen<FormState>(
      formManagerProvider(formId),
      (previous, next) {
        if (previous == null) return;

        // 检查每个字段的错误是否发生变化
        for (final entry in next.fields.entries) {
          final name = entry.key;
          final error = next.getError(name);
          final previousError = previous.getError(name);

          if (previousError != error) {
            onErrorChanged(name, error);
          }
        }
      },
    );
  }

  /// 监听表单提交状态
  static void listenToSubmitStatus(
    WidgetRef ref,
    String formId,
    void Function(bool submitting, bool submitted) onStatusChanged,
  ) {
    ref.listen<FormState>(
      formManagerProvider(formId),
      (previous, next) {
        if (previous == null) return;

        if (previous.submitting != next.submitting || previous.submitted != next.submitted) {
          onStatusChanged(next.submitting, next.submitted);
        }
      },
    );
  }

  /// 监听表单验证状态
  static void listenToValidationStatus(
    WidgetRef ref,
    String formId,
    void Function(bool isValid) onValidationChanged,
  ) {
    ref.listen<FormState>(
      formManagerProvider(formId),
      (previous, next) {
        if (previous == null) return;

        if (previous.isValid != next.isValid) {
          onValidationChanged(next.isValid);
        }
      },
    );
  }
}
