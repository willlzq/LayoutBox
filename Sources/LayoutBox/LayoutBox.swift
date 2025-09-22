// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  GridCollection.swift
//  BlueGuysSoc
//  布局详细文档：https://kingnight.github.io/programming/2023/08/25/UICollection-Compositional-Layout%E5%85%A8%E8%AF%A6%E8%A7%A3.html
//  Created by files Share on 2025/9/19.
//
import UIKit

/// 布局盒子类型枚举
/// 用于区分布局元素是单个项目(item)还是组合组(group)
public enum LayoutBoxType : Hashable {
    /// 表示单个单元格布局
    case item
    /// 表示组合的布局组
    case group
}

/// 布局组方向枚举
/// 定义组内元素的排列方向
public enum GroupDirection : Hashable {
    /// 水平方向排列元素
    case horizontal
    /// 垂直方向排列元素
    case vertical
}
/// NSCollectionLayoutDimension扩展
/// 提供更简洁的方式创建宽度和高度维度
public extension NSCollectionLayoutDimension {
    /// 创建基于分数的宽度维度
    /// - Parameter fractionalWidth: 相对父容器的宽度比例(0.0-1.0)
    /// - Returns: 配置好的NSCollectionLayoutDimension实例
    class func w(_ fractionalWidth: CGFloat) -> Self{
        return self.fractionalWidth(fractionalWidth)
    }
    
    /// 创建基于分数的高度维度
    /// - Parameter fractionalHeight: 相对父容器的高度比例(0.0-1.0)
    /// - Returns: 配置好的NSCollectionLayoutDimension实例
    class func h(_ fractionalHeight: CGFloat) -> Self{
        return self.fractionalHeight(fractionalHeight)
    }
}

/// 布局盒子基础配置类
/// 所有布局元素(项目和组)的基类，提供共享的布局属性
public class LayoutBoxConfig {
    /// 边缘间距元组类型定义
    /// 用于设置布局元素四个方向的间距
    public typealias EdgeSpacing =  (leading: NSCollectionLayoutSpacing?,  // 左侧间距
                              top: NSCollectionLayoutSpacing?,       // 顶部间距
                              trailing: NSCollectionLayoutSpacing?,  // 右侧间距
                              bottom: NSCollectionLayoutSpacing?)    // 底部间距
    
    /// 布局盒子类型
    /// 默认值为.item(项目)
    var boxType: LayoutBoxType = .item
    
    /// 布局元素的尺寸
    /// 包含宽度和高度维度配置
    var itemSize: NSCollectionLayoutSize
    
    /// 内容边缘插入
    /// 控制布局元素内容区域与边界的距离
    var insets: NSDirectionalEdgeInsets?
    
    /// 边缘间距配置
    /// 控制布局元素与其相邻元素之间的间距
    var edges: EdgeSpacing?
    
    /// 初始化布局配置
    /// - Parameters:
    ///   - width: 宽度维度配置
    ///   - height: 高度维度配置
    @MainActor
    init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension){
        self.itemSize =  NSCollectionLayoutSize(widthDimension: width,
                                                heightDimension: height)
    }
}
/// LayoutBoxConfig扩展
/// 提供流式接口方法，用于链式配置布局属性
public extension LayoutBoxConfig {
    /// 设置布局盒子类型
    /// - Parameter boxType: 要设置的布局类型(.item或.group)
    /// - Returns: 返回自身实例，以支持链式调用
    @discardableResult
    func boxType(_ boxType: LayoutBoxType) -> Self {
        self.boxType = boxType
        return self
    }
    
    /// 设置布局元素尺寸
    /// - Parameter itemSize: 要设置的尺寸对象
    /// - Returns: 返回自身实例，以支持链式调用
    @discardableResult
    func itemSize(itemSize: NSCollectionLayoutSize) -> Self {
        self.itemSize = itemSize
        return self
    }
    
    /// 设置内容边缘插入
    /// - Parameter insets: 边缘插入对象
    /// - Returns: 返回自身实例，以支持链式调用
    @discardableResult
    public func insets(_ insets: NSDirectionalEdgeInsets) -> Self {
        self.insets = insets
        return self
    }
    
    /// 设置内容边缘插入(各方向单独设置)
    /// - Parameters:
    ///   - top: 顶部边缘插入值
    ///   - leading: 左侧边缘插入值
    ///   - bottom: 底部边缘插入值
    ///   - trailing: 右侧边缘插入值
    /// - Returns: 返回自身实例，以支持链式调用
    public func insets(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) -> Self {
        self.insets = NSDirectionalEdgeInsets.init(top: top, leading: leading, bottom: bottom, trailing: trailing)
        return self
    }
    
