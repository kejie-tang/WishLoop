# WishLoop 1.0.0 (195) — Android MVP 验证记录

验证日期：2026-09-07。参考项目与基线见 [BASELINE.md](BASELINE.md)。

## 功能

| 功能 | 实现 |
|---|---|
| 今天 | 今日奖励、账户余额、主要愿望、按频率安排的兴趣、完成及撤销 |
| 兴趣 | 创建/编辑、Emoji、描述、时长、整数奖励、原频率模型、指定星期、归档/恢复/软删除 |
| 账户 | 全账本求和、当月奖励、最近流水、正负 ADJUSTMENT |
| 愿望 | 创建/编辑/删除、主要愿望、进度、余额不足禁用、二次确认、唯一兑换、兑换时间 |
| 设置 | 复用主题与语言；通知、完整导出/恢复、旧数据导入、关于、虚拟金额声明 |
| 本地数据 | SQLite 持久化；原数据库 v8 增量迁移至 v9；关闭/重开及损坏恢复回滚测试 |
| 中文/深色 | 新增文案全部走 ARB，简体中文优先，英文完整，复用 Material 3 主题 |

## 核心设计

`WishLoop UI → Provider / WalletController → HobbyWalletRepository → 原 sqflite 数据库`。

完成在单个事务中写入原 `mh_records`、关联元数据 `hw_checkins` 和唯一 `EARN`。撤销用完成 ID 定位并删除收入，恢复此前部分完成记录；完成/撤销/再次完成不会重复入账。UI 忙碌锁、数据库唯一索引、SQLite 原子事务共同防重复。

金额一律为整数分。余额永远是全部 `hw_transactions.amount_minor` 之和；没有另设可直接修改的余额字段。人工调整生成 `ADJUSTMENT`。愿望兑换事务内重新读取余额、校验状态，写入唯一 `SPEND`/`hw_redemptions` 并标记已兑换。所有这些规则都可脱离 Widget 测试。

数据库版本 **9**：新增表 `hw_checkins`、`hw_transactions`、`hw_wishlist`、`hw_redemptions`；原 `mh_habits` 新增 `hobby_emoji`、`reward_minor`、`duration_minutes`、`weekday_mask`。原表和历史数据保留。详细默认值和索引见 [README](../../README.md)。

## 静态检查与自动化测试

- `flutter pub get`：成功。
- `flutter analyze`：**No issues found!**，退出码 0，[原始结果](analyze.txt)。
- `flutter test`：**1358 passed**，退出码 0，[原始结果](tests.txt)。基线 1328 个，新增 30 个。
- `git diff --check`：通过。

新增测试文件：

- `test/wishloop/ledger_test.dart`：23 个。创建唯一收入、10 次并发完成、撤销、再次完成、修改奖励后撤销、零奖励、正负调整、完整账本求和、流水超过 200 条、余额不足、8 次并发兑换、两个愿望竞争余额、撤销导致负余额、进度上下限、跨日/月、频率与星期限制、归档/删除保留奖励、旧记录编辑触发器、事务异常回滚、重开数据库、部分记录恢复，以及通过真实生产 opener 执行 v8→v9 迁移且旧数据不丢失。
- `test/wishloop/backup_test.dart`：3 个。完整往返恢复、重复恢复、SHA-256/版本损坏拒绝、关联损坏时全部回滚。
- `test/wishloop/pages_test.dart`：4 个。四页面浅色/深色中文渲染、完成→撤销→再完成→兑换 UI 流程、英文及 1.6 倍字体渲染。

## Android 模拟器与 release 实测

专用 Pixel 7 / Android 16 API 36 ARM64 模拟器，不涉及用户手机的数据。

