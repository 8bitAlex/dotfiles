#!/bin/sh
# Build a 3-line tmux status stack (top -> bottom):
#   [0] app-context cheatsheet  — switches on #{pane_current_command}
#                                 (vim, lazygit, k9s, htop, pager, ...)
#   [1] tmux prefix cheatsheet  — static
#   [2] oh-my-tmux main bar     — the colourful bar, pinned to the bottom edge
#
# tmux draws status-format[0] as the TOP line and higher indices toward the
# anchored (bottom) edge, so the main bar must live on the highest index.
#
# Reload-safe: the pristine main-bar template (tmux's default status-format[0])
# is stashed in @omt_main_format on first run. To find it we scan the current
# status-format lines for the first one that isn't a cheatsheet of ours — this
# also recovers it cleanly when upgrading a server that already had 2 lines.
#
# Adding an app: add one nested #{?#{==:#{pane_current_command},NAME},SHEET,...}.
#
# Invoked from ~/.config/tmux/tmux.conf.local via run-shell.

MARK='fill=#3c3836'   # marker present in our custom lines, never in tmux's default bar

orig=$(tmux show -gv '@omt_main_format' 2>/dev/null)
if [ -z "$orig" ]; then
  for idx in 0 1 2 3 4; do
    c=$(tmux show -gv "status-format[$idx]" 2>/dev/null)
    [ -z "$c" ] && continue
    case "$c" in *"$MARK"*) continue ;; esac   # one of our cheatsheet lines
    orig="$c"; break                            # first real (non-cheatsheet) template
  done
  [ -n "$orig" ] && tmux set -gq '@omt_main_format' "$orig"
fi
[ -n "$orig" ] || orig='#[align=left]#{T;=/#{status-left-length}:status-left}#[list=on align=#{status-justify}]#{W:#{T:window-status-format}#{window-status-separator},#{T:window-status-current-format}#{window-status-separator}}#[nolist align=right]#{T;=/#{status-right-length}:status-right}'

tmux set -g 'status-format[2]' "$orig"
tmux set -g 'status-format[1]' '#[align=centre,fill=#3c3836,bg=#3c3836,fg=#928374]#[fg=#fe8019]prefix#[fg=#928374]   #[fg=#d79921]-#[fg=#928374] split↓   #[fg=#d79921]_#[fg=#928374] split→   #[fg=#d79921]c#[fg=#928374] new-win   #[fg=#d79921]x#[fg=#928374] kill-pane   #[fg=#d79921]&#[fg=#928374] kill-win   #[fg=#d79921]hjkl#[fg=#928374] move   #[fg=#d79921]HJKL#[fg=#928374] resize   #[fg=#d79921]z#[fg=#928374] zoom   #[fg=#d79921]Space#[fg=#928374] arrange   #[fg=#d79921]q#[fg=#928374] pick   #[fg=#d79921]Tab#[fg=#928374] last   #[fg=#d79921]d#[fg=#928374] detach'
tmux set -g 'status-format[0]' '#[align=centre,fill=#3c3836,bg=#3c3836,fg=#928374]#{?#{m:*vim,#{pane_current_command}},#[fg=#8ec07c]VIM#[fg=#928374]   #[fg=#b8bb26]:w#[fg=#928374] write   #[fg=#b8bb26]:q#[fg=#928374] quit   #[fg=#b8bb26]:wq#[fg=#928374] save+quit   #[fg=#b8bb26]:q!#[fg=#928374] discard   #[fg=#b8bb26]dd#[fg=#928374] cut   #[fg=#b8bb26]yy#[fg=#928374] yank   #[fg=#b8bb26]p#[fg=#928374] paste   #[fg=#b8bb26]u#[fg=#928374] undo   #[fg=#b8bb26]^r#[fg=#928374] redo   #[fg=#b8bb26]/#[fg=#928374] search   #[fg=#b8bb26]n/N#[fg=#928374] next/prev   #[fg=#b8bb26]gg/G#[fg=#928374] top/bot   #[fg=#b8bb26]:%s///#[fg=#928374] replace   #[fg=#b8bb26]v#[fg=#928374] visual,#{?#{==:#{pane_current_command},lazygit},#[fg=#8ec07c]LAZYGIT#[fg=#928374]   #[fg=#b8bb26]space#[fg=#928374] stage   #[fg=#b8bb26]c#[fg=#928374] commit   #[fg=#b8bb26]A#[fg=#928374] amend   #[fg=#b8bb26]P#[fg=#928374] push   #[fg=#b8bb26]p#[fg=#928374] pull   #[fg=#b8bb26]1-5#[fg=#928374] panels   #[fg=#b8bb26]z#[fg=#928374] undo   #[fg=#b8bb26]x#[fg=#928374] menu   #[fg=#b8bb26]/#[fg=#928374] filter   #[fg=#b8bb26]q#[fg=#928374] quit,#{?#{==:#{pane_current_command},k9s},#[fg=#8ec07c]K9S#[fg=#928374]   #[fg=#b8bb26]:ctx#[fg=#928374] context   #[fg=#b8bb26]:ns#[fg=#928374] namespace   #[fg=#b8bb26]:<res>#[fg=#928374] navigate   #[fg=#b8bb26]/#[fg=#928374] filter   #[fg=#b8bb26]d#[fg=#928374] describe   #[fg=#b8bb26]l#[fg=#928374] logs   #[fg=#b8bb26]y#[fg=#928374] yaml   #[fg=#b8bb26]s#[fg=#928374] shell   #[fg=#b8bb26]e#[fg=#928374] edit   #[fg=#b8bb26]^d#[fg=#928374] delete   #[fg=#b8bb26]esc#[fg=#928374] back   #[fg=#b8bb26]:q#[fg=#928374] quit,#{?#{==:#{pane_current_command},htop},#[fg=#8ec07c]HTOP#[fg=#928374]   #[fg=#b8bb26]F3#[fg=#928374] search   #[fg=#b8bb26]F4#[fg=#928374] filter   #[fg=#b8bb26]F5#[fg=#928374] tree   #[fg=#b8bb26]F6#[fg=#928374] sort   #[fg=#b8bb26]F9#[fg=#928374] kill   #[fg=#b8bb26]u#[fg=#928374] user   #[fg=#b8bb26]Space#[fg=#928374] tag   #[fg=#b8bb26]F10#[fg=#928374] quit,#{?#{||:#{==:#{pane_current_command},less},#{==:#{pane_current_command},man}},#[fg=#8ec07c]PAGER#[fg=#928374]   #[fg=#b8bb26]Space#[fg=#928374] page   #[fg=#b8bb26]b#[fg=#928374] back   #[fg=#b8bb26]/#[fg=#928374] search   #[fg=#b8bb26]n/N#[fg=#928374] next/prev   #[fg=#b8bb26]g/G#[fg=#928374] top/bot   #[fg=#b8bb26]q#[fg=#928374] quit,#[fg=#665c54]#{pane_current_command}}}}}}'
tmux set -g status 3
tmux set -g status-interval 2   # refresh the app-context line promptly
