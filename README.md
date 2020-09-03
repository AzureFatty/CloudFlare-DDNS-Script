# CloudFlare-DDNS-Script
CloudFlare 动态域名服务脚本，支持IPv4&IPv6

支持LEDE/OPENWRT，需要安装ca-bundle curl jq(`opkg install ca-bundle curl jq`)

**或者手动指定jq路径 [jq](https://stedolan.github.io/jq/download/) 工具，请在 [https://stedolan.github.io/jq/download/](https://stedolan.github.io/jq/download/) 下载适合自己的版本。**

**LEDE/OPENWRT 某些版本使用 `opkg install jq` 之后运行脚本出问题的情况，也可以尝试手动指定**

```bash
#LEDE/Openwrt may need install ca-bundle curl(opkg install ca-bundle curl)

#Add you custom record to the CloudFlare first.

#Your sub domain
SUB_DOMAIN="sub.example.com"
#dash --> example.com --> Overview --> Zone ID:
#https://dash.cloudflare.com/_your_account_id_/example.com
ZONE_ID="5d41402abc4b2a76b9719d911017c592"
#API Tokens
#https://dash.cloudflare.com/profile/api-tokens
#Manage access and permissions for your accounts, sites, and products
#example.com- Zone:Read, DNS:Edit
TOKEN_ID="7d793037a076018657-_rZiTa4-f5xIgEvXxHNv"
#The path of jq binaries . Download from https://stedolan.github.io/jq/download/
#If the system has installed jq. Just typed jq.
#If you custom a special binary. Just typed the path of jq.
JQ_PATH="jq"
```
| 参数       | 含义                                                         |
| ---------- | ------------------------------------------------------------ |
| SUB_DOMAIN | 待用的子域名                                                 |
| ZONE_ID    | 待使用域名概览页面的Zone ID值                                |
| TOKEN_ID   | https://dash.cloudflare.com/profile/api-tokens 页面的令牌（建议细分权限 example.com- Zone:Read, DNS:Edit） |
| JQ_PATH    | jq工具路径，LEDE/OPENWRT通过opkg安装的，则直接填写jq即可     |

### 注意事项

- 使用脚本前，请先修改上述字段所对应的正确的值；

- 请提前在CloudFlare控制台添加好相对应的纪录，本脚本只做更新，不做增加功能；
- 如果想同时支持IPv4&IPv6，则需要在CloudFlare控制台添加两条纪录，一条Type为A，一条Type为AAAA；

## License

    Copyright 2020, Engineer Zhou
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
