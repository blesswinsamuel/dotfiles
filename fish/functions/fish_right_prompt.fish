function fish_right_prompt
    set_color green --bold
    if test $CMD_DURATION -gt 0
        # Show duration of the last command in seconds
        set duration (echo "$CMD_DURATION 1000" | awk '{printf "%.3fs", $1 / $2}')
        printf "[$duration]"
        printf " "
    end
    set_color cyan --bold
	printf "%s" (date "+%T")
    set_color normal
end
