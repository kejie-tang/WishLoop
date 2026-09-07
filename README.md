# WishLoop · 兴趣账户

一个仅供 Android 自用的离线 App：完成喜欢的事，记录虚拟奖励，慢慢实现自己的愿望。

**所有 ¥ 金额都只是个人兴趣激励和虚拟记账单位。App 不提供真实货币奖励、提现、交易或兑换现金。**

[下载 Android APK（v1.1.0）](https://github.com/kejie-tang/WishLoop/releases/tag/v1.1.0) · [v1.1.0 验证记录](docs/wishloop/V1.1.0.md)

## 使用

- **今天**：周/月净奖励日历、账户余额、主要愿望进度与预计天数；点日期补记或撤销。日历下滑展开月视图、标题处上滑收起为周视图，左右滑动翻周/月，也可使用按钮。
- **兴趣**：创建、编辑、归档、恢复、删除；支持 Emoji、描述、时长、正负金额、每天/每周/每月/自定义周期及指定星期。负数兴趣用于记录不好的习惯，点击“记录发生”扣减，撤销退回原扣减。
- **账户**：余额、当月净奖励、最近 200 条流水、正负人工调整。完整历史保存在数据库和备份中。
- **愿望**：目标价格、备注、主要愿望、进度、余额不足提示、二次确认兑换及兑换历史。
- **设置**：右上角进入；主题、语言、每日提醒、通知测试、完整备份、恢复、Table Habit 导入、关于。

首次使用默认为简体中文；可切换英文或沿用原项目其他语言（新增功能在其他语言下使用英文）。支持浅色、深色、跟随系统。

## 数据与正确性

复用 Table Habit 的 **Provider + sqflite SQLite + SharedPreferences + Material 3 + ARB**，没有更换状态管理或数据库。

`UI → WalletController → HobbyWalletRepository → 原 SQLite 数据库`

完成兴趣时，同一个 SQLite 事务会写入原有 `mh_records`、对应的 `hw_checkins`，以及一条 `EARN` 账本记录。唯一键 `(habit_uuid, day)` 和 `(source_type, source_id)` 双重防重复；每天最多获得一次奖励。

v10 中 `EARN` 表示一次兴趣记录的净变动，可为正数、零或负数；仍使用唯一的 CHECK_IN 关联。负数兴趣不会因为余额不足而跳过扣减，账户可为负。

余额的唯一事实来源是 `SUM(hw_transactions.amount_minor)`。金额使用整数分，默认 CNY，输入解析和金额运算不经过 double。double 仅用于原有完成数值、图形进度等非金额数据。金额输入失焦时规范为两位小数，超出两位按十进制四舍五入：`3.5 → 3.50`、`3.456 → 3.46`、`-3.456 → -3.46`。

撤销会删除对应收入及完成关联，恢复之前的部分完成记录（如存在）。修改兴趣奖励不改变已发生收入。归档或删除兴趣保留已经获得的奖励。兑换后再撤销收入允许余额为负，账本仍然准确。

愿望兑换在事务中重新校验余额与状态，写入唯一的负数 `SPEND`，同时保存兑换时间并标记已兑换。重复点击、并发调用和两个愿望竞争同一余额都不能重复扣款或超支。

频率沿用 `HabitFrequency`：每周按周一开始的自然周、每月按自然月、自定义周期以原兴趣开始日期为锚点；达到周期次数后休息。指定星期是额外的打卡限制。

## 奖励日历与预计天数

日历统计按打卡的所属日期汇总正负净奖励，不包含人工调整和愿望兑换。红色表示正数、绿色表示负数，零与无记录使用中性色。深浅按当前可见周/月内的最大每日净奖励绝对值缩放：`abs(当天净奖励) / 当前周期最大绝对值`；只在当前周期内归一化，不受其他月份的大额记录影响。

选择过去日期后可补记/撤销，未来日期不可提前记账；可以回看并撤销归档或删除兴趣留下的记录。补记采用当前规则、当前金额，旧记录撤销仍使用发生时金额。早于创建日期的补记会延伸兴趣开始日期，自定义周期按整周期向前延伸，保持原本的周期相位。周期次数和指定星期限制继续生效。

预计天数使用**包含今天的最近 14 个自然日**的净兴趣奖励，未记录日按 0 计。计算为 `ceil((目标金额 - 当前余额) × 14 / 最近14天净奖励合计)`，全程使用整数分。已经达到目标显示“已达到目标”；合计为 0 或负数时显示“暂无法预计”；余额为负数时剩余差额会相应增大。这里只是依照过去记录的估算。

## 数据库迁移

支持原数据库 **v8 → v10** 和已发布 WishLoop **v9 → v10**。保留原兴趣、打卡、分组、账本、兑换和元数据；不删除数据库。

新增 `mh_habits` 列：

| 列 | 类型/默认值 | 含义 |
|---|---|---|
| `hobby_emoji` | TEXT / 🌱 | 兴趣图标 |
| `reward_minor` | INTEGER / 0 | 每次奖励，整数分 |
| `duration_minutes` | INTEGER / 30 | 预计时长 |
| `weekday_mask` | INTEGER / 127 | 周一到周日位掩码 |

v9 新增表：`hw_checkins`、`hw_transactions`、`hw_wishlist`、`hw_redemptions`。

v10 没有新增业务表/字段，放开 `reward_minor` 与兴趣 EARN 的负数约束，新增 `hw_checkins_day` 索引。按 SQLite 官方建新表/复制/替换流程，在同一迁移事务中保留所有行、ID、原索引、触发器和自增序列；提交前验证外键，事务外恢复外键检查。

`hw_transactions` 含 id、amount_minor、type（EARN/SPEND/ADJUSTMENT）、source_type（CHECK_IN/WISHLIST/MANUAL）、source_id、title、timestamp、currency。CHECK_IN 对应原 `mh_records`；修改/删除原记录的触发器会清理关联收入。

旧兴趣默认每次奖励 ¥0，编辑后开始计算新奖励；旧历史打卡不补发收入。

## 备份

设置 → 导出完整备份 → Android 系统文件选择器 → 保存到 Downloads 或自己的文件目录。

备份包含原四张表和全部新增表，包括全部流水（不限 200 条）、愿望与兑换。JSON 文件包含版本与 SHA-256 校验；v10 可恢复 v9 和 v10 的完整备份。恢复会二次确认，验证表结构、外键、账本关系，事务失败会完整回滚。主题、语言及系统通知许可保留本机设置。

不要只使用上游的习惯导出格式备份 WishLoop：它不包含账本。上游 JSON 导入入口仅用于迁移兴趣及历史记录，导入失败会回滚；匹配的记录可能被更新。

## Android 构建与测试

本次开发环境：Flutter **3.47.2** / Dart **3.13.2** / JDK **17**，Android API 36 模拟器。

```sh
flutter pub get
flutter gen-l10n
dart format .
flutter analyze
flutter test
flutter build apk --release
```

APK：`build/app/outputs/flutter-apk/app-release.apk`。支持 Android 7.0 及以上；Android 显示名称统一继承 `android/app/src/main/res/values/strings.xml` 中的 WishLoop。

保留原 `f_generic` 默认 flavor 及 APK 路径复制逻辑。没有正式 keystore 时，release 使用本机 debug keystore 签名，适合个人安装。保管签名密钥，后续升级使用同一密钥，否则 Android 无法覆盖安装。不要把密钥上传 GitHub。

applicationId 保持 `io.github.friesi23.mhabit`。**正式上架前需要修改 package name / applicationId**。如果手机已安装官方 Table Habit，不同签名无法直接覆盖；先在原 App 导出数据，避免丢失历史。

[构建环境记录](docs/wishloop/BUILD.md) · [基线结果](docs/wishloop/BASELINE.md) · [最新验证记录](docs/wishloop/V1.1.0.md) · [v1.0.0 验证](docs/wishloop/VERIFICATION.md)

Android 集成测试只在专用、空白测试设备运行：

```sh
flutter test integration_test/android_mvp_test.dart -d emulator-5554
```

通知测试需要系统允许通知权限。测试包括真实 SQLite、正负金额、自动小数规范、完成/撤销/再完成、历史补记、周/月手势、14 天净奖励预测、兑换、备份恢复、深色模式和系统通知。

原项目商店发布及多平台工作流已移至 `docs/upstream-workflows/`，不会在此仓库执行。保留一个手动触发的 Android 检查工作流；本地签名与 CI 签名不同，日常升级请优先使用同一台构建机产物。

## 第一阶段范围与限制

- 仅验证 Android；没有账号、后端、云同步、支付、广告、AI、分析 SDK。Release manifest 移除网络访问权限。
- 旧功能代码与测试保留以减少重构；新入口不启动云同步，也不展示商店、捐赠等入口。
- Android 通知使用系统非精确定时，省电策略可能延迟；兴趣提醒沿用上游的下一次提醒机制，每次打开/编辑/打卡后重排，设置中的每日提醒独立重复。真机厂商策略仍需观察。
- 不是实际购买工具：兑换只记录虚拟支出，真正购买由自己决定。
- 应用图标暂沿用参考项目，正式品牌图标后续再做。

## 来源与许可证

基于 [FriesI23/mhabit (Table Habit)](https://github.com/FriesI23/mhabit)，保留原作者版权、Apache-2.0 [LICENSE](LICENSE) 与 [第三方声明](LICENSE_THIRDPARTY.md)。WishLoop 修改包括奖励账本、愿望、离线 Android 入口、简体中文文案、全量备份与相关测试。[参考项目原 README](docs/wishloop/UPSTREAM_README.md)。

`vendor/great_list_view` 是工作区已有的 Dart 3.13 兼容补丁，说明见 [PATCHES.md](vendor/great_list_view/PATCHES.md)。
