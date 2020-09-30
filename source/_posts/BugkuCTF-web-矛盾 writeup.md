---
title: BugkuCTF-web-矛盾 writeup
date: 2019-06-29 16:48:41
tags: CTF WEB
categories: CTF做题记录
---

>绕过is_numeric() //判断参数是否为数字
<!--more-->
---
# 题目描述
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190629164438134.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
打开链接，得到
```php
$num=$_GET['num'];//GET方式得到参数num值
if(!is_numeric($num))//判断num是否为数字，如果不是则输出num的值
{
echo $num;
if($num==1)//如果num==1则输出FLAG
echo 'flag{**********}';
}
```
num既要是1又要不是数字，这就是矛盾所在
那么晚们可以令`num=1xx`即可绕过验证，而又使num为1
# 得到FLAG
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190629164831239.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
