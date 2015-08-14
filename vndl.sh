#!/bin/sh

VERSION=0.4.6
vimrc_file_path=~/.vimrc
vimrc_file_temp_path=$vimrc_file_path.vndl.tmp
bundle_dir=~/.vim/bundle

# flags
FORCE=1

function check {
  local noerrors=true
  if [ ! -e $vimrc_file_path ]; then
    echo "Your vimrc wasn't found."
    noerrors=false
  else
    grep 'call vundle#end()' $vimrc_file_path > /dev/null || {
      echo 'missing vundle#end() call';
      noerrors=false
    }
    grep 'call vundle#begin()' $vimrc_file_path > /dev/null || {
      echo 'missing vundle#begin() call';
      noerrors=false
    }
  fi
  if [ ! -d $bundle_dir ]; then
    echo "You don't seem to have a bundle directory. Do you have Vundle installed?"
    noerrors=false
  fi
  hash perl 2> /dev/null || {
    echo 'Could not find perl.'
    noerrors=false
  }
  hash git 2> /dev/null || {
    echo 'Could not find git'
    noerrors=false
  }
  hash sed 2> /dev/null || {
    echo 'Could not find sed.'
    noerrors=false
  }
  hash grep 2> /dev/null || { echo 'Could not find grep.'
    noerrors=false
  }
  if $noerrors; then
    echo "YAY, no errors"
  fi
}

function bundle_install {
  vim -c "set shell=/bin/bash" +BundleInstall +qall
}

function bundle_update {
  vim -c "set shell=/bin/bash" +BundleUpdate +qall
}

function is_installed {
  local plugin=$1

  cat $vimrc_file_path \
  | grep -E "^\"? ?Plugin '(http.*/)?$plugin/?'" \
  > /dev/null
  return $?
}

function move_temp_file {
  local length_diff=$1
  local original_length=$(wc -l < $vimrc_file_path | bc)
  local new_length=$(wc -l < $vimrc_file_temp_path | bc)
  local expected_length=$(echo "$original_length+$length_diff" | bc)
  if [[ "$FORCE" = "0" ]] || [[ "$expected_length" = "$new_length" ]]; then
    mv $vimrc_file_temp_path $vimrc_file_path
    return $?
  else
    echo "The file was a different length than expected."
    echo "Check $vimrc_file_temp_path to see if it contains what you expected."
    return 1
  fi
}

function unknown_command {
  echo "$cmnd is not a vndl command"
  echo
  show_help
}

function install_vundle {
  local vundle_bundle_dir="$bundle_dir/Vundle.vim"
  [ ! -d $vundle_bundle_dir ] &&
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  grep 'vundle#begin' $vimrc_file_path > /dev/null || {
    echo "Adding the Vundle bits to your .vimrc"
    cp $vimrc_file_path $vimrc_file_temp_path
    >> $vimrc_file_temp_path cat <<EOF
set rtp+=$vundle_bundle_dir
call vundle#begin()
call vundle#end()
EOF
    move_temp_file 3
  }

}

function get_directory_name {
  local plugin=$1

  echo $plugin \
  | grep -Eo '[^/]+$'
}

function remove_plugin_dir {
  local plugin=$1
  local plugin_directory=$(get_directory_name $plugin)

  if [ -n "$plugin_directory" ]; then
    rm -rf $bundle_dir/$plugin_directory
  fi
}

function resolve_plugin {
  local plugin=$1

  case $plugin in
    [0-9]*)
      list_plugins | sed "${plugin}q;d" \
      | cut -f2 \
      | sed 's|^- ||'
      ;;
    *)
      cat $vimrc_file_path \
      | grep -Eo "^\"? ?Plugin '([^']+/)?$plugin/?(.vim)?'" \
      | grep -Eo "'.*'" \
      | grep -Eo "[^']+" \
      | sed "1q;d"
      ;;
  esac

}

function install_plugin {
  local plugin=$1
  echo installing $plugin

  if [ $plugin = 'vundle' ]; then
    install_vundle
  elif is_installed $plugin; then
    echo "$plugin is already installed"
  else
    cat $vimrc_file_path \
    | perl -pe "s|^call vundle#end().+$|Plugin '$plugin'\ncall vundle#end()|" \
    > $vimrc_file_temp_path

    move_temp_file 1

    bundle_install
  fi
}

function remove_plugin {
  local plugin=$1
  local full_plugin=$(resolve_plugin $plugin)
  echo removing $full_plugin

  if is_installed "$full_plugin" || [ "$FORCE" = "0" ]; then
    cat $vimrc_file_path \
    | perl -pe "s|^\"? ?Plugin\\s+'$full_plugin'\\s*\n||" \
    > $vimrc_file_temp_path \
    && move_temp_file -1 \
    || echo 'could not save changes to plugins'

    remove_plugin_dir $full_plugin
  else
    echo "That plugin doesn't seem to be installed."
  fi

}

function list_plugins {
  cat $vimrc_file_path \
  | grep -oE "^\"? ?Plugin '[^']*'"    \
  | sed "s/\"[ \\t]*Plugin[ \\t]*/- /" \
  | sed "s/Plugin //" \
  | sed "s/'//g" \
  | nl
}

function disable_plugin {
  local plugin=$1
  local full_plugin=$(resolve_plugin $plugin)
  echo disabling $full_plugin

  cat $vimrc_file_path \
  | perl -pe "s|^Plugin\\s+'$full_plugin'|\" Plugin '$full_plugin'|" \
  > $vimrc_file_temp_path \
  && move_temp_file 0 \
  || echo 'could not save changes to plugins'
}

function enable_plugin {
  local plugin=$1
  local full_plugin=$(resolve_plugin $plugin)
  if [ "$full_plugin" = '' ]; then
    echo "could not locate plugin $plugin"
    exit
  fi
  echo enabling $full_plugin

  cat $vimrc_file_path \
  | perl -pe "s|^\"\\s*Plugin\\s+'$full_plugin'|Plugin '$full_plugin'|" \
  > $vimrc_file_temp_path \
  && move_temp_file 0 \
  || echo 'could not save changes to plugins'

  remove_plugin_dir
}

for arg in $@; do
  case $arg in
    -f) FORCE=0;;
  esac
done

function show_help {
  cat <<EOF
usage: vndl command [plugin]
  install   -i    install a plugin
  remove    -r    remove a plugin
  disable   -d    comment out a plugin
  enable    -e    uncomment out a plugin
  list      -l    list the installed plugins
  sync      -s    call BundleInstall
  check     -c    check that things are working properly
  --version -v    show the version of vndl you're running
  --help    -h    show this help message
EOF
}

function show_version {
  echo $VERSION
}

cmnd=$1

for arg in "${@:2}"; do
  echo $arg

  case $arg in
    -f) ;;
    *)
      case $cmnd in
        install|-i)   install_plugin $arg;;
        remove|-r)    remove_plugin  $arg;;
        disable|-d)   disable_plugin $arg;;
        enable|-e)    enable_plugin  $arg;;
        resolve|-x)   resolve_plugin $arg;;
        installed)    is_installed   $arg && echo 'installed';;
      esac
    ;;
  esac

done

if [[ "" = "$2" ]]; then

  case $cmnd in
    sync|-s)        bundle_install;;
    list|-l)        list_plugins;;
    check|-c)       check;;
    update|-u)      bundle_update;;
    --version|-v)   show_version;;
    --help|-h|'')   show_help;;
    *)              unknown_command;;
  esac

fi
