# SM Form

一个功能强大的 Flutter 表单组件库，基于 `hooks_riverpod` 构建，提供完整的表单管理、校验、提交、联动和监听功能。

## 功能特性

- ✅ **表单管理** - 统一管理表单状态和字段
- ✅ **表单提交** - 支持异步提交和提交状态管理
- ✅ **表单校验** - 内置常用校验器，支持自定义校验规则
- ✅ **表单值派发** - 自动同步表单值变化
- ✅ **表单联动** - 声明式配置，自动处理字段显示/隐藏、必填状态、选项更新
- ✅ **表单监听** - 监听表单值、错误、状态等变化
- ✅ **多种字段类型** - 文本、数字、下拉、复选框、单选等
- ✅ **动态选项** - 支持根据依赖字段动态更新下拉选项
- ✅ **自动校验** - 支持失去焦点时自动校验
- ✅ **实时校验** - 输入后自动清除错误，已校验字段实时重新校验
- ✅ **自动滚动** - 提交失败时自动滚动到错误字段
- ✅ **多表单支持** - 同一页面可同时使用多个独立表单

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  sm_form:
    path: ../sm_form # 或使用 git/版本号
  hooks_riverpod: ^2.5.1
  flutter_hooks: ^0.20.5
```

## 快速开始

### 1. 设置 ProviderScope

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. 定义表单字段

```dart
final fields = {
  'username': FormFieldModel<String>(
    name: 'username',
    label: '用户名',
    required: true,
    initialValue: '',
    validators: [
      CommonValidators.required(message: '用户名不能为空'),
      CommonValidators.length(min: 3, max: 20),
    ],
  ),
  'email': FormFieldModel<String>(
    name: 'email',
    label: '邮箱',
    required: true,
    validators: [
      CommonValidators.required(),
      CommonValidators.email(),
    ],
  ),
};
```

### 3. 创建表单

#### 基础表单 (SmForm)

```dart
SmForm(
  formId: 'my_form',
  fields: fields,
  child: Column(
    children: [
      SmTextField(
        formId: 'my_form',
        name: 'username',
        label: '用户名',
      ),
      SmTextField(
        formId: 'my_form',
        name: 'email',
        label: '邮箱',
        keyboardType: TextInputType.emailAddress,
      ),
      SmFormSubmitButton(
        formId: 'my_form',
        text: '提交',
        onSubmit: (values) async {
          print('提交的数据: $values');
          return values;
        },
        onSuccess: (result) {
          print('提交成功');
        },
      ),
    ],
  ),
)
```

#### 支持联动的表单 (SmFormWithDependency)

```dart
SmFormWithDependency(
  formId: 'my_form',
  fields: fields,
  dependencies: dependencies,  // 联动配置
  child: Column(
    children: [
      // 字段组件...
    ],
  ),
)
```

## 字段类型

### 文本输入 (SmTextField)

```dart
SmTextField(
  formId: 'form_id',
  name: 'field_name',
  label: '标签',
  hint: '提示文本',
  obscureText: false,  // 密码输入
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(Icons.person),
)
```

### 数字输入 (SmNumberField)

```dart
SmNumberField(
  formId: 'form_id',
  name: 'age',
  label: '年龄',
  prefixIcon: Icon(Icons.calendar_today),
)
```

### 下拉选择 (SmDropdownField)

```dart
SmDropdownField<String>(
  formId: 'form_id',
  name: 'gender',
  label: '性别',
  items: [
    DropdownMenuItem(value: 'male', child: Text('男')),
    DropdownMenuItem(value: 'female', child: Text('女')),
  ],
)
```

### 复选框 (SmCheckboxField)

```dart
SmCheckboxField(
  formId: 'form_id',
  name: 'agree',
  label: '同意用户协议',
)
```

### 单选按钮组 (SmRadioGroupField)

```dart
SmRadioGroupField<String>(
  formId: 'form_id',
  name: 'option',
  label: '选项',
  options: [
    RadioOption(value: 'option1', label: '选项1'),
    RadioOption(value: 'option2', label: '选项2'),
  ],
)
```

### 自定义字段

如果现有的字段类型不满足需求，可以使用 `SmFormField<T>` 创建自定义字段：

```dart
SmFormField<int>(
  formId: 'form_id',
  name: 'rating',
  builder: (context, value, errorText, onChanged, disabled) {
    // context: BuildContext
    // value: 当前字段值 (T?)
    // errorText: 错误信息 (String?)
    // onChanged: 值变化回调 (void Function(T?))
    // disabled: 是否禁用 (bool)

    return InputDecorator(
      decoration: InputDecoration(
        labelText: '评分',
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        children: List.generate(5, (index) {
          final rating = index + 1;
          final isSelected = value != null && value >= rating;
          return GestureDetector(
            onTap: disabled ? null : () => onChanged(rating),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          );
        }),
      ),
    );
  },
)
```

**自定义字段的 builder 参数说明**：

- `context`: BuildContext，用于访问主题、媒体查询等
- `value`: 当前字段的值（类型为 `T?`）
- `errorText`: 字段的错误信息（如果有）
- `onChanged`: 值变化时的回调函数，调用 `onChanged(newValue)` 来更新字段值
- `disabled`: 字段是否被禁用

**完整示例**：

```dart
// 1. 定义字段模型
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
  ),
};

