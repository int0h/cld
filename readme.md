# CLD

> ⚠️ **Disclaimer**
> This project is a **proof of concept**. It is not a complete or hardened security solution and does **not** cover all possible attack vectors. It is simply a step toward safer autonomous coding workflows.

## Overview
CLD provides a minimal security layer for autonomous coding agents by running **Claude Code** inside a Docker container.

It addresses a common workflow vulnerability: even when command execution is restricted (e.g. only allowing `npm test`), malicious code can still be injected into source or test files and executed indirectly.

## Problem

### Manual Approval Mode
In this mode, the agent can read files, but every modification or command must be explicitly approved or executed manually.
This approach is relatively safe, but it significantly slows down development and makes the workflow highly interactive and tedious.

### Autonomous Mode with Whitelisting
This mode allows the agent to operate more independently by whitelisting certain commands (e.g. `npm test`).
While this *appears* safe, it is misleading: the agent can inject malicious code into source or test files, which then gets executed indirectly through allowed commands. This effectively bypasses the whitelist and enables arbitrary code execution on the host.

Even with strict whitelisting, agents can:
- Inject arbitrary code into source/tests
- Execute system commands indirectly (e.g. via `child_process.exec`)
- Modify hidden areas (`node_modules`, `.git`)
- Access or leak sensitive files

## Solution
CLD runs the **entire Claude Code environment inside a Docker container** and enforces additional constraints:

### 1. Full Environment Isolation
- Claude Code itself runs inside the container (not just individual commands)
- Prevents any direct execution on the host machine

### 2. Controlled Filesystem Access
- Project directory is mounted as a workspace
- Sensitive areas are overlaid:
  - `.git` → read-only
  - `node_modules` → read-only

This prevents:
- Hidden persistence outside visible code changes
- Unauthorized git operations (e.g. hooks, commits)
- Silent dependency tampering

### 3. Secret Protection
- Configurable ignore-like file (similar to `.gitignore`)
- Marked paths are replaced with placeholder content inside the container
- Prevents accidental secret exposure to the agent

## Security Goals
- No arbitrary code execution on host
- No hidden persistence outside reviewed changes
- No modification of critical directories
- Reduced risk of secret exfiltration

## Limitations
- Proof of concept
- Not a complete sandbox or hardened security solution
- Requires manual inspection of changes
- Does not prevent all possible attack vectors

## Requirements
- Docker installed and running
- Bash environment

## Usage
There is no formal installation.

Typical setup:
```bash
# Clone repository
git clone https://github.com/int0h/cld.git

# Add scripts to PATH manually
export PATH="$PATH:/path/to/cld-repo"

# Run Claude Code inside the sandbox
cld
```