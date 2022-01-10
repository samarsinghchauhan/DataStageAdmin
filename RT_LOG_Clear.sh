#!/bin/sh
#!/bin/bash
cd `cat /.dshome`
. ./dsenv
`cat /.dshome`/bin/uvsh << EOF
LOGTO $1
CLEAR.FILE RT_LOG$2
UNLOCK ALL
UNLOCK ALL
QUIT
<< begin_command
