---
title: 重启，SQLi-labs GET
date: 2020-10-14 21:24:02
categories: CTF做题记录
---

本lab旨在培养注入思维，提供注入思路，lab不要求找flag，别为了做题而做题！有些东西能自己动手的就试试，我重写lab的原因之一就是没有动手实践\
搭建环境较多，可以自行百度，本lab目的是查其他表或者库
<!-- TOC -->

- [Less-1 GET-基于错误的-单引号-字符型注入](#less-1-get-基于错误的-单引号-字符型注入)
- [Less-2 GET-基于错误的-数字型](#less-2-get-基于错误的-数字型)
- [Less-3 GET-基于错误的-单引号变形的字符型注入](#less-3-get-基于错误的-单引号变形的字符型注入)
- [Less-4 GET-基于错误的-双引号字符型注入](#less-4-get-基于错误的-双引号字符型注入)
- [Less-5 GET-双注入-单引号字符型注入](#less-5-get-双注入-单引号字符型注入)
- [LESS-6 GET-双注入-双引号字符型注入](#less-6-get-双注入-双引号字符型注入)
- [LESS-7 GET-导出文件-字符型注入](#less-7-get-导出文件-字符型注入)
- [LESS-8 GET-布尔盲注-单引号字符型注入](#less-8-get-布尔盲注-单引号字符型注入)
- [LESS-9 GET-基于时间的盲注-单引号字符型注入](#less-9-get-基于时间的盲注-单引号字符型注入)
- [LESS-10 GET-基于时间的盲注-双引号字符型注入](#less-10-get-基于时间的盲注-双引号字符型注入)

<!-- /TOC -->
<!--more-->

# Less-1 GET-基于错误的-单引号-字符型注入
进门提示输入id参数
![start](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.qh4fn20disr.png)
输入`?id=1`回显给了账号密码，id较多，没必要一个一个试，先看源码，翻一下sql语句
```php
<?php
//including the Mysql connect parameters.
include("../sql-connections/sql-connect.php");
error_reporting(0);//关闭所有PHP错误报告
// take the variables 
if(isset($_GET['id']))
{
$id=$_GET['id'];
//logging the connection parameters to a file for analysis.
$fp=fopen('result.txt','a');
fwrite($fp,'ID:'.$id."\n");
fclose($fp);

// connectivity 


$sql="SELECT * FROM users WHERE id='$id' LIMIT 0,1";
$result=mysql_query($sql);
$row = mysql_fetch_array($result);

	if($row)
	{
  	echo "<font size='5' color= '#99FF00'>";
  	echo 'Your Login name:'. $row['username'];
  	echo "<br>";
  	echo 'Your Password:' .$row['password'];
  	echo "</font>";
  	}
	else 
	{
	echo '<font color= "#FFFF00">';
	print_r(mysql_error());
	echo "</font>";  
	}
}
	else { echo "Please input the ID as parameter with numeric value";}

?>
```
脚本第一行导入了连接数据库的配置文件，抑制了错误回显，GET方法接受id参数，并将每次参数值存入result.txt文件中，之后开始sql查询，注意最后`id='$id'`为单引号闭合(一般数值类型的不去用单双引号包括，此处为lab需要)（sql语句不懂的建议先去学习一下MySQL的基础，只是基础就好）。那么如果我去手动闭合会怎么样，比如输入一个`?id=1'`，这在sql语句中就变成了`SELECT * FROM users WHERE id='1'' LIMIT 0,1`，出现了MySQL的报错，在MySQL里测试会让闭合后面的单引号才能继续执行，闭合后也就相当于`SELECT * FROM users WHERE id='1'' LIMIT 0,1;';`，后面引号的内容被丢掉了，没效果。
![less1_error](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.69fl2g4cmy4.png)
![less1_test](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.hn1lqmnbc5a.png)
>
- 在此解释一下输入`select 1,2,3;`MySQL干了什么\
它什么也没干，就是原样输出数组，这时它是个1行n列的表，表的属性名和值都是我们输入的数组，详细介绍可以看[这篇blog](https://blog.csdn.net/weixin_44840696/article/details/89166154)\

- MySQL的几个引号\
单双引号不必多嘴，就是括住字符串的\
反引号（esc下面那个键），它是为了区分MYSQL的保留字与普通字符而引入的符号。举个栗子：``SELECT `select` FROM `test` WHERE select='字段值'``。
在test表中，有个select字段，如果不用反引号，MYSQL将把select视为保留字而导致出错，所以，有MYSQL保留字作为字段的，必须加上反引号来区分。

- MySql的几个注释
  - `--` 单行注释，常用来注入时屏蔽查询后面的字符串，后面会说
  - `#` 单行注释，常用于post注入时的屏蔽，get时用无效，因为浏览器解析url时会将`#`当成锚点不予传输给服务器
  - `/**/` 多行注释，常用于绕过空格的过滤，即用`/**/`代替空格

那我们要怎么查询其他表的内容呢？我们知道，查内容需要知道表名、列名，才可以select，在MySQL5.5以上的版本引入了information_schema库，information_schema这个数据库中保存了MySQL服务器所有数据库的信息，我们一般用其中的`tables`来获取当前数据库的所有表名。还不明白？动手实践一下。`TABLE_SCHEMA`代表数据库，`TABLE_NAME`代表数据库中的表
![information_schema.tables](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.iaob8fwvw2.png)
使用`select TABLE_SCHEMA, TABLE_NAME from information_schema.tables;`可以查询所有数据库及表，自己实践一下。在注入时常用`select table_name from information_schema.tables where table_schema=database();`
![information_schema.tables](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.b7af64mw44.png)
此时将此语句带入到url里，例如这样`?id=-1' union select 1,table_name,3 from information_schema.tables where table_schema=database()--+`
![Less1_huixian](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.dzfbttb9194.png)
>
- 什么是union\
MySQL UNION 操作符用于连接两个以上的 SELECT 语句的结果组合到一个结果集合中。多个 SELECT 语句会删除重复的数据。--[菜鸟教程](https://www.runoob.com/mysql/mysql-union-operation.html)

- id的值为何是-1\
不让id为1的原因就是想让前面的select查询为空，不然union链接的后面select会被前面吃掉，看一下第一关的源码可以知道，查询数据后只进行了一次取数据，而前面不置空的话会出现两条数据导致第二条我们要的数据显示不出来
![Less1_id](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.mrykeg0t73.png)

可以发现，我们在MySQL查询的表不止一张，为什么回显就给了第一个表呢？这也是因为查询数据后只进行了一次取数据，也就只会取出第一张表的记录，这时候可以用`group_concat()`函数，此函数就是做连接字符串使用的，如果查询数据有多条，可以使用这个函数将其归为一条数据。也可以用`concat()`来连接，不过`group_concat()`会连接所有非 NULL 的字符串
![Less1_group_concat()](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.recqr7vg5vd.png)
所以可以将payload改为:`?id=-1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+`
![Less1_payload](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.yczpw3jwgj7.png)
ok，你大概也知道了怎么用注入的方法去查当前数据库里的所有表名，回头再看一下注入语句，为何使用了`select 1,xx,3 from xx where xx`？为什么不能直接`select xx from xx where xx`？这牵涉到回显的问题，在输入不同的id值时返回不同的数据，这个数据所在的地方就是回显，这个数据也不是随意输入的，需要先找这个表有多少列，然后再判断回显，如果union列数不同会怎样？
![Less1_diff_columns](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.eqke29fimo.png)
判断列数用order by



# Less-2 GET-基于错误的-数字型

# Less-3 GET-基于错误的-单引号变形的字符型注入

# Less-4 GET-基于错误的-双引号字符型注入

# Less-5 GET-双注入-单引号字符型注入

# LESS-6 GET-双注入-双引号字符型注入

# LESS-7 GET-导出文件-字符型注入

# LESS-8 GET-布尔盲注-单引号字符型注入

# LESS-9 GET-基于时间的盲注-单引号字符型注入

# LESS-10 GET-基于时间的盲注-双引号字符型注入