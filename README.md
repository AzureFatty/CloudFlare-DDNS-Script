# CloudFlare-DDNS-Script
CloudFlare 动态域名服务脚本

支持LEDE/OPENWRT，可能需要安装ca-bundle curl(`opkg install ca-bundle curl`)

**依赖 [jq](https://stedolan.github.io/jq/download/) 工具，请在 [https://stedolan.github.io/jq/download/](https://stedolan.github.io/jq/download/) 下载适合自己的版本。**

```bash
#LEDE/Openwrt may need install ca-bundle(opkg install ca-bundle)

#Your domain
DOMAIN="example.com"
#Your sub domain
SUB_DOMAIN="sub.example.com"
#Yor account
AUTH_EMAIL="Your account"
#Your auth key:https://www.cloudflare.com/a/profile --> Global API Key
AUTH_KEY="8b1a9953c4611296a827abf8c47804d7"
#The path of jq binaries . Download from https://stedolan.github.io/jq/download/ 
JQ_PATH="./jq-linux64"
#[Optional]https://www.cloudflare.com/a/overview/example.com --> Zone ID:
DNS_ZONE_ID=""
```
| 参数          | 含义                       |
| ----------- | ------------------------ |
| DOMAIN      | 域名                       |
| SUB_DOMAIN  | 待用的子域名                   |
| AUTH_EMAIL  | CloudFlare登录账号           |
| AUTH_KEY    | Global API Key           |
| JQ_PATH     | jq工具路径                   |
| DNS_ZONE_ID | 域名Zone ID，可以不填写，不填写会自动获取 |

## License

    Copyright 2018, Engineer Zhou

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
