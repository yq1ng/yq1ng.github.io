---
title: BugkuCTF-web-网站被黑 writeup
date: 2019-07-09 13:41:09
tags: CTF WEB
categories: CTF做题记录
---

>御剑拿后台，bp爆破
<!--more-->
---
# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709113146530.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
解题链接：http://123.206.87.240:8002/webshell/
打开链接有一个炫酷的网页，，，
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709113252714.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
拿出御剑一顿扫描，得到后台网址
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709114114628.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
http://123.206.87.240:8002/webshell/shell.php
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709113443516.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
这，，，爆破吧，掏出bp，抓包，丢到Intruder里面跑一下
设置爆破参数
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709114650315.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
这个用默认字典就行，选password
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709114340129.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
点Start attack喝口茶，等着就行,记得按Length排序
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709115940287.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
还没跑完就出密码了
# 得到FLAG
密码：hack
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190709120028443.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
