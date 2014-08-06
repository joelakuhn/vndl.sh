#!/bin/bash

VERSION=0.2.1
vimrc_file_path=~/.vimrc
vimrc_file_temp_path=$vimrc_file_path.tmp
bundle_dir=~/.vim/bundle

cmnd=$1
plugin=$2

function bundle_install {
  vim +BundleInstall +qall
}

function remove_plugin_dir {
  rm -rf $bundle_dir/$plugin
}

function install_plugin {
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

function remove_plugin {
  cat $vimrc_file_path \
  | perl -pe "s|^\"? ?Plugin\\s+'(http.*)?$plugin/?'\\s*\n||" \
  > $vimrc_file_temp_path \
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'

  remove_plugin_dir
}

function list_plugins {
  cat $vimrc_file_path \
  | grep -oE "^\"? ?Plugin '.*'" \
  | sed "s/\" Plugin /- /" \
  | sed "s/Plugin //" \
  | sed "s/'//g" \
  | nl
}

function disable_plugin {
  cat $vimrc_file_path \
  | perl -pe "s|^Plugin '((?:http.*/)?$plugin/?)'|\" Plugin '\$1'|" \
  > $vimrc_file_temp_path \
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'

  remove_plugin_dir
}

function enable_plugin {
  cat $vimrc_file_path \
  | perl -pe "s|^\" Plugin '((?:http.*/)?$plugin/?)'|Plugin '\$1'|" \
  > $vimrc_file_temp_path \
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'

  remove_plugin_dir
}

function show_help {
  echo 'vndl install plugin'
  echo 'vndl remove plugin'
  echo 'vndl disable plugin'
  echo 'vndl enable plugin'
  echo 'vndl list'
  echo 'vndl sync'
  echo 'vndl check'
  echo 'vndl --version'
  echo 'vndl --help'
}

function show_version {
  echo $VERSION
}

case $cmnd in
  install|-i)   install_plugin;;
  remove|-r)    remove_plugin;;
  disable|-d)   disable_plugin;;
  enable|-e)    enable_plugin;;
  sync|-s)      bundle_install;;
  list|-l)      list_plugins;;
  check|-c)     check;;
  --version)    show_version;;
  --help|-h)    show_help;;
  '') show_help;;
esac
