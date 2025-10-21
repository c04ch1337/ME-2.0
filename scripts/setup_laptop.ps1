Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { winget install Git.Git }
git clone https://github.com/chatrouter/chatrouter; cd chatrouter; npm install; cd ..
git clone https://github.com/usestrix/strix; cd strix; pip install -r requirements.txt; cd ..
git clone https://github.com/Factory-AI/factory; cd factory; pip install -r requirements.txt; cd ..
git clone https://github.com/bolna-ai/bolna; cd bolna; pip install -r requirements.txt; cd ..
Write-Output "Setup done. Edit .env, run compose."