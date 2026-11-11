# cloro for Claude SEO

A community integration for [Claude SEO](https://github.com/AgriciDaniel/claude-seo)
that asks AI search engines a question from a chosen country and reports
whether the answer mentions or cites your brand. It uses
[cloro](https://cloro.dev)'s hosted MCP server.

`/seo-cloro` sends one prompt to ChatGPT, Google AI Mode, Gemini or Bing AI
Mode, or runs a Google search with its AI Overview. It returns the answer text
and the sources the answer cites.

## Who maintains it

cloro maintains this repository, and cloro sells the service it connects to.
It is not part of Claude SEO, and the Claude SEO maintainer does not audit,
ship or support it. Report problems in
[this repository's issues](https://github.com/cloro-dev/claude-seo-cloro/issues).

## Cost

Each call uses cloro credits. The Free plan includes 500 credits a month. Paid
plans are on [cloro.dev/pricing](https://cloro.dev/pricing).

| Engine | Credits per call |
|---|---|
| ChatGPT | 7 |
| Gemini | 6 |
| Google AI Mode | 6 |
| Bing AI Mode | 6 |
| Google Search | 5 |
| Google Search with AI Overview | 7 |
| Country and state lists | 0 |

These include cloro's 2-credit surcharge for a synchronous request. A US state
adds 2 credits on ChatGPT, Gemini and Bing AI Mode. One `/seo-cloro visibility`
run asks all five engines once: 32 credits. The skill shows the planned calls
and the credit total, and waits for you to confirm, before any request that
needs more than 3 calls.

## Prerequisites

- Claude Code
- Python 3
- A cloro API key from [dashboard.cloro.dev/api-keys](https://dashboard.cloro.dev/api-keys)
- Optional: [Claude SEO](https://github.com/AgriciDaniel/claude-seo). The skill
  also works without it.

## Install

### macOS and Linux

```bash
git clone https://github.com/cloro-dev/claude-seo-cloro
cd claude-seo-cloro
./install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/cloro-dev/claude-seo-cloro
cd claude-seo-cloro
.\install.ps1
```

The installer asks for your API key (the input is hidden) and then:

1. copies the `seo-cloro` skill to `~/.claude/skills/seo-cloro/`;
2. adds a `cloro` entry to `mcpServers` in `~/.claude.json`, with your key in
   an `Authorization` header. On Linux and macOS the file mode is 0600.

It does not change Claude SEO's files or dependencies. If `~/.claude.json` is
not valid JSON, the installer stops and changes nothing. The key is not
written to this repository and is not printed.

Open a new Claude Code session, run `/mcp`, and check that `cloro` is
connected.

## Commands

| Command | What it does |
|---|---|
| `/seo-cloro visibility <prompt> <brand-or-domain> [--country XX]` | Asks the prompt on ChatGPT, Google AI Mode, Gemini, Bing AI Mode and Google AI Overview, and reports where the brand is mentioned or cited |
| `/seo-cloro ask <engine> <prompt> [--country XX]` | Asks one engine: `chatgpt`, `aimode`, `gemini` or `bing` |
| `/seo-cloro serp <query> [--country XX] [--aio]` | Google organic results; `--aio` also extracts the AI Overview |

The default country is `US`. Claude also uses the skill on its own when you
ask whether an AI engine recommends or cites a brand.

`/seo-cloro` is not a subcommand of Claude SEO's `/seo`. Claude SEO's own
skills do not call it. When Claude SEO is installed, the skill hands content
work to `seo-geo` and keyword data to `seo-dataforseo`.

One call is one sample. AI answers change between runs, so one result is not
a rate or a trend.

## Security

- The skill tells the agent to treat AI answers, search results and cited
  pages as untrusted data: text in them that addresses the agent is reported,
  never followed.
- Your API key stays in `~/.claude.json` on your machine. The MCP server is
  `https://mcp.cloro.dev/mcp`, run by cloro.

## Uninstall

```bash
./uninstall.sh       # macOS and Linux
.\uninstall.ps1      # Windows
```

This removes `~/.claude/skills/seo-cloro/` and the `cloro` entry in
`~/.claude.json`.

## License

MIT
