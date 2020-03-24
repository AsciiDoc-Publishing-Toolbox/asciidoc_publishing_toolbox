#/usr/bin/env bash

_adpt_completions()
{
  local cur prev opts commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
	commands="init build chap"
	opts="--help --verbose --no-verbose --version"


	case ${COMP_CWORD} in
        1)
            if [[ ${cur} == -* ]] ; then
				COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
				#return 0
			else
				COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
			fi
            ;;
        2)
            case ${prev} in
                init)
					if [[ ${cur} == -* ]] ; then
						opts="--help --overwrite"
					else
						opts="$(ls -d */)"
					fi
                    ;;
                build)
					opts="--help --directory"
                    ;;
				chap)
					opts="--help --title --part --rename --directory"
					;;
            esac
			COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _adpt_completions adpt
