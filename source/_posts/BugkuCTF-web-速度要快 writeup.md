---
title: BugkuCTF-web-速度要快 writeup
date: 2019-09-29 21:04:02
tags: CTF WEB
categories: CTF做题记录
---

>脚本能力+0.001
>POST快速反弹
>另：[bugku 秋名山车神](https://blog.csdn.net/weixin_43578492/article/details/101701339)
<!--more-->
---
## 题目描述
[题目](http://123.206.87.240:8002/web6/)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929175744255.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)

---
看看源码，让我们POST一个参数：`margin`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929175929868.png)
提交啥内容呢？看看响应头
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929180043644.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
flag是个base64，解码，发现还是一个base64，自己做题时多试几遍才会知道
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929180727826.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
再次解码，hackbar提交试试
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929180812489.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
那就上脚本呗，不过在试flag时发现每次刷新都会产生新的flag，所以要用==session==对象会话保持同一个flag
```python
import requests	//引入requests库
import base64	//引入base64库

url = '''http://123.206.87.240:8002/web6/'''
s = requests.session()	//保持会话
hader = s.get(url).headers	//提取响应头的flag参数
key = base64.b64decode(base64.b64decode(hader['flag']).decode().split(':')[1])	//两次base64解码，split以冒号分隔并提取第二个字符串
post = {'margin':key}
print(s.post(url, post).text)
```
- 为什么第七行还要用一次decode()？
- 因为b64encode和b64decode接收参数为bytes或ascii码字符串，返回值为bytes。不用一次decode会导致输出时为`b'xxx'`
	字符串和bytes互相转换有encode和decode方法，默认编码为utf-8。
提交得到flag
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929182207991.png)
---
### 骚思路
既然每次返回头的flag都不一样，那么它cookie也不一样喽，看看haders吧
```python
import requests
import base64

url = '''http://123.206.87.240:8002/web6/'''
get_response = requests.get(url)
print("GET request headers:\n", get_response.request.headers)
print("GET response headers:\n", get_response.headers)

key = base64.b64decode(base64.b64decode(get_response.headers['flag']).decode().split(':')[1])
post = {'margin':key}
post_response = requests.post(url, data = post)
print("POST request headers:\n", post_response.request.headers)
print("POST response headers:\n", post_response.headers)
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929201638594.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
可以看到cookies并不一样，所以我们在提交post的时候再加上一个cookie的值就好啦，但事实真的是这样吗？我们看看加了session会话后的headers是什么样的
```python
import requests
import base64

url = '''http://123.206.87.240:8002/web6/'''
s = requests.session()
get_response = s.get(url)
print("GET request headers:\n", get_response.request.headers)
print("GET response headers:\n", get_response.headers)

key = base64.b64decode(base64.b64decode(get_response.headers['flag']).decode().split(':')[1])
post = {'margin':key}
post_response = s.post(url, data = post)
print("POST request headers:\n", post_response.request.headers)
print("POST response headers:\n", post_response.headers)
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929202950511.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3ODQ5Mg==,size_16,color_FFFFFF,t_70)
确实，加了session的会话后在post的请求头上确实加上了同一个cookie
那么上最终脚本
```python
import requests
import base64

url = '''http://123.206.87.240:8002/web6/'''
header = requests.get(url).headers

key = base64.b64decode(base64.b64decode(header['flag']).decode().split(':')[1])
phpsessid = header['Set-Cookie'].split(';')[0].split('=')[1]
post = {'margin':key}
cookie = {'PHPSESSID':phpsessid}
print(requests.post(url, data = post, cookies = cookie).text)
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190929210241126.png)

---
[参考博客](https://ciphersaw.me/2017/12/16/%E8%AF%A6%E8%A7%A3%20CTF%20Web%20%E4%B8%AD%E7%9A%84%E5%BF%AB%E9%80%9F%E5%8F%8D%E5%BC%B9%20POST%20%E8%AF%B7%E6%B1%82/)
