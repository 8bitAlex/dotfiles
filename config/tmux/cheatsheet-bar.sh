#!/bin/sh
# Build a 3-line tmux status stack (top -> bottom):
#   [0] app-context cheatsheet  — switches on #{pane_current_command}
#                                 (vim, lazygit, k9s, htop, claude, pager, ...)
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
# Adding an app: add one nested #{?#{==:#{pane_current_command},NAME},SHEET,...}
# (or #{m:*PAT*,...} to match on a wildcard / truncated process name).
#
# Invoked from ~/.config/tmux/tmux.conf.local via run-shell.

MARK='fill=#3b3638'   # marker present in our custom lines, never in tmux's default bar

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
tmux set -g 'status-format[1]' '#[align=centre,fill=#3b3638,bg=#3b3638,fg=#a0a08b]#[fg=#f0cc5a]prefix#[fg=#a0a08b]   #[fg=#d9a93a]-#[fg=#a0a08b] split↓   #[fg=#d9a93a]_#[fg=#a0a08b] split→   #[fg=#d9a93a]c#[fg=#a0a08b] new-win   #[fg=#d9a93a]x#[fg=#a0a08b] kill-pane   #[fg=#d9a93a]&#[fg=#a0a08b] kill-win   #[fg=#d9a93a]hjkl#[fg=#a0a08b] move   #[fg=#d9a93a]HJKL#[fg=#a0a08b] resize   #[fg=#d9a93a]z#[fg=#a0a08b] zoom   #[fg=#d9a93a]Space#[fg=#a0a08b] arrange   #[fg=#d9a93a]q#[fg=#a0a08b] pick   #[fg=#d9a93a]Tab#[fg=#a0a08b] last   #[fg=#d9a93a]d#[fg=#a0a08b] detach'
tmux set -g 'status-format[0]' '#[align=centre,fill=#3b3638,bg=#3b3638,fg=#a0a08b]#{?#{m:*vim,#{pane_current_command}},#[fg=#7fd9c4]VIM#[fg=#a0a08b]   #[fg=#94e344]:w#[fg=#a0a08b] write   #[fg=#94e344]:q#[fg=#a0a08b] quit   #[fg=#94e344]:wq#[fg=#a0a08b] save+quit   #[fg=#94e344]:q!#[fg=#a0a08b] discard   #[fg=#94e344]dd#[fg=#a0a08b] cut   #[fg=#94e344]yy#[fg=#a0a08b] yank   #[fg=#94e344]p#[fg=#a0a08b] paste   #[fg=#94e344]u#[fg=#a0a08b] undo   #[fg=#94e344]^r#[fg=#a0a08b] redo   #[fg=#94e344]/#[fg=#a0a08b] search   #[fg=#94e344]n/N#[fg=#a0a08b] next/prev   #[fg=#94e344]gg/G#[fg=#a0a08b] top/bot   #[fg=#94e344]:%s///#[fg=#a0a08b] replace   #[fg=#94e344]v#[fg=#a0a08b] visual,#{?#{==:#{pane_current_command},lazygit},#[fg=#7fd9c4]LAZYGIT#[fg=#a0a08b]   #[fg=#94e344]space#[fg=#a0a08b] stage   #[fg=#94e344]c#[fg=#a0a08b] commit   #[fg=#94e344]A#[fg=#a0a08b] amend   #[fg=#94e344]P#[fg=#a0a08b] push   #[fg=#94e344]p#[fg=#a0a08b] pull   #[fg=#94e344]1-5#[fg=#a0a08b] panels   #[fg=#94e344]z#[fg=#a0a08b] undo   #[fg=#94e344]x#[fg=#a0a08b] menu   #[fg=#94e344]/#[fg=#a0a08b] filter   #[fg=#94e344]q#[fg=#a0a08b] quit,#{?#{==:#{pane_current_command},k9s},#[fg=#7fd9c4]K9S#[fg=#a0a08b]   #[fg=#94e344]:ctx#[fg=#a0a08b] context   #[fg=#94e344]:ns#[fg=#a0a08b] namespace   #[fg=#94e344]:<res>#[fg=#a0a08b] navigate   #[fg=#94e344]/#[fg=#a0a08b] filter   #[fg=#94e344]d#[fg=#a0a08b] describe   #[fg=#94e344]l#[fg=#a0a08b] logs   #[fg=#94e344]y#[fg=#a0a08b] yaml   #[fg=#94e344]s#[fg=#a0a08b] shell   #[fg=#94e344]e#[fg=#a0a08b] edit   #[fg=#94e344]^d#[fg=#a0a08b] delete   #[fg=#94e344]esc#[fg=#a0a08b] back   #[fg=#94e344]:q#[fg=#a0a08b] quit,#{?#{==:#{pane_current_command},htop},#[fg=#7fd9c4]HTOP#[fg=#a0a08b]   #[fg=#94e344]F3#[fg=#a0a08b] search   #[fg=#94e344]F4#[fg=#a0a08b] filter   #[fg=#94e344]F5#[fg=#a0a08b] tree   #[fg=#94e344]F6#[fg=#a0a08b] sort   #[fg=#94e344]F9#[fg=#a0a08b] kill   #[fg=#94e344]u#[fg=#a0a08b] user   #[fg=#94e344]Space#[fg=#a0a08b] tag   #[fg=#94e344]F10#[fg=#a0a08b] quit,#{?#{m:*claude*,#{pane_current_command}},#[fg=#7fd9c4]CLAUDE#[fg=#a0a08b]   #[fg=#94e344]/#[fg=#a0a08b] cmds+skills   #[fg=#94e344]@#[fg=#a0a08b] files   #[fg=#94e344]!#[fg=#a0a08b] bash   #[fg=#94e344]###[fg=#a0a08b] memory   #[fg=#94e344]esc#[fg=#a0a08b] interrupt   #[fg=#94e344]esc esc#[fg=#a0a08b] rewind   #[fg=#94e344]S-Tab#[fg=#a0a08b] mode   #[fg=#94e344]^r#[fg=#a0a08b] verbose   #[fg=#94e344]/clear#[fg=#a0a08b] reset   #[fg=#94e344]/compact#[fg=#a0a08b] compact   #[fg=#94e344]/model#[fg=#a0a08b] model   #[fg=#94e344]^c#[fg=#a0a08b] quit,#{?#{||:#{==:#{pane_current_command},less},#{==:#{pane_current_command},man}},#[fg=#7fd9c4]PAGER#[fg=#a0a08b]   #[fg=#94e344]Space#[fg=#a0a08b] page   #[fg=#94e344]b#[fg=#a0a08b] back   #[fg=#94e344]/#[fg=#a0a08b] search   #[fg=#94e344]n/N#[fg=#a0a08b] next/prev   #[fg=#94e344]g/G#[fg=#a0a08b] top/bot   #[fg=#94e344]q#[fg=#a0a08b] quit,#[fg=#a0a08b]#{pane_current_command}}}}}}}'
tmux set -g status 3
tmux set -g status-interval 2   # refresh the app-context line promptly
