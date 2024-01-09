# nushell-warp
Usable work in progress script to support [Nushell](https://github.com/nushell/nushell) in [Warp](https://github.com/warpdotdev/Warp/)
![image](https://github.com/UserSv4/nushell-warp/assets/70157095/cf2f567e-381e-4409-b6a3-e8b35989e872)
# Installation:
Make sure you have Python installed
Download https://raw.githubusercontent.com/UserSv4/nushell-warp/main/bash into any directory
Make the script executable (`cd ~/Downloads; chmod +x ./bash`)
In Warp's settings set the script as your custom shell
# How to use in subshells:
After you've used the script normally at least once (so that the /tmp file is generated), execute `source /tmp/_nu_script_for_warp` in your Nu subshell.
# Known issues:
Requires Python
No SSH
Very bad syntax highlighting
No custom prompt and some parts of Warp's prompt aren't implemented
No titles for Warp's tabs 
No (SQLite history)[https://www.nushell.sh/blog/2022-06-14-nushell_0_64.html#future-sqlite-backed-history-phiresky] support
An extra new line gets placed before the output of each command
