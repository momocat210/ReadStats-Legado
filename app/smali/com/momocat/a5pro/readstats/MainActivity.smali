.class public Lcom/momocat/a5pro/readstats/MainActivity;
.super Landroid/app/Activity;
.source "SourceFile"

# instance fields
.field public web:Landroid/webkit/WebView;


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method


# virtual methods
.method protected onCreate(Landroid/os/Bundle;)V
    .locals 4

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    new-instance v0, Landroid/webkit/WebView;

    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Lcom/momocat/a5pro/readstats/MainActivity;->web:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v1

    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V


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

    new-instance v1, Lcom/momocat/a5pro/readstats/CmdClient;

    invoke-direct {v1, p0}, Lcom/momocat/a5pro/readstats/CmdClient;-><init>(Lcom/momocat/a5pro/readstats/MainActivity;)V

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    const-string v1, "file:///android_asset/index.html"

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    invoke-virtual {p0, v0}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    return-void
.end method

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
