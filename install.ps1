# cloro for Claude SEO: installer (Windows / PowerShell).
# Mirrors install.sh. Claude SEO's own files are not changed.
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw "Python 3 required" }

$SkillDir = Join-Path $HOME ".claude/skills"
# MCP servers live in ~/.claude.json (the file `claude mcp add` writes).
# NOT ~/.claude/settings.json - `mcpServers` is not a key Claude Code reads
# there, so entries written to settings.json silently never load.
$McpConfigJson = Join-Path $HOME ".claude.json"

Write-Host "Get a key at https://dashboard.cloro.dev/api-keys"
Write-Host "The Free plan includes 500 credits a month."
$Key = Read-Host "cloro API key" -AsSecureString
$Plain = [System.Net.NetworkCredential]::new("", $Key).Password
if (-not $Plain) { throw "No key provided." }

# Python writes ~/.claude.json: Windows PowerShell 5.1 ConvertFrom-Json rejects
# valid JSON whose keys differ only in case, which ~/.claude.json can contain.
$py = @"
import json, os, sys, tempfile
path, key = sys.argv[1], os.environ['CLAUDE_SEO_SECRET']
data = {}
if os.path.exists(path):
    try:
        with open(path, encoding='utf-8') as fh: data = json.load(fh)
    except ValueError: sys.exit('x ' + path + ' is not valid JSON. Nothing was changed; fix it and rerun.')
if not isinstance(data, dict) or not isinstance(data.get('mcpServers', {}), dict):
    sys.exit('x ' + path + ' has an unexpected shape. Nothing was changed; fix it and rerun.')
data.setdefault('mcpServers', {})['cloro'] = {
    'type': 'http',
    'url': 'https://mcp.cloro.dev/mcp',
    'headers': {'Authorization': 'Bearer ' + key},
}
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or '.', prefix='.settings.', suffix='.json')
with os.fdopen(fd, 'w', encoding='utf-8') as fh: json.dump(data, fh, indent=2)
os.replace(tmp, path)
print('Wrote mcpServers.cloro to ' + path)
"@
$env:CLAUDE_SEO_SECRET = $Plain
try {
    $py | python - $McpConfigJson
    # A native command's non-zero exit does not throw, even with Stop.
    if ($LASTEXITCODE -ne 0) { throw "Nothing was saved (python exited $LASTEXITCODE). See the message above." }
} finally { Remove-Item Env:CLAUDE_SEO_SECRET -ErrorAction SilentlyContinue }

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillTarget = Join-Path $SkillDir "seo-cloro"
New-Item -ItemType Directory -Path $SkillTarget -Force | Out-Null
Copy-Item -Path (Join-Path $SourceDir "skills/seo-cloro/SKILL.md") `
          -Destination (Join-Path $SkillTarget "SKILL.md") -Force
Write-Host "[OK] Installed skill: $SkillTarget"

Write-Host ""
Write-Host "Done. Open a new Claude Code session and run /seo-cloro visibility <prompt> <brand>."
