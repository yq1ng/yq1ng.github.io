---
title: BugkuCTF-web-web基础$_GET writeup
date: 2019-06-25 09:20:36
tags: CTF WEB
categories: CTF做题记录
---

>学会GET传参                                                                                   
<!--more-->
---
# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190625091210365.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
进入链接得到以下代码
```php
$what=$_GET['what'];
echo $what;
if($what=='flag')
echo 'flag{****}';
```
意思是当what以GET形式接受到flag参数时，输出FLAG
# 得到FLAG
则在url后加`?what=flag`即可得到flag
flagflag{bugku_get_su8kej2en}
