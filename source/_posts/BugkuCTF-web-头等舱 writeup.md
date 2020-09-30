---
title: BugkuCTF-web-头等舱 writeup
date: 2019-07-06 13:47:34
tags: CTF WEB
categories: CTF做题记录
---

>小白你的脑洞呢！！！
<!--more-->
---
# 题目描述
解题链接：http://123.206.87.240:9009/hd.php
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706134222359.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
打开链接，什么都没有，真的是什么都没有
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706134300261.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查看源代码也是什么也没有
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019070613433574.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
那就抓包看看
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019070613442627.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
也没有，emm
再回去看看题目，头等舱，头等舱，头等舱，响应头？？？！！！
放到Repeater里面，Go以下，Response里面已经出来flag了

# 得到FLAG
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706134700864.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
