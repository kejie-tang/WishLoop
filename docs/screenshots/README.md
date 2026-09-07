# WishLoop 界面截图

这些截图用于项目 [README](../../README.md) 的功能展示。

- 版本：账户（含美元）和桌面小组件为 **1.4.0（204）** release APK；货币设置为 **1.3.0（203）**；其余页面为 **1.2.0（202）**。
- 设备：专用 Android 16 / API 36 模拟器，1080 × 2400 像素。
- 语言：简体中文；主题：浅色及深色。
- 采集日期：2026-09-07。
- 内容：模拟器中的演示兴趣、账本和愿望数据，**不随 APK 预置**。图片为实际应用截图，保留原始 PNG 或仅做无损压缩，没有修改界面或金额。

| 图片 | 展示内容 |
| --- | --- |
| [today.png](today.png) | 紧凑首页、周奖励日历和兴趣优先布局 |
| [hobbies.png](hobbies.png) | 分类、拖动排序、正数奖励与负数习惯 |
| [wallet.png](wallet.png) | 人民币余额与 14 / 30 / 180 天变化曲线 |
| [wallet-usd.png](wallet-usd.png) | 切换美元后的余额与曲线 |
| [currency-settings.png](currency-settings.png) | 默认货币切换与小组件帮助入口 |
| [wishlist.png](wishlist.png) | 愿望进度、预计天数和已兑换记录 |
| [calendar-month.png](calendar-month.png) | 按当前月份归一化的每日净奖励 |
| [dark-mode.png](dark-mode.png) | 深色模式下的今天页面 |
| [home-widget.png](home-widget.png) | 4×2 桌面小组件，四个未完成兴趣仅显示 emoji 与金额 |
| [home-widget-dark.png](home-widget-dark.png) | 深色模式及美元单位的桌面组件 |
| [categories.png](categories.png) | 分类管理与排序 |

更新截图时，先安装对应版本 APK，使用专用模拟器和演示数据进入相应页面，再执行：

```sh
adb -s emulator-5554 exec-out screencap -p > docs/screenshots/today.png
```

同时更新本文件中的版本和日期，保持截图与发布版本一致。
