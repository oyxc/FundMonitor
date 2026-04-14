# Fund Monitor 文档组织指南

## 📚 文档目录结构

```
Docs/
├── README.md                           # 文档索引（本目录）
├── DOCUMENTATION_GUIDE.md              # 文档组织指南（本文件）
│
├── Project/                            # 项目级文档
│   ├── PROJECT_STRUCTURE.md            # 项目结构详细说明
│   ├── STRUCTURE.md                    # 文件移动记录
│   ├── DIRECTORY_TREE.txt              # 可视化目录树
│   └── CLEANUP_REPORT.md               # SceneDelegate 清理报告
│
├── MyFunds/                            # 自选模块文档
│   ├── REDESIGN_PLAN.md                # 自选模块重构方案
│   ├── LOAD_MORE_FEATURE.md            # 加载更多功能说明
│   ├── SEARCH_LOAD_MORE_TEST.md        # 搜索加载测试文档
│   └── TEST_FUND_011011.md             # 基金添加测试指南
│
└── Common/                             # 公共文档
    └── API_GUIDE.md                    # API 接入说明
```

## 📖 文档分类说明

### 1. Project（项目级文档）

**用途**：项目整体架构、结构、历史记录

**包含文档**：
- **PROJECT_STRUCTURE.md** - 详细的项目结构说明
  - 模块划分
  - 目录组织
  - 依赖关系
  - 命名规范
  
- **STRUCTURE.md** - 文件移动和重构记录
  - 模块化重组过程
  - 文件移动命令
  
- **DIRECTORY_TREE.txt** - 可视化目录树
  - 带图标的目录结构
  - 统计信息
  
- **CLEANUP_REPORT.md** - SceneDelegate 清理报告
  - 清理过程
  - 验证结果

**适用场景**：
- 新成员了解项目结构
- 架构设计参考
- 项目重构记录

### 2. MyFunds（自选模块文档）

**用途**：自选模块的功能设计、开发、测试文档

**包含文档**：
- **REDESIGN_PLAN.md** - 自选模块重构方案
  - 设计目标
  - UI 设计
  - 功能规划
  
- **LOAD_MORE_FEATURE.md** - 加载更多功能说明
  - 功能概述
  - 实现方案
  - 使用说明
  
- **SEARCH_LOAD_MORE_TEST.md** - 搜索加载测试
  - 测试场景
  - 测试步骤
  - 预期结果
  
- **TEST_FUND_011011.md** - 基金添加测试
  - 测试用例
  - 测试数据
  - 验证方法

**适用场景**：
- 自选模块功能开发
- 功能测试验证
- 问题排查

### 3. Common（公共文档）

**用途**：跨模块的公共功能文档

**包含文档**：
- **API_GUIDE.md** - API 接入说明
  - 已接入的 API
  - API 使用方法
  - 数据格式说明

**适用场景**：
- API 集成开发
- 网络请求调试
- 数据格式参考

## 🔍 文档查找指南

### 按需求查找

| 需求 | 推荐文档 |
|------|---------|
| 了解项目结构 | `Project/PROJECT_STRUCTURE.md` |
| 查看目录树 | `Project/DIRECTORY_TREE.txt` |
| 了解 API 接入 | `Common/API_GUIDE.md` |
| 自选模块开发 | `MyFunds/REDESIGN_PLAN.md` |
| 功能测试 | `MyFunds/SEARCH_LOAD_MORE_TEST.md` |
| 项目历史 | `Project/STRUCTURE.md` |

### 按角色查找

**新成员**：
1. README.md（项目根目录）
2. Project/PROJECT_STRUCTURE.md
3. Project/DIRECTORY_TREE.txt

**开发人员**：
1. Common/API_GUIDE.md
2. MyFunds/REDESIGN_PLAN.md
3. Project/PROJECT_STRUCTURE.md

**测试人员**：
1. MyFunds/SEARCH_LOAD_MORE_TEST.md
2. MyFunds/TEST_FUND_011011.md

**架构师**：
1. Project/PROJECT_STRUCTURE.md
2. Project/STRUCTURE.md
3. Project/CLEANUP_REPORT.md

## 📝 文档编写规范

### 1. 文件命名
- 使用大写字母和下划线：`PROJECT_STRUCTURE.md`
- 名称要清晰表达文档内容
- 避免使用缩写

### 2. 文档结构
```markdown
# 文档标题

## 概述
简要说明文档内容

## 详细内容
### 子章节1
### 子章节2

## 总结
关键要点总结

---
**更新日期**：YYYY-MM-DD
```

### 3. 文档分类
- **项目级**：放在 `Docs/Project/`
- **模块级**：放在 `Docs/[模块名]/`
- **公共级**：放在 `Docs/Common/`

### 4. 文档更新
- 修改文档后更新底部的日期
- 重大变更需要在文档开头添加更新日志
- 保持文档与代码同步

## 🔗 相关链接

- [项目 README](../README.md)
- [项目结构说明](Project/PROJECT_STRUCTURE.md)
- [API 接入指南](Common/API_GUIDE.md)

## 📊 文档统计

- **总文档数**：10个
- **项目文档**：4个
- **模块文档**：4个（MyFunds）
- **公共文档**：1个
- **索引文档**：2个（README + 本文件）

---

**创建日期**：2024-02-02  
**最后更新**：2024-02-02
