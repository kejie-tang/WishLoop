# vivo / OriginOS 6 桌面小组件

核查时间：2026-09-07。用户系统为 OriginOS 6；目前没有连接 vivo 真机，以下区分官方公开说明、WishLoop 的实现和仍需真机确认的部分。

## 添加入口

vivo 官方提供的 OriginOS 通用入口是：**长按桌面空白处 → 原子组件 → 长按需要的组件拖到桌面**；探索桌面则从桌面上滑进入应用列表，再选择顶部的原子组件。该说明没有单独列出 OriginOS 6 的第三方兼容清单。[vivo 官方：如何添加/删除桌面挂件或组件](https://www.vivo.com.cn/service/questions/all?categoryId=156&questionId=586)

安装 WishLoop 后先打开一次，再尝试以下任一方式：

1. WishLoop 设置 → Android 桌面小组件 → 在系统弹窗中确认添加。
2. 长按桌面空白处，进入原子组件列表，查找 WishLoop 并拖到桌面。

设置中的问号按钮可随时查看手动添加说明。应用内按钮没有弹窗时，仍可尝试系统组件列表。不要为了刷新组件而清除 App 数据或桌面数据。

## 平台规则与本项目实现

| 项目 | 规则与 WishLoop 行为 |
| --- | --- |
| 技术类型 | 使用标准 Android `AppWidgetProvider` + `RemoteViews`，包含 Manifest receiver 和 `appwidget-provider` 元数据。没有使用 vivo 私有 SDK。 |
| 应用内添加 | Android 8 / API 26 起的 `requestPinAppWidget` 需要桌面支持，最终由用户在桌面弹窗中确认。返回 `true` 只代表桌面支持请求，不能当作添加成功的证明。 |
| 手动添加 | 由系统桌面的组件选择器提供；实际目录、布局和可选尺寸由桌面决定。 |
| 大小 | 默认声明横向 4 列 × 纵向 2 行，允许缩放。最多显示 4 个今日未完成兴趣，四个位置并排，仅显示 emoji 和金额。旧组件保留桌面已保存的尺寸，升级后需手动缩小或移除后重新添加。vivo 的实际格数和边距需要真机确认。 |
| 更新 | App 打卡、撤销、兑换、编辑和切换货币后主动刷新。系统周期刷新设为 30 分钟；Android 的 `updatePeriodMillis` 不支持低于 30 分钟，后台执行也可能延迟。 |
| 数据与跳转 | 缓存只用于展示。点余额进入账户，点愿望进入愿望页；点 emoji 通过 PendingIntent 广播与 JobService 在后台调用原有 Dart Repository 完成今日打卡，随后刷新余额并补入下一个未完成兴趣，不启动 Activity。撤销在 App 中操作。 |

Android 官方依据：[组件添加与发现](https://developer.android.com/develop/ui/views/appwidgets/discoverability)、[AppWidgetManager](https://developer.android.com/reference/android/appwidget/AppWidgetManager)、[组件更新规则](https://developer.android.com/develop/ui/views/appwidgets/advanced)。

## 直接点击完成

Android 标准 AppWidget 允许 `PendingIntent.getBroadcast` 触发操作，无需进入 App 页面。广播接收器只提交短时后台作业，避免在接收器的有限执行时间内启动 Flutter 和操作数据库；Android 12 及以上优先使用 expedited job，额度不足时退回普通 JobScheduler。后台使用无界面的 FlutterEngine，复用同一个 Repository 和 SQLite 原子事务。

完成后按已有兴趣顺序移除当前项并补位，保留最多 4 项；正数、负数和零都按兴趣设置记账。请求带有日期和原奖励金额，跨天、兴趣归档或金额变化后会刷新组件，不能按旧内容入账。重复请求由原有完成唯一键去重，短时间连点另有防抖；执行中断的请求不自动重放，以免在 App 已撤销后重新记账。

这是标准 Android 能力，查阅的 vivo 官方公开资料没有提供 OriginOS 6 对第三方后台按钮的单独保证。省电限制可能延迟或终止后台执行；组件会提示状态待确认，此时打开 App 核对记录，或在刷新后再次点击。不要把尚未刷新的数字当作打卡成功。

依据：[Android 组件更新与交互](https://developer.android.com/develop/ui/views/appwidgets/advanced)、[JobInfo.Builder](https://developer.android.com/reference/android/app/job/JobInfo.Builder)。

## 支持范围结论

WishLoop 已实现标准 Android 桌面组件，可继续按这个接口在 OriginOS 6 上验证。**不能把标准组件等同于已获得 vivo 专属原子组件、锁屏组件或负一屏服务适配。** 本次查阅的 vivo 公开资料不足以确认这些专属入口的第三方准入条件，没有引入上架、登录或 vivo SDK；新增的 JobService 仅执行用户点击和系统组件刷新的本地操作。

当前验证覆盖 Android 16 / API 36 模拟器的系统桌面，不代表已完成 OriginOS 6 真机兼容性验证。真机应重点确认：列表是否能找到 WishLoop、缩放后内容是否完整、点击 emoji 是否留在桌面完成打卡并补位、关闭 App 后是否仍能操作、人民币/美元切换后是否刷新。若组件列表中没有 WishLoop，需要结合具体机型和系统桌面版本定位，不能仅凭 OriginOS 6 名称判定原因。
