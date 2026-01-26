# Changelog

所有重要的变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2024

### 新增功能

#### 核心功能

- ✅ **表单管理** - 统一管理表单状态和字段，支持多表单实例
- ✅ **表单提交** - 支持异步提交和提交状态管理
- ✅ **表单校验** - 内置常用校验器，支持同步/异步自定义校验规则
- ✅ **表单值派发** - 自动同步表单值变化
- ✅ **表单联动** - 声明式配置，自动处理字段显示/隐藏、必填状态、选项更新
- ✅ **表单监听** - 监听表单值、错误、状态等变化

#### 字段类型

- ✅ **文本输入** (`SmTextField`) - 支持各种键盘类型、前缀/后缀图标
- ✅ **数字输入** (`SmNumberField`) - 数字专用输入框
- ✅ **下拉选择** (`SmDropdownField`) - 静态选项下拉框
- ✅ **动态下拉选择** (`SmDropdownFieldDynamic`) - 根据依赖字段动态生成选项
- ✅ **复选框** (`SmCheckboxField`) - 布尔值复选框
- ✅ **单选按钮组** (`SmRadioGroupField`) - 单选按钮组
- ✅ **自定义字段** (`SmFormField<T>`) - 支持创建任意类型的自定义字段

#### 校验功能

- ✅ **内置校验器** - 必填、长度、邮箱、手机号、数字范围、正则表达式等
- ✅ **自定义校验器** - 支持同步和异步校验函数
- ✅ **自动校验** - 支持失去焦点时自动校验
- ✅ **实时校验** - 输入后自动清除错误，已校验字段实时重新校验

#### 联动功能

- ✅ **声明式配置** - 使用 `formDependencies()` 简化联动规则定义
- ✅ **条件规则** - 支持 `whenValue`、`whenValueIn`、`when` 等多种条件判断
- ✅ **联动操作** - 支持显示/隐藏、必填/非必填、更新选项、更新值、清除值
- ✅ **批量赋值** - `patch` 方法支持批量设置字段值，自动按依赖顺序更新并触发联动

#### 用户体验

- ✅ **自动滚动** - 提交失败时自动滚动到第一个错误字段
- ✅ **错误提示** - 清晰的错误信息显示和管理
- ✅ **禁用/只读** - 支持字段禁用和只读状态
- ✅ **选项自动清理** - 联动导致选项变化时，自动清除无效值

#### 表单监听

- ✅ **值变化监听** - `FormListener.listenToValueChanges`
- ✅ **错误变化监听** - `FormListener.listenToErrorChanges`
- ✅ **提交状态监听** - `FormListener.listenToSubmitStatus`
- ✅ **验证状态监听** - `FormListener.listenToValidationStatus`

#### 表单管理 API

- ✅ **获取表单状态** - `formManagerProvider(formId)`
- ✅ **手动校验** - `validateField`、`validateAll`
- ✅ **重置表单** - `reset`
- ✅ **清除表单** - `clear`
- ✅ **设置字段错误** - `setFieldError`
- ✅ **启用/禁用字段** - `setFieldEnabled`
- ✅ **批量更新** - `patch` 方法

### 技术特性

- 基于 `hooks_riverpod` 进行状态管理
- 使用 `flutter_hooks` 提供响应式 UI
- 支持泛型类型，类型安全
- 支持多表单实例，通过 `formId` 区分
- 拓扑排序确保依赖字段按正确顺序更新
