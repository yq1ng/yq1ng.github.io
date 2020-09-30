---
title: BugkuCTF-web-点击一百万次 writeup
date: 2019-07-11 21:58:17
tags: CTF WEB
categories: CTF做题记录
---

>控制台一样传参！
<!--more-->
---
# 题目描述
解题传送门：http://123.206.87.240:9001/test/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711214329175.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711214438287.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
什么？？？让我点击一百万次？！都散了吧，要手的
滚回去看看提示，唔，JS啊，F12
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711214907857.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
我把`clickcount`的值改为1000000了，没出flag，我真是疯了，想到这么蠢的方法，哈哈
打开我的火狐，post传参呐
# 得到FLAG
方法一、
在浏览器控制台直接输入`clicks=1000000`再点击饼干刷新一下页面即可
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711215645897.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711215703183.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
方法二、
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711215422942.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
