# alfred-openurl-workflow

## 几个命令
```
udef 配置名 网址
    指定配置名对应该网址
    网址中可以使用{param_name}做动态参数
uopen 配置名
    打开指定配置名对应的网址
    这里的配置名，支持正则表达式
uopen 配置名 param_name=xxx
    打开指定配置名对应的网址，替代配置名中对应的动态参数
ucopy 配置名
    拷贝指定配置名对应的网址
```