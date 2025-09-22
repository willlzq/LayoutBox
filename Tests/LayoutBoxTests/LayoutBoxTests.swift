import XCTest
@testable import LayoutBox

final class LayoutBoxTests: XCTestCase {
    
    // 测试基本的项目布局创建
    @MainActor func testItemLayoutBoxCreation() throws {
        let itemBox = ItemLayoutBox(columns: 2, width: .fractionalWidth(0.5), height: .fractionalHeight(1.0))
        let items = itemBox.toBuild()
        
        // 验证创建的项目数量是否正确
        XCTAssertEqual(items.count, 2)
        
        // 验证项目尺寸是否正确
        let item = items.first
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.layoutSize.widthDimension.dimension, 0.5)
        XCTAssertEqual(item?.layoutSize.heightDimension.dimension, 1.0)
    }
    
    // 测试基本的组布局创建
    @MainActor func testGroupLayoutBoxCreation() throws {
        let groupBox = GroupLayoutBox(width: .fractionalWidth(1.0), height: .absolute(100)) {
            ItemLayoutBox(columns: 1, width: .fractionalWidth(1.0), height: .fractionalHeight(1.0))
        }
        let group = groupBox.toBuild()
        
        // 验证组尺寸是否正确
        XCTAssertEqual(group.layoutSize.widthDimension.dimension, 1.0)
        XCTAssertEqual(group.layoutSize.heightDimension.dimension, 100)
        
        // 验证组包含的项目数量
        XCTAssertEqual(group.subitems.count, 1)
    }
    
    // 测试嵌套组布局
    @MainActor func testNestedGroupLayout() throws {
        let nestedGroupBox = GroupLayoutBox(width: .fractionalWidth(1.0), height: .fractionalHeight(0.4)) {
            ItemLayoutBox(columns: 2, width: .fractionalWidth(0.5), height: .fractionalHeight(1.0))
            
            GroupLayoutBox(direction: .vertical, width: .fractionalWidth(0.5), height: .fractionalHeight(1.0)) {
                ItemLayoutBox(columns: 1, width: .fractionalWidth(1.0), height: .fractionalHeight(0.5))
            }
        }
        let nestedGroup = nestedGroupBox.toBuild()
        
        // 验证嵌套组尺寸
        XCTAssertEqual(nestedGroup.layoutSize.widthDimension.dimension, 1.0)
        XCTAssertEqual(nestedGroup.layoutSize.heightDimension.dimension, 0.4)
        
        // 验证嵌套组包含的子项数量
        XCTAssertGreaterThanOrEqual(nestedGroup.subitems.count, 2)
    }
    
    // 测试间距和边缘插入配置
    @MainActor func testSpacingAndInsetsConfiguration() throws {
        let itemBox = ItemLayoutBox(columns: 1, width: .fractionalWidth(1.0), height: .fractionalHeight(1.0))
            .insets(top: 10, leading: 10, bottom: 10, trailing: 10)
            .leading(.fixed(5))
        let items = itemBox.toBuild()
        
        // 验证内容边缘插入
        let item = items.first
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.contentInsets.top, 10)
        XCTAssertEqual(item?.contentInsets.leading, 10)
        XCTAssertEqual(item?.contentInsets.bottom, 10)
        XCTAssertEqual(item?.contentInsets.trailing, 10)
    }
}
