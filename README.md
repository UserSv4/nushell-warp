# nushell-warp
Usable work in progress script to support [Nushell](https://github.com/nushell/nushell) in [Warp](https://github.com/warpdotdev/Warp/)
![image](https://github.com/UserSv4/nushell-warp/assets/70157095/aaf9b498-ceee-4378-8e8b-b15856fb4086)

# Installation
1. Make sure you have Python installed
2. Download https://raw.githubusercontent.com/UserSv4/nushell-warp/main/bash
3. Make the script is executable (`cd ~/Downloads; chmod +x ./bash`)
4. Set the script as your custom shell in Warp's settings
# How to use in subshells
After you've used the script normally at least once (so that the /tmp file is generated), execute `source /tmp/_nu_script_for_warp` in your Nu subshell.
# Known issues
1. Requires Python
2. No SSH integration
3. Very bad syntax highlighting
4. No custom prompt support and some parts of Warp's builtin prompt aren't implemented
5. Incorrect tabs' titles
6. No SQLite history (https://www.nushell.sh/blog/2022-06-14-nushell_0_64.html#future-sqlite-backed-history-phiresky) support
7. An extra line is printed before the output of each command
