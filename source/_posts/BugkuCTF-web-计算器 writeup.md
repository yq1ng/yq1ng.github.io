---
title: BugkuCTF-web-计算器 writeup
date: 2019-06-24 14:23:17
tags: CTF WEB
categories: CTF做题记录
---

# 题目描述
解题链接：http://123.206.87.240:8002/yanzhengma/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190624140921901.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
<!--more-->
## 解题思路
`解法一、`
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019062414101817.png)
随机运算，但是只能输入一个数值，按F12看源代码可知，输入长度被限制为1
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190624141520806.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
将`1`改为`9`，再次输入即可得到FLAG
`解法二、`
这是我无意间知道的
F12-source-js-code.js
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190624142257749.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
