import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_form/sm_form.dart';

/// 简化的表单联动示例
class FormLinkageSimpleExamplePage extends ConsumerStatefulWidget {
  const FormLinkageSimpleExamplePage({super.key});

  @override
  ConsumerState<FormLinkageSimpleExamplePage> createState() => _FormLinkageSimpleExamplePageState();
}

class _FormLinkageSimpleExamplePageState extends ConsumerState<FormLinkageSimpleExamplePage> {
  @override
  Widget build(BuildContext context) {
    // 定义表单字段
    final fields = {
      'A': FormFieldModel<String>(
        name: 'A',
        label: '选项A',
        hint: '请选择选项A',
        required: true,
      ),
      'B': FormFieldModel<String>(
        name: 'B',
        label: '选项B',
        hint: '请选择选项B',
        required: true,
      ),
      'C': FormFieldModel<String>(
        name: 'C',
        label: '选项C',
        hint: '请选择选项C',
        required: true,
      ),
      'D': FormFieldModel<String>(
        name: 'D',
        label: '选项D',
        hint: '请选择选项D',
        required: false,
      ),
    };

    // 定义联动规则（使用声明式配置）
    final dependencies = formDependencies()
        // B 依赖 A：当 A = 'a1' 时，B 的选项变为 b11, b22, b33, b44
        .add(
          formDependencies().field('B').dependsOn('A').whenValue('a1').thenUpdateOptions((value) => ['b11', 'b22', 'b33', 'b44']).build(),
        )
        // C 依赖 A：当 A = 'a1' 时，C 的选项变为 c11, c22, c33, c44
        .add(
          formDependencies().field('C').dependsOn('A').whenValue('a1').thenUpdateOptions((value) => ['c11', 'c22', 'c33', 'c44']).build(),
        )
        // D 依赖 B 和 C：当 B = 'b2' 或 'b22'，或 C = 'c22' 或 'C22' 时，D 显示且必填
        .add(
          formDependencies().field('D').dependsOn('B').whenValueIn(['b2', 'b22']).thenShow().thenRequire().build(),
        )
        .add(
          formDependencies().field('D').dependsOn('C').whenValueIn(['c22', 'C22']).thenShow().thenRequire().build(),
        )
        .build();

    return Scaffold(
      appBar: AppBar(
        title: const Text('简化表单联动示例'),
      ),
      body: SmFormWithDependency(
        formId: 'linkage_simple_form',
        fields: fields,
        dependencies: dependencies,
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
              // 字段 A
              _buildFieldA(),

              const SizedBox(height: 16),

              // 字段 B（动态选项）
              _buildFieldB(),

              const SizedBox(height: 16),

              // 字段 C（动态选项）
              _buildFieldC(),

              const SizedBox(height: 16),

              // 字段 D（条件显示）
              _buildFieldD(),

              const SizedBox(height: 32),

              // Patch 按钮（演示批量赋值）
              ElevatedButton(
                onPressed: () {
                  final manager = ref.read(formManagerProvider('linkage_simple_form').notifier);
                  // 一次性设置多个字段的值，会自动触发联动
                  manager.patch({
                    'A': 'a1',
                    'B': 'b22',
                    'C': 'c22',
                    'D': 'd1',
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已使用 patch 方法批量赋值')),
                  );
                },
                child: const Text('Patch 赋值（A=a1, B=b22, C=c22）'),
              ),

              const SizedBox(height: 16),

              // 提交按钮
              SmFormSubmitButton(
                formId: 'linkage_simple_form',
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

  /// 构建字段A
  Widget _buildFieldA() {
    return const SmDropdownField<String>(
      formId: 'linkage_simple_form',
      name: 'A',
      label: '选项A',
      hint: '请选择选项A',
      items: [
        DropdownMenuItem(value: 'a1', child: Text('a1')),
        DropdownMenuItem(value: 'a2', child: Text('a2')),
        DropdownMenuItem(value: 'a3', child: Text('a3')),
      ],
    );
  }

  /// 构建字段B（根据A的值动态变化）
  Widget _buildFieldB() {
    final formState = ref.watch(formManagerProvider('linkage_simple_form'));
    final aValue = formState.getValue<String>('A');

    // 根据A的值动态生成B的选项
    List<DropdownMenuItem<String>> items;
    if (aValue == 'a1') {
      items = const [
        DropdownMenuItem(value: 'b11', child: Text('b11')),
        DropdownMenuItem(value: 'b22', child: Text('b22')),
        DropdownMenuItem(value: 'b33', child: Text('b33')),
        DropdownMenuItem(value: 'b44', child: Text('b44')),
      ];
    } else {
      items = const [
        DropdownMenuItem(value: 'b1', child: Text('b1')),
        DropdownMenuItem(value: 'b2', child: Text('b2')),
        DropdownMenuItem(value: 'b3', child: Text('b3')),
        DropdownMenuItem(value: 'b4', child: Text('b4')),
      ];
    }

    return SmDropdownField<String>(
      formId: 'linkage_simple_form',
      name: 'B',
      label: '选项B',
      hint: '请选择选项B',
      items: items,
    );
  }

  /// 构建字段C（根据A的值动态变化）
  Widget _buildFieldC() {
    final formState = ref.watch(formManagerProvider('linkage_simple_form'));
    final aValue = formState.getValue<String>('A');

    // 根据A的值动态生成C的选项
    List<DropdownMenuItem<String>> items;
    if (aValue == 'a1') {
      items = const [
        DropdownMenuItem(value: 'c11', child: Text('c11')),
        DropdownMenuItem(value: 'c22', child: Text('c22')),
        DropdownMenuItem(value: 'c33', child: Text('c33')),
        DropdownMenuItem(value: 'c44', child: Text('c44')),
      ];
    } else {
      items = const [
        DropdownMenuItem(value: 'c1', child: Text('c1')),
        DropdownMenuItem(value: 'c2', child: Text('c2')),
        DropdownMenuItem(value: 'c3', child: Text('c3')),
        DropdownMenuItem(value: 'c4', child: Text('c4')),
      ];
    }

    return SmDropdownField<String>(
      formId: 'linkage_simple_form',
      name: 'C',
      label: '选项C',
      hint: '请选择选项C',
      items: items,
    );
  }

  /// 构建字段D（根据B和C的值动态显示/隐藏）
  Widget _buildFieldD() {
    final formState = ref.watch(formManagerProvider('linkage_simple_form'));
    final bValue = formState.getValue<String>('B');
    final cValue = formState.getValue<String>('C');

    // 判断D是否应该显示
    final shouldShow = (bValue == 'b2' || bValue == 'b22') || (cValue == 'c22' || cValue == 'C22');

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return const SmDropdownField<String>(
      formId: 'linkage_simple_form',
      name: 'D',
      label: '选项D（必填）',
      hint: '请选择选项D',
      items: [
        DropdownMenuItem(value: 'd1', child: Text('d1')),
        DropdownMenuItem(value: 'd2', child: Text('d2')),
        DropdownMenuItem(value: 'd3', child: Text('d3')),
      ],
    );
  }
}
