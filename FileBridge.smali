.class public final Lcom/momocat/a5pro/readstats/FileBridge;
.super Ljava/lang/Object;
.source "SourceFile"

# 无 root 文件桥：只访问公共外部存储与用户选择的备份文件。
# 所有方法通过 addJavascriptInterface 暴露给 WebView。

.field private final ctx:Landroid/content/Context;

.field public static picked:Ljava/lang/String;

.field public static pickedName:Ljava/lang/String;

.field public static dirUri:Landroid/net/Uri;

.field public static dirDocId:Ljava/lang/String;

.field public static dirName:Ljava/lang/String;

.field public static pagerOn:Z

.field public static fontDirUri:Landroid/net/Uri;

.field public static fontList:Ljava/lang/String;


# ---------------------------------------------------------------- constructor
.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;

    return-void
.end method


# ---------------------------------------------------------------- list()
# 返回候选备份文件（ZIP / JSON），每行一条：路径<TAB>文件名<TAB>字节数
.method public list()Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 14

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;
    move-result-object v1

    const/16 v2, 0x7
    new-array v2, v2, [Ljava/lang/String;
    const/4 v3, 0x0
    const-string v4, "Download"
    aput-object v4, v2, v3
    const/4 v3, 0x1
    const-string v4, "Documents"
    aput-object v4, v2, v3
    const/4 v3, 0x2
    const-string v4, "backup"
    aput-object v4, v2, v3
    const/4 v3, 0x3
    const-string v4, "Backups"
    aput-object v4, v2, v3
    const/4 v3, 0x4
    const-string v4, "Legado"
    aput-object v4, v2, v3
    const/4 v3, 0x5
    const-string v4, "legado"
    aput-object v4, v2, v3
    const/4 v3, 0x6
    const-string v4, ""
    aput-object v4, v2, v3

    const/4 v3, 0x0

    :dir_loop
    array-length v4, v2
    if-ge v3, v4, :dir_done

    aget-object v4, v2, v3
    new-instance v5, Ljava/io/File;
    invoke-direct {v5, v1, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v5}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v5
    if-eqz v5, :next_dir

    const/4 v6, 0x0
    :file_loop
    array-length v7, v5
    if-ge v6, v7, :next_dir

    aget-object v7, v5, v6
    invoke-virtual {v7}, Ljava/io/File;->isFile()Z
    move-result v8
    if-eqz v8, :next_file

    invoke-virtual {v7}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v8
    invoke-virtual {v8}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v9

    # 不是 .zip 就去检查 .json
    const-string v10, ".zip"
    invoke-virtual {v9, v10}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v10
    if-eqz v10, :check_json

    # 是 ZIP：名字需含 backup / legado / read 之一
    const-string v10, "backup"
    invoke-virtual {v9, v10}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v10
    if-nez v10, :accept
    const-string v10, "legado"
    invoke-virtual {v9, v10}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v10
    if-nez v10, :accept
    const-string v10, "read"
    invoke-virtual {v9, v10}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v10
    if-nez v10, :accept
    goto :next_file

    :check_json
    const-string v10, ".json"
    invoke-virtual {v9, v10}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v10
    if-eqz v10, :next_file

    # JSON: 只收备份/阅读记录相关，避免列满根目录的无关文件
    const-string v10, "backup"
    invoke-virtual {v9, v10}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v10
    if-nez v10, :accept
    const-string v10, "legado"
    invoke-virtual {v9, v10}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v10
    if-nez v10, :accept
    const-string v10, "readrecord"
    invoke-virtual {v9, v10}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v10
    if-nez v10, :accept
    goto :next_file

    :accept
    invoke-virtual {v7}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v10
    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v10, "\t"
    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v8, "\t"
    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/io/File;->length()J
    move-result-wide v10
    invoke-virtual {v0, v10, v11}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v8, "\n"
    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :next_file
    add-int/lit8 v6, v6, 0x1
    goto :file_loop

    :next_dir
    add-int/lit8 v3, v3, 0x1
    goto :dir_loop

    :dir_done
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- readText(path)
.method public readText(Ljava/lang/String;)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 8
    :try_start_0
    new-instance v0, Ljava/io/File;
    invoke-direct {v0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->length()J
    move-result-wide v1
    const-wide/32 v3, 0x800000
    cmp-long v1, v1, v3
    if-lez v1, :size_ok
    const-string v0, "ERR: file too large"
    return-object v0

    :size_ok
    new-instance v1, Ljava/io/FileInputStream;
    invoke-direct {v1, v0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    new-instance v2, Ljava/io/ByteArrayOutputStream;
    invoke-direct {v2}, Ljava/io/ByteArrayOutputStream;-><init>()V
    const/16 v3, 0x1000
    new-array v3, v3, [B

    :rloop
    invoke-virtual {v1, v3}, Ljava/io/InputStream;->read([B)I
    move-result v4
    const/4 v5, -0x1
    if-eq v4, v5, :rdone
    const/4 v5, 0x0
    invoke-virtual {v2, v3, v5, v4}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :rloop

    :rdone
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    invoke-virtual {v2}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    new-instance v1, Ljava/lang/String;
    const-string v2, "UTF-8"
    invoke-direct {v1, v0, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :err
    return-object v1

    :err
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- readZip(zip, entry)
# 在系统 ZipFile 中按「文件名」查找 entry（兼容备份 ZIP 内带目录前缀的情况）
.method public readZip(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 12
    :try_start_0
    new-instance v0, Ljava/util/zip/ZipFile;
    invoke-direct {v0, p1}, Ljava/util/zip/ZipFile;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/util/zip/ZipFile;->entries()Ljava/util/Enumeration;
    move-result-object v1

    :eloop
    invoke-interface {v1}, Ljava/util/Enumeration;->hasMoreElements()Z
    move-result v2
    if-eqz v2, :notfound

    invoke-interface {v1}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/util/zip/ZipEntry;

    invoke-virtual {v2}, Ljava/util/zip/ZipEntry;->getName()Ljava/lang/String;
    move-result-object v3
    const-string v4, "/"
    invoke-virtual {v3, v4}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v4
    if-gez v4, :nobase
    add-int/lit8 v4, v4, 0x1
    invoke-virtual {v3, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v3

    :nobase
    invoke-virtual {v3, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :eloop

    invoke-virtual {v0, v2}, Ljava/util/zip/ZipFile;->getInputStream(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;
    move-result-object v2

    new-instance v3, Ljava/io/ByteArrayOutputStream;
    invoke-direct {v3}, Ljava/io/ByteArrayOutputStream;-><init>()V
    const/16 v4, 0x1000
    new-array v4, v4, [B

    :zloop
    invoke-virtual {v2, v4}, Ljava/io/InputStream;->read([B)I
    move-result v5
    const/4 v6, -0x1
    if-eq v5, v6, :zdone
    const/4 v6, 0x0
    invoke-virtual {v3, v4, v6, v5}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :zloop

    :zdone
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V
    invoke-virtual {v0}, Ljava/util/zip/ZipFile;->close()V
    invoke-virtual {v3}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    new-instance v1, Ljava/lang/String;
    const-string v2, "UTF-8"
    invoke-direct {v1, v0, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :zerr
    return-object v1

    :notfound
    invoke-virtual {v0}, Ljava/util/zip/ZipFile;->close()V
    const-string v0, "ERR: entry not found"
    return-object v0

    :zerr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- savePng(b64)
.method public savePng(Ljava/lang/String;)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 8
    :try_start_0
    const/4 v0, 0x0
    invoke-static {p1, v0}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B
    move-result-object v0

    sget-object v1, Landroid/os/Environment;->DIRECTORY_PICTURES:Ljava/lang/String;
    invoke-static {v1}, Landroid/os/Environment;->getExternalStoragePublicDirectory(Ljava/lang/String;)Ljava/io/File;
    move-result-object v1
    new-instance v2, Ljava/io/File;
    const-string v3, "ReadStats"
    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    new-instance v1, Ljava/io/File;
    const-string v3, "读痕-阅读账单.png"
    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    invoke-virtual {v2, v0}, Ljava/io/OutputStream;->write([B)V
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V

    # 通知相册刷新
    iget-object v0, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    const/4 v2, 0x1
    new-array v2, v2, [Ljava/lang/String;
    const/4 v3, 0x0
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v4
    aput-object v4, v2, v3
    const/4 v3, 0x0
    const/4 v4, 0x0
    invoke-static {v0, v2, v3, v4}, Landroid/media/MediaScannerConnection;->scanFile(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;Landroid/media/MediaScannerConnection$OnScanCompletedListener;)V

    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :serr
    return-object v0

    :serr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- pick()
# 打开系统文件管理器（SAF），无需任何存储权限
.method public pick()V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 3

    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.OPEN_DOCUMENT"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    const-string v1, "android.intent.category.OPENABLE"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    const-string v1, "*/*"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    iget-object v1, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    check-cast v1, Landroid/app/Activity;

    const/16 v2, 0x3e9
    invoke-virtual {v1, v0, v2}, Landroid/app/Activity;->startActivityForResult(Landroid/content/Intent;I)V

    return-void
.end method


# ---------------------------------------------------------------- takePicked()
.method public takePicked()Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 3

    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->picked:Ljava/lang/String;
    if-eqz v0, :tlog_skip
    const-string v1, "ReadStats"
    const-string v2, "takePicked: HAS DATA"
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :tlog_skip

    const/4 v1, 0x0
    sput-object v1, Lcom/momocat/a5pro/readstats/FileBridge;->picked:Ljava/lang/String;
    if-eqz v0, :has
    const-string v0, "ERR: nothing picked"
    :has
    return-object v0
.end method


# ---------------------------------------------------------------- pickedLen()
# 分片读取：WebView 的 JS 桥不能可靠返回很长的字符串，改为 8KB 一片
.method public pickedLen()I
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 1
    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->picked:Ljava/lang/String;
    if-eqz v0, :plnull
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v0
    return v0
    :plnull
    const/4 v0, -0x1
    return v0
.end method


# ---------------------------------------------------------------- chunk(index)
.method public chunk(I)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 5
    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->picked:Ljava/lang/String;
    if-eqz v0, :chnull
    const/16 v1, 0x2000
    mul-int v2, p1, v1
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v3
    if-ge v2, v3, :chnull
    add-int v4, v2, v1
    if-le v4, v3, :chsub
    move v4, v3
    :chsub
    invoke-virtual {v0, v2, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v0
    return-object v0
    :chnull
    const-string v0, ""
    return-object v0
.end method


# ---------------------------------------------------------------- clearPicked()
.method public clearPicked()V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 1
    const/4 v0, 0x0
    sput-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->picked:Ljava/lang/String;
    return-void
.end method


# ---------------------------------------------------------------- setPicked()
.method public static setPicked(Ljava/lang/String;)V
    .locals 3
    const-string v0, "ReadStats"
    if-eqz p0, :snull
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "setPicked len="
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0}, Ljava/lang/String;->length()I
    move-result v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    goto :sdone
    :snull
    const-string v1, "setPicked NULL"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :sdone
    sput-object p0, Lcom/momocat/a5pro/readstats/FileBridge;->picked:Ljava/lang/String;
    return-void
.end method


# ---------------------------------------------------------------- name()
# 返回最近一次 SAF 选中文件的显示名（用于界面反馈「已选择 xxx」）
.method public name()Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 1
    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->pickedName:Ljava/lang/String;
    if-eqz v0, :nnull
    return-object v0
    :nnull
    const-string v0, ""
    return-object v0
.end method


# ---------------------------------------------------------------- saveJson(b64, filename)
# 优先保存到用户所选文件夹（SAF tree）；未选择则存公共「下载」目录，返回路径/结果
.method public saveJson(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 9
    :try_start_0
    const/4 v0, 0x0
    invoke-static {p1, v0}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B
    move-result-object v0

    sget-object v1, Lcom/momocat/a5pro/readstats/FileBridge;->dirUri:Landroid/net/Uri;
    if-eqz v1, :save_default

    # ---- 保存到所选文件夹（SAF DocumentsContract） ----
    iget-object v2, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2

    sget-object v3, Lcom/momocat/a5pro/readstats/FileBridge;->dirUri:Landroid/net/Uri;
    sget-object v4, Lcom/momocat/a5pro/readstats/FileBridge;->dirDocId:Ljava/lang/String;
    invoke-static {v3, v4}, Landroid/provider/DocumentsContract;->buildDocumentUriUsingTree(Landroid/net/Uri;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v3

    const-string v4, "application/json"
    invoke-static {v2, v3, v4, p2}, Landroid/provider/DocumentsContract;->createDocument(Landroid/content/ContentResolver;Landroid/net/Uri;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v4
    if-eqz v4, :doc_fail

    invoke-virtual {v2, v4}, Landroid/content/ContentResolver;->openOutputStream(Landroid/net/Uri;)Ljava/io/OutputStream;
    move-result-object v5
    invoke-virtual {v5, v0}, Ljava/io/OutputStream;->write([B)V
    invoke-virtual {v5}, Ljava/io/OutputStream;->close()V

    new-instance v6, Ljava/lang/StringBuilder;
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V
    const-string v7, "已保存到所选文件夹："
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6
    return-object v6

    :doc_fail
    const-string v6, "ERR: createDocument failed"
    return-object v6

    # ---- 默认：公共「下载」目录 ----
    :save_default
    sget-object v1, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;
    invoke-static {v1}, Landroid/os/Environment;->getExternalStoragePublicDirectory(Ljava/lang/String;)Ljava/io/File;
    move-result-object v1
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v1, p2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    new-instance v1, Ljava/io/FileOutputStream;
    invoke-direct {v1, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    invoke-virtual {v1, v0}, Ljava/io/OutputStream;->write([B)V
    invoke-virtual {v1}, Ljava/io/OutputStream;->close()V

    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v6
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :jerr
    return-object v6

    :jerr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- queryName()
# 从 SAF Uri 查询文件显示名（OpenableColumns._display_name）
.method private static queryName(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    .locals 7
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    move-object v1, p1
    const/4 v2, 0x1
    new-array v2, v2, [Ljava/lang/String;
    const/4 v3, 0x0
    const-string v4, "_display_name"
    aput-object v4, v2, v3
    const/4 v3, 0x0
    const/4 v4, 0x0
    const/4 v5, 0x0
    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v0
    if-eqz v0, :qnull
    invoke-interface {v0}, Landroid/database/Cursor;->moveToFirst()Z
    move-result v1
    if-eqz v1, :qclose
    const-string v1, "_display_name"
    invoke-interface {v0, v1}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v1
    if-ltz v1, :qclose
    invoke-interface {v0, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v2
    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    return-object v2
    :qclose
    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :qnull
    const/4 v0, 0x0
    return-object v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :qerr
    :qerr
    move-exception v0
    const/4 v0, 0x0
    return-object v0
.end method


# ---------------------------------------------------------------- readAll()
.method private static readAll(Ljava/io/InputStream;)[B
    .locals 5
    new-instance v0, Ljava/io/ByteArrayOutputStream;
    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V
    const/16 v1, 0x1000
    new-array v1, v1, [B
    :rloop
    invoke-virtual {p0, v1}, Ljava/io/InputStream;->read([B)I
    move-result v2
    const/4 v3, -0x1
    if-eq v2, v3, :rdone
    const/4 v3, 0x0
    invoke-virtual {v0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :rloop
    :rdone
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- zipEntry()
# 在 ZIP 字节流里按文件名找 entry，返回 UTF-8 文本；找不到返回 null
.method private static zipEntry([BLjava/lang/String;)Ljava/lang/String;
    .locals 9
    :try_start_0
    new-instance v0, Ljava/io/ByteArrayInputStream;
    invoke-direct {v0, p0}, Ljava/io/ByteArrayInputStream;-><init>([B)V
    new-instance v1, Ljava/util/zip/ZipInputStream;
    invoke-direct {v1, v0}, Ljava/util/zip/ZipInputStream;-><init>(Ljava/io/InputStream;)V

    :eloop
    invoke-virtual {v1}, Ljava/util/zip/ZipInputStream;->getNextEntry()Ljava/util/zip/ZipEntry;
    move-result-object v2
    if-eqz v2, :no_entry

    invoke-virtual {v2}, Ljava/util/zip/ZipEntry;->getName()Ljava/lang/String;
    move-result-object v3
    const-string v4, "/"
    invoke-virtual {v3, v4}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v4
    if-gez v4, :cmp_name
    add-int/lit8 v4, v4, 0x1
    invoke-virtual {v3, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v3

    :cmp_name
    invoke-virtual {v3, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :next_entry

    new-instance v3, Ljava/io/ByteArrayOutputStream;
    invoke-direct {v3}, Ljava/io/ByteArrayOutputStream;-><init>()V
    const/16 v4, 0x1000
    new-array v4, v4, [B
    :cloop
    invoke-virtual {v1, v4}, Ljava/io/InputStream;->read([B)I
    move-result v5
    const/4 v6, -0x1
    if-eq v5, v6, :cdone
    const/4 v6, 0x0
    invoke-virtual {v3, v4, v6, v5}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :cloop
    :cdone
    const-string v5, "ReadStats"
    const-string v6, "zipEntry OK"
    invoke-static {v5, v6}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {v1}, Ljava/util/zip/ZipInputStream;->close()V
    invoke-virtual {v3}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    move-result-object v0
    new-instance v1, Ljava/lang/String;
    const-string v2, "UTF-8"
    invoke-direct {v1, v0, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    return-object v1

    :next_entry
    invoke-virtual {v1}, Ljava/util/zip/ZipInputStream;->closeEntry()V
    goto :eloop

    :no_entry
    const-string v5, "ReadStats"
    const-string v6, "zipEntry not found"
    invoke-static {v5, v6}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {v1}, Ljava/util/zip/ZipInputStream;->close()V
    const/4 v0, 0x0
    return-object v0

    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :zerr

    :zerr
    move-exception v0
    const-string v5, "ReadStats"
    const-string v6, "zipEntry EXCEPTION"
    invoke-static {v5, v6}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v0, 0x0
    return-object v0
.end method


# ---------------------------------------------------------------- cacheUri()
# 把 SAF 选中的文件复制到 App 私有缓存，之后用 ZipFile 随机读取
.method private static cacheUri(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    .locals 6
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    invoke-virtual {v0, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;
    move-result-object v0

    new-instance v1, Ljava/io/File;
    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v2
    const-string v3, "readstats_picked.zip"
    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const/16 v3, 0x1000
    new-array v3, v3, [B

    :cloop
    invoke-virtual {v0, v3}, Ljava/io/InputStream;->read([B)I
    move-result v4
    const/4 v5, -0x1
    if-eq v4, v5, :cdone
    const/4 v5, 0x0
    invoke-virtual {v2, v3, v5, v4}, Ljava/io/OutputStream;->write([BII)V
    goto :cloop

    :cdone
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- handleUri()
# 用 ZipFile 精确取备份里的 readRecordDetail.json（找不到再回退）
.method public static handleUri(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    .locals 6
    :try_start_0
    invoke-static {p0, p1}, Lcom/momocat/a5pro/readstats/FileBridge;->queryName(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :qn_fallback
    sput-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->pickedName:Ljava/lang/String;
    goto :qn_done
    :qn_fallback
    const-string v0, "选择的备份文件"
    sput-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->pickedName:Ljava/lang/String;
    :qn_done
    invoke-static {p0, p1}, Lcom/momocat/a5pro/readstats/FileBridge;->cacheUri(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v0

    new-instance v1, Lcom/momocat/a5pro/readstats/FileBridge;
    invoke-direct {v1, p0}, Lcom/momocat/a5pro/readstats/FileBridge;-><init>(Landroid/content/Context;)V

    const-string v2, "readRecordDetail.json"
    invoke-virtual {v1, v0, v2}, Lcom/momocat/a5pro/readstats/FileBridge;->readZip(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v2, "ERR:"
    invoke-virtual {v3, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :got_text

    const-string v2, "readRecordSession.json"
    invoke-virtual {v1, v0, v2}, Lcom/momocat/a5pro/readstats/FileBridge;->readZip(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v2, "ERR:"
    invoke-virtual {v3, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :got_text

    const-string v2, "readRecord.json"
    invoke-virtual {v1, v0, v2}, Lcom/momocat/a5pro/readstats/FileBridge;->readZip(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v2, "ERR:"
    invoke-virtual {v3, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :got_text

    const-string v4, "ReadStats"
    invoke-static {v4, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {v1, v0}, Lcom/momocat/a5pro/readstats/FileBridge;->readText(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3

    :got_text
    const-string v0, "UTF-8"
    invoke-virtual {v3, v0}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v0
    const/4 v1, 0x2
    invoke-static {v0, v1}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;
    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :herr
    return-object v0

    :herr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "ReadStats"
    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    return-object v0
.end method


# ---------------------------------------------------------------- sharePng(b64)
# 生成图片账单：写入系统相册（MediaStore，保持 PNG 原图）并调起系统分享面板
.method public sharePng(Ljava/lang/String;)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 8
    :try_start_0
    const/4 v0, 0x0
    invoke-static {p1, v0}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B
    move-result-object v0

    # 显示名：读痕-阅读账单-<毫秒>.png
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "读痕-阅读账单-"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v2
    invoke-virtual {v1, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v2, ".png"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    new-instance v2, Landroid/content/ContentValues;
    invoke-direct {v2}, Landroid/content/ContentValues;-><init>()V
    const-string v3, "_display_name"
    invoke-virtual {v2, v3, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V
    const-string v3, "mime_type"
    const-string v4, "image/png"
    invoke-virtual {v2, v3, v4}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v3, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    invoke-virtual {v3}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v3

    sget-object v4, Landroid/provider/MediaStore$Images$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;
    invoke-virtual {v3, v4, v2}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;
    move-result-object v4
    if-eqz v4, :ins_fail

    invoke-virtual {v3, v4}, Landroid/content/ContentResolver;->openOutputStream(Landroid/net/Uri;)Ljava/io/OutputStream;
    move-result-object v5
    invoke-virtual {v5, v0}, Ljava/io/OutputStream;->write([B)V
    invoke-virtual {v5}, Ljava/io/OutputStream;->close()V

    new-instance v5, Landroid/content/Intent;
    const-string v6, "android.intent.action.SEND"
    invoke-direct {v5, v6}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v6, "image/png"
    invoke-virtual {v5, v6}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;
    const-string v6, "android.intent.extra.STREAM"
    invoke-virtual {v5, v6, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;
    const/4 v6, 0x1
    invoke-virtual {v5, v6}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    const-string v6, "分享阅读账单"
    invoke-static {v5, v6}, Landroid/content/Intent;->createChooser(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;
    move-result-object v5

    iget-object v6, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    check-cast v6, Landroid/app/Activity;
    invoke-virtual {v6, v5}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    return-object v1

    :ins_fail
    const-string v0, "ERR: MediaStore insert failed"
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :sherr
    return-object v0

    :sherr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- pickDir()
# 打开系统文件管理器选择导出文件夹（SAF OPEN_DOCUMENT_TREE，requestCode 1002）
.method public pickDir()V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 3
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.OPEN_DOCUMENT_TREE"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    iget-object v1, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    check-cast v1, Landroid/app/Activity;
    const/16 v2, 0x3ea
    invoke-virtual {v1, v0, v2}, Landroid/app/Activity;->startActivityForResult(Landroid/content/Intent;I)V
    return-void
.end method


# ---------------------------------------------------------------- handleDirUri()
# SAF 选好文件夹后：取持久化权限，记录 treeUri / docId / 显示名
.method public static handleDirUri(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    .locals 5
    if-nez p1, :has_uri
    const-string v0, "ERR: no uri"
    return-object v0

    :has_uri
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    const/4 v1, 0x3
    invoke-virtual {v0, p1, v1}, Landroid/content/ContentResolver;->takePersistableUriPermission(Landroid/net/Uri;I)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :perm_ok

    :perm_ok
    sput-object p1, Lcom/momocat/a5pro/readstats/FileBridge;->dirUri:Landroid/net/Uri;

    invoke-static {p1}, Landroid/provider/DocumentsContract;->getTreeDocumentId(Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->dirDocId:Ljava/lang/String;

    # 显示名 = docId 冒号后部分（如 primary:Download → Download）
    const-string v1, ":"
    invoke-virtual {v0, v1}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v1
    if-gez v1, :cut
    add-int/lit8 v1, v1, 0x1
    invoke-virtual {v0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0
    :cut
    sput-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->dirName:Ljava/lang/String;
    return-object v0
.end method


# ---------------------------------------------------------------- dirName()
# 返回已选导出文件夹显示名（未选择返回空串）
.method public dirName()Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 1
    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->dirName:Ljava/lang/String;
    if-eqz v0, :dnull
    return-object v0
    :dnull
    const-string v0, ""
    return-object v0
.end method


# ---------------------------------------------------------------- setPagerOn(on)
# JS 侧声明当前主题是否带悬浮翻页键（供音量键/实体翻页键拦截判断）
.method public setPagerOn(Z)V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 0
    sput-boolean p1, Lcom/momocat/a5pro/readstats/FileBridge;->pagerOn:Z
    return-void
.end method


# ---------------------------------------------------------------- pickFontDir()
# 打开系统文件管理器选择字体文件夹（SAF OPEN_DOCUMENT_TREE，requestCode 1003）
.method public pickFontDir()V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 3
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.OPEN_DOCUMENT_TREE"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    iget-object v1, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    check-cast v1, Landroid/app/Activity;
    const/16 v2, 0x3eb
    invoke-virtual {v1, v0, v2}, Landroid/app/Activity;->startActivityForResult(Landroid/content/Intent;I)V
    return-void
.end method


# ---------------------------------------------------------------- handleFontDir()
# 字体文件夹选好后：记住 treeUri，扫描其中的 .ttf / .otf，返回文件名列表（换行分隔）
# 说明：个别 ROM（海信 browser.download.provider）会忽略投影/返回空 display_name，
#       故用 null 投影拿全部列，逐行扫所有列找 .ttf / .otf 值（兼容路径形式）。
.method public static handleFontDir(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;
    .locals 10
    if-nez p1, :has_uri
    const-string v0, "ERR: no uri"
    return-object v0

    :has_uri
    sput-object p1, Lcom/momocat/a5pro/readstats/FileBridge;->fontDirUri:Landroid/net/Uri;

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "fontDir uri="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "ReadStats"
    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :try_start_0
    invoke-static {p1}, Landroid/provider/DocumentsContract;->getTreeDocumentId(Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v0
    invoke-static {p1, v0}, Landroid/provider/DocumentsContract;->buildChildDocumentsUriUsingTree(Landroid/net/Uri;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    move-object v2, v0
    const/4 v3, 0x0
    const/4 v4, 0x0
    const/4 v5, 0x0
    const/4 v6, 0x0
    invoke-virtual/range {v1 .. v6}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v1
    if-eqz v1, :no_cursor

    invoke-interface {v1}, Landroid/database/Cursor;->getColumnCount()I
    move-result v7
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "font rows="
    invoke-interface {v1}, Landroid/database/Cursor;->getCount()I
    move-result v2
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v3, " cols="
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v3, "ReadStats"
    invoke-static {v3, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v3, 0x0
    :cnloop
    if-ge v3, v7, :cnend
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "col["
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, "]="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-interface {v1, v3}, Landroid/database/Cursor;->getColumnName(I)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v2, "ReadStats"
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    add-int/lit8 v3, v3, 0x1
    goto :cnloop
    :cnend

    invoke-interface {v1}, Landroid/database/Cursor;->moveToFirst()Z
    move-result v2
    if-eqz v2, :valend
    const/4 v3, 0x0
    :cvloop
    if-ge v3, v7, :valend
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "val["
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, "]="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-interface {v1, v3}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v2, "ReadStats"
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    add-int/lit8 v3, v3, 0x1
    goto :cvloop
    :valend

    # 诊断后回到首行之前，避免吞掉第一行
    const/4 v2, -0x1
    invoke-interface {v1, v2}, Landroid/database/Cursor;->moveToPosition(I)Z

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    :floop
    invoke-interface {v1}, Landroid/database/Cursor;->moveToNext()Z
    move-result v2
    if-eqz v2, :floop_end
    const/4 v4, 0x0
    :fscan
    if-ge v4, v7, :frow_done
    invoke-interface {v1, v4}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v5
    if-eqz v5, :fnext_col
    invoke-virtual {v5}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v6
    const-string v8, ".ttf"
    invoke-virtual {v6, v8}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v9
    if-nez v9, :fhit
    const-string v8, ".otf"
    invoke-virtual {v6, v8}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v9
    if-eqz v9, :fnext_col

    :fhit
    const-string v8, "/"
    invoke-virtual {v5, v8}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v2
    if-ltz v2, :fuse
    add-int/lit8 v2, v2, 0x1
    invoke-virtual {v5, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v5
    :fuse
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const/16 v2, 0xa
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    :frow_done
    goto :floop
    :fnext_col
    add-int/lit8 v4, v4, 0x1
    goto :fscan

    :floop_end
    invoke-interface {v1}, Landroid/database/Cursor;->close()V
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    sput-object v2, Lcom/momocat/a5pro/readstats/FileBridge;->fontList:Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :ferr
    return-object v2

    :no_cursor
    const-string v2, "ERR: no cursor"
    sput-object v2, Lcom/momocat/a5pro/readstats/FileBridge;->fontList:Ljava/lang/String;
    return-object v2

    :ferr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    sput-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->fontList:Ljava/lang/String;
    return-object v0
.end method


# ---------------------------------------------------------------- listFonts()
# 返回最近一次扫描到的字体列表（未扫描返回空串）
.method public listFonts()Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 1
    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->fontList:Ljava/lang/String;
    if-eqz v0, :empty
    return-object v0
    :empty
    const-string v0, ""
    return-object v0
.end method


# ---------------------------------------------------------------- loadFont(name)
# 把所选文件夹里的指定字体复制到 App 私有目录，返回 file:// URL 供 CSS @font-face 使用
# v2.7：复制到唯一文件名 c<时间戳>.ttf（每次 URL 不同，绕过 WebView 按 URL 的字体缓存，
#       修复切换字体界面不更新的 bug）；成功后清理旧字体文件。
# 同名用全列扫描匹配，document_id 用 getColumnIndex 获取（防投影被忽略）。
.method public loadFont(Ljava/lang/String;)Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 10
    if-nez p1, :has_name
    const-string v0, "ERR: no name"
    return-object v0

    :has_name
    sget-object v0, Lcom/momocat/a5pro/readstats/FileBridge;->fontDirUri:Landroid/net/Uri;
    if-nez v0, :has_dir
    const-string v0, "ERR: 请先选择字体文件夹"
    return-object v0

    :has_dir
    :try_start_0
    invoke-static {v0}, Landroid/provider/DocumentsContract;->getTreeDocumentId(Landroid/net/Uri;)Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/provider/DocumentsContract;->buildChildDocumentsUriUsingTree(Landroid/net/Uri;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v1
    iget-object v2, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    move-object v3, v1
    const/4 v4, 0x0
    const/4 v5, 0x0
    const/4 v6, 0x0
    const/4 v7, 0x0
    invoke-virtual/range {v2 .. v7}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v2
    if-eqz v2, :scan_fail
    move-object v3, v2
    invoke-interface {v3}, Landroid/database/Cursor;->getColumnCount()I
    move-result v7
    const-string v8, "document_id"
    invoke-interface {v3, v8}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v8
    if-ltz v8, :scan_fail

    :scan
    invoke-interface {v3}, Landroid/database/Cursor;->moveToNext()Z
    move-result v4
    if-eqz v4, :scan_fail
    const/4 v4, 0x0
    :cols
    if-ge v4, v7, :scan
    invoke-interface {v3, v4}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v5
    if-eqz v5, :ncol
    invoke-virtual {v5}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v6
    const-string v9, ".ttf"
    invoke-virtual {v6, v9}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v9
    if-nez v9, :cand
    const-string v9, ".otf"
    invoke-virtual {v6, v9}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v9
    if-eqz v9, :ncol

    :cand
    const-string v9, "/"
    invoke-virtual {v5, v9}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v2
    if-ltz v2, :whole
    add-int/lit8 v2, v2, 0x1
    invoke-virtual {v5, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v5
    :whole
    invoke-virtual {p1, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v9
    if-eqz v9, :ncol

    invoke-interface {v3, v8}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v9
    invoke-interface {v3}, Landroid/database/Cursor;->close()V
    invoke-static {v0, v9}, Landroid/provider/DocumentsContract;->buildDocumentUriUsingTree(Landroid/net/Uri;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v4

    iget-object v1, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    invoke-virtual {v1, v4}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;
    move-result-object v1
    iget-object v2, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    invoke-virtual {v2}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v2
    new-instance v3, Ljava/io/File;
    const-string v5, "fonts"
    invoke-direct {v3, v2, v5}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v3}, Ljava/io/File;->mkdirs()Z
    # v2.7：唯一文件名 c<时间戳>.ttf —— 旧实现固定写 current.ttf，换字体后返回同一
    # file:// URL，WebView 按 URL 缓存旧字形，导致界面不更新（需先恢复默认才生效）。
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v6
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "c"
    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v6, v7}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v8, ".ttf"
    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v3, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v3, Ljava/io/FileOutputStream;
    invoke-direct {v3, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const v5, 0x10000
    new-array v5, v5, [B

    :copy
    invoke-virtual {v1, v5}, Ljava/io/InputStream;->read([B)I
    move-result v6
    if-lez v6, :copy_end
    const/4 v0, 0x0
    invoke-virtual {v3, v5, v0, v6}, Ljava/io/FileOutputStream;->write([BII)V
    goto :copy

    :copy_end
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    invoke-virtual {v3}, Ljava/io/FileOutputStream;->close()V
    # v2.7：清理旧字体文件，只保留刚写入的这一个（防私有目录无限膨胀）
    invoke-virtual {v2}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v4
    invoke-virtual {v4}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v4
    if-eqz v4, :clean_done
    array-length v5, v4
    const/4 v6, 0x0
    :clean_loop
    if-ge v6, v5, :clean_done
    aget-object v7, v4, v6
    if-eqz v7, :clean_next
    invoke-virtual {v7, v2}, Ljava/io/File;->equals(Ljava/lang/Object;)Z
    move-result v8
    if-nez v8, :clean_next
    invoke-virtual {v7}, Ljava/io/File;->delete()Z
    :clean_next
    add-int/lit8 v6, v6, 0x1
    goto :clean_loop
    :clean_done
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "file://"
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :lferr
    return-object v1

    :ncol
    add-int/lit8 v4, v4, 0x1
    goto :cols

    :scan_fail
    const-string v0, "ERR: 字体文件未找到"
    return-object v0

    :lferr
    move-exception v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "ERR: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ---------------------------------------------------------------- fontUrl()
# 返回已复制到私有目录的字体 file:// URL（没有则返回空串）
# v2.7：字体文件不再固定为 current.ttf，改为扫描 fonts/ 目录取最新的 .ttf
#       （loadFont 每次写 c<时间戳>.ttf；此处兼容历史遗留的 current.ttf）
.method public fontUrl()Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    .locals 10
    :try_start_0
    iget-object v0, p0, Lcom/momocat/a5pro/readstats/FileBridge;->ctx:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "fonts"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v3
    if-eqz v3, :none
    array-length v5, v3
    const/4 v4, 0x0
    const/4 v6, 0x0
    const-wide/16 v0, -0x1
    :fu_loop
    if-ge v4, v5, :fu_done
    aget-object v7, v3, v4
    if-eqz v7, :fu_next
    invoke-virtual {v7}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v2
    const-string v8, ".ttf"
    invoke-virtual {v2, v8}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v8
    if-eqz v8, :fu_next
    invoke-virtual {v7}, Ljava/io/File;->lastModified()J
    move-result-wide v8
    cmp-long v2, v8, v0
    if-lez v2, :fu_next
    move-wide v0, v8
    move-object v6, v7
    :fu_next
    add-int/lit8 v4, v4, 0x1
    goto :fu_loop
    :fu_done
    if-eqz v6, :none
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "file://"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :fuerr
    return-object v0

    :none
    const-string v0, ""
    return-object v0

    :fuerr
    const-string v0, ""
    return-object v0
.end method
