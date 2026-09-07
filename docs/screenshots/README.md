# WishLoop 界面截图

这些截图用于项目 [README](../../README.md) 的功能展示。

- 版本：WishLoop **1.1.5（201）** release APK。
- 设备：专用 Android 16 / API 36 模拟器，1080 × 2400 像素。
- 语言：简体中文；主题：浅色及深色。
- 采集日期：2026-09-07。
- 内容：模拟器中的演示兴趣、账本和愿望数据，**不随 APK 预置**。图片为实际应用截图，仅做 PNG 无损压缩，没有修改界面或金额。

| 图片 | 展示内容 |
| --- | --- |
| [today.png](today.png) | 周奖励日历、兴趣账户和主要愿望 |
| [hobbies.png](hobbies.png) | 正数奖励与负数习惯 |
| [wallet.png](wallet.png) | 余额、当月净奖励和账本流水 |
| [wishlist.png](wishlist.png) | 愿望进度、预计天数和已兑换记录 |
| [calendar-month.png](calendar-month.png) | 按当前月份归一化的每日净奖励 |
| [dark-mode.png](dark-mode.png) | 深色模式下的今天页面 |

更新截图时，先安装对应版本 APK，使用专用模拟器和演示数据进入相应页面，再执行：

```sh
adb -s emulator-5554 exec-out screencap -p > docs/screenshots/today.png
```

同时更新本文件中的版本和日期，保持截图与发布版本一致。