// 2. 使用自定义字段
SmFormField<DateTime>(
  formId: 'form_id',
  name: 'date',
  builder: (context, value, errorText, onChanged, disabled) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: '日期',
        errorText: errorText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      child: InkWell(
        onTap: disabled ? null : () async {
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
            value != null
                ? '${value.year}-${value.month}-${value.day}'
                : '请选择日期',
          ),
        ),
      ),
    );
  },
)
```

更多自定义字段示例请查看 `example/lib/custom_field_example.dart`。

## 校验器

### 内置校验器

```dart
// 必填
CommonValidators.required(message: '此字段为必填项')

// 长度
CommonValidators.length(min: 3, max: 20)

// 邮箱
CommonValidators.email()

// 手机号（中国）
CommonValidators.phone()

// 数字范围
CommonValidators.range(min: 0, max: 100)

// 正则表达式
CommonValidators.pattern(RegExp(r'^\d+$'), message: '只能输入数字')

// 组合多个校验器
CommonValidators.combine([
  CommonValidators.required(),
  CommonValidators.email(),
])
```

### 自定义校验器

```dart
FormFieldModel<String>(
  name: 'password',
  validators: [
    (value) {
      if (value == null || value.length < 8) {
        return '密码至少8个字符';
      }
      return null;
    },
  ],
)
```

## 表单监听

### 监听值变化

```dart
FormListener.listenToValueChanges(
  ref,
  'form_id',
  (name, value) {
    print('字段 $name 的值变为: $value');
  },
);
```

### 监听错误变化

```dart
FormListener.listenToErrorChanges(
  ref,
  'form_id',
  (name, error) {
    print('字段 $name 的错误: $error');
  },
);
```

### 监听提交状态

```dart
FormListener.listenToSubmitStatus(
  ref,
  'form_id',
  (submitting, submitted) {
    print('提交中: $submitting, 已提交: $submitted');
  },
);
```

### 监听验证状态

```dart
FormListener.listenToValidationStatus(
  ref,
  'form_id',
  (isValid) {
    print('表单是否有效: $isValid');
  },
);
```

## 表单管理

### 获取表单状态

```dart
final formState = ref.watch(formManagerProvider('form_id'));
final manager = ref.read(formManagerProvider('form_id').notifier);

// 获取值
final username = formState.getValue<String>('username');
final allValues = formState.getValues();

// 手动校验
await manager.validateField('username');
await manager.validateAll();

// 重置表单
manager.reset();

// 清除表单
manager.clear();

// 设置字段错误
manager.setFieldError('username', '用户名已存在');

// 启用/禁用字段
manager.setFieldEnabled('username', false);

// 批量更新表单值（patch）- 一次性设置多个字段，自动触发联动
manager.patch({
  'username': 'john',
  'email': 'john@example.com',
  'age': 25,
}, skipValidation: false);  // skipValidation: true 跳过校验
```

## 字段联动

### 方式一：声明式配置（推荐）

使用 `SmFormWithDependency` 和声明式配置，简化联动逻辑：

```dart
// 定义表单字段
final fields = {
  'province': FormFieldModel<String>(
    name: 'province',
    label: '省份',
    required: true,
  ),
  'city': FormFieldModel<String>(
    name: 'city',
    label: '城市',
    required: true,
  ),
  'district': FormFieldModel<String>(
    name: 'district',
    label: '区县',
    required: false,
  ),
};

// 定义联动规则
final dependencies = formDependencies()
    // 当省份选择 'beijing' 时，城市选项更新
    .add(
      formDependencies()
          .field('city')
          .dependsOn('province')
          .whenValue('beijing')
          .thenUpdateOptions((value) => ['chaoyang', 'haidian', 'dongcheng'])
          .build(),
    )
    // 当城市选择 'chaoyang' 时，区县显示且必填
    .add(
      formDependencies()
          .field('district')
          .dependsOn('city')
          .whenValue('chaoyang')
          .thenShow()
          .thenRequire()
          .build(),
    )
    .build();

