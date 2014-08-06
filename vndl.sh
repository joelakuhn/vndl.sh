#!/bin/bash

cmnd=$1
plugin=$2
VERSION=0.2.1
vimrc_file_path=~/.vimrc
vimrc_file_temp_path=$vimrc_file_path.tmp
bundle_dir=~/.vim/bundle

function bundle_install {
  vim +BundleInstall +qall
}

function remove_plugin_dir {
  rm -rf $bundle_dir/$plugin
}

function install_plugin {
  cat $vimrc_file_path \
  | perl -pe "s/^\" Plugins$/\" Plugins\nPlugin '$plugin'/" \
  > $vimrc_file_temp_path

  mv $vimrc_file_temp_path $vimrc_file_path

  bundle_install
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
  hash grep 2> /dev/null || {
    echo 'Could not find grep.'
    noerrors=false
  }
  if $noerrors; then
    echo "YAY, no errors"
  fi
}

function remove_plugin {
  cat $vimrc_file_path \
  | perl -pe "s/^\"? ?Plugin '$plugin'\n//" \
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
  | sed "s/'//g"
}

function disable_plugin {
  cat $vimrc_file_path \
  | perl -pe "s/^Plugin '$plugin'/\" Plugin '$plugin'/" \
  > $vimrc_file_temp_path \
  && mv $vimrc_file_temp_path $vimrc_file_path \
  || echo 'could not save changes to plugins'

  remove_plugin_dir
}

function enable_plugin {
  cat $vimrc_file_path \
  | perl -pe "s/^\" Plugin '$plugin'/Plugin '$plugin'/" \
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
  '') show_help;;
esac