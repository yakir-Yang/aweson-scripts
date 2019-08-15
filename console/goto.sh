#! /bin/bash
# Author http://blog.csdn.net/hursing

# this variable should be complex enough to avoid naming pollution
shortcut_and_paths=(
	'proj         /Volumes/Projects'
	'nsoft        /Volumes/Projects/nsoft-cloud'
	'golib        /usr/local/Cellar/go/1.12.4/libexec/src'
    #-----------------------------------------------------
	'language     /Volumes/Projects/language'
	'go           /Volumes/Projects/language/go/src'
	'python       /Volumes/Projects/language/python'
    #-----------------------------------------------------
	'linux        /Volumes/Projects/linux'
	'k8s          /Volumes/Projects/kubernetes'
	'dockerfile   /Volumes/Projects/dockerfile'
	'openstack    /Volumes/Projects/openstack'
	'blogs        /Volumes/Projects/blogs'
	'any101       /Volumes/Projects/any101'
    #-----------------------------------------------------
	'loadbalance  /Volumes/Projects/loadbalance'
	'envoy        /Volumes/Projects/loadbalance/envoy'
    #-----------------------------------------------------
	'messagequeue /Volumes/Projects/message-queue'
	'kafka        /Volumes/Projects/message-queue/kafka'
    #-----------------------------------------------------
	'elk          /Volumes/Projects/elk'
	'tools        /Volumes/Projects/tools'
    #-----------------------------------------------------
	'turbo-proxy  /Volumes/Projects/nsoft-cloud/turbo-proxy'
	'kubespray    /Volumes/Projects/nsoft-cloud/kubespray'
	'charts       /Volumes/Projects/nsoft-cloud/charts'
	'sdwan        /Volumes/Projects/nsoft-cloud/sdwan'
	'helm         /Volumes/Projects/nsoft-cloud/helm'
	'ovs          /Volumes/Projects/nsoft-cloud/ovs'
	'vpp          /Volumes/Projects/nsoft-cloud/vpp'
    #-----------------------------------------------------
	'serverless   /Volumes/Projects/serverless'
	'frontend     /Volumes/Projects/frontend'
)

tabwordlist=

for ((i = 1; i <= ${#shortcut_and_paths[@]}; i++)); do
	cmd=${shortcut_and_paths[$i]}
	shortcut=${cmd%% *}
	tabwordlist=$tabwordlist" "$shortcut

done

complete -W "$tabwordlist" to

to() {
  if [ -z $1 ]; then
    tohelp
    return
  fi

	for ((i = 1; i <= ${#shortcut_and_paths[@]}; i++)); do
		cmd=${shortcut_and_paths[$i]}
		shortcut=${cmd%% *}
		ipath=${cmd##* }

		if [ $shortcut = $1 ]; then
			cd $ipath
		fi
	done
}

tohelp() {
	for ((i = 1; i <= ${#shortcut_and_paths[@]}; i++)); do
		cmd=${shortcut_and_paths[$i]}
		shortcut=${cmd%% *}
		ipath=${cmd#* }
		echo -e "$shortcut  $ipath"
	done
	echo -e "\033[0;33;1mexample: input 'to ${shortcut_and_paths[1]%% *}' to run 'cd ${shortcut_and_paths[1]##* }'\033[0m"
}
