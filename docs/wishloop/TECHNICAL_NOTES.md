# WishLoop 技术与数据说明

本页记录账本规则、数据迁移、备份及 Android 构建方式。项目介绍与安装入口见 [README](../../README.md)。

## 数据与正确性

复用 Table Habit 的 **Provider + sqflite SQLite + SharedPreferences + Material 3 + ARB**，没有更换状态管理或数据库。

`UI → WalletController → HobbyWalletRepository → 原 SQLite 数据库`

完成兴趣时，同一个 SQLite 事务会写入原有 `mh_records`、对应的 `hw_checkins`，以及一条 `EARN` 账本记录。唯一键 `(habit_uuid, day)` 和 `(source_type, source_id)` 双重防重复；每天最多获得一次奖励。

v10 中 `EARN` 表示一次兴趣记录的净变动，可为正数、零或负数；仍使用唯一的 CHECK_IN 关联。负数兴趣不会因为余额不足而跳过扣减，账户可为负。

余额的唯一事实来源是 `SUM(hw_transactions.amount_minor)`。金额使用整数分，默认 CNY，可在设置切换 USD；切换只重设虚拟记账单位，所有金额数值保持不变，没有汇率换算。输入解析和金额运算不经过 double。double 仅用于原有完成数值、图形进度和曲线坐标；余额、日变动及统计汇总仍使用整数。金额输入失焦时规范为两位小数，超出两位按十进制四舍五入：`3.5 → 3.50`、`3.456 → 3.46`、`-3.456 → -3.46`。

撤销会删除对应收入及完成关联，恢复之前的部分完成记录（如存在）。修改兴趣奖励不改变已发生收入。归档或删除兴趣保留已经获得的奖励。兑换后再撤销收入允许余额为负，账本仍然准确。

愿望兑换在事务中重新校验余额与状态，写入唯一的负数 `SPEND`，同时保存兑换时间并标记已兑换。重复点击、并发调用和两个愿望竞争同一余额都不能重复扣款或超支。

频率沿用 `HabitFrequency`：每周按周一开始的自然周、每月按自然月、自定义周期以原兴趣开始日期为锚点；达到周期次数后休息。指定星期是额外的打卡限制。

## 奖励日历与预计天数

日历统计按打卡的所属日期汇总正负净奖励，不包含人工调整和愿望兑换。红色表示正数、绿色表示负数，零与无记录使用中性色。深浅按当前可见周/月内的最大每日净奖励绝对值缩放：`abs(当天净奖励) / 当前周期最大绝对值`；只在当前周期内归一化，不受其他月份的大额记录影响。

选择过去日期后可补记/撤销，未来日期不可提前记账；可以回看并撤销归档或删除兴趣留下的记录。补记采用当前规则、当前金额，旧记录撤销仍使用发生时金额。早于创建日期的补记会延伸兴趣开始日期，自定义周期按整周期向前延伸，保持原本的周期相位。周期次数和指定星期限制继续生效。

预计天数使用**包含今天的最近 14 个自然日**的净兴趣奖励，未记录日按 0 计。计算为 `ceil((目标金额 - 当前余额) × 14 / 最近14天净奖励合计)`，全程使用整数分。已经达到目标显示“已达到目标”；合计为 0 或负数时显示“暂无法预计”；余额为负数时剩余差额会相应增大。这里只是依照过去记录的估算。

## 账户变化曲线与货币

账户页面可选择最近 14、30、180 天，包含今天。连线使用轻度平滑并启用过冲抑制，不改变账本数据点或点选数值。曲线展示每天结束时的账户余额，点按或拖动可查看指定日期的余额与当日变化。期间变化等于该区间全部账本变动之和。

统计覆盖完整账本，不受“最近记录”最多 200 条的展示限制。包括 EARN、SPEND、ADJUSTMENT，空白日期结转余额；区间前已有金额作为期初余额。打卡按 `hw_checkins.day` 归属日期，调整和兑换按本地日期归属。选择首页的历史日期不改变账户曲线的今天基准。补记和撤销后重新从账本计算。

`hw_settings` 的单行配置保存账户货币。切换 CNY / USD 需要确认，在一个 SQLite 事务中更新配置与全部账本行的 `currency`；兴趣奖励与愿望价格的整数分数值不变。所有后续收入、兑换、调整读取同一配置，数据库触发器拒绝不匹配的币种。UI、提醒与桌面小组件使用同一货币符号。

## 数据库迁移

当前数据库版本 **11**，支持原数据库 v8、WishLoop v9 / v10 升级至 v11。保留原兴趣、打卡、分组、账本、兑换和元数据；不删除数据库。

新增 `mh_habits` 列：

| 列 | 类型/默认值 | 含义 |
|---|---|---|
| `hobby_emoji` | TEXT / 🌱 | 兴趣图标 |
| `reward_minor` | INTEGER / 0 | 每次奖励，整数分 |
| `duration_minutes` | INTEGER / 30 | 预计时长 |
| `weekday_mask` | INTEGER / 127 | 周一到周日位掩码 |

