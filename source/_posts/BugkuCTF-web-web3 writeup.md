---
title: BugkuCTF-web-web3 writeup
date: 2019-06-29 16:55:23
tags: CTF WEB
categories: CTF做题记录
---

# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190629165133843.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
<!--more-->
# 解题思路
打开链接后一直有弹窗，禁止使用即可，也可以直接在URL前加`view-source:`
查看源代码，拖到最后发现
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190629165308435.png)
最后一串编码为`Unicode编码转换ASCII`，用[站长工具](http://tool.chinaz.com/tools/unicode.aspx)即可完成转换
# 得到FLAG
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190629165515214.png)
