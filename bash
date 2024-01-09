cat > /tmp/_nu_script_for_warp <<'EOF'
const _shell = bash
const _shell_version = '5.2.1(1)-release'
# const _shell = fish
# const _shell_version = '3.6.1'

const DCS_START = "\u{1b}P$"
const DCS_JSON_MARKER = d
const DCS_END = "\u{9c}"
# const OSC_START_GENERATOR_OUTPUT = "\u{1b}]9277;A\u{07}"
# const OSC_END_GENERATOR_OUTPUT = "\u{1b}]9277;B\u{07}"

$env._last_command = "1" # part of a workaround so everything is displayed properly when hitting enter in Warp without entering any commands; can't work with normal mutable variables in closures so using $env

let _vi_mode = (if $env.config.edit_mode in $env.config and $env.config.edit_mode == vi { '1' } else { '0' })
let _is_subshell = 'WARP_SESSION_ID' in $env # TODO is this the best way to deal with subshells?

let WARP_SESSION_ID = ((date now | format date %s) + (random int ..999_999 | into string)) | into int
$env.WARP_SESSION_ID = $WARP_SESSION_ID # TODO is this export needed?

$env.PROMPT_COMMAND = ''
$env.PROMPT_COMMAND_RIGHT = ''
$env.config.edit_mode = emacs



def "_warp message" [hook: string, value: record = {}] {
	# TODO use encode hex after it's released? https://www.nushell.sh/commands/docs/encode_hex.html#:~:text=Tips%3A%20Command%20encode%20hex%20was%20not%20included%20in%20the%20official%20binaries%20by%20default%2C%20you%20have%20to%20build%20it%20with%20%2D%2Dfeatures%3Dextra%20flag
	print ($DCS_START + $DCS_JSON_MARKER + ({ hook: $hook, value: $value } | to json | od -An -v -tx1 | str replace -a ' ' '' | str replace -am "\n" '') + $DCS_END)
}

def "_warp init-shell" [
	session_id: int,
	shell: string,
	user: string,
	hostname: string,
	is_subshell: bool
] {
	_warp message InitShell { session_id: $session_id, shell: $shell, $user: user, hostname: $hostname, is_subshell: $is_subshell }
}

def "_warp command-finished" [exit_code: int] {
	_warp message CommandFinished { exit_code: $exit_code }
}

def "_warp precmd" [
	pwd: string,
	ps1: string,
	rprompt: string,
	git_branch: string,
	virtual_env: string,
	conda_env: string,
	session_id: int
] {
	# TODO add and encode ps1
	_warp message Precmd { pwd: $pwd, ps1: '', rprompt: $rprompt, git_branch: $git_branch, virtual_env: $virtual_env, conda_env: $conda_env, session_id: $session_id }
}

def "_warp precmd-filled" [] {
	# TODO add ps1 rprompt gitbranch virtual-env conda-env
  # TODO fix git_branch not working somehow
	mut git_branch = (GIT_OPTIONAL_LOCK=0 git symbolic-ref --short HEAD err> /dev/null)
	if $git_branch == "" { $git_branch = (GIT_OPTIONAL_LOCK=0 git rev-parse --short HEAD err> /dev/null) }
	_warp precmd $env.PWD '' '' $git_branch '' '' $WARP_SESSION_ID
}

def "_warp preexec" [command: string] {
	_warp message Preexec { command: $command }
}

# TODO what is this Warp hook for?
def "_warp input-buffer" [buffer: string] {
	_warp message InputBuffer { buffer: $buffer }
}

