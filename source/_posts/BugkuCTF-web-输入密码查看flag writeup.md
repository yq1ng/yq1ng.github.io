---
title: BugkuCTF-web-输入密码查看flag writeup
date: 2019-07-11 21:40:07
tags: CTF WEB
categories: CTF做题记录
---

>没什么，还是爆破
<!--more-->
---
# 题目描述
解题链接：http://123.206.87.240:8002/baopo/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711211159890.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
![在这里插入图片描述](https://img-blog.csdnimg.cn/201907112114098.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
5位密码，URL有提示，直接bp爆破吧
抓包，放到Intruder里
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711211721392.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
改参，一个变量
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711211832982.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
构造Payload，由于是五位数密码，直接遍历10000-->99999好了
以下为设置方法
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711213925145.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
Start attack即可，记得按Length排序，容易看出爆破成功没有
喝口水，等会就行
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071121360931.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 得到FLAG
密码：13579
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711213650181.png)
