---
title: BugkuCTF-web-web5 writeup
date: 2019-07-06 13:38:11
tags: CTF WEB
categories: CTF做题记录
---

>各大浏览器均可在控制台里面解码JS的jother，另外，别忘记题目提示
<!--more-->
---
# 题目描述
解题链接：http://123.206.87.240:8002/web5/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706131449616.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
打开链接后,得到一个对话框
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706131525541.png)
随便输
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706131616839.png)
没啥可用的东西，查看源码，得到超长编码，由于编码太长，这里我就不把它粘贴出来了，这是JS的jother编码，大多数浏览器的控制台都能直接解析它，只需要将编码复制到Console中，敲Enter即可
例如：Chrome浏览器
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706133047889.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
Firefox浏览器
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706133324451.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
得到的flag提交以下发现并不对
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190706133425291.png)
看一下题目描述，发现提示`字母大写`。。。
再提交一次`CTF{WHATFK}`
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019070613354248.png)
那这个就是flag啦，恭喜。
