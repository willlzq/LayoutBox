# 仿swiftUI一步步使用声明式语法创建NSCollectionLayoutGroup

## 前言

当我们在 SwiftUI 中编写如下代码时，ViewBuilder 的 buildBlock 方法就在幕后工作：

```swift
VStack {
    Text("Hello")
    Image(systemName: "star")
    if showDetail {
        Text("Detail view") // 对应 TrueContent
    } else {
        Text("Summary view") // 对应 FalseContent
        Button("Tap me") {}
    }
}
```

这种声明式语法让界面构建变得如此清晰直观，那么在 Swift 原生语言中是否也可以实现类似的效果呢？答案是肯定的！

在本文中，我将带领大家一步步实现一个仿 SwiftUI 声明式语法的布局库，用于更优雅地创建 `NSCollectionLayoutGroup`，这个库正是基于 Swift 的三大语法特性实现的。

## Swift 声明式语法的三大利器

### 1. 布局构建器：@resultBuilder

`@resultBuilder` 是实现声明式语法的核心，它允许我们以更自然的方式组合多个元素，而不需要使用逗号分隔。在 Swift 5.4 之前，它被称为 `@_functionBuilder`。

### 2. 逃逸闭包：@escaping

通过逃逸闭包，我们可以在函数尾部使用大括号 `{}` 创建一个结构化的代码块，这使得我们的 API 调用看起来更像 JSON 结构，支持无限嵌套。

### 3. 链式语法

链式语法允许我们在一行代码中进行多次方法调用，只要每个方法都返回 `self` 实例。

在这三大利器中，`@resultBuilder` 是最为基础和核心的，它为整个声明式语法奠定了基础。

## 核心难点解析

使用 `@resultBuilder` 实现声明式语法时，如果想要支持 `if` 和 `for` 循环语法，就必须实现 `buildEither` 和 `buildArray` 方法。这要求我们的核心数据结构必须支持递归包含自己类型的列表。

以 `LayoutBoxConfig` 类为例：

```swift
public class LayoutBoxConfig {
    // 其他属性...
    private var isExpression: Bool = false
    private var selflist: [LayoutBoxConfig] = []
    
    // 用于构建列表的初始化方法
    public init(list: [LayoutBoxConfig]) {
        self.isExpression = true
        self.selflist = list
    }
    
    // 获取所有子项目的递归方法
    public func subItems() -> [LayoutBoxConfig] {
        var list: [LayoutBoxConfig] = []
        for item in self.selflist {
            if item.isExpression {
                // 递归获取所有子项目
                list.append(contentsOf: item.subItems())
            } else {
                list.append(item)
            }
        }
        return list
    }
}
```

这种设计允许我们在 `@resultBuilder` 中这样处理：

```swift
public static func buildArray(_ components: [LayoutBoxConfig]) -> LayoutBoxConfig {
    // 处理 for 循环
    LayoutBoxConfig(list: components)
}

public static func buildEither(first component: LayoutBoxConfig) -> LayoutBoxConfig {
    // 处理 if 分支
    component
}

public static func buildEither(second component: LayoutBoxConfig) -> LayoutBoxConfig {
    // 处理 else 分支
    component
}
```

## 实现步骤详解

### 步骤 1: 定义基础数据结构

首先，我们需要定义一些基础的数据结构来表示布局元素：

```swift
/// 布局盒子类型枚举
public enum LayoutBoxType {
    case item // 单个单元格布局
    case group // 组合的布局组
}

/// 布局组方向枚举
public enum GroupDirection {
    case horizontal // 水平方向排列
    case vertical // 垂直方向排列
}
```

### 步骤 2: 创建布局配置基类

接下来，创建 `LayoutBoxConfig` 基类，它是所有布局元素的基础：

```swift
@MainActor public class LayoutBoxConfig {
    // 边缘间距类型定义
    public typealias EdgeSpacing = (leading: NSCollectionLayoutSpacing?, 
                                  top: NSCollectionLayoutSpacing?, 
                                  trailing: NSCollectionLayoutSpacing?, 
                                  bottom: NSCollectionLayoutSpacing?)
    
    var boxType: LayoutBoxType = .item
    var itemSize: NSCollectionLayoutSize
    var insets: NSDirectionalEdgeInsets?
    var edges: EdgeSpacing?
    private var isExpression: Bool = false
    private var selflist: [LayoutBoxConfig] = []
    
    // 初始化方法和其他功能...
}
```

### 步骤 3: 实现 @resultBuilder

现在，我们来实现核心的 `LayoutBuilder` 结构体：

```swift
@MainActor @resultBuilder
public struct LayoutBuilder {
    public static func buildBlock(_ components: LayoutBoxConfig...) -> LayoutBoxConfig {
        if components.count == 1 {
            components.first!
        } else {
            LayoutBoxConfig(list: components)
        }
    }
    
    public static func buildEither(first component: LayoutBoxConfig) -> LayoutBoxConfig {
        component
    }
    
    public static func buildEither(second component: LayoutBoxConfig) -> LayoutBoxConfig {
        component
    }
    
    public static func buildArray(_ components: [LayoutBoxConfig]) -> LayoutBoxConfig {
        LayoutBoxConfig(list: components)
    }
}
```

### 步骤 4: 创建具体的布局元素类

接下来，创建 `ItemLayoutBox` 和 `GroupLayoutBox` 类：

