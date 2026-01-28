import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_form/sm_form.dart';

/// 自定义字段示例
class CustomFieldExamplePage extends ConsumerStatefulWidget {
  const CustomFieldExamplePage({super.key});

  @override
  ConsumerState<CustomFieldExamplePage> createState() => _CustomFieldExamplePageState();
}

class _CustomFieldExamplePageState extends ConsumerState<CustomFieldExamplePage> {
  @override
  Widget build(BuildContext context) {
    // 定义表单字段
    final fields = {
      'rating': FormFieldModel<int>(
        name: 'rating',
        label: '评分',
        required: true,
        validators: [
          CommonValidators.required(message: '请选择评分'),
        ],
      ),
      'date': FormFieldModel<DateTime>(
        name: 'date',
        label: '日期',
        required: true,
        validators: [
          CommonValidators.required(message: '请选择日期'),
        ],
      ),
      'color': FormFieldModel<Color>(
        name: 'color',
        label: '颜色',
        required: false,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义字段示例'),
      ),
      body: SmForm(
        formId: 'custom_form',
        fields: fields,
        onInitialized: () {
          if (kDebugMode) {
            print('表单初始化完成');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 自定义评分字段（星级评分）
              _buildRatingField(),

              const SizedBox(height: 16),

              // 自定义日期选择字段
              _buildDateField(),

              const SizedBox(height: 16),

              // 自定义颜色选择字段
              _buildColorField(),

              const SizedBox(height: 32),

              // 显示当前表单值
              _buildFormValues(),

              const SizedBox(height: 16),

              // 提交按钮
              SmFormSubmitButton(
                formId: 'custom_form',
                text: '提交',
                onSubmit: (values) async {
                  if (kDebugMode) {
                    print('表单提交成功: $values');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('提交成功: $values')),
                  );
                  return values;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建自定义评分字段（星级评分）
  Widget _buildRatingField() {
    return SmFormField<int>(
      formId: 'custom_form',
      name: 'rating',
      builder: (context, value, errorText, onChanged, disabled) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: '评分',
            hintText: '请选择评分',
            errorText: errorText,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = value != null && value >= rating;
              return GestureDetector(
                onTap: disabled ? null : () => onChanged(rating),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// 构建自定义日期选择字段
  Widget _buildDateField() {
    return SmFormField<DateTime>(
      formId: 'custom_form',
      name: 'date',
      builder: (context, value, errorText, onChanged, disabled) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: '日期',
            hintText: '请选择日期',
            errorText: errorText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: InkWell(
            onTap: disabled
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: value ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      onChanged(picked);
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                value != null ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}' : '请选择日期',
                style: TextStyle(
                  color: value != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建自定义颜色选择字段
  Widget _buildColorField() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];

    return SmFormField<Color>(
      formId: 'custom_form',
      name: 'color',
      builder: (context, value, errorText, onChanged, disabled) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: '颜色',
            hintText: '请选择颜色',
            errorText: errorText,
            border: const OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              final isSelected = value == color;
              return GestureDetector(
                onTap: disabled ? null : () => onChanged(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// 显示当前表单值
  Widget _buildFormValues() {
    final formState = ref.watch(formManagerProvider('custom_form'));
    final values = formState.getValues();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前表单值：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...values.entries.map((entry) {
              String displayValue;
              if (entry.value is DateTime) {
                final date = entry.value as DateTime;
                displayValue = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              } else if (entry.value is Color) {
                final color = entry.value as Color;
                displayValue = 'Color(${color.red}, ${color.green}, ${color.blue})';
              } else {
                displayValue = entry.value?.toString() ?? 'null';
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('${entry.key}: $displayValue'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
