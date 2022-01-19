# Bash knows 3 diferent shells: normal shell, interactive shell, login shell.
# ~/.bashrc is read for interactive shells and ~/.profile is read for login
# shells. We just let ~/.profile also read ~/.bashrc and put everything in
# ~/.bashrc.

test -z "$PROFILEREAD" && . /etc/profile
. /root/.bash_profile

#alias hilbert='finger @hilbert.suse.de'
#export EDITOR=/usr/bin/pico
#export NNTPSERVER=news.suse.de

# commands common to all logins

if ! [ $TERM ] ; then
    eval `tset -s -Q`
    case $TERM in
      con*|vt100) tset -Q -e ^?
        ;;
    esac
fi

#
# nearly no known program needs $TERMCAP - 'Slang'-programs get confused
# with a set $TERMCAP -> unset it.
# unset TERMCAP

# Some programs support several languages for their output.
# If you want them to use german, please uncomment the following line.
#export LANG=de_DE.ISO-8859-1
# LANG=de_DE@euro
# export LANG
# export LANGUAGE=de

#
# try to set DISPLAY smart (from Hans) :)
#
if test -z "$DISPLAY" -a "$TERM" = "xterm" -a -x /usr/bin/who ; then
    WHOAMI="`/usr/bin/who am i`"
    _DISPLAY="`expr "$WHOAMI" : '.*(\([^\.][^\.]*\).*)'`:0.0"
    if [ "${_DISPLAY}" != ":0:0.0" -a "${_DISPLAY}" != " :0.0" \
         -a "${_DISPLAY}" != ":0.0" ]; then
        export DISPLAY="${_DISPLAY}";
    fi
    unset WHOAMI _DISPLAY
fi

test -e ~/.alias && . ~/.alias

if [[ -z "$XDG_RUNTIME_DIR" ]]; then
  export XDG_RUNTIME_DIR=/run/user/$UID
  if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    export XDG_RUNTIME_DIR=/tmp/$USER-runtime
    if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
      mkdir -m 0700 "$XDG_RUNTIME_DIR"
    fi
  fi
fi

export DISPLAY LESS PS1 PS2
umask 022