    /// 设置内容边缘插入(统一值)
    /// - Parameter space: 四个方向的统一边缘插入值
    /// - Returns: 返回自身实例，以支持链式调用
    public func insets(space: CGFloat) -> Self {
        self.insets = NSDirectionalEdgeInsets.init(top: space, leading: space, bottom: space, trailing: space)
        return self
    }
    
    /// 设置边缘间距配置
    /// - Parameter edges: 边缘间距元组
    /// - Returns: 返回自身实例，以支持链式调用
    @discardableResult
    public func edges(_ edges: EdgeSpacing) -> Self {
        self.edges = edges
        return self
    }
    
    /// 设置左侧边缘间距
    /// - Parameter value: 左侧间距值
    /// - Returns: 返回自身实例，以支持链式调用
    public func leading(_ value: NSCollectionLayoutSpacing?) -> Self {
        if edges == nil {
            self.edges = (leading: value, top: nil, trailing: nil, bottom: nil)
        } else {
            self.edges?.leading = value
        }
        return self
    }
    
    /// 设置顶部边缘间距
    /// - Parameter value: 顶部间距值
    /// - Returns: 返回自身实例，以支持链式调用
    public func top(_ value: NSCollectionLayoutSpacing?) -> Self {
        if edges == nil {
            self.edges = (leading: nil, top: value, trailing: nil, bottom: nil)
        } else {
            self.edges?.top = value
        }
        return self
    }
    
    /// 设置右侧边缘间距
    /// - Parameter value: 右侧间距值
    /// - Returns: 返回自身实例，以支持链式调用
    public func trailing(_ value: NSCollectionLayoutSpacing?) -> Self {
        if edges == nil {
            self.edges = (leading: nil, top: nil, trailing: value, bottom: nil)
        } else {
            self.edges?.trailing = value
        }
        return self
    }
    
    /// 设置底部边缘间距
    /// - Parameter value: 底部间距值
    /// - Returns: 返回自身实例，以支持链式调用
    public func bottom(_ value: NSCollectionLayoutSpacing?) -> Self {
        if edges == nil {
            self.edges = (leading: nil, top: nil, trailing: nil, bottom: value)
        } else {
            self.edges?.bottom = value
        }
        return self
    }
}

/// 布局构建器结果构建器
/// 允许使用函数式语法构建布局配置数组
@MainActor @resultBuilder
public struct LayoutBuilder {
    /// 构建嵌套数组的布局配置
    /// - Parameter components: 布局配置的嵌套数组
    /// - Returns: 展平后的布局配置数组
    static func buildArray(_ components: [[LayoutBoxConfig]]) -> [LayoutBoxConfig] {
        Array(components.joined())
    }
    
    /// 构建单个布局配置块
    /// - Parameter components: 可变数量的布局配置项
    /// - Returns: 布局配置数组
    public static func buildBlock(_ components: LayoutBoxConfig...) -> [LayoutBoxConfig] {
        components
    }
}
/// LayoutBoxConfig扩展
/// 提供配置实际布局项的方法
public extension LayoutBoxConfig {
    /// 将配置应用到实际的集合布局项
    /// - Parameter item: 要配置的NSCollectionLayoutItem实例
    @MainActor func config(item: NSCollectionLayoutItem) {
        // 应用内容边缘插入
        if let contentInsets = self.insets {
            item.contentInsets = contentInsets
        }
        // 应用边缘间距配置
        if let edgeSpacing = self.edges {
            item.edgeSpacing = NSCollectionLayoutEdgeSpacing.init(leading: edgeSpacing.leading,
                                                                 top: edgeSpacing.top,
                                                                 trailing: edgeSpacing.trailing,
                                                                 bottom: edgeSpacing.bottom)
        }
    }
}
/// 项目布局盒子类
/// 表示单个集合视图单元格的布局配置
@MainActor
public class ItemLayoutBox: LayoutBoxConfig {
    /// 列数
    /// 表示要创建的相同项目的数量
    var columns: Int = 1
    
    /// 初始化项目布局盒子
    /// - Parameters:
    ///   - columns: 要创建的列数/相同项目数量
    ///   - width: 宽度维度配置
    ///   - height: 高度维度配置
    init(columns: Int = 1, width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension){
        super.init(width: width, height: height)
        self.boxType = .item  // 设置为项目类型
        self.columns = columns  // 设置列数
    }
    
    /// 构建布局项目数组
    /// - Returns: 配置好的NSCollectionLayoutItem实例数组
     func toBuild() -> [NSCollectionLayoutItem] {
        // 创建基础项目配置
        let item = NSCollectionLayoutItem(layoutSize: self.itemSize)
        // 应用配置
        config(item: item)
        // 根据列数创建并返回相同配置的项目数组
        return [NSCollectionLayoutItem](repeating: item, count: self.columns)
    }
}
/// 组布局盒子类
/// 表示可以包含多个项目或子组的布局组配置
///
@MainActor
public class GroupLayoutBox: LayoutBoxConfig {
    /// 组内元素排列方向
    /// 默认值为.horizontal(水平)
    var direction: GroupDirection = .horizontal
    