// 使用 SmFormWithDependency
SmFormWithDependency(
  formId: 'address_form',
  fields: fields,
  dependencies: dependencies,
  child: Column(
    children: [
      SmDropdownField<String>(
        formId: 'address_form',
        name: 'province',
        label: '省份',
        items: [
          DropdownMenuItem(value: 'beijing', child: Text('北京')),
          DropdownMenuItem(value: 'shanghai', child: Text('上海')),
        ],
      ),
      // 城市字段会根据省份动态更新选项
      _buildCityField(),
      // 区县字段会根据城市动态显示/隐藏
      _buildDistrictField(),
    ],
  ),
)
```

#### 联动规则 API

```dart
// 当依赖字段的值等于指定值时
formDependencies()
    .field('fieldName')
    .dependsOn('dependsOnField')
    .whenValue('value')
    .thenShow()        // 显示字段
    .thenRequire()     // 设置为必填
    .thenUpdateOptions((value) => [...])  // 更新选项
    .thenUpdateValue((value) => ...)      // 更新字段值
    .thenClearValue()  // 清除字段值
    .build()

// 当依赖字段的值在指定列表中时
.whenValueIn(['value1', 'value2'])

// 自定义条件
.when((value) => value != null && value.length > 0)
```

### 方式二：手动处理（传统方式）

通过 `dependencies` 和 `onChanged` 手动实现字段联动：

```dart
FormFieldModel<String>(
  name: 'city',
  dependencies: ['province'],  // 依赖省份字段
  onChanged: (value) {
    // 当省份变化时，可以更新城市选项
    print('省份变化，更新城市选项');
  },
)
```

### 动态选项字段

使用 `SmDropdownFieldDynamic` 处理动态选项：

```dart
SmDropdownFieldDynamic<String>(
  formId: 'form_id',
  name: 'city',
  dependsOn: 'province',  // 依赖的字段
  label: '城市',
  itemsBuilder: (provinceValue) {
    // 根据省份值动态生成城市选项
    if (provinceValue == 'beijing') {
      return [
        DropdownMenuItem(value: 'chaoyang', child: Text('朝阳')),
        DropdownMenuItem(value: 'haidian', child: Text('海淀')),
      ];
    }
    return [
      DropdownMenuItem(value: 'huangpu', child: Text('黄浦')),
      DropdownMenuItem(value: 'pudong', child: Text('浦东')),
    ];
  },
)
```

## 高级用法

### 异步校验

```dart
FormFieldModel<String>(
  name: 'username',
  validators: [
    (value) async {
      // 检查用户名是否已存在
      final exists = await checkUsernameExists(value);
      return exists ? '用户名已存在' : null;
    },
  ],
)
```

### 动态字段

```dart
// 动态注册字段
final manager = ref.read(formManagerProvider('form_id').notifier);
manager.registerField(FormFieldModel<String>(
  name: 'dynamic_field',
  label: '动态字段',
));
```

### 批量赋值（Patch）

使用 `patch` 方法可以一次性设置多个字段的值，并自动触发联动：

```dart
final manager = ref.read(formManagerProvider('form_id').notifier);

// 批量设置字段值，会自动按照依赖顺序更新，并触发联动
manager.patch({
  'province': 'beijing',
  'city': 'chaoyang',
  'district': 'sanlitun',
});

// 跳过校验（只更新值，不进行校验）
manager.patch({
  'username': 'john',
  'email': 'john@example.com',
}, skipValidation: true);
```

**特性**：

- 自动按照依赖顺序更新字段（被依赖的字段先更新）
- 自动触发字段联动规则
- 自动清除错误信息
- 可选择是否进行校验

## 示例

完整示例请查看 `example/lib/main.dart`，包含以下示例：

- **基础表单示例** (`FormExamplePage`) - 展示基本的表单功能
- **表单联动示例（手动方式）** (`FormLinkageExamplePage`) - 展示手动处理表单联动
- **表单联动示例（简化方式）** (`FormLinkageSimpleExamplePage`) - 使用声明式配置简化联动逻辑
- **多表单示例** (`MultiFormExamplePage`) - 展示同一页面多个独立表单
- **自定义字段示例** (`CustomFieldExamplePage`) - 展示如何创建自定义表单字段

### 运行示例

```bash
cd example
flutter run
```

## 特性说明

### 自动处理选项变化

当联动导致选项更新时，如果当前字段的值不在新选项中，系统会自动清除该值，避免 `DropdownButton` 报错。

### 多表单支持

通过 `formId` 区分不同的表单，可以在同一页面使用多个独立的表单：

```dart
SmForm(
  formId: 'form1',
  fields: {...},
  child: ...,
)

SmForm(
  formId: 'form2',
  fields: {...},
  child: ...,
)
```

### 自动滚动到错误字段

提交表单时，如果验证失败，会自动滚动到第一个有错误的字段。

## License

MIT License
