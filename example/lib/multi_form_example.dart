import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_form/sm_form.dart';

/// 多表单示例页面
class MultiFormExamplePage extends StatelessWidget {
  const MultiFormExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 定义第一个表单的字段
    final form1Fields = {
      'name': FormFieldModel<String>(
        name: 'name',
        label: '姓名',
        required: true,
        initialValue: '',
        validators: [
          CommonValidators.required(message: '请输入姓名'),
        ],
      ),
      'email': FormFieldModel<String>(
        name: 'email',
        label: '邮箱',
        required: true,
        initialValue: '',
        validators: [
          CommonValidators.required(message: '请输入邮箱'),
          CommonValidators.email(),
        ],
      ),
    };

    // 定义第二个表单的字段
    final form2Fields = {
      'product': FormFieldModel<String>(
        name: 'product',
        label: '产品名称',
        required: true,
        initialValue: '',
        validators: [
          CommonValidators.required(message: '请输入产品名称'),
        ],
      ),
      'price': FormFieldModel<num>(
        name: 'price',
        label: '价格',
        required: true,
        initialValue: null,
        validators: [
          CommonValidators.required(message: '请输入价格'),
          CommonValidators.range(min: 0, minMessage: '价格必须大于0'),
        ],
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('多表单示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 第一个表单
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '用户信息表单 (form1)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SmForm(
                      formId: 'form1',
                      fields: form1Fields,
                      child: Column(
                        children: [
                          const SmTextField(
                            formId: 'form1',
                            name: 'name',
                            label: '姓名',
                            hint: '请输入姓名',
                          ),
                          const SizedBox(height: 16),
                          const SmTextField(
                            formId: 'form1',
                            name: 'email',
                            label: '邮箱',
                            hint: '请输入邮箱',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          SmFormSubmitButton(
                            formId: 'form1',
                            text: '提交用户信息',
                            onSubmit: (values) async {
                              await Future.delayed(const Duration(seconds: 1));
                              if (kDebugMode) {
                                print('表单1提交的数据: $values');
                              }
                              return values;
                            },
                            onSuccess: (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('用户信息提交成功！')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 第二个表单
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '产品信息表单 (form2)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SmForm(
                      formId: 'form2',
                      fields: form2Fields,
                      child: Column(
                        children: [
                          const SmTextField(
                            formId: 'form2',
                            name: 'product',
                            label: '产品名称',
                            hint: '请输入产品名称',
                          ),
                          const SizedBox(height: 16),
                          const SmNumberField(
                            formId: 'form2',
                            name: 'price',
                            label: '价格',
                            hint: '请输入价格',
                          ),
                          const SizedBox(height: 16),
                          SmFormSubmitButton(
                            formId: 'form2',
                            text: '提交产品信息',
                            onSubmit: (values) async {
                              await Future.delayed(const Duration(seconds: 1));
                              if (kDebugMode) {
                                print('表单2提交的数据: $values');
                              }
                              return values;
                            },
                            onSuccess: (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('产品信息提交成功！')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 显示两个表单的值
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '表单值监听',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _FormValuesDisplay(formId: 'form1', title: '表单1的值'),
                    SizedBox(height: 16),
                    _FormValuesDisplay(formId: 'form2', title: '表单2的值'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 表单值显示组件
class _FormValuesDisplay extends ConsumerWidget {
  final String formId;
  final String title;

  const _FormValuesDisplay({
    required this.formId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...formState.getValues().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        if (formState.getValues().isEmpty)
          Text(
            '暂无数据',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
      ],
    );
  }
}
