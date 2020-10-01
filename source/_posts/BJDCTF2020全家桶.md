---
title: BJDCTF2020全家桶
date: 2020-10-01 10:03:08
categories: CTF做题记录
---

<!-- TOC -->

- [[BJDCTF2020]Easy MD5](#bjdctf2020easy-md5)
- [[BJDCTF2020]Mark loves cat](#bjdctf2020mark-loves-cat)

<!-- /TOC -->

<!--more-->
---

# [BJDCTF2020]Easy MD5
>md5(str,true)的绕过：ffifdyop；md5强弱判断的绕过

随便搜了搜没发现啥东西，抓包看看response，这个猛一看还是万能密码，但是后面的password查询加密了，普通的万能密码不能用，这个查询方式在实验吧也有一个，当时直接给了一个能用的payload：`ffifdyop`，这个直接成功了，接下来看看原理
![抓包](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.d5njrglf5k9.png)
![done1](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.6l1aq9ihj5.png)

原理：md5后面加上true意为返回原始16字符二进制格式\
![md5-true](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.qnoq1b13yqc.png)\
再来看看字符串被加密成什么了，可以看到加上true后字符串出现了`'or'6`，这在MySQL查询里可是万能密码啊

![加密](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.3qlfnv1bxmd.png)

在mysql里面，在用作布尔型判断时，以数字开头的字符串会被当做整型数。要注意的是这种情况是必须要有单引号括起来的，比如password='xxx' or '1xx'，那么就相当于password='xxx' or 1 ，也就相当于password='xxx' or true，所以返回值就是true
![MySql](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.zc8ak1q37d.png)

所以i要'or'后面的字符串为一个非零的数字开头都会返回True，可以用一个脚本来找，脚本引自[这里](http://mslc.ctf.su/wp/leet-more-2010-oh-those-admins-writeup/)
```php
<?php 
for ($i = 0;;) { 
 for ($c = 0; $c < 1000000; $c++, $i++)
  if (stripos(md5($i, true), '\'or\'') !== false)
   echo("\nmd5($i) = " . md5($i, true) . "\n");
 echo(".");
}
?>
```
输入上述字符串后进入下一关，~~可以发现赵师傅征婚的注释~~，弱判断的md5数组绕过，md5函数不能处理数组，遇到数组时会变成空
payload为`?a[]=&b[]=`
![2nd](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.yd1iq3erkml.png)
下一关与上一关的不同就是所有的比较都变成了强比较，不过还是能用数组绕过哈哈哈，其实第二关应该考的是md5碰撞，寻找两个明文相同但加密后都是以`0e`开头的字符串，例如`QNKCDZO`和`s214587387a`
![done](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.la7zyjqxrvh.png)

---
# [BJDCTF2020]Mark loves cat
>git泄露，变量覆盖

网站做的挺精致，转了一圈没发现啥，在contact那有留言框，可能有xss吧，结果并没有可能是太菜了，扫一下看看，git源码泄露，下载下来（这是网上师傅wp的，我的githack又炸了，下不下来。。。）
![dirsearch](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.0whio49hlxkn.png)
```php
<?php
include 'flag.php';
$yds = "dog";
$is = "cat";
$handsome = 'yds';

foreach($_POST as $x => $y){
    $$x = $y;
}

foreach($_GET as $x => $y){
    $$x = $$y;
}

foreach($_GET as $x => $y){
    if($_GET['flag'] === $x && $x !== 'flag'){	//GET方式传flag只能传一个flag=flag
        exit($handsome);
    }
}

if(!isset($_GET['flag']) && !isset($_POST['flag'])){	//GET和POST其中之一必须传flag
    exit($yds);
}

if($_POST['flag'] === 'flag'  || $_GET['flag'] === 'flag'){	//GET和POST传flag,必须不能是flag=flag
    exit($is);
}

echo "the flag is: ".$flag;
```
payload:
```
GET:yds=flag
POST:$flag=flag
```
![done](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.8xz99i9yyqn.png)

---