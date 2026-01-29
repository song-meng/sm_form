import '../models/form_field_model.dart';

/// 常用校验器
class CommonValidators {
  /// 必填校验
  static FormFieldValidator<T> required<T>({String? message}) {
    return (T? value) {
      if (value == null) {
        return message ?? '此字段为必填项';
      }
      if (value is String && value.trim().isEmpty) {
        return message ?? '此字段为必填项';
      }
      if (value is List && value.isEmpty) {
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
      if (value == null || value.isEmpty) return null;
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
  
  /// URL 校验
  static FormFieldValidator<String> url({String? message}) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!urlRegex.hasMatch(value)) {
        return message ?? '请输入有效的网址';
      }
      return null;
    };
  }
  
  /// 密码强度校验
  /// 
  /// [minLength] 最小长度（默认 8）
  /// [requireUppercase] 是否需要大写字母（默认 true）
  /// [requireLowercase] 是否需要小写字母（默认 true）
  /// [requireNumber] 是否需要数字（默认 true）
  /// [requireSpecialChar] 是否需要特殊字符（默认 false）
  static FormFieldValidator<String> password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = false,
    String? message,
  }) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      
      if (value.length < minLength) {
        return message ?? '密码长度至少 $minLength 个字符';
      }
      if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
        return message ?? '密码必须包含大写字母';
      }
      if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
        return message ?? '密码必须包含小写字母';
      }
      if (requireNumber && !RegExp(r'[0-9]').hasMatch(value)) {
        return message ?? '密码必须包含数字';
      }
      if (requireSpecialChar && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return message ?? '密码必须包含特殊字符';
      }
      
      return null;
    };
  }
  
  /// 确认值匹配校验（如确认密码）
  /// 
  /// [getValue] 获取要匹配的值的函数
  static FormFieldValidator<T> match<T>(
    T? Function() getValue, {
    String? message,
  }) {
    return (T? value) {
      if (value == null) return null;
      final matchValue = getValue();
      if (value != matchValue) {
        return message ?? '两次输入不一致';
      }
      return null;
    };
  }
  
  /// 身份证号校验（中国）
  static FormFieldValidator<String> idCard({String? message}) {
    final idCardRegex = RegExp(
      r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
    );
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!idCardRegex.hasMatch(value)) {
        return message ?? '请输入有效的身份证号码';
      }
      return null;
    };
  }
  
  /// 纯数字校验
  static FormFieldValidator<String> numeric({String? message}) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r'^\d+$').hasMatch(value)) {
        return message ?? '请输入纯数字';
      }
      return null;
    };
  }
  
  /// 纯字母校验
  static FormFieldValidator<String> alpha({String? message}) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
        return message ?? '请输入纯字母';
      }
      return null;
    };
  }
  
  /// 字母数字校验
  static FormFieldValidator<String> alphanumeric({String? message}) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
        return message ?? '请输入字母或数字';
      }
      return null;
    };
  }
  
  /// 整数校验
  static FormFieldValidator<num> integer({String? message}) {
    return (num? value) {
      if (value == null) return null;
      if (value is! int && value.truncate() != value) {
        return message ?? '请输入整数';
      }
      return null;
    };
  }
  
  /// 正数校验
  static FormFieldValidator<num> positive({String? message}) {
    return (num? value) {
      if (value == null) return null;
      if (value <= 0) {
        return message ?? '请输入正数';
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
  
  /// 条件校验器
  /// 
  /// [condition] 返回 true 时才执行校验
  /// [validator] 要执行的校验器
  static FormFieldValidator<T> when<T>(
    bool Function() condition,
    FormFieldValidator<T> validator,
  ) {
    return (T? value) {
      if (!condition()) return null;
      return validator(value);
    };
  }
}