v9 新增表：`hw_checkins`、`hw_transactions`、`hw_wishlist`、`hw_redemptions`。

v10 没有新增业务表/字段，放开 `reward_minor` 与兴趣 EARN 的负数约束，新增 `hw_checkins_day` 索引。按 SQLite 官方建新表/复制/替换流程，在同一迁移事务中保留所有行、ID、原索引、触发器和自增序列；提交前验证外键，事务外恢复外键检查。

v11 新增单行 `hw_settings(id, currency)` 表；保留现有 `hw_transactions.currency` 列，将约束由仅 CNY 扩展为 CNY / USD。沿用复制/替换事务迁移保留原账本及兑换外键，新建货币一致性触发器。旧版本默认升级为 CNY。

`hw_transactions` 含 id、amount_minor、type（EARN/SPEND/ADJUSTMENT）、source_type（CHECK_IN/WISHLIST/MANUAL）、source_id、title、timestamp、currency。CHECK_IN 对应原 `mh_records`；修改/删除原记录的触发器会清理关联收入。

旧兴趣默认每次奖励 ¥0，编辑后开始计算新奖励；旧历史打卡不补发收入。

## 备份

设置 → 导出完整备份 → Android 系统文件选择器 → 保存到 Downloads 或自己的文件目录。

备份包含原四张表和全部新增表，包括全部流水（不限 200 条）、愿望与兑换。JSON 文件包含版本与 SHA-256 校验；v11 可恢复 v9、v10 和 v11 的完整备份；旧备份恢复时补入默认 CNY，新备份包含当前货币设置。恢复会二次确认，验证表结构、外键、账本关系，事务失败会完整回滚。主题、语言及系统通知许可保留本机设置。

不要只使用上游的习惯导出格式备份 WishLoop：它不包含账本。上游 JSON 导入入口仅用于迁移兴趣及历史记录，导入失败会回滚；匹配的记录可能被更新。

## 桌面直接打卡

原生组件声明 4 列 × 2 行，显示最多四个按兴趣排序的当日未完成项，仅展示 emoji 和带正负号的金额。点击通过私有 PendingIntent 广播进入短时 JobService，启动无界面的 FlutterEngine，再调用 `WishLoopWidgetAction → HobbyWalletRepository.complete`。数据库仍是同一个本地文件；独立连接随后台引擎关闭，不另建账本。

后台完成沿用完成记录、原兴趣记录和 EARN 的同一事务。组件请求的日期及金额在事务内再次验证；重复完成不会增加流水。后台提交后重建展示缓存并通知已运行的页面刷新。原生递增代数防止较旧的页面快照覆盖后台新快照。请求在调用 Dart 前持久标记为已领取；中断后不自动重放，待用户核对或再次明确点击。桌面缩放或系统进程生命周期不会成为账本事实来源。数据库仍为 v11，没有增加表或字段。

Android 复用 sqflite 原生单线程，通过一个 Java 源文件补丁使调度器在事务期间只处理该连接的消息，提交、回滚或关闭后再处理其他连接，避免 BEGIN 阻塞另一连接的 COMMIT。另设 5 秒 SQLite 锁等待。没有更换插件或 SQLite，也不使用已弃用的线程配置 API；补丁附带上游源码哈希校验和 BSD 许可证，详见 [sqflite 补丁说明](../../android/sqflite_patch/PATCHES.md)。

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

[构建环境记录](BUILD.md) · [基线结果](BASELINE.md) · [最新验证记录](V1.4.0.md) · [v1.0.0 验证](VERIFICATION.md)

Android 集成测试只在专用、空白测试设备运行：

```sh
flutter test integration_test/android_mvp_test.dart -d emulator-5554
```

新增桌面并发回归可单独运行，不修改 release App 的演示数据：

```sh
flutter test integration_test/widget_concurrency_test.dart --flavor f_dev -d emulator-5554
```

通知测试需要系统允许通知权限。测试包括真实 SQLite、正负金额、自动小数规范、完成/撤销/再完成、历史补记、周/月手势、14 天净奖励预测、兑换、备份恢复、深色模式和系统通知。

原项目商店发布及多平台工作流已移至 `docs/upstream-workflows/`，不会在此仓库执行。保留一个手动触发的 Android 检查工作流；本地签名与 CI 签名不同，日常升级请优先使用同一台构建机产物。

## 第一阶段范围与限制

- 仅验证 Android；没有账号、后端、云同步、支付、广告、AI、分析 SDK。Release manifest 移除网络访问权限。
- 旧功能代码与测试保留以减少重构；新入口不启动云同步，也不展示商店、捐赠等入口。
- vivo / OriginOS 6 桌面组件入口、标准接口规则与真机验证范围见 [vivo 小组件说明](VIVO-WIDGET.md)。
- Android 通知使用系统非精确定时，省电策略可能延迟；兴趣提醒沿用上游的下一次提醒机制，每次打开/编辑/打卡后重排，设置中的每日提醒独立重复。真机厂商策略仍需观察。
- 不是实际购买工具：兑换只记录虚拟支出，真正购买由自己决定。
- 应用图标暂沿用参考项目，正式品牌图标后续再做。