- `flutter test integration_test/android_mvp_test.dart -d emulator-5554 --no-pub --no-uninstall`：**1 个完整集成测试通过，All tests passed!**。测试在真实 sqflite 和 Android 通知服务上执行，涵盖表单创建、完整奖惩闭环、备份恢复、四页深色模式与真实活动通知。见 [集成测试日志](android-integration.txt)。
- Release APK `adb install -r`：成功；冷启动成功，继承原有测试数据库。
- Release UI 创建人工调整 +¥483，账本显示对应 ADJUSTMENT；创建 ¥2999 愿望，进度 16.1%，不足时兑换按钮禁用。
- Release UI 导出完整备份，使用原生 Android `ACTION_CREATE_DOCUMENT` 保存到 Downloads；校验 JSON SHA-256、8 张表、全部 3 条流水，余额为 48300 分。
- 清空**专用模拟器**应用数据以验证新安装与备份灾后恢复；首次启动为中文空账户。通过原生文件选择器选回刚才导出的文件，确认后恢复成功。
- 强制停止并冷启动 release App：余额 ¥483、今日奖励 ¥5、跑步已完成、两个愿望及兑换记录保留。见 [重启页面记录](release-relaunch.txt)。
- Release UI 请求系统通知许可并发送通知成功；Android `dumpsys notification` 确认活动通知；启用每日提醒后，`dumpsys alarm` 确认 21:30 的系统计划通知。

验证过程中修复了 Android flavor 中文资源仍显示原应用名的问题，最终所有语言均继承主资源名称 WishLoop。模拟器调试阶段曾出现 ADB 断连；重启模拟器、切换软件渲染后完整测试通过。关闭 DDS 的诊断运行触发 Flutter 工具自身 golden stream 错误，最终测试恢复正常 DDS 配置并通过；没有为规避它修改业务规则或跳过断言。

## Release APK

`flutter build apk --release` 已成功（本机前缀 `WISHLOOP_MAVEN_MIRROR=1`，见 [构建环境](BUILD.md)）。最终构建耗时 22.8 秒，退出码 0，[构建日志](build-release.txt)。

- 文件：`build/app/outputs/flutter-apk/app-release.apk`，约 70.8 MB。
- 应用名称：**WishLoop**；版本 **1.0.0 (195)**。
- applicationId：`io.github.friesi23.mhabit`。
- minSdk 24（Android 7.0），targetSdk/compileSdk 36。
- ABI：arm64-v8a、armeabi-v7a、x86_64。
- `apksigner verify`：通过，APK Signature Scheme v2，本机 debug keystore 签名；这是 release 编译产物。
- Manifest 无 INTERNET / ACCESS_NETWORK_STATE，无需网络运行。
- SHA-256：`c5d688fb589f39609ba22bfbd30210d14905e7003f798368a9af724e05c7b9a8`。

[包信息](apk-badging.txt) · [签名验证](apk-signature.txt)

## 适用范围与已知限制

1. 仅 Android。没有引入账号、后台服务器、云同步、支付、广告或 AI。
2. 未连接用户实体手机；厂商省电策略、重启后的提醒及连续多日使用仍需在用户手机观察。兴趣通知沿用原项目下一次提醒机制；设置中的每日提醒独立重复，非精确闹钟可能延迟。
3. 使用原 applicationId 和本机构建签名。若已安装官方 Table Habit，签名不同不能直接覆盖；先导出旧数据。后续 WishLoop 升级保持同一签名密钥，不把密钥上传仓库。正式上架前再修改 package name / applicationId。
4. 图标沿用参考项目。旧兴趣默认 ¥0，编辑奖励后开始积累，不为旧打卡补发奖励。
5. 备份包括所有业务数据，不包括本机主题、语言、通知许可。账本页面展示最近 200 条，完整流水仍参与余额且随备份导出。
6. 构建工具存在未来 Gradle/AGP 支持期限提示，但本次编译成功；没有为消除非阻塞提示而大幅升级技术栈。

下一阶段建议：真机连续一周使用反馈；按实际使用调整布局；正式图标及独立包名；之后再考虑轻量统计或桌面小组件。本阶段不实现这些扩展。
