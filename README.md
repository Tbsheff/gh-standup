# gh standup

A terminal standup report that pulls your GitHub activity and generates an AI-condensed Yesterday/Today/Blockers summary.

## Install

```bash
gh extension install Tbsheff/gh-standup
```

### Requirements

- [`gh`](https://cli.github.com/) — GitHub CLI, authenticated via `gh auth login`
- [`jq`](https://jqlang.github.io/jq/download/) — JSON processor

```bash
brew install gh jq
```

## Usage

```bash
gh standup                        # auto-detects your GitHub org
gh standup --org mycompany        # specify org
gh standup --no-summary           # skip AI summary
gh standup --style minimal        # compact output
```

## What it shows

- **Shipped** — PRs you merged today + yesterday, grouped by repo
- **Open** — Non-draft PRs in progress, with APPROVED/CHANGES status
- **Drafts** — Collapsed into one line per group
- **Reviews** — PRs where your review is requested
- **Linear issues** — Open issues assigned to you (optional)
- **AI summary** — Yesterday/Today/Blockers bullets condensed from your PR data

## AI Summary

The summary uses [Fireworks](https://fireworks.ai/) with Kimi K2.5 to condense your PR titles into a standup you can paste into Slack. Set `FIREWORKS_API_KEY` to enable it.

Alternatively, use `--provider claude` if you have the Claude CLI installed.

Without an API key, pass `--no-summary` — the PR report works standalone.

## Configuration

| Env Variable | CLI Flag | Default | Description |
|---|---|---|---|
| `STANDUP_ORG` | `--org` | auto-detected | GitHub org to search |
| `STANDUP_STYLE` | `--style` | `box` | Style: box, colorful, table, minimal |
| `STANDUP_SUMMARY` | `--no-summary` | on | AI summary generation |
| `STANDUP_SUMMARY_PROVIDER` | `--provider` | `fireworks` | AI provider: fireworks or claude |
| `STANDUP_SUMMARY_MODEL` | `--model` | `kimi-k2p5-turbo` | Fireworks model ID |
| `FIREWORKS_API_KEY` | — | — | Required for Fireworks AI summaries |
| `LINEAR_RECENCY_DAYS` | — | `30` | Linear issue lookback |
| `STANDUP_NO_HYPERLINKS` | — | off | Disable clickable terminal links |

## How it works

1. **4 parallel GraphQL queries** fetch merged PRs, open PRs, review requests, and Linear issues
2. **Rendering** groups by repo with Shipped/Open/Draft sections and action items banner
3. **AI summary** pre-formats a standup draft from the data, sends it to the model to condense, and parses structured JSON for reliable rendering

## License

MIT