def "_warp bootstrapped" [
	histfile: string,
	session_id: int, # unnecessary? only in bash? no fish?
	shell: string,
	home_dir: string,
	user: string, # only in bash? no fish?
	host: string, # only bash? no fish?
	path: string,
	env_var_names: string,
	abbreviations: string, # TODO find out what this does. was set to an empty string by Warp's own script. the reverse engeneering was made from the bash script so maybe bash just doesnt support this abbreviations
	aliases: string, # lets Warp highlight aliases and expand them as you type
	function_names: string,
	builtins: string, # the function_names should contain builtins
	keywords: string, # TODO manually hardcode?
	shell_version: string, #3.6.1 for fish
	shell_options: string, #only bash? no fish  TODO figure this out if it's even needed
	rcfiles_start_time: int, # only bash? no fish.TODO figure out what's this for and maybe set a proper value
	rcfiles_end_time: int, #only bash? no fish. TODO figure out what's this for and maybe set a proper value
	vi_mode_enabled: string
] {
	_warp message Bootstrapped {
		histfile: $histfile,
		session_id: $session_id,
		shell: $shell,
		home_dir: $home_dir,
		user: $user,
		host: $host,
		path: $path,
		env_var_names: $env_var_names,
		abbreviations: $abbreviations,
		aliases: $aliases,
		function_names: $function_names,
		builtins: $builtins,
		keywords: $keywords,
		shell_version: $shell_version,
		shell_options: $shell_options,
		# rcfiles_start_time: $rcfiles_start_time, # TODO - arent allowed in fish or cant be 0???
		# rcfiles_end_time: $rcfiles_end_time, # TODO - arent allowed in fish or cant be 0???
		vi_mode_enabled: $vi_mode_enabled
	}
}



# so that Warp can make the working directory the same as the current tab when opening a new one
if WARP_INITIAL_WORKING_DIR in $env {
	cd $env.WARP_INITIAL_WORKING_DIR
}

# necessary for Warp to work; makes Warp print out the whole config for a choosen shell
_warp init-shell $env.WARP_SESSION_ID $_shell (whoami) ((sys).host.hostname) $_is_subshell

(_warp bootstrapped
	$nu.history-path # TODO support SQL?
	$env.WARP_SESSION_ID
	$_shell
	$env.HOME
	(whoami)
	((sys).host.hostname)
	($env.PATH | str join ':') # TODO does fish use ' ' and bash ':'?
	($env | transpose key value | reduce -f '' {|it, acc| $acc + $it.key + "\n"} | str trim) # TODO consider sending the list of normal variables instead of environment variables for better syntax highlighting
	'' # TODO are there abbreviations in Nu?
	# (scope aliases | each {|a| echo $"alias ($a.name) '($a.expansion | str replace -a "'" "\\'")'"} | str join "\n") # fish version
	(scope aliases | each {|a| echo $"alias ($a.name)='($a.expansion | str replace -a "'" "\\'")'"} | str join "\n") # bash version
	(scope commands | each {|c| ($c.name | split column " ").column1.0} | uniq | str join "\n") # function names vs aliases vs builtins vs keywords?
	'' # TODO hardcode builtins?
	'' # TODO hardcode keywords?
	$_shell_version
	'' # TODO figure out what's shell options are for and maybe set a proper value
	# TODO figure out what are rcfile times for and maybe set a proper value
	0 
	0
	$_vi_mode)

# ignores Warp's Bash bootstrap script sent by Warp because of the init-shell message; the script ends with 'unset WARP_BOOTSTRAP_VAR'
python -c `for line in __import__('sys').stdin: exit() if 'unset WARP_BOOTSTRAP_VAR' in line else None` # TODO don't use Python; somehow after like an hour of trying I have yet to find a single reliable alternative to this Python script

$env.config = ($env.config | upsert hooks {
	pre_prompt: {
		if $env._last_command == "" { return }
		_warp command-finished $env.LAST_EXIT_CODE
		_warp precmd-filled
	}
	pre_execution: {
		if (commandline) == "" { return }
		$env._last_command = (commandline)
		_warp preexec (commandline)
	}
})

# binds because for some reason Warp seems to send Ctrl+P before sending the command's text to shell and after that it sends Ctrl+J which doesn't seem to work as Enter in Nu by default
$env.config = ($env.config | upsert keybindings [
	# TODO figure out why Warp even sends Ctrl+P to shells
	{
		modifier: control
		keycode: char_p
		mode: emacs
		event: { edit: Clear }
	}
	{
		modifier: control
		keycode: char_j
		mode: emacs
		event: { send: Enter }
	}
])
EOF
nu -e 'source /tmp/_nu_script_for_warp'
