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

## 将来Jev連携がClaude Codeの標準機能になった場合

このrepoは、Jev依存をClaude Codeのユーザー設定だけに閉じ込めています。
アプリケーションコードや各プロジェクトの`CLAUDE.md`にはJev依存を追加しません。

そのため、Claude Code側でJev連携が標準提供された場合は、次の手順だけでこの自作連携を切り離せます。

### macOS / Linux / WSL

```bash
./uninstall.sh
```

### Windows PowerShell

```powershell
.\uninstall.ps1
```

アンインストールで削除されるのは次の2点だけです。

- user scopeで登録したJev MCP
- `~/.claude/rules/jev.md`

以下は変更・削除されません。

- 各リポジトリのコード
- 各プロジェクトの`CLAUDE.md`
- `~/.claude/CLAUDE.md`
- その他のMCP設定
- その他の`~/.claude/rules/`配下のルール

削除後は、Claude Code標準のJev機能を有効化してください。
標準機能側で別の設定やルールが必要な場合は、その時点のClaude Code公式手順に従ってください。

### 手動で切り離す場合

スクリプトを使わない場合でも、次の2操作だけです。

```bash
claude mcp remove jev --scope user
rm ~/.claude/rules/jev.md
```

Windowsでは、MCP登録を削除した後に
`%USERPROFILE%\.claude\rules\jev.md`を削除してください。

## 設計方針

このrepoでは、Jevをプロジェクト固有の依存ではなく、**Claude Codeの実行時拡張**として扱います。

```text
Claude Code
  ├─ user-scope MCP: Jev
  └─ ~/.claude/rules/jev.md
          ↓
      各プロジェクト
      （変更なし）
```

この構成にすることで、Jev MCPのURL変更、認証方式の変更、標準機能への移行、Jev自体の利用停止を、各プロジェクトから独立して行えます。

## 社内配布

このrepoをcloneして`config.env`のURLだけ設定すれば導入できます。
URLや認証方式が確定したら、社内向けブランチで`config.example.env`の初期値を更新してください。
