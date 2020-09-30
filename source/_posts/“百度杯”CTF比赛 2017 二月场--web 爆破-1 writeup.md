---
title: “百度杯”CTF比赛 2017 二月场--web 爆破-1 writeup
date: 2019-06-14 15:03:25
tags: CTF WEB
categories: CTF做题记录
---

# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190613134554606.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
<!--more-->
## 解题思路
创建赛题，点击链接得到一段源码：
```php
<?php
include "flag.php";
$a = @$_REQUEST['hello'];//REQUEST可以接收来自GET或者POST的数据
if(!preg_match('/^\w*$/',$a )){//preg_match 函数用于执行一个正则表达式匹配,返回 pattern 的匹配次数
  die('ERROR');
}
eval("var_dump($$a);");// var_dump() 函数返回变量的数据类型和值
show_source(__FILE__);
?>
```
这个代码的作用是如果匹配正则表达式`/^\w*$/`，就打印变量`$$a`
`$a`是hello，`$$a`是六位变量`$hello`；
由于`$a`在函数内，要想访问`$hello`,则需要将其改为超全局变量GLOBALS；
即，在URL后面加?hello=GLOBALS;
输出语句变为
```php
eval("var_dump($$a);");
eval("var_dump($hello);");
eval("var_dump($GLOBALS);");
```
## 得到FLAG
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190613143231966.png)
flag{1ba2ca18-ebbc-4e48-89f2-514d1ae7379a}
