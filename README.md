# 一格 (YiGe) - 每日一格，封存时光

<p align="center">
  <img src="YiGe/Resources/AppIcon.svg" width="120" height="120" alt="YiGe App Icon">
</p>

## 📖 产品简介

**一格**是一个极简、治愈、充满仪式感的生活记录工具。通过独特的"封存"与"拆封"仪式，让每一天的记忆变得珍贵而有意义。

### 核心特性

- 🔖 **封存仪式** - 盖上专属印章，用弹性动画封存这一天
- 📬 **拆封惊喜** - 24小时后，通过3D翻转动画拆开时光信封
- ⏳ **时光机** - 摇一摇手机，随机回忆过去的美好时刻
- 📅 **日历视图** - 以网格形式展示每月记录状态
- 🌤 **心情天气** - 记录每日心情和天气

## 🛠 技术栈

- **语言**: Swift 5.9+
- **框架**: SwiftUI
- **最低支持版本**: iOS 17.0
- **数据存储**: UserDefaults + JSON Serialization
- **架构模式**: MVVM

## 📁 项目结构

```
YiGe/
├── Sources/
│   ├── YiGeApp.swift           # App入口
│   ├── Models.swift            # 数据模型
│   ├── DataManager.swift       # 数据管理
│   ├── ContentView.swift       # 主视图（包含HomeView, CalendarGridView）
│   ├── NewRecordView.swift     # 新建记录视图（封存动画）
│   ├── RecordDetailView.swift  # 记录详情视图（拆封动画）
│   ├── TimeCapsuleView.swift   # 时光机视图
│   ├── SettingsView.swift      # 设置视图
│   └── NotificationManager.swift # 通知管理
├── Resources/
│   ├── Assets.xcassets/        # 颜色和图标资源
│   ├── AppIcon.svg             # App图标SVG源文件
│   └── Info.plist              # 应用配置
└── Info.plist
```

## 🚀 快速开始

### 在 Xcode 中创建项目

1. 打开 Xcode，选择 **Create a new Xcode project**
2. 选择 **iOS** → **App**
3. 填写项目信息：
   - **Product Name**: `YiGe`
   - **Team**: 选择你的开发者账号
   - **Organization Identifier**: 例如 `com.yourname`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
4. 选择保存位置并创建项目

### 导入代码文件

1. 删除 Xcode 自动生成的 `ContentView.swift`
2. 将 `YiGe/Sources/` 目录下的所有 `.swift` 文件拖入 Xcode 项目
3. 将 `YiGe/Resources/Assets.xcassets/` 中的所有 colorset 目录拖入项目的 `Assets.xcassets`

### 配置 App Icon

1. 使用 SVG 编辑器或在线工具将 `AppIcon.svg` 转换为 1024x1024 的 PNG 图片
2. 将生成的 PNG 图片拖入 `Assets.xcassets/AppIcon.appiconset`

### 配置 Info.plist

确保 `Info.plist` 包含以下权限说明：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>一格需要访问您的相册来添加照片到记录中</string>
<key>NSUserNotificationsUsageDescription</key>
<string>一格需要发送通知来提醒您记录每日生活</string>
```

### 运行项目

1. 选择目标设备或模拟器（iOS 17.0+）
2. 点击运行按钮 (⌘R)

## 🎨 颜色配置

| 名称 | Hex值 | 说明 |
|:---|:---|:---|
| PrimaryWarm | `#F5A623` | 主色调-温暖橙 |
| SealColor | `#D4574B` | 封印色-朱红 |
| BackgroundCream | `#FDF8F3` | 背景色-奶油白 |
| CardBackground | `#FFFFFF` | 卡片背景-纯白 |
| TextPrimary | `#2C2C2C` | 主要文字色 |
| TextSecondary | `#8E8E93` | 次要文字色 |
| GridEmpty | `#F5F5F5` | 空格子色 |
| GridSealed | `#FFF3E0` | 已封存格子色 |
| GridOpened | `#E8F5E9` | 已拆开格子色 |
| GridToday | `#FFF8E1` | 今日格子色 |
| GridFuture | `#FAFAFA` | 未来格子色 |

## 📱 核心功能说明

### 封存动画 (NewRecordView)

用户点击"封存"按钮后，触发一个模拟印章盖下的弹性动画：
- 印章从上方落下
- 撞击时产生震动反馈
- 弹性回弹效果
- 显示"已封存"文字

### 拆封动画 (RecordDetailView)

封存24小时后，用户可以拆开记录：
- 向上滑动触发拆封
- 信封盖子3D翻转动画
- 信封向下移出
- 内容淡入显示

### 时光机 (TimeCapsuleView)

- 3D旋转的时光胶囊视觉
- 陀螺仪控制胶囊倾斜
- 摇一摇随机抽取旧记录（大于7天）

## 📋 中国区 App Store 发布准备

1. **ICP备案**: 根据政策要求，建议提前准备个人ICP备案
2. **隐私政策**: 需要准备隐私政策页面
3. **ASO优化**:
   - App名称: `一格 - 每日封存时光`
   - 副标题: `像拆日历一样回顾生活`
4. **推广渠道**: 聚焦小红书，强调封存动画和拆信封等仪式感场景

## 📄 许可证

MIT License

---

**一格** - 每日一格，封存时光 ✨

