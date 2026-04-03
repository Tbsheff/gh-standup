# standup-report

A terminal standup report that pulls your GitHub activity and generates an AI-condensed summary you can paste into Slack.

```
standup-report --org mycompany
```

![standup-report demo](https://github.com/user-attachments/assets/placeholder.png)

## What it does

- **Shipped PRs** — PRs you merged today + yesterday (cross-repo, org-scoped)
- **Open PRs** — Non-draft PRs still in progress, with review status (APPROVED/CHANGES)
- **Draft collapsing** — Groups duplicate-title draft PRs into one line
- **Reviews needed** — PRs where your review is requested
- **Linear issues** — Open issues assigned to you (optional, if Linear CLI installed)
- **AI summary** — Condenses everything into Yesterday/Today/Blockers bullet points

All data fetched in parallel via GitHub GraphQL. AI summary via Fireworks (Kimi K2.5) or Claude CLI.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Tbsheff/standup-report/main/install.sh | bash
```

Or manually:

```bash
curl -fsSL https://raw.githubusercontent.com/Tbsheff/standup-report/main/standup-report -o ~/.local/bin/standup-report
chmod +x ~/.local/bin/standup-report
```

### Requirements

- **`gh`** — GitHub CLI ([install](https://cli.github.com/)), authenticated via `gh auth login`
- **`jq`** — JSON processor ([install](https://jqlang.github.io/jq/download/))

### Optional

- **`FIREWORKS_API_KEY`** — For AI summaries via [Fireworks](https://fireworks.ai/) (uses Kimi K2.5 turbo)
- **`claude`** — Claude CLI as an alternative AI summary provider (`--provider claude`)
- **`linear`** — [Linear CLI](https://github.com/linear/linear-cli) for issue tracking integration

## Usage

```bash
# Auto-detect your GitHub org
standup-report

# Specify org explicitly
standup-report --org mycompany

# Skip AI summary (faster, no API key needed)
standup-report --no-summary

# Different rendering styles
standup-report --style minimal
standup-report --style colorful
standup-report --style table
```

### Shell alias

```bash
# Bash/Zsh
alias standup='standup-report'

# Fish
alias standup 'standup-report'
```

## Configuration

All settings can be set via environment variables or CLI flags.

| Env Variable | CLI Flag | Default | Description |
|---|---|---|---|
| `STANDUP_ORG` | `--org` | auto-detected | GitHub org to search PRs in |
| `STANDUP_STYLE` | `--style` | `box` | Rendering style: box, colorful, table, minimal |
| `STANDUP_SUMMARY` | `--summary`/`--no-summary` | `1` (on) | AI summary generation |
| `STANDUP_SUMMARY_MODEL` | `--model` | `kimi-k2p5-turbo` | Fireworks model for summaries |
| `STANDUP_SUMMARY_PROVIDER` | `--provider` | `fireworks` | AI provider: fireworks or claude |
| `LINEAR_RECENCY_DAYS` | — | `30` | Days to look back for Linear issues |
| `STANDUP_NO_HYPERLINKS` | — | `0` | Set to `1` to disable clickable terminal links |
| `FIREWORKS_API_KEY` | — | — | Required for Fireworks AI summaries |

## How it works

1. **4 parallel GraphQL queries** fetch merged PRs, open PRs, review requests, and Linear issues
2. **Rendering** groups PRs by repo, separates Shipped/Open/Draft sections
3. **AI summary** pre-formats a draft standup from the data, sends it to the model to condense similar items into themed bullets, and extracts structured JSON for reliable rendering

The AI summary uses Fireworks' Anthropic-compatible API with explicit thinking separation, so reasoning tokens don't leak into the output.

## License

MIT
