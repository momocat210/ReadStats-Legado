#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""构建「读痕 · 阅读统计」墨本阅读专版（无 root）。

- 名称沿用「读痕 · 阅读统计」，包名沿用 com.momocat.a5pro.readstats
- 只针对墨本阅读(Legado)备份里的 readRecordDetail.json 做统计
- 全程不调用 su / 不依赖 root：新增 FileBridge JS 接口读公共目录与 ZIP
- 命令通道 su -c 改成 sh -c（仅作兜底，核心流程不用它）
"""
import glob
import os
import shutil
import subprocess

ROOT = os.path.dirname(os.path.abspath(__file__))
WS = os.path.dirname(ROOT)
SHELL = os.path.join(WS, "lockscreen-upgrade", "app")
APP = os.path.join(ROOT, "app")
BUILD = os.path.join(ROOT, "_build")
TOOLS = os.path.join(WS, "inkos", "tools")
APKTOOL = os.path.join(TOOLS, "apktool.jar")
SIGNER = os.path.join(TOOLS, "uber-apk-signer.jar")
JAVA = os.path.join(os.path.expanduser("~"), ".workbuddy", "binaries", "python",
                    "versions", "3.13.12", "Lib", "site-packages", "jdk4py",
                    "java-runtime", "bin", "java.exe")
OUT = os.path.join(ROOT, "A5Pro-ReadStats-Legado-v2.7.apk")
OLD = "com/momocat/a5pro/lockscreen"
NEW = "com/momocat/a5pro/readstats"
VERSION_NAME = "2.7"
VERSION_CODE = "11"
ICON_DENSITIES = ["mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"]

MAIN_INSERT = """
    # ---- 运行时申请外部存储权限（Android 6+ 必需，无 root 读备份的前提） ----
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x17

    if-lt v1, v2, :perm_done

    const-string v1, "android.permission.READ_EXTERNAL_STORAGE"

    invoke-virtual {p0, v1}, Landroid/app/Activity;->checkSelfPermission(Ljava/lang/String;)I

    move-result v2

    if-eqz v2, :perm_done

    const/4 v1, 0x2

    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0

    const-string v3, "android.permission.READ_EXTERNAL_STORAGE"

    aput-object v3, v1, v2

    const/4 v2, 0x1

    const-string v3, "android.permission.WRITE_EXTERNAL_STORAGE"

    aput-object v3, v1, v2

    const/4 v2, 0x1

    invoke-virtual {p0, v1, v2}, Landroid/app/Activity;->requestPermissions([Ljava/lang/String;I)V

    :perm_done

    # ---- 无 root 文件桥 ----
    new-instance v1, Lcom/momocat/a5pro/readstats/FileBridge;

    invoke-direct {v1, p0}, Lcom/momocat/a5pro/readstats/FileBridge;-><init>(Landroid/content/Context;)V

    const-string v2, "FS"

    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v1

    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V

    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowUniversalAccessFromFileURLs(Z)V

    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
"""


ON_ACTIVITY_RESULT = """
.method protected onActivityResult(IILandroid/content/Intent;)V
    .locals 6

    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onActivityResult(IILandroid/content/Intent;)V

    # ---- 1002 (0x3ea)：SAF 选择导出文件夹 ----
    const/16 v0, 0x3ea

    if-ne p1, v0, :not_dir

    const/4 v0, -0x1

    if-ne p2, v0, :dir_ret

    if-eqz p3, :dir_ret

    goto :dir_ok

    :dir_ret
    return-void

    :dir_ok
    :try_start_0
    invoke-virtual {p3}, Landroid/content/Intent;->getData()Landroid/net/Uri;
    move-result-object v0
    if-eqz v0, :dir_ret
    invoke-static {p0, v0}, Lcom/momocat/a5pro/readstats/FileBridge;->handleDirUri(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :dir_ign

    :notify_dir
    const-string v1, "ReadStats"
    const-string v2, "notify onDirPicked"
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v1, p0, Lcom/momocat/a5pro/readstats/MainActivity;->web:Landroid/webkit/WebView;
    const-string v2, "javascript:window.onDirPicked()"
    invoke-virtual {v1, v2}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    :dir_ign
    return-void

    :not_dir
    # ---- 1003 (0x3eb)：SAF 选择字体文件夹 ----
    const/16 v0, 0x3eb
    if-ne p1, v0, :not_font
    const/4 v0, -0x1
    if-ne p2, v0, :font_ret
    if-eqz p3, :font_ret
    goto :font_ok

    :font_ret
    return-void

    :font_ok
    :try_start_f
    invoke-virtual {p3}, Landroid/content/Intent;->getData()Landroid/net/Uri;
    move-result-object v0
    if-eqz v0, :font_ret
    invoke-static {p0, v0}, Lcom/momocat/a5pro/readstats/FileBridge;->handleFontDir(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v1
    :try_end_f
    .catch Ljava/lang/Throwable; {:try_start_f .. :try_end_f} :font_ign

    :notify_font
    const-string v2, "ReadStats"
    invoke-static {v2, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    const-string v2, "notify onFontDirPicked"
    invoke-static {v2, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v1, p0, Lcom/momocat/a5pro/readstats/MainActivity;->web:Landroid/webkit/WebView;
    const-string v2, "javascript:window.onFontDirPicked()"
    invoke-virtual {v1, v2}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    :font_ign
    return-void

    :not_font
    const/16 v0, 0x3e9
    if-eq p1, v0, :code_ok
    return-void

    :code_ok
    const-string v4, "ReadStats"
    const-string v5, "step: code ok"
    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v0, -0x1
    if-eq p2, v0, :result_ok
    return-void

    :result_ok
    const-string v4, "ReadStats"
    const-string v5, "step: result ok"
    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    if-nez p3, :has_intent
    return-void

    :has_intent
    const-string v4, "ReadStats"
    const-string v5, "step: has intent"
    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {p3}, Landroid/content/Intent;->getData()Landroid/net/Uri;
    move-result-object v0
    if-nez v0, :has_uri
    return-void

    :has_uri
    const-string v4, "ReadStats"
    const-string v5, "step: has uri"
    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :try_start_1
    invoke-static {p0, v0}, Lcom/momocat/a5pro/readstats/FileBridge;->handleUri(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lcom/momocat/a5pro/readstats/FileBridge;->setPicked(Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :err

    :notify_js
    const-string v2, "ReadStats"
    const-string v3, "notify_js"
    invoke-static {v2, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    iget-object v1, p0, Lcom/momocat/a5pro/readstats/MainActivity;->web:Landroid/webkit/WebView;
    const-string v2, "javascript:window.onFilePicked()"
    invoke-virtual {v1, v2}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    return-void

    :err
    move-exception v1
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "ERR: "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lcom/momocat/a5pro/readstats/FileBridge;->setPicked(Ljava/lang/String;)V
    goto :notify_js
.end method
"""


ON_KEY_DOWN = """
# ---- 音量键 / 实体翻页键：黑白主题时映射为翻页（由 FileBridge.pagerOn 控制） ----
# ---- v2.6 修复：super 已处理的按键（返回键 KEYCODE_BACK 等）原样返回 true ----
# ---- 此前错误地返回 false，导致返回键失去系统默认的退出行为 ----
.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .locals 1
    invoke-super {p0, p1, p2}, Landroid/app/Activity;->onKeyDown(ILandroid/view/KeyEvent;)Z
    move-result v0
    if-nez v0, :key_pass

    sget-boolean v0, Lcom/momocat/a5pro/readstats/FileBridge;->pagerOn:Z
    if-eqz v0, :key_def

    const/16 v0, 0x18
    if-ne p1, v0, :chk_25
    const/16 v0, -0x1
    goto :do_step

    :chk_25
    const/16 v0, 0x19
    if-ne p1, v0, :chk_92
    const/16 v0, 0x1
    goto :do_step

    :chk_92
    const/16 v0, 0x5c
    if-ne p1, v0, :chk_93
    const/16 v0, -0x1
    goto :do_step

    :chk_93
    const/16 v0, 0x5d
    if-ne p1, v0, :key_def
    const/16 v0, 0x1

    :do_step
    invoke-direct {p0, v0}, Lcom/momocat/a5pro/readstats/MainActivity;->keyStep(I)V
    const/4 v0, 0x1
    return v0

    :key_pass
    const/4 v0, 0x1
    return v0

    :key_def
    const/4 v0, 0x0
    return v0
.end method

.method private keyStep(I)V
    .locals 3
    iget-object v0, p0, Lcom/momocat/a5pro/readstats/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :ks_ret

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "javascript:pageStep("
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, ")"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    :ks_ret
    return-void
.end method
"""


def sh(args):
    r = subprocess.run(args, capture_output=True, text=True, errors="replace")
    if r.returncode != 0:
        print(r.stdout[-1200:], r.stderr[-1200:])
        raise RuntimeError("命令失败: " + " ".join(args[:4]))
    return r.stdout


def prep():
    if os.path.isdir(APP):
        shutil.rmtree(APP)
    shutil.copytree(SHELL, APP, ignore=shutil.ignore_patterns("build", "index.html"))

    src = os.path.join(APP, "smali", OLD)
    dst = os.path.join(APP, "smali", NEW)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.isdir(src):
        os.rename(src, dst)
    for f in glob.glob(os.path.join(dst, "*.smali")):
        s = open(f, encoding="utf-8").read()
        s = s.replace(OLD, NEW).replace(OLD.replace("/", "."), NEW.replace("/", "."))
        open(f, "w", encoding="utf-8", newline="\n").write(s)

    # 新增文件桥
    shutil.copy2(os.path.join(ROOT, "FileBridge.smali"),
                 os.path.join(dst, "FileBridge.smali"))

    # MainActivity：注册 JS 接口
    p = os.path.join(dst, "MainActivity.smali")
    s = open(p, encoding="utf-8").read()
    anchor = "    new-instance v1, Lcom/momocat/a5pro/readstats/CmdClient;"
    if anchor not in s:
        raise RuntimeError("MainActivity 插入点未找到")
    s = s.replace(".locals 3", ".locals 4", 1)
    s = s.replace(anchor, MAIN_INSERT + "\n" + anchor)
    s = s.rstrip() + "\n\n" + ON_ACTIVITY_RESULT.strip() + "\n" + ON_KEY_DOWN.strip() + "\n"
    if ":key_pass" not in s:
        raise RuntimeError("onKeyDown 返回键修复未注入")
    open(p, "w", encoding="utf-8", newline="\n").write(s)

    # CmdTask：彻底去掉 su
    p = os.path.join(dst, "CmdTask.smali")
    s = open(p, encoding="utf-8").read()
    s = s.replace('const-string v3, "su"', 'const-string v3, "sh"')
    s = s.replace('const-string v2, "ROOT_ERROR: "', 'const-string v2, "CMD_ERROR: "')
    if '"su"' in s or "ROOT_ERROR" in s:
        raise RuntimeError("CmdTask 仍残留 su")
    open(p, "w", encoding="utf-8", newline="\n").write(s)

    # Manifest：包名 / 版本 / 图标 / 外部存储权限
    p = os.path.join(APP, "AndroidManifest.xml")
    s = open(p, encoding="utf-8").read()
    s = s.replace("com.momocat.a5pro.lockscreen", "com.momocat.a5pro.readstats")
    s = s.replace('android:versionCode="6"', 'android:versionCode="%s"' % VERSION_CODE)
    s = s.replace('android:versionName="2.4"', 'android:versionName="%s"' % VERSION_NAME)
    s = s.replace('android:allowBackup="true"',
                  'android:allowBackup="true"\n        android:icon="@mipmap/ic_launcher"')
    s = s.replace("    <uses-sdk",
                  '    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />\n'
                  '    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />\n\n'
                  "    <uses-sdk")
    s = s.replace('android:theme="@android:style/Theme.Material.Light.NoActionBar">',
                  'android:theme="@android:style/Theme.Material.Light.NoActionBar"\n'
                  '        android:requestLegacyExternalStorage="true">')
    open(p, "w", encoding="utf-8", newline="\n").write(s)

    # apktool.yml
    p = os.path.join(APP, "apktool.yml")
    s = open(p, encoding="utf-8").read()
    s = s.replace("versionCode: 6", "versionCode: " + VERSION_CODE)
    s = s.replace("versionName: '2.4'", "versionName: '%s'" % VERSION_NAME)
    open(p, "w", encoding="utf-8", newline="\n").write(s)

    # App 名称不变
    p = os.path.join(APP, "res", "values", "strings.xml")
    s = open(p, encoding="utf-8").read().replace("猫猫锁屏设置", "读痕 · 阅读统计")
    open(p, "w", encoding="utf-8", newline="\n").write(s)

    # 界面
    html = open(os.path.join(ROOT, "index.html"), encoding="utf-8").read()
    assets = os.path.join(APP, "assets")
    os.makedirs(assets, exist_ok=True)
    open(os.path.join(assets, "index.html"), "w", encoding="utf-8",
         newline="\n").write(html)

    # 图标：书本线条图标（黑白主调）
    for d in ICON_DENSITIES:
        src = os.path.join(ROOT, "icon", d, "ic_launcher.png")
        if not os.path.isfile(src):
            raise RuntimeError("缺少图标 icon/%s/ic_launcher.png" % d)
        dst_dir = os.path.join(APP, "res", "mipmap-" + d)
        os.makedirs(dst_dir, exist_ok=True)
        shutil.copy2(src, os.path.join(dst_dir, "ic_launcher.png"))
    print("壳已准备（无 root）:", APP)


def build():
    if os.path.isdir(BUILD):
        shutil.rmtree(BUILD)
    os.makedirs(BUILD)
    unsigned = os.path.join(BUILD, "unsigned.apk")
    signed = os.path.join(BUILD, "signed")
    os.makedirs(signed)
    print("=== 1/3 apktool 回编译 ===")
    sh([JAVA, "-jar", APKTOOL, "b", "-f", "-o", unsigned, APP])
    print("=== 2/3 签名 ===")
    sh([JAVA, "-jar", SIGNER, "-a", unsigned, "-o", signed, "--allowResign"])
    apks = sorted(glob.glob(os.path.join(signed, "*-aligned-debugSigned.apk")))
    if not apks:
        raise RuntimeError("签名产物未生成")
    shutil.copy2(apks[0], OUT)
    print("=== 3/3 校验 ===")
    import zipfile
    with zipfile.ZipFile(OUT) as z:
        names = set(z.namelist())
        for n in ("AndroidManifest.xml", "classes.dex", "resources.arsc",
                  "assets/index.html"):
            if n not in names:
                raise RuntimeError("APK 缺少 " + n)
        dex = z.read("classes.dex")
        if b"readstats" not in dex or b"lockscreen" in dex:
            raise RuntimeError("classes.dex 包名替换不彻底")
        if b"FileBridge" not in dex:
            raise RuntimeError("FileBridge 未编译进 classes.dex")
        if b"saveJson" not in dex or b"queryName" not in dex:
            raise RuntimeError("FileBridge 新接口（saveJson/queryName）未编译进 classes.dex")
        if b"sharePng" not in dex or b"pickDir" not in dex or b"handleDirUri" not in dex:
            raise RuntimeError("v2.4 新接口（分享/选文件夹）未编译进 classes.dex")
        if (b"setPagerOn" not in dex or b"pickFontDir" not in dex or b"loadFont" not in dex or
                b"fontUrl" not in dex or b"onKeyDown" not in dex or b"keyStep" not in dex):
            raise RuntimeError("v2.5 新接口（翻页键/字体）未编译进 classes.dex")
        html = z.read("assets/index.html").decode("utf-8")
        if "读痕·让阅读留痕" not in html or "FS." not in html:
            raise RuntimeError("界面注入/文件桥调用缺失")
        if "exportReeden" not in html or "已选择" not in html:
            raise RuntimeError("Reeden 导出 / 选择文件反馈缺失")
        if "showTab" not in html or "applyTheme" not in html or "墨水屏主题" not in html:
            raise RuntimeError("v2.2 标签页 / 主题系统缺失")
        if "邮蓝" not in html or "赭金" not in html:
            raise RuntimeError("v2.3 邮政色系彩屏主题缺失")
        if "shareBill" not in html or "pickExportDir" not in html or "pageStep" not in html:
            raise RuntimeError("v2.4 分享/导出文件夹/翻页键缺失")
        if "pickFontDir" not in html or "resetFont" not in html or "momo_cat" not in html:
            raise RuntimeError("v2.5 字体选择/署名缺失")
        if "page-bill" in html or "读　痕" in html:
            raise RuntimeError("账单标签页未移除或旧标题残留")
        if "root" in html:
            raise RuntimeError("界面仍有 root 字眼")
        if "①" in html:
            raise RuntimeError("界面仍残留 ① 序号")
        if "雾紫" not in html or "蓝橘" not in html or "苔赤" not in html:
            raise RuntimeError("v2.6 新增彩屏主题（雾紫/蓝橘/苔赤）缺失")
        if "fcard" not in html or "redrawBill" not in html:
            raise RuntimeError("v2.6 字体卡片 / 账单字体缺失")
        if "FONT_SEQ" not in html or "FONT_FAM" not in html:
            raise RuntimeError("v2.7 字体即时切换修复缺失")
        if b"current.ttf" in dex:
            raise RuntimeError("v2.7 字体唯一文件名修复缺失（dex 仍含 current.ttf）")
        if b"currentTimeMillis" not in dex:
            raise RuntimeError("v2.7 字体唯一文件名机制未编译进 classes.dex")
        if "<b>想更新统计：</b>" not in html or "<b>换主题：</b>" not in html:
            raise RuntimeError("v2.7 使用说明标签加粗缺失")
        if "墨痕inkstain" not in html:
            raise RuntimeError("排版来源标注（KoReader 墨痕inkstain）缺失")
        if "为「墨本阅读」设计" not in html:
            raise RuntimeError("v2.6 副标题（「墨本阅读」加引号）缺失")
        if "hcw" not in html or "末段补齐" not in html:
            raise RuntimeError("v2.6 账单热力图/条形码右对齐缺失")
        for n in ("res/mipmap-mdpi/ic_launcher.png", "res/mipmap-xxxhdpi/ic_launcher.png"):
            if n not in names:
                raise RuntimeError("缺少图标资源 " + n)
    print("APK :", OUT)
    print("大小:", os.path.getsize(OUT), "bytes")


if __name__ == "__main__":
    prep()
    build()
