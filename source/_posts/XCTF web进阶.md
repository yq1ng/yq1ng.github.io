---
title: XCTF web进阶
date: 2020-10-30 23:09:11
categories: CTF做题记录
---

<!-- TOC -->

- [web2](#web2)

<!-- /TOC -->

<!--more-->
# web2
```php
<?php
$miwen="a1zLbgQsCESEIqRLwuQAyMwLyq2L5VwBxqGA3RQAyumZ0tmMvSGM2ZwB4tws";

function encode($str){
    $_o=strrev($str); // 反转字符串
    // echo $_o;
        
    for($_0=0;$_0<strlen($_o);$_0++){ // 对每一位都进行操作
       
        $_c=substr($_o,$_0,1); // _c=反转后的miwen的第i位
        $__=ord($_c)+1; // __=_c的ascii值+1
        $_c=chr($__); // _c=__对应的字符
        $_=$_.$_c; // 把_c存起来
    } 
    // 把上述编码结果依次进行base64、反转、str_rot13编码
    return str_rot13(strrev(base64_encode($_)));
}

highlight_file(__FILE__);
/*
   逆向加密算法，解密$miwen就是flag
*/
?>
```
```php
<?php
$miwen="a1zLbgQsCESEIqRLwuQAyMwLyq2L5VwBxqGA3RQAyumZ0tmMvSGM2ZwB4tws";
function decode($cipher){
	$cipher=base64_decode(strrev(str_rot13($cipher)));
	
	for($i=0;$i<strlen($cipher);$i++){
		$x=substr($cipher,$i,1);
		$x_=ord($x)-1;
		$x=chr($x_);
		$text=$text.$x;
	}
	return strrev($text);
}

echo decode($miwen);
?>
```