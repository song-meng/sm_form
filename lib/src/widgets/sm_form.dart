import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../form_manager.dart';
import '../models/form_field_model.dart' as form_models;
import '../utils/field_converter.dart';

/// 表单组件
class SmForm extends ConsumerStatefulWidget {
  /// 表单 ID（用于区分多个表单）
  final String formId;

  /// 表单字段配置
  final Map<String, form_models.FormFieldModel> fields;

  /// 表单子组件
  final Widget child;

  /// 表单初始化完成回调
  final VoidCallback? onInitialized;

  const SmForm({
    super.key,
    required this.formId,
    required this.fields,
    required this.child,
    this.onInitialized,
  });

  @override
  ConsumerState<SmForm> createState() => _SmFormState();
}

class _SmFormState extends ConsumerState<SmForm> {
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }
  
  @override
  void didUpdateWidget(SmForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 formId 变化，重新初始化
    if (oldWidget.formId != widget.formId) {
      _initialized = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeForm();
      });
    }
  }

  void _initializeForm() {
    if (_initialized) return;
    
    final manager = ref.read(formManagerProvider(widget.formId).notifier);
    // 使用 FieldConverter 批量转换并注册字段
    final dynamicFields = FieldConverter.convertAll(widget.fields);
    manager.registerFields(dynamicFields);
    
    _initialized = true;
    widget.onInitialized?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
