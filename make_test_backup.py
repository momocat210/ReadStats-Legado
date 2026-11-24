#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""用现有 legado.db 快照生成一份「墨本阅读备份 ZIP」用于开发验证。

字段名与 Legado 3.26 数据库实体一致；真实使用时用户直接导出墨本阅读自带备份即可。
"""
import json
import os
import sqlite3
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(os.path.dirname(ROOT), "readstats", "db", "legado.db")
OUT = os.path.join(ROOT, "out")
os.makedirs(OUT, exist_ok=True)
ZIP = os.path.join(OUT, "backup2026-11-13.zip")

c = sqlite3.connect("file:%s?mode=ro" % DB.replace("\\", "/"), uri=True)


def q(sql):
    try:
        cur = c.execute(sql)
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row)) for row in cur.fetchall()]
    except Exception as e:
        print("  skip:", e)
        return []


detail = q("select deviceId,bookName,bookAuthor,date,readTime,readWords,"
           "firstReadTime,lastReadTime from readRecordDetail")
record = q("select deviceId,bookName,bookAuthor,readTime,lastRead from readRecord")
session = q("select id,deviceId,bookName,bookAuthor,startTime,endTime,words "
            "from readRecordSession")
shelf = q("select name,author from books")

items = {
    "readRecordDetail.json": detail,
    "readRecord.json": record,
    "readRecordSession.json": session,
    "bookshelf.json": shelf,
    "settings.json": {"app": "legado", "version": "3.26.17"},
}
with zipfile.ZipFile(ZIP, "w", zipfile.ZIP_DEFLATED) as z:
    for name, obj in items.items():
        z.writestr(name, json.dumps(obj, ensure_ascii=False, separators=(",", ":")))
c.close()
print("生成:", ZIP, os.path.getsize(ZIP), "bytes")
for k, v in items.items():
    print("  %-28s %6d 条" % (k, len(v) if isinstance(v, list) else 1))
