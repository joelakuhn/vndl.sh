vndl.sh
=======

vndl.sh is a simple front end for the Vundle package manager for vim. Vndl makes it easier to quickly add and remove plugins to vim without having to open your vimrc file.

Usage
-----

Install the Command-T plugin (adds rc entry and runs BundleInstall)
	
	vmdl install Command-T

remove Command-T (removes rc entry and bundle)
	
	vndl remove Command-T

disable Command-T (comments out the rc entry)

	vndl disable Command-T

enable Command-T (uncomments the rc entry)

	vndl enable Command-T

list installed plugins (lists all rc Plugin entries)

	vndl list

download all currently configured plugins (i.e. BundleInstall)

	vndl sync

check that your environment is configured the way vndl expects 

	vndl check

Install Vundle itself.

  vndl install vundle

All plugins can be referenced by the number next to them when running the list command.

  vndl disable 4 # disables the 4th plugin in your plugins list.

Todo
----
