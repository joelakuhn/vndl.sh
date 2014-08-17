#!/bin/bash

VERSION=0.4.1
vimrc_file_path=~/.vimrc
vimrc_file_temp_path=$vimrc_file_path.tmp
bundle_dir=~/.vim/bundle

function check {
  local noerrors=true
  if [ ! -e $vimrc_file_path ]; then
    echo "Your vimrc wasn't found."
    noerrors=false
  fi
  if [ ! -d $bundle_dir ]; then
    echo "You don't seem to have a bundle directory. Do you have Vundle installed?"
    noerrors=false
  fi
  hash perl 2> /dev/null || {
    echo 'Could not find perl.'
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
  vim +BundleInstall +qall
}

function is_installed {
  local plugin=$1

  cat $vimrc_file_path \
  | grep -E "^\"? ?Plugin\\s+'(http.*/)?$plugin/?'\\s*" \
  > /dev/null
  return $?
}

function unknown_command {
  echo "$cmnd is not a vndl command"
  echo
  show_help
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
      | grep -Eo "^\"? ?Plugin '([^']+/)?$plugin/?'" \
      | grep -Eo "'.*'" \
      | grep -Eo "[^']+"
      ;;
  esac

}

function install_plugin {
  local plugin=$1

  if [ $plugin = 'vundle' ]; then
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  else
    cat $vimrc_file_path \
    | perl -pe "s|^call vundle#end().+$|Plugin '$plugin'\ncall vundle#end()|" \
    > $vimrc_file_temp_path

    mv $vimrc_file_temp_path $vimrc_file_path

    bundle_install
  fi
}

function remove_plugin {
  local plugin=$1
  local full_plugin=$(resolve_plugin $plugin)

  is_installed "$full_plugin" || {
    echo "That plugin doesn't seem to be installed."
  }

  cat $vimrc_file_path \
  | perl -pe "s|^\"? ?Plugin\\s+'$full_plugin'\\s*\n||" \
  > $vimrc_file_temp_path \
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'

  remove_plugin_dir $full_plugin
}

function list_plugins {
  cat $vimrc_file_path \
  | grep -oE "^\"? ?Plugin '[^']*'" \
  | sed "s/\" Plugin /- /" \
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
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'
}

function enable_plugin {
  local plugin=$1
  local full_plugin=$(resolve_plugin $plugin)
  echo enabling $full_plugin

  cat $vimrc_file_path \
  | perl -pe "s|^\" Plugin\\s+'$full_plugin'|Plugin '$full_plugin'|" \
  > $vimrc_file_temp_path \
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'

  remove_plugin_dir
}

function show_help {
  cat <<EOF
usage: vndl command [plugin]
  install   -i    installs a plugin
  remove    -r    remove a plugin
  disable   -d    comments out a plugin
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

  case $cmnd in
    install|-i)   install_plugin $arg;;
    remove|-r)    remove_plugin $arg;;
    disable|-d)   disable_plugin $arg;;
    enable|-e)    enable_plugin $arg;;
    resolve|-x)   resolve_plugin $arg;;
  esac

done

case $cmnd in
  sync|-s)        bundle_install;;
  list|-l)        list_plugins;;
  check|-c)       check;;
  --version|-v)   show_version;;
  --help|-h)      show_help;;
  *)              unknown_command;;
esac
