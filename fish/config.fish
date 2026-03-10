if status is-interactive
    atuin init fish | source
end

starship init fish | source
zoxide init fish | source
mise activate fish | source

# Paths
fish_add_path /opt/homebrew/opt/libpq/bin
fish_add_path ~/.local/bin

set -gx XDG_CONFIG_HOME "$HOME/.config"


# OrbStack
source ~/.orbstack/shell/init.fish 2>/dev/null; or true

# VS Code / Cursor shell integration
string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

# Tmux sessionizer
bind \cf tmux-sessionizer

# --- Git abbreviations ---
abbr --add am 'git amend'
abbr --add gbr 'git br'
abbr --add gco 'git co'
abbr --add gd 'git diff -w'
abbr --add gds 'git diff -w --staged'
abbr --add glogo 'git logo'
abbr --add gp 'git push origin'
abbr --add gs 'git status'

# --- todo.txt ---
alias t='todo.sh'
alias ta='todo.sh add'
alias tl='todo.sh list'
alias td='todo.sh do'
alias tp='todo.sh pri'
alias t1='todo.sh list "(A)"'
alias t2='todo.sh list "(B)"'
alias t3='todo.sh list "(C)"'
alias tt='todo.sh list +today'
alias tw='todo.sh list +work'

set -x TODO_DIR "$HOME/.todo"
set -x TODO_FILE "$TODO_DIR/todo.txt"
set -x DONE_FILE "$TODO_DIR/done.txt"
set -x REPORT_FILE "$TODO_DIR/report.txt"

# --- calendar.txt ---
alias cal="$EDITOR ~/calendar.txt"
alias calcat="cat ~/calendar.txt"

function calgrep
    grep -i $argv ~/calendar.txt
end

function caladd
    if not command -v gdate >/dev/null
        echo "GNU date (gdate) not found. Install coreutils: brew install coreutils"
        return 1
    end

    set input (string join " " $argv)
    set parsed_date (gdate "+%Y-%m-%d w%V %a")
    set time_spec ""
    set event_text "$input"

    if string match -qr "tomorrow at \\d+[ap]?m" "$input"
        set parts (string match -r "(.*) (tomorrow at (\\d+[ap]?m))" "$input")
        if test $status -eq 0
            set event_text (string trim "$parts[2]")
            set time_spec "$parts[4]"
            set parsed_date (gdate -d "tomorrow" "+%Y-%m-%d w%V %a")
        end
    else if string match -qr "next [a-z]+ at \\d+[ap]?m" "$input"
        set parts (string match -r "(.*) (next [a-z]+ at (\\d+[ap]?m))" "$input")
        if test $status -eq 0
            set event_text (string trim "$parts[2]")
            set date_part "$parts[3]"
            set time_spec "$parts[4]"
            set parsed_date (gdate -d "$date_part" "+%Y-%m-%d w%V %a")
        end
    else if string match -qr tomorrow "$input"
        set parts (string match -r "(.*) tomorrow" "$input")
        if test $status -eq 0
            set event_text (string trim "$parts[2]")
            set parsed_date (gdate -d "tomorrow" "+%Y-%m-%d w%V %a")
        end
    else if string match -qr "next [a-z]+" "$input"
        set parts (string match -r "(.*) (next [a-z]+)" "$input")
        if test $status -eq 0
            set event_text (string trim "$parts[2]")
            set parsed_date (gdate -d "$parts[3]" "+%Y-%m-%d w%V %a")
        end
    end

    if test -n "$time_spec"
        echo "$parsed_date  $time_spec $event_text" >>~/calendar.txt
        echo "Added: $parsed_date  $time_spec $event_text"
    else
        echo "$parsed_date  $event_text" >>~/calendar.txt
        echo "Added: $parsed_date  $event_text"
    end
end

function caltoday
    grep (date "+%Y-%m-%d") ~/calendar.txt
end

function caltomorrow
    grep (date -v+1d "+%Y-%m-%d") ~/calendar.txt
end

function caldate
    grep -i $argv ~/calendar.txt
end

function calsort
    sort ~/calendar.txt -o ~/calendar.txt
end
