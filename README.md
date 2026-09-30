# claude-code-jev-setup

Claude CodeへJev MCPを**ユーザーグローバル**で導入するためのセットアップツールです。

各プロジェクトの`CLAUDE.md`を変更せず、Jev連携をClaude Codeのユーザー設定として独立して追加します。

導入されるのは次の2点だけです。

1. Jev MCPを`--scope user`で登録
2. `~/.claude/rules/jev.md`へJev専用ルールを配置

そのため、既存プロジェクトへの影響を抑えつつ導入でき、将来Claude Code側でJev連携が標準提供された場合も簡単に切り離せます。

## Setup

### macOS / Linux / WSL

```bash
git clone https://github.com/ShunsukeTamura06/claude-code-jev-setup.git
cd claude-code-jev-setup

cp config.example.env config.env
# config.env の JEV_MCP_URL を利用するJev MCPのURLに変更
./install.sh
```

### Windows PowerShell

```powershell
git clone https://github.com/ShunsukeTamura06/claude-code-jev-setup.git
cd claude-code-jev-setup

Copy-Item config.example.env config.env
# config.env の JEV_MCP_URL を利用するJev MCPのURLに変更
.\install.ps1
```

## Configuration

```env
JEV_MCP_URL=http://your-jev-host:8000/mcp
JEV_MCP_NAME=jev
JEV_MCP_HEADER=
```

認証ヘッダーを使う場合:

```env
JEV_MCP_HEADER=Authorization: Bearer REPLACE_ME
```

`config.env`は`.gitignore`対象です。

## Execution routing policy

このセットアップでは、Jevを「モデルを頻繁に切り替えるルーター」ではなく、**主にeffortを選ぶ軽量な実行ルーター**として扱います。

基本方針:

- 同一セッション内ではmodelを原則固定する
- Jevは主に `medium / high / max` などのeffortを選ぶ
- セッション途中でmodelを切り替えてprompt cacheを失う構成は避ける
- より強いmodelが本当に必要な場合は、現在のセッションを置き換えるのではなく、別workerとして起動する
- 別workerには会話履歴全体ではなく、必要なタスク・ファイル・制約・完了条件だけを渡す
- Jevの判断が無効・取得不能・低信頼なら、現在のmodelとホストのデフォルトeffortを使う

イメージ:

```text
current Claude session
        │
        ├─ Jev -> medium effort
        ├─ Jev -> high effort
        └─ Jev -> max effort

        必要な場合のみ

        └─ separate stronger worker
              └─ 必要な情報だけ渡す
```

この設計は、Jevのルーティング効果を得つつ、model切り替えによる不要なcontext再処理やcache missを抑えることを意図しています。

## What gets installed

```text
Claude Code
  ├─ user-scope MCP: Jev
  └─ ~/.claude/rules/jev.md
          ↓
      all projects
      (project files remain unchanged)
```

Jevはプロジェクト固有の依存ではなく、**Claude Codeの実行時拡張**として扱います。

この構成により、以下を各プロジェクトから独立して変更できます。

- Jev MCPのURL
- 認証方式
- Jev利用ルール
- Jev自体の有効化・無効化
- 将来の標準Jev連携への移行

## Verify

```bash
claude mcp list
```

Claude Code内では `/mcp` でも接続状況を確認できます。

## Uninstall

### macOS / Linux / WSL

```bash
./uninstall.sh
```

### Windows PowerShell

```powershell
.\uninstall.ps1
```

削除されるのは次の2点だけです。

- user scopeで登録したJev MCP
- `~/.claude/rules/jev.md`

以下は変更・削除されません。

- 各リポジトリのコード
- 各プロジェクトの`CLAUDE.md`
- `~/.claude/CLAUDE.md`
- その他のMCP設定
- その他の`~/.claude/rules/`配下のルール

## Migrating to native Jev support

将来Claude CodeがJev連携を標準機能として提供した場合、このセットアップはそのまま削除できます。

### 1. この連携を削除

macOS / Linux / WSL:

```bash
./uninstall.sh
```

Windows:

```powershell
.\uninstall.ps1
```

### 2. Claude Code標準のJev機能を有効化

その時点のClaude Code公式手順に従って標準機能を設定してください。

このリポジトリはアプリケーションコードやプロジェクトの`CLAUDE.md`にJev依存を追加しないため、コード変更や移行作業は不要です。

### Manual removal

スクリプトを使わず手動で削除する場合:

```bash
claude mcp remove jev --scope user
rm ~/.claude/rules/jev.md
```

WindowsではMCP登録を削除した後、

```text
%USERPROFILE%\.claude\rules\jev.md
```

を削除してください。

## Files

```text
.
├── README.md
├── config.example.env
├── install.sh
├── install.ps1
├── uninstall.sh
├── uninstall.ps1
└── rules/
    └── jev.md
```
