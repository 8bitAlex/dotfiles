#!/bin/sh
# Reorder the tmux status lines so the muted keybinding cheatsheet sits ABOVE
# oh-my-tmux's colourful main bar.
#
# tmux draws status-format[0] as the TOP line of the status group and higher
# indices nearer the anchored (bottom) edge. So to keep the main bar pinned to
# the bottom with the cheatsheet above it, the main bar must live on line [1]
# and the cheatsheet on line [0].
#
# oh-my-tmux never sets status-format itself — its bar renders from tmux's
# default status-format[0] template (which pulls in status-left / window-list /
# status-right). We copy that template onto line [1], then claim line [0].
#
# Invoked from ~/.config/tmux/tmux.conf.local via run-shell.

main=$(tmux show -gv 'status-format[0]' 2>/dev/null)
[ -n "$main" ] || main='#[align=left]#{T;=/#{status-left-length}:status-left}#[list=on align=#{status-justify}]#{W:#{T:window-status-format}#{window-status-separator},#{T:window-status-current-format}#{window-status-separator}}#[nolist align=right]#{T;=/#{status-right-length}:status-right}'

tmux set -g 'status-format[1]' "$main"
tmux set -g 'status-format[0]' '#[align=centre,fill=#3c3836,bg=#3c3836,fg=#928374]#[fg=#fe8019]prefix#[fg=#928374]   #[fg=#d79921]-#[fg=#928374] split↓   #[fg=#d79921]_#[fg=#928374] split→   #[fg=#d79921]c#[fg=#928374] new-win   #[fg=#d79921]x#[fg=#928374] kill-pane   #[fg=#d79921]&#[fg=#928374] kill-win   #[fg=#d79921]hjkl#[fg=#928374] move   #[fg=#d79921]HJKL#[fg=#928374] resize   #[fg=#d79921]z#[fg=#928374] zoom   #[fg=#d79921]Space#[fg=#928374] arrange   #[fg=#d79921]q#[fg=#928374] pick   #[fg=#d79921]Tab#[fg=#928374] last   #[fg=#d79921]d#[fg=#928374] detach'
tmux set -g status 2
