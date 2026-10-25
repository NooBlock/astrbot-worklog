# appendix/ — 原始交付文档（已脱敏）

工作区里原本生成的三份技术交付文档，保留在这里作为工作日记的原始依据：

| 文件 | 原文 | 内容 |
| --- | --- | --- |
| [`AstrBot-安装报告.md`](AstrBot-安装报告.md) | `AstrBot-安装报告.md` | AstrBot Launcher / Python / Node / uv 的安装与验证、pip 403 修复、磁盘清理 |
| [`SNOWLUMA-DEPLOY.md`](SNOWLUMA-DEPLOY.md) | `SNOWLUMA-DEPLOY.md` | SnowLuma v2.2.0 部署、QQ hook、OneBot 端口与 AstrBot 对接、完整性标签坑 |
| [`AstrBot-DEPLOY-NOTES.md`](AstrBot-DEPLOY-NOTES.md) | `astrbot/DEPLOY-NOTES.md` | AstrBot v4.29.3 部署、uv sync、WebUI、OneBot v11 鉴权、沙箱坑 |

脱敏规则：

- 所有 WebUI 密码、OneBot access token、JWT secret、API Key → `<REDACTED_*>`；
- QQ 号 → `<QQ_UIN_*>`，QQ 昵称 → `<QQ_NICKNAME>`；
- 用户目录 `C:\Users\A` → `C:\Users\<USER>`；
- 工作区路径 `D:\deepseek bot project` → `<WORKSPACE>`，SnowLuma 目录 → `<SNOWLUMA_DIR>`。

原文里的时间、命令、报错与结论均未改动。
