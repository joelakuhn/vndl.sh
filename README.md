vndl.sh
=======

vndl.sh is a simple front end for the Vundle package manager for vim. Vndl makes it easier to quickly add and remove plugins to vim without having to open your vimrc file.

Usage
-----

Install Vundle itself.

	vndl install vundle

List Installed Plugins.

  vndl list

  1  checksyntax
  2  quickfixsigns
  3  https://github.com/kchmck/vim-coffee-script
  4  https://github.com/terryma/vim-multiple-cursors
  5  scrooloose/nerdcommenter
  6  dag/vim-fish
  7  wting/rust.vim
  8  https://github.com/sickill/vim-monokai
  9  wavded/vim-stylus
  10 SearchComplete
  11 tpope/vim-markdown
  12 https://github.com/zah/nimrod.vim

Install the Command-T plugin (adds rc entry and runs BundleInstall)
	
	vmdl install Command-T

Remove Command-T (removes rc entry and bundle)
	
	vndl remove Command-T

Remove plugin that is third in the listing above

  vndl remove 3

Disable Command-T (comments out the rc entry)

	vndl disable Command-T

Enable Command-T (uncomments the rc entry)

	vndl enable Command-T

List installed plugins (lists all rc Plugin entries)

	vndl list

Download all currently configured plugins (i.e. BundleInstall)

	vndl sync

Check that your environment is configured the way vndl expects 

	vndl check

All plugins can be referenced by the number next to them when running the list command.

	vndl disable 4 # disables the 4th plugin in your plugins list.
