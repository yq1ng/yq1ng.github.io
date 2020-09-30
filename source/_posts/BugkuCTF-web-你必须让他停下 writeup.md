---
title: BugkuCTF-web-你必须让他停下 writeup
date: 2019-06-30 17:10:24
tags: CTF WEB
categories: CTF做题记录
---

>运气、耐心
<!--more-->
---
# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190630170610419.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
打开链接后，页面一直自动刷新，直接bp抓包
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190630170704570.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
发送到Repeater里，每go一下，发现图片都会变化，这个是随机的，所以多go几次当出现`10.jpg`时flag就出来了，好像有时候出现`10.jpg`也没有flag，多go几次就行
# 得到FLAG
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190630170929375.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
