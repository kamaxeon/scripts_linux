#!/bin/bash
sh header.sh

drbdadm primary r0 ; mount /dev/drbd0 /replica

sh footer.sh 27B 27B 
