import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_form/sm_form.dart';
import 'form_linkage_example.dart';
import 'form_linkage_simple_example.dart';
import 'multi_form_example.dart';
import 'custom_field_example.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SM Form Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// 主页，包含导航到不同示例
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SM Form 示例'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('基础表单示例'),
            subtitle: const Text('展示基本的表单功能'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormExamplePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('表单联动示例（手动方式）'),
            subtitle: const Text('展示手动处理表单联动'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormLinkageExamplePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('表单联动示例（简化方式）'),
            subtitle: const Text('使用声明式配置简化联动逻辑'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormLinkageSimpleExamplePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('多表单示例'),
            subtitle: const Text('展示同一页面多个独立表单'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MultiFormExamplePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('自定义字段示例'),
            subtitle: const Text('展示如何创建自定义表单字段'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomFieldExamplePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FormExamplePage extends StatelessWidget {
  const FormExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 定义表单字段
    final fields = {
      'username': FormFieldModel<String>(
        name: 'username',
        label: '用户名',
        hint: '请输入用户名',
        required: true,
        initialValue: '',
        validators: [
          CommonValidators.required(message: '用户名不能为空'),
          CommonValidators.length(
            min: 3,
            max: 20,
            minMessage: '用户名至少3个字符',
            maxMessage: '用户名不能超过20个字符',
          ),
        ],
      ),
      'email': FormFieldModel<String>(
        name: 'email',
        label: '邮箱',
        hint: '请输入邮箱地址',
        required: true,
        initialValue: '',
        validators: [
          CommonValidators.required(message: '邮箱不能为空'),
          CommonValidators.email(message: '请输入有效的邮箱地址'),
        ],
      ),
      'phone': FormFieldModel<String>(
        name: 'phone',
        label: '手机号',
        hint: '请输入手机号',
        required: true,
        initialValue: '',
        validators: [
          CommonValidators.required(message: '手机号不能为空'),
          CommonValidators.phone(message: '请输入有效的手机号'),
        ],
      ),
      'age': FormFieldModel<num>(
        name: 'age',
        label: '年龄',
        hint: '请输入年龄',
        required: true,
        initialValue: null,
        validators: [
          CommonValidators.required(message: '年龄不能为空'),
          (value) {
            if (value == null) return '年龄不能为空';
            if (value < 0 || value > 150) {
              return '年龄必须在0-150之间';
            }
            return null;
          },
        ],
      ),
      'gender': FormFieldModel<String>(
        name: 'gender',
        label: '性别',
        required: true,
        initialValue: null,
        validators: [
          CommonValidators.required(message: '请选择性别'),
        ],
      ),
      'agree': FormFieldModel<bool>(
        name: 'agree',
        label: '同意用户协议',
        required: true,
        initialValue: false,
        validators: [
          (value) {
            if (value != true) {
              return '必须同意用户协议';
            }
            return null;
          },
        ],
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('表单示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SmForm(
        formId: 'example_form',
        fields: fields,
        onInitialized: () {
          print('表单初始化完成');
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SmTextField(
                formId: 'example_form',
                name: 'username',
                label: '用户名',
                hint: '请输入用户名',
                prefixIcon: Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              const SmTextField(
                formId: 'example_form',
                name: 'email',
                label: '邮箱',
                hint: '请输入邮箱地址',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email),
              ),
              const SizedBox(height: 16),
              const SmTextField(
                formId: 'example_form',
                name: 'phone',
                label: '手机号',
                hint: '请输入手机号',
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(Icons.phone),
              ),
              const SizedBox(height: 16),
              const SmNumberField(
                formId: 'example_form',
                name: 'age',
                label: '年龄',
                hint: '请输入年龄',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              const SizedBox(height: 16),
              const SmDropdownField<String>(
                formId: 'example_form',
                name: 'gender',
                label: '性别',
                hint: '请选择性别',
                items: [
                  DropdownMenuItem(value: 'male', child: Text('男')),
                  DropdownMenuItem(value: 'female', child: Text('女')),
                  DropdownMenuItem(value: 'other', child: Text('其他')),
                ],
              ),
              const SizedBox(height: 16),
              const SmCheckboxField(
                formId: 'example_form',
                name: 'agree',
                label: '我同意用户协议和隐私政策',
              ),
              const SizedBox(height: 24),
              SmFormSubmitButton(
                formId: 'example_form',
                text: '提交表单',
                onSubmit: (values) async {
                  // 模拟提交
                  await Future.delayed(const Duration(seconds: 2));
                  return values;
                },
                onSuccess: (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('提交成功！')),
                  );
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('提交失败: $error')),
                  );
                },
              ),
              const SizedBox(height: 16),
              // 表单值监听示例
              const FormValueListener(
                formId: 'example_form',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 表单值监听示例组件
class FormValueListener extends ConsumerWidget {
  final String formId;

  const FormValueListener({
    super.key,
    required this.formId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formManagerProvider(formId));

    // 监听表单值变化
    FormListener.listenToValueChanges(
      ref,
      formId,
      (name, value) {
        print('字段 $name 的值变为: $value');
      },
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前表单值:',
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
            const SizedBox(height: 8),
            Text(
              '表单状态:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('是否有效: ${formState.isValid}'),
            Text('是否已修改: ${formState.isDirty}'),
            Text('是否已提交: ${formState.submitted}'),
            Text('正在提交: ${formState.submitting}'),
          ],
        ),
      ),
    );
  }
}
