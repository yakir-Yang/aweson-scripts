#! /bin/bash
# Author http://blog.csdn.net/hursing

# this variable should be complex enough to avoid naming pollution
shortcut_and_paths=(
	'work /home/yakir/work'

	'ebc /home/yakir/work/ebc'
	'wmg /home/yakir/github_projs/wheremygirls'
	'wwwhtml /var/www/html'
	'goproj /home/yakir/goproj'

	'chmker /home/yakir/work/chromium/src/third_party/kernel/v3.14/'
	'github /home/yakir/github_projs'
)

tabwordlist=

for ((i = 0; i < ${#shortcut_and_paths[@]}; i++)); do
	cmd=${shortcut_and_paths[$i]}
	shortcut=${cmd%% *}
	tabwordlist=$tabwordlist" "$shortcut

done

complete -W "$tabwordlist" to

to() {
	for ((i = 0; i < ${#shortcut_and_paths[@]}; i++)); do
		cmd=${shortcut_and_paths[$i]}
		shortcut=${cmd%% *}
		path=${cmd#* }

		if [ $shortcut = $1 ]; then
			cd $path
		fi
	done
}

tohelp() {
	for ((i = 0; i < ${#shortcut_and_paths[@]}; i++)); do
		cmd=${shortcut_and_paths[$i]}
		shortcut=${cmd%% *}
		path=${cmd#* }
		echo -e "to $shortcut\t\t=>\t\tcd $path"
	done
	echo -e "\033[0;33;1mexample: input 'to ${shortcut_and_paths[0]%% *}' to run 'cd ${shortcut_and_paths[0]#* }'\033[0m"
}
