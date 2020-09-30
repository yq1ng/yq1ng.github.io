---
title: buuoj BJDCTF-2nd WP
date: 2020-06-11 10:08:10
tags: CTF WEB
categories: CTF做题记录
---

> 复现地址：buuoj.cn
> ssti的简单使用
<!--more-->
---
# [BJDCTF 2nd]fake google
打开复现地址是一个Google页面
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611075142860.png)
随便搜索一下看了源码提示ssti
>SSTI又叫服务端模板注入攻击
>推荐先知师傅的一篇入门教程：https://xz.aliyun.com/t/3679

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611075232196.png)
那就试试ssti能不能用吧，`?name={{1-1}}`下面输出却是0，说明注入是可以的
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611075751716.png)
列出基类，`?name={{"".__class__.__base__}}`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611080032266.png)
列出其子类，`?name={{"".__class__.__base__.__subclasses__()}}`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611080133962.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
有这么多，我们需要查找到有==os==类的子类，可以看到确实有一个这样的类，现在就是找到他的下标，肯定不会一个一个数鸭哈哈，写个脚本（当然也能用bp爆破），在上一条payload的后面加上`[]`就行，就像是找数组里面的值（`?name={{"".__class__.__base__.__subclasses__()[110]}}`）
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611080619702.png)
```python
import requests
import time

for i in range(0,200):
	time.sleep(0.06)//赵师傅靶机有访问频率限制，所以加上sleep
	url = 'http://6b31caef-86aa-49f5-b819-14ec6d3637e6.node3.buuoj.cn/qaq?name={{"".__class__.__base__.__subclasses__()[%s]}}'% i
	#print(url)
	res = requests.get(url)
	if 'os._wrap_close' in res.text:
		print(url)
		break
```
运行后得到os类在117位，然后初始化此类（`?name={{"".__class__.__base__.__subclasses__()[117].__init__.__globals__}}`），用pepon执行命令，可以看到flag在根目录下，cat一下就出来了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611082102973.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611082144159.png)

---
# [BJDCTF 2nd]old-hack

> RCE的利用

开了靶机，黑客既视感
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611082246944.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
上面的THINKPHP5是一个php框架，用参数s引入一个不存在的模块爆出版本信息，然后去搜搜有没有漏洞hhh
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084056466.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
直接搜5.0.23的RCE,flag在根目录下，cat一下就好
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084228995.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [BJDCTF 2nd]假猪套天下第
> HTTP Header基础知识考察
> 这道题是Y1ng大师傅出的题，考的很基础
> Y1ng师傅出题笔记：https://www.gem-love.com/ctf/2056.html#%E5%81%87%E7%8C%AA%E5%A5%97%E5%A4%A9%E4%B8%8B%E7%AC%AC%E4%B8%80
> Y1ng推荐的HTTP Header 详解：https://www.cnblogs.com/jxl1996/p/10245958.html

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084438687.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
admin弱口令登陆发现，但是用其他的账户随便输都能进去，进去后啥也没有，抓包看看
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084653455.png)
302跳转！，进去注释给的页面
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611085307456.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611085415184.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
没发现啥有用的，在抓包看看，cookie里面有个time参数，根据页面提示把他改到99年以后，又说我们不是来自本地的用户
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611085605328.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
用xff修改后（X-Forwarded-For:127.0.0.1直接加到repeater最下面就好），说我Too young too simple，那就换种方式，用Client-IP或者X-Real-IP；
然后提示访问要来自gem-love.com，用Referer:gem-love.com;
接着提示我们的浏览器不是Commodo 64，至于Commodo 64是什么自行搜索，然后用Commodore 64把UA头改了就行；
然后说邮箱不对，加上From:root@gem-love.com;
最后提示代理服务器需要是y1ng.vip，或者你可以py100一月hhh，加上via:y1ng.vip;
大功告成，解一下base64就好了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611091429240.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
持续更新

