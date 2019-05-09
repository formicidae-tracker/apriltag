#
# Regular cron jobs for the libapriltags package
#
0 4	* * *	root	[ -x /usr/bin/libapriltags_maintenance ] && /usr/bin/libapriltags_maintenance
