---
title: BugkuCTF-web-备份是个好习惯 writeup
date: 2019-07-11 23:10:15
tags: CTF WEB
categories: CTF做题记录
---

>常用备份文件后缀：`*.swp，*.bak`
>md5函数漏洞
>php弱判断
<!--more-->
---
# 题目描述
题目传送门：http://123.206.87.240:8002/web16/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711220141739.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
打开链接得到的一串暂时看不懂的编码。。。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711220258278.png)
小白什么都不懂，直接御剑扫描吧
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711221646935.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
看大佬的wp是用源码泄露工具搞到的备份文件，以后可能会补上此方法
备份地址：http://123.206.87.240:8002/web16/index.php.bak
下载文件，内容如下：
```php
<?php
/**
 * Created by PhpStorm.
 * User: Norse
 * Date: 2017/8/6
 * Time: 20:22
*/

include_once "flag.php";
ini_set("display_errors", 0);
$str = strstr($_SERVER['REQUEST_URI'], '?');//str=URL?后面内容
$str = substr($str,1);//从第一个开始
$str = str_replace('key','',$str);//把字符串中的key全部换成空格
parse_str($str);
echo md5($key1);

echo md5($key2);
if(md5($key1) == md5($key2) && $key1 !== $key2){
    echo $flag."取得flag";
}
?>
```
代码知识点：
`strstr() 函数` strstr(string,search,before_search) 搜索字符串在另一字符串中是否存在，如果是，返回该字符串及剩余部分，否则返回 FALSE(区分大小写)，`stristr() 函数`，这个不区分;
`substr() 函数` substr(string,start,length) 返回字符串的一部分;
`str_replace() 函数`str_replace(find,replace,string,count)
替 换字符串中的一些字符（区分大小写）。
`parse_str() 函数`      parse_str(string,array) 把查询字符串解析到变量中


所以，整段代码的意思就是j截取URL`?`后的参数，并把gat到的变量中所有`key`替换为空格，不过这里我们可以用kkeyey绕过
```php
if(md5($key1) == md5($key2) && $key1 !== $key2)
```
但是通过这段代码可以知道，我们传进去的变量，它们的md5值要相同，但它们本身却有不同，这里我们又要用到一个小知识点：

法一、md5()函数是无法处理数组的，如果传入的为数组，会返回NULL，所以两个数组经过加密后得到的都是NULL,也就是相等的。

所以将key1，key2写成数组，内容再不一样就行啦

法二、利用==弱比较漏洞
科学计数法为\*e***，如果两个字符串解密后是0e***那么他们两个就相等啦
下面几个都是开头为0e的
```
QNKCDZO
240610708
s878926199a
s155964671a
s214587387a
s214587387a
```
# 得到FLAG
法一、构造Payload
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711230722660.png)
法二、构造Payload
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071123080461.png)
