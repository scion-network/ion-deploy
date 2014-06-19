===============================================================================
Tools to work with OOINet (ION) system
===============================================================================


INSTALLATION
============

Requires a tools virtualenv:

mkvirtualenv --no-site-packages tools

pip install -r requirements.txt


pip install pyyaml
pip install requests
pip install psycopg2
pip install ipython


Put a .cfg (YML syntax) file somewhere by copying the template iondiag_example.cfg to iondiag.cfg
Set sysname plus rabbit/postgres connection info.
The default config file is ./iondiag.cfg. The -c option allows to set another path.


iondiag.py
==========

Start tool with another config file
> python iondiag.py -c mycfg.cfg

Retrieve system info and store/overwrite in ./sysinfo dir
> python iondiag.py -d sysinfo

Run diagnosis based on content in ./sysinfo dir
> python iondiag.py -d sysinfo -l

Verbose output
> python iondiag.py -v

Interactive shell
> python iondiag.py -d sysinfo -l -i


Interactive analysis
--------------------

