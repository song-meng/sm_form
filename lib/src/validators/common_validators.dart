import '../models/form_field_model.dart';

/// 常用校验器
class CommonValidators {
  /// 必填校验
  static FormFieldValidator<T> required<T>({String? message}) {
    return (T? value) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        return message ?? '此字段为必填项';
      }
      return null;
    };
  }

  /// 字符串长度校验
  static FormFieldValidator<String> length({
    int? min,
    int? max,
    String? minMessage,
    String? maxMessage,
  }) {
    return (String? value) {
      if (value == null) return null;
      final len = value.length;
      if (min != null && len < min) {
        return minMessage ?? '长度不能少于 $min 个字符';
      }
      if (max != null && len > max) {
        return maxMessage ?? '长度不能超过 $max 个字符';
      }
      return null;
    };
  }

  /// 邮箱校验
  static FormFieldValidator<String> email({String? message}) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!emailRegex.hasMatch(value)) {
        return message ?? '请输入有效的邮箱地址';
      }
      return null;
    };
  }

  /// 手机号校验（中国）
  static FormFieldValidator<String> phone({String? message}) {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!phoneRegex.hasMatch(value)) {
        return message ?? '请输入有效的手机号码';
      }
      return null;
    };
  }

  /// 数字范围校验
  static FormFieldValidator<num> range({
    num? min,
    num? max,
    String? minMessage,
    String? maxMessage,
  }) {
    return (num? value) {
      if (value == null) return null;
      if (min != null && value < min) {
        return minMessage ?? '值不能小于 $min';
      }
      if (max != null && value > max) {
        return maxMessage ?? '值不能大于 $max';
      }
      return null;
    };
  }

  /// 正则表达式校验
  static FormFieldValidator<String> pattern(
    Pattern pattern, {
    String? message,
  }) {
    final regex = pattern is RegExp ? pattern : RegExp(pattern.toString());
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) {
        return message ?? '格式不正确';
      }
      return null;
    };
  }

  /// 组合多个校验器
  static FormFieldValidator<T> combine<T>(
    List<FormFieldValidator<T>> validators,
  ) {
    return (T? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
