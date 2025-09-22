# LayoutBox

LayoutBox是一个优雅的Swift库，用于iOS开发，通过声明式语法简化UICollectionViewCompositionalLayout的创建过程。它提供了一种简洁、直观的方式来构建复杂的集合视图布局，使您能够专注于应用程序的业务逻辑而非繁琐的布局代码。

## 特性

- **声明式语法**：使用简洁明了的声明式API构建复杂布局
- **链式调用**：支持流畅的链式语法进行布局配置
- **组合灵活**：轻松创建嵌套的水平/垂直布局组
- **间距控制**：精确控制项目间距、边缘间距和内容边缘插入
- **支持iOS 14+**：兼容较新的iOS版本
- **Swift Package Manager支持**：易于集成到项目中

## 快速开始

### 安装

#### Swift Package Manager

在Xcode中，选择File > Add Packages...，然后输入以下URL：

```
https://github.com/willlzq/LayoutBox.git
```

### 基本用法

```swift
import LayoutBox
import UIKit

// 创建一个简单的2列水平布局
let section = self.createSimpleLayoutSection()
let layout = UICollectionViewCompositionalLayout(section: section)
let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

// 创建布局的函数
func createSimpleLayoutSection() -> NSCollectionLayoutSection {
    // 创建一个水平组，包含2列项目
    let group = GroupLayoutBox(width: .fractionalWidth(1.0), height: .absolute(100)) {
        ItemLayoutBox(columns: 2, width: .fractionalWidth(0.5), height: .fractionalHeight(1.0))
            .insets(space: 8)
    }
    .space(.fixed(8)) // 设置项目间距
    .insets(space: 16) // 设置组的边缘间距
    .toBuild()
    
    // 创建并返回section
    let section = NSCollectionLayoutSection(group: group)
    return section
}
```

## 示例

### 示例1：嵌套组布局

创建包含不同类型子项的复杂嵌套布局：

```swift
// 创建嵌套组布局
let nestedGroupLayout = GroupLayoutBox(width: .fractionalWidth(1.0), height: .fractionalHeight(0.4)) {
    // 2列的水平项目组
    ItemLayoutBox(columns: 2, width: .w(0.3), height: .h(1.0))
        .insets(space: 10)
    
    // 垂直子组
    GroupLayoutBox(direction: .vertical, width: .fractionalWidth(0.4), height: .fractionalHeight(1.0)) {
        ItemLayoutBox(columns: 2, width: .fractionalWidth(1.0), height: .fractionalHeight(0.3))
            .insets(NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}
.insets(NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
.toBuild()

let section = NSCollectionLayoutSection(group: nestedGroupLayout)
```

### 示例2：不同尺寸项目的垂直布局

创建包含不同高度项目的垂直布局：

```swift
// 创建垂直组，包含三个不同高度的项目
let verticalGroupLayout = GroupLayoutBox(direction: .vertical, width: .absolute(110), height: .absolute(205)) {
    ItemLayoutBox(columns: 1, width: .absolute(110), height: .absolute(45))
    ItemLayoutBox(columns: 1, width: .absolute(110), height: .absolute(65))
    ItemLayoutBox(columns: 1, width: .absolute(110), height: .absolute(85))
}
.space(.fixed(5)) // 项目间距
.leading(.flexible(5)) // 左侧弹性间距
.trailing(.flexible(5)) // 右侧弹性间距
.toBuild()

let section = NSCollectionLayoutSection(group: verticalGroupLayout)
```

## API参考

### 尺寸便捷方法

```swift
// 使用便捷方法创建宽度维度
let width = NSCollectionLayoutDimension.w(0.5) // 等同于 .fractionalWidth(0.5)

// 使用便捷方法创建高度维度
let height = NSCollectionLayoutDimension.h(0.3) // 等同于 .fractionalHeight(0.3)
```

### ItemLayoutBox

用于定义单个项目的布局配置：

```swift
// 创建一个项目布局
let item = ItemLayoutBox(columns: 2, width: .fractionalWidth(0.5), height: .fractionalHeight(1.0))
    .insets(space: 8) // 设置内容边缘插入

// 构建为NSCollectionLayoutItem数组
let layoutItems = item.toBuild()
```

### GroupLayoutBox

用于定义布局组，可包含多个项目或子组：

```swift
// 创建一个水平组
let group = GroupLayoutBox(width: .fractionalWidth(1.0), height: .absolute(100)) {
    // 组内容...
}
.direction(.horizontal) // 设置方向(默认为水平)
.space(.fixed(8)) // 设置项目间距
.insets(space: 16) // 设置组的边缘插入
.toBuild() // 构建为NSCollectionLayoutGroup
```

### 间距控制

```swift
// 设置特定边缘的间距
let group = GroupLayoutBox(width: .fractionalWidth(1.0), height: .absolute(100)) {
    // 组内容...
}
.leading(.fixed(10)) // 左侧间距
.top(.flexible(5)) // 顶部弹性间距
.trailing(.fixed(10)) // 右侧间距
.bottom(.flexible(5)) // 底部弹性间距
```

## License

LayoutBox is available under the MIT license. See the LICENSE file for more info.

## 贡献

欢迎提交Pull Requests来改进这个库。

## 作者

files Share

## 鸣谢

本库受到了SwiftUI声明式语法的启发，旨在为UIKit中的集合视图布局提供类似的开发体验。
