---
title: BugkuCTF-web-login1(SKCTF) writeup
date: 2019-07-13 13:53:12
tags: CTF WEB
categories: CTF做题记录
---

>SQL在执行字符串处理的时候是会自动修剪掉尾部的空白符的
<!--more-->
---
# 题目描述
解题传送门：http://123.206.31.85:49163/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713134135424.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
打开链接：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713134221556.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
登陆？万能密码搞一下
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713134419350.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
，，，不行啊，有个注册账号，试试去，随意注册一个，登进去看看再说
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713134542133.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
额，这样啊，回去看看提示，嗯，，约束攻击

攻击之前先来了解一些知识点吧，拿小本本记下来
- 什么是约束攻击？
约束SQL注入的原理就是利用的约束条件，比如最长只能有15个字符的话，如果你输入的是abcdefghijklmnop(16位），那么保存在数据库里的就是abcdefghijklmno，那么别人用abcdefghijklmno注册一个用户名，就可以登陆。
- 有什么用（怎么用）
SQL在执行字符串处理的时候是会自动修剪掉尾部的空白符的，也就是说`"abc"=="abc "`，同样我们可以通过注册用户名为"abc "的账号来登陆"abc"的账号。
ok,科普结束

这题意思就是登上管理员（admin）的号就出flag了呗，再注册一次这次用`admin `做账号（admin后面有一个空格）密码自己写，然后在登陆一遍就可以了

# 得到FLAG
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713135143988.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# END
