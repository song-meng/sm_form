import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_form/sm_form.dart';

/// 表单联动示例页面
class FormLinkageExamplePage extends ConsumerStatefulWidget {
  const FormLinkageExamplePage({super.key});

  @override
  ConsumerState<FormLinkageExamplePage> createState() => _FormLinkageExamplePageState();
}

class _FormLinkageExamplePageState extends ConsumerState<FormLinkageExamplePage> {
  // 记录上一次的A值，用于检测A值是否真的变化了
  String? _lastAValue;
  // 记录上一次D的显示状态，避免重复清除
  bool _lastDShouldShow = false;

  @override
  Widget build(BuildContext context) {
    // 定义表单字段
    final fields = {
      'A': FormFieldModel<String>(
        name: 'A',
        label: '选项A',
        required: true,
        initialValue: null,
        validators: [
          CommonValidators.required(message: '请选择选项A'),
        ],
      ),
      'B': FormFieldModel<String>(
        name: 'B',
        label: '选项B',
        required: true,
        initialValue: null,
        dependencies: ['A'],
        validators: [
          CommonValidators.required(message: '请选择选项B'),
        ],
      ),
      'C': FormFieldModel<String>(
        name: 'C',
        label: '选项C',
        required: true,
        initialValue: null,
        dependencies: ['A'],
        validators: [
          CommonValidators.required(message: '请选择选项C'),
        ],
      ),
      'D': FormFieldModel<String>(
        name: 'D',
        label: '选项D',
        required: false, // 初始不必填，显示时会通过自定义校验确保必填
        initialValue: null,
        dependencies: ['B', 'C'],
        validators: [
          // 动态校验函数，会在校验时检查B和C的值
          (value) {
            // 这个校验器会在 validateAll 时被调用
            // 但此时无法访问 formState，所以我们需要在提交时手动检查
            // 这里先返回 null，实际的校验在提交时处理
            return null;
          },
        ],
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('表单联动示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SmForm(
        formId: 'linkage_form',
        fields: fields,
        onInitialized: () {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '表单联动示例',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '规则：\n'
                '1. 当A选择a1时，B的选项变为b11,b22,b33,b44，C的选项变为c11,c22,c33,c44\n'
                '2. 当B选择b2/b22或C选择c22/C22时，D显示且必填\n'
                '3. 其他情况D隐藏',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // 字段A
              _buildFieldA(),
              const SizedBox(height: 16),
              // 字段B（根据A动态变化）
              _buildFieldB(),
              const SizedBox(height: 16),
              // 字段C（根据A动态变化）
              _buildFieldC(),
              const SizedBox(height: 16),
              // 字段D（根据B和C动态显示）
              _buildFieldD(),
              const SizedBox(height: 24),
              // 提交按钮
              SmFormSubmitButton(
                formId: 'linkage_form',
                text: '提交表单',
                onSubmit: (values) async {
                  // 提交前检查D字段是否需要必填
                  final formState = ref.read(formManagerProvider('linkage_form'));
                  final bValue = formState.getValue<String>('B');
                  final cValue = formState.getValue<String>('C');
                  final dValue = formState.getValue<String>('D');

                  // 判断是否需要显示D
                  final shouldShowD = bValue == 'b2' || bValue == 'b22' || cValue == 'c22' || cValue == 'C22';

                  // 如果需要显示D但未填写，设置错误
                  if (shouldShowD && (dValue == null || dValue.isEmpty)) {
                    final manager = ref.read(formManagerProvider('linkage_form').notifier);
                    manager.setFieldError('D', '请选择选项D');
                    throw Exception('请选择选项D');
                  }

                  await Future.delayed(const Duration(seconds: 1));
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
            ],
          ),
        ),
      ),
    );
  }

  /// 构建字段A
  Widget _buildFieldA() {
    return const SmDropdownField<String>(
      formId: 'linkage_form',
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
    final formState = ref.watch(formManagerProvider('linkage_form'));
    final aValue = formState.getValue<String>('A');
    final manager = ref.read(formManagerProvider('linkage_form').notifier);

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

    // 监听A的变化，当A变化时清除B的值（如果B的值不在新选项中）
    final currentBValue = formState.getValue<String>('B');
    if (aValue != _lastAValue && aValue != null) {
      _lastAValue = aValue;
      if (currentBValue != null) {
        // 检查B的值是否在新的选项中
        final isValidOption = items.any((item) => item.value == currentBValue);
        if (!isValidOption) {
          // B的值不在新选项中，清除它（只清除一次）
          Future.microtask(() {
            final currentState = ref.read(formManagerProvider('linkage_form'));
            final currentB = currentState.getValue<String>('B');
            // 再次检查，避免重复清除
            if (currentB != null && !items.any((item) => item.value == currentB)) {
              manager.updateValue<String>('B', null);
            }
          });
        }
      }
    }

    return SmDropdownField<String>(
      formId: 'linkage_form',
      name: 'B',
      label: '选项B',
      hint: '请选择选项B',
      items: items,
    );
  }

  /// 构建字段C（根据A的值动态变化）
  Widget _buildFieldC() {
    final formState = ref.watch(formManagerProvider('linkage_form'));
    final aValue = formState.getValue<String>('A');
    final manager = ref.read(formManagerProvider('linkage_form').notifier);

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

    // 监听A的变化，当A变化时清除C的值（如果C的值不在新选项中）
    final currentCValue = formState.getValue<String>('C');
    if (aValue != _lastAValue && aValue != null) {
      if (currentCValue != null) {
        // 检查C的值是否在新的选项中
        final isValidOption = items.any((item) => item.value == currentCValue);
        if (!isValidOption) {
          // C的值不在新选项中，清除它（只清除一次）
          Future.microtask(() {
            final currentState = ref.read(formManagerProvider('linkage_form'));
            final currentC = currentState.getValue<String>('C');
            // 再次检查，避免重复清除
            if (currentC != null && !items.any((item) => item.value == currentC)) {
              manager.updateValue<String>('C', null);
            }
          });
        }
      }
    }

    return SmDropdownField<String>(
      formId: 'linkage_form',
      name: 'C',
      label: '选项C',
      hint: '请选择选项C',
      items: items,
    );
  }

  /// 构建字段D（根据B和C的值动态显示/隐藏）
  Widget _buildFieldD() {
    final formState = ref.watch(formManagerProvider('linkage_form'));
    final bValue = formState.getValue<String>('B');
    final cValue = formState.getValue<String>('C');

    // 判断是否需要显示D：B为b2或b22，或者C为c22或C22
    final shouldShow = bValue == 'b2' || bValue == 'b22' || cValue == 'c22' || cValue == 'C22';

    // 如果显示状态变化了，清除或保留D的值
    if (shouldShow != _lastDShouldShow) {
      _lastDShouldShow = shouldShow;
      if (!shouldShow) {
        // 从显示变为隐藏，清除D的值和错误
        final manager = ref.read(formManagerProvider('linkage_form').notifier);
        Future.microtask(() {
          manager.updateValue<String>('D', null);
          manager.setFieldError('D', null);
        });
      }
    }

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    // 需要显示D字段，使用自定义校验器来确保必填
    return const SmDropdownField<String>(
      formId: 'linkage_form',
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
