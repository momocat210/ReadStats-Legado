#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把墨本阅读备份(readRecordDetail.json)转换为 Reeden 外部导入 JSON。

用法：
  python convert_reeden.py [备份zip或json路径] [输出路径]
默认读 out/real_backup.zip，输出 out/reeden_import.json。
转换逻辑与读痕 App 内 exportReeden() 完全一致。
"""
import json
import os
import sys
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))


def load_records(path):
    if path.endswith(".zip"):
        with zipfile.ZipFile(path) as z:
            for name in ("readRecordDetail.json", "readRecordSession.json", "readRecord.json"):
                if name in z.namelist():
                    return json.loads(z.read(name).decode("utf-8")), name
            raise RuntimeError("备份里没有阅读记录 JSON")
    with open(path, encoding="utf-8") as f:
        return json.load(f), os.path.basename(path)


def convert(records):
    books = {}
    for r in records:
        name = str(r.get("bookName") or r.get("title") or "未知")
        author = str(r.get("bookAuthor") or r.get("author") or "")
        date = str(r.get("date") or "")[:10]
        ms = int(r.get("readTime") or 0)
        words = int(r.get("readWords") or 0)
        k = (name, author)
        b = books.setdefault(k, {"dd": {}, "dw": {}})
        if date:
            b["dd"][date] = b["dd"].get(date, 0) + ms
            if words:
                b["dw"][date] = b["dw"].get(date, 0) + words

    out = []
    for (name, author), b in books.items():
        dd = sorted(b["dd"].items())
        dw = b["dw"]
        rs = {"readStatus": "reading", "readRoundNo": 1}
        if dd:
            rs["readStartTime"] = dd[0][0] + "T00:00:00"
            rs["lastReadTime"] = dd[-1][0] + "T23:59:59"
        out.append({
            "title": name,
            "author": author,
            "tags": ["读痕导出"],
            "category": "读痕",
            "readingState": rs,
            "readingStatistics": {
                "readingRecords": [
                    dict({"date": d, "readSeconds": round(ms / 1000)},
                         **({"wordCount": dw[d]} if dw.get(d) else {}))
                    for d, ms in dd
                ]
            },
        })
    out.sort(key=lambda x: -sum(r["readSeconds"] for r in x["readingStatistics"]["readingRecords"]))
    return out


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "out", "real_backup.zip")
    dst = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, "out", "reeden_import.json")
    records, name = load_records(src)
    data = convert(records)
    with open(dst, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    total_sec = sum(r["readSeconds"] for b in data for r in b["readingStatistics"]["readingRecords"])
    n_rec = sum(len(b["readingStatistics"]["readingRecords"]) for b in data)
    print("来源:", name, "记录数:", len(records))
    print("输出:", dst)
    print("书籍: %d 本 / 逐日记录 %d 条 / 合计 %.1f 小时" % (len(data), n_rec, total_sec / 3600))


if __name__ == "__main__":
    main()
