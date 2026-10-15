# -*- coding: utf-8 -*-
"""轮询 WxHideBar CI（按 head_sha 过滤）"""
import json, os, sys, time, urllib.request

TOKEN = os.environ["GH_TOKEN"]
REPO = "Corpse-zhao/WxHideBar"
SHA = sys.argv[1]
API = "https://api.github.com"


def get(path):
    req = urllib.request.Request(API + path)
    req.add_header("Authorization", "token " + TOKEN)
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


for i in range(60):
    runs = get("/repos/%s/actions/runs?head_sha=%s" % (REPO, SHA))
    rs = runs.get("workflow_runs", [])
    if rs and all(r["status"] == "completed" for r in rs):
        ok = all(r["conclusion"] == "success" for r in rs)
        for r in rs:
            print(r["id"], r["name"], r["conclusion"])
        sys.exit(0 if ok else 2)
    print("waiting...", rs and rs[0]["status"])
    time.sleep(15)
print("timeout")
sys.exit(3)