```swift
/// 项目布局盒子类 - 表示单个单元格
@MainActor
public class ItemLayoutBox: LayoutBoxConfig {
    var columns: Int = 1
    
    public init(columns: Int = 1, width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension) {
        super.init(width: width, height: height)
        self.boxType = .item
        self.columns = columns
    }
    
    public func toBuild() -> [NSCollectionLayoutItem] {
        let item = NSCollectionLayoutItem(layoutSize: self.itemSize)
        config(item: item)
        return [NSCollectionLayoutItem](repeating: item, count: self.columns)
    }
}

/// 组布局盒子类 - 表示可以包含多个项目或子组的布局组
@MainActor
public class GroupLayoutBox: LayoutBoxConfig {
    var direction: GroupDirection = .horizontal
    var space: NSCollectionLayoutSpacing?
    private var subitems: [LayoutBoxConfig] = []
    
    @discardableResult
    public init(direction: GroupDirection = .horizontal,
                width: NSCollectionLayoutDimension,
                height: NSCollectionLayoutDimension,
                @LayoutBuilder _ builder: () -> LayoutBoxConfig) {
        super.init(width: width, height: height)
        self.boxType = .group
        self.direction = direction
        self.subitems = builder().subItems()
    }
    
    // 其他方法...
}
```

### 步骤 5: 添加链式语法支持

为了支持链式语法，我们需要在 `LayoutBoxConfig` 扩展中添加一系列返回 `self` 的方法：

```swift
public extension LayoutBoxConfig {
    @discardableResult
    func boxType(_ boxType: LayoutBoxType) -> Self {
        self.boxType = boxType
        return self
    }
    
    @discardableResult
    func insets(_ insets: NSDirectionalEdgeInsets) -> Self {
        self.insets = insets
        return self
    }
    
    // 更多链式方法...
}
```

## 实际应用示例

现在，让我们看看如何使用这个库来创建复杂的布局：

### 示例 1: 创建嵌套组布局

```swift
@MainActor static func Example1() -> NSCollectionLayoutSection {
    // 创建嵌套组，包含两个子项：一个2列项目和一个垂直子组
    let nestedGroup = GroupLayoutBox(width: .fractionalWidth(1.0), height: .fractionalHeight(0.4)) {
        // 2列的水平项目组，占父容器30%宽度
        ItemLayoutBox(columns: 2, width: .w(0.3), height: .h(1.0))
            .insets(space: 10)
        
        // 垂直子组，占父容器40%宽度
        GroupLayoutBox(direction: .vertical, width: .fractionalWidth(0.4), height: .fractionalHeight(1.0)) {
            // 子组内的2列项目，占子组100%宽度和30%高度
            ItemLayoutBox(columns: 2, width: .fractionalWidth(1.0), height: .fractionalHeight(0.3))
                .insets(NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        }
    }
        .insets(NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .toBuild()
    
    // 创建并返回基于该组的section
    let section = NSCollectionLayoutSection(group: nestedGroup)
    return section
}
```

### 示例 2: 支持 if 和 for 循环

```swift
@MainActor static func Example3() -> NSCollectionLayoutSection {
    // 测试for 和 if 语法
    let testForAndif = true
    let group = GroupLayoutBox(direction: .horizontal, width: .w(1.0), height: .absolute(120)) {
        if testForAndif {
            ItemLayoutBox(columns: 1, width: .w(0.20), height: .h(1.0)).insets(space: 20)
            ItemLayoutBox(columns: 1, width: .w(0.20), height: .h(1.0)).insets(space: 10)
            
            for i in 0..<2 {
                ItemLayoutBox(columns: 1, width: .w(0.20), height: .h(1.0)).insets(space: CGFloat(i) * 10)
            }
            
            ItemLayoutBox(columns: 1, width: .w(0.1), height: .h(1.0)).insets(space: 1)
            ItemLayoutBox(columns: 1, width: .w(0.1), height: .h(1.0)).insets(space: 5)
        } else {
            for i in 0..<10 {
                ItemLayoutBox(columns: 1, width: .w(0.1), height: .h(1.0)).insets(space: CGFloat(i) * 0.5)
            }
        }
    }
        .leading(.flexible(10)).trailing(.flexible(10)).top(.flexible(10)).bottom(.flexible(10))
        .toBuild()
    
    let section = NSCollectionLayoutSection(group: group)
    return section
}
```

## 关于LayoutBox
LayoutBox是一个优雅的Swift库，用于iOS开发，通过声明式语法简化UICollectionViewCompositionalLayout的创建过程。它提供了一种简洁、直观的方式来构建复杂的集合视图布局，使您能够专注于应用程序的业务逻辑而非繁琐的布局代码
安装
Swift Package Manager
在Xcode中，选择File > Add Packages...，然后输入以下URL：

https://github.com/willlzq/LayoutBox.git


## 总结

通过 Swift 的 `@resultBuilder`、逃逸闭包和链式语法这三大利器，我们成功实现了一个仿 SwiftUI 风格的声明式布局库。这个库让创建 `NSCollectionLayoutGroup` 变得更加直观和优雅，大大提高了代码的可读性和可维护性。

核心要点回顾：

1. `@resultBuilder` 是实现声明式语法的基础
2. 支持递归的结构设计是实现 `if` 和 `for` 语法的关键
3. 逃逸闭包让 API 调用更加结构化
4. 链式语法提供了流畅的配置体验

这种声明式语法不仅可以用于布局，还可以应用到很多其他场景，比如构建 attributed string、创建复杂的配置对象等。希望本文能给你带来一些启发，让你的代码变得更加优雅和直观！