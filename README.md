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

	vndl enalbe Command-T

list installed plugins (lists all rc Plugin entries)

	vndl list

install all currently configured plugins (i.e. BundleInstall)

	vndl sync