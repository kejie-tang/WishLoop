# Android 构建环境

- Flutter 3.47.2 / Dart 3.13.2
- JDK 17（Eclipse Temurin 17.0.20.1）
- Android Gradle Plugin 8.13.2 / Gradle 8.14.3 / Kotlin 2.3.20
- Android SDK、NDK 由 Flutter/Gradle 根据已有项目配置选择
- 默认 flavor f_generic；无正式 keystore 时用本机 debug keystore 签署 release

参考机 Android Studio 自带 Java 25，与 Gradle 8.14.3 不兼容。使用 JDK 17 即可，无需升级整个 Gradle/AGP 技术栈。官方参考：[Gradle JVM compatibility](https://docs.gradle.org/current/userguide/compatibility.html)、[Temurin installation](https://adoptium.net/installation/)。

```sh
flutter config --jdk-dir=/path/to/jdk17/Contents/Home
flutter build apk --release
```

本机构建另遇到 Maven Central 对 Gradle 请求返回 403，curl 下载正常。使用 Google 托管的 Maven Central 镜像解决。仅为本机安装了环境变量控制的 Gradle init 脚本 `~/.gradle/init.d/wishloop-network.gradle`；不改动项目依赖版本或 Flutter SDK源码。仓库中保留了可审阅的脚本副本 [`wishloop-network.gradle`](wishloop-network.gradle)。需要时复制到 `~/.gradle/init.d/`，启用方式：

```sh
WISHLOOP_MAVEN_MIRROR=1 flutter build apk --release
```

其他机器正常联网时不需要此变量或脚本。未来 Flutter 版本提示升级 Gradle/AGP 的警告不阻止本版本构建；本阶段保留已验证组合。

测试和 APK 构建应依次运行，不在同一工作目录并行执行 `flutter test`/`flutter pub get` 与 Gradle release 构建。Flutter 会按构建模式重新生成插件注册文件，并行运行可能导致 integration_test 插件注册竞态；结束测试后单独重新执行 release 构建即可。