    /// 项目间距
    /// 控制组内元素之间的间距
    var space: NSCollectionLayoutSpacing?
    
    /// 子项目配置数组
    /// 存储组内包含的项目或子组配置
    private var subitems: [LayoutBoxConfig] = []
    
    /// 初始化组布局盒子
    /// - Parameters:
    ///   - direction: 组内元素排列方向
    ///   - width: 组宽度维度配置
    ///   - height: 组高度维度配置
    ///   - builder: 用于构建子项目的构建器闭包
    @discardableResult
    init(direction: GroupDirection = .horizontal,
         width: NSCollectionLayoutDimension,
         height: NSCollectionLayoutDimension,
         @LayoutBuilder _ builder: () -> [LayoutBoxConfig]) {
        super.init(width: width, height: height)
        self.boxType = .group  // 设置为组类型
        self.direction = direction  // 设置排列方向
        self.subitems = builder()  // 获取子项目配置
    }
    
    /// 设置组内项目间距
    /// - Parameter spacing: 要设置的间距对象
    /// - Returns: 返回自身实例，以支持链式调用
    @discardableResult
    public func space(_ spacing: NSCollectionLayoutSpacing) -> Self {
        self.space = spacing
        return self
    }
    
    /// 构建布局组
    /// - Returns: 配置好的NSCollectionLayoutGroup实例
    @MainActor @discardableResult
    public  func toBuild() -> NSCollectionLayoutGroup {
        var subChilds: [NSCollectionLayoutItem] = []
        var isOnlyItem = true  // 标记是否只包含ItemLayoutBox类型的子项
        
        // 处理所有子项配置
        for item in self.subitems {
            switch item.boxType {
            case .item:
                // 处理项目类型子项
                if let layout = item as? ItemLayoutBox {
                    subChilds.append(contentsOf: layout.toBuild())
                }
            case .group:
                // 处理组类型子项(嵌套组)
                if let layout = item as? GroupLayoutBox {
                    subChilds.append(layout.toBuild())
                    isOnlyItem = false  // 包含子组，标记为非纯项目组
                }
            }
        }
        
        let group: NSCollectionLayoutGroup!
        // 检查iOS版本并决定使用哪种构建方式
        if isOnlyItem && subChilds.count > 1, #available(iOS 16.0, *) {
            // iOS 16+且只包含相同类型项目时，使用更高效的重复子项创建方式
            group = direction == .horizontal ?
                NSCollectionLayoutGroup.horizontal(layoutSize: self.itemSize,
                                                   repeatingSubitem: subChilds.first!,
                                                   count: subChilds.count)
                :
                NSCollectionLayoutGroup.vertical(layoutSize: self.itemSize,
                                                 repeatingSubitem: subChilds.first!,
                                                 count: subChilds.count)
        } else {
            // 标准方式创建布局组
            group = direction == .horizontal ?
                NSCollectionLayoutGroup.horizontal(layoutSize: self.itemSize,
                                                   subitems: subChilds)
                :
                NSCollectionLayoutGroup.vertical(layoutSize: self.itemSize,
                                                 subitems: subChilds)
        }
        
        // 应用基础配置和间距配置
        config(item: group)
        if let spacing = self.space {
            group.interItemSpacing = spacing
        }
        
        return group
    }
}

/// 布局构建器示例类
/// 提供使用本库创建各种复杂布局的示例代码
 class LayoutBuilderExamples {
    /// 创建嵌套组布局示例
    /// - Returns: 配置好的NSCollectionLayoutSection实例
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
        .insets(NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))  // 外部组的边缘插入
        .toBuild()  // 构建组
        
        // 创建并返回基于该组的section
        let section = NSCollectionLayoutSection(group: nestedGroup)
        return section
    }
    
    /// 创建不同尺寸项目的垂直组布局示例
    /// - Returns: 配置好的NSCollectionLayoutSection实例
    @MainActor static func Example2() -> NSCollectionLayoutSection {
        // 创建垂直组，包含三个不同高度的项目
        let group = GroupLayoutBox(direction: .vertical, width: .absolute(110), height: .absolute(205)) {
            // 高度45的项目
            ItemLayoutBox(columns: 1, width: .absolute(110), height: .absolute(45))
            // 高度65的项目
            ItemLayoutBox(columns: 1, width: .absolute(110), height: .absolute(65))
            // 高度85的项目
            ItemLayoutBox(columns: 1, width: .absolute(110), height: .absolute(85))
        }
        .space(.fixed(5))  // 项目间距5
        .leading(.flexible(5))  // 左侧弹性间距5
        .trailing(.flexible(5))  // 右侧弹性间距5
        .toBuild()  // 构建组
        
        // 创建并返回基于该组的section
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
