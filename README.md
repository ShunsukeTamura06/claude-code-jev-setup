# claude-code-jev-setup

Claude CodeへJev MCPを**ユーザーグローバル**で導入するための小さなセットアップrepoです。
各プロジェクトの`CLAUDE.md`は変更しません。

導入すると次の2点だけがユーザー環境へ追加されます。

1. Jev MCPを`--scope user`で登録
2. `~/.claude/rules/jev.md`へJev専用ルールを配置

そのため、将来Claude Code側でJev連携が標準化された場合も簡単に削除できます。

## セットアップ

### macOS / Linux / WSL

```bash
cp config.example.env config.env
# config.env の JEV_MCP_URL を社内環境のURLに変更
./install.sh
```

### Windows PowerShell

```powershell
Copy-Item config.example.env config.env
# config.env の JEV_MCP_URL を編集
.\install.ps1
```

## 設定例

```env
JEV_MCP_URL=http://your-internal-host:8000/mcp
JEV_MCP_NAME=jev
JEV_MCP_HEADER=
```

認証ヘッダーを使う場合:

```env
JEV_MCP_HEADER=Authorization: Bearer REPLACE_ME
```

`config.env`は`.gitignore`対象です。

## 確認

```bash
claude mcp list
```

Claude Code内では `/mcp` でも確認できます。

## 削除

macOS / Linux / WSL:

```bash
./uninstall.sh
```

Windows:

```powershell
.\uninstall.ps1
```

これでJev MCP登録と`~/.claude/rules/jev.md`だけを削除します。
既存のプロジェクト`CLAUDE.md`やユーザー`~/.claude/CLAUDE.md`には触れません。

## 社内配布

このrepoをcloneして`config.env`のURLだけ設定すれば導入できます。
URLや認証方式が確定したら、社内向けブランチで`config.example.env`の初期値を更新してください。
