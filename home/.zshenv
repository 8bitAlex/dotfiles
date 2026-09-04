# Environment every zsh needs, interactive or not.
#
# .zshenv is sourced by *every* zsh invocation -- login, interactive, script,
# and the one-shot shells GUI apps spawn -- and it runs before .zshrc. Anything
# a non-interactive consumer has to see belongs here, not in .zshrc, where an
# early `exec` or an interactive-only guard can strand it.

# Claude Code keeps its config under ~/.claude rather than the default
# ~/.claude.json. Terminal sessions and the VS Code extension have to agree on
# this or they end up with two configs -- separate MCP server lists, separate
# project trust, separate history.
export CLAUDE_CONFIG_DIR="$HOME/.claude"
