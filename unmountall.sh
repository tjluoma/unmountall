#!/bin/zsh -f
# unmount all mounted disks (except '/Volumes/MobileBackup')
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Repo:	https://github.com/tjluoma/unmountall
# Date:	2014-10-13

NAME="$0:t:r"

	# sounds to be played at the end of the script
	# depending on whether or not the script was able to unmount them
SUCCESS=/System/Library/Sounds/Glass.aiff
FAILURE=/System/Library/Sounds/Basso.aiff

##################################################################

function msg
{
	MSG="$@"

	echo "$NAME: $MSG"

	if (( $+commands[growlnotify] ))
	then
		pgrep -x -q Growl && \
		growlnotify --appIcon "Disk Utility" --identifier "$NAME" --message "$MSG" --title "$NAME"
	fi
}


function on_success
{
	[[ -e "$SUCCESS" ]] && afplay "$SUCCESS"

		# comment out the next line if you don't want a voice confirmation
	say "No drives mounted."

	msg "No drives are mounted."

	exit 0
}


##################################################################

CD_DVD=$(drutil discinfo)

if [ "$CD_DVD" != "" ]
then
	# all we know at this point is that there is a DVD/CD drive
	# if there is a disk in the drive, eject it (or try to)
	(drutil discinfo | fgrep -q '  Please insert a disc to get disc info.') || drutil eject
fi

	# initialize a variable we will use to see if any of these fail
FAIL_COUNT=0

	####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
	# this will get us a list of all the currently mounted drives
	# split at line breaks, not spaces
	# and put into an array
IFS=$'\n' ALL_MOUNTS=($(diskutil list -plist 	|\
fgrep -A1 '<key>MountPoint</key>' 				|\
egrep "<string>.*</string>"					|\
fgrep -v '<string>/</string>'					|\
egrep -v '/Volumes/MobileBackup'				|\
sed 's#.*<string>##g ; s#</string>##g'))

	# if nothing mounted, exit
if [[ "$ALL_MOUNTS" == "" ]]
then
	on_success
fi

	# how many times should we try to unmount before giving up
MAX_TRIES=5

for MOUNT_POINT in $ALL_MOUNTS
do

	# we start at 0 because we're going to increment the counter as soon as we enter the loop
	COUNT=0

	while [[ -d "$MOUNT_POINT" ]]
	do
		((COUNT++))

		if [[ "$COUNT" -gt "$MAX_TRIES" ]]
		then
				# Increment FAIL_COUNT
			((FAIL_COUNT++))

			msg "$COUNT exceeds max $MAX_TRIES"

				# 'break' will go to the next MOUNT_POINT in $ALL_MOUNTS
			break
		fi

		msg "Trying to unmount $MOUNT_POINT ($COUNT/$MAX_TRIES)"

		diskutil unmount "$MOUNT_POINT" || sleep 5

	done
done

if [ "$FAIL_COUNT" = "0" ]
then
	on_success
else
	[[ -e "$FAILURE" ]] && afplay "$FAILURE"

	if [ "$FAIL_COUNT" = "1" ]
	then
		MSG="One drive is still mounted."
	elif [ "$FAIL_COUNT" -gt "1" ]
	then
		MSG="$FAIL_COUNT drives are still mounted."
	else
		MSG="At least one drive is still mounted."
	fi

		# comment out the 'say' line if you don't want a voice confirmation
	say "$MSG"

	if (( $+commands[growlnotify] ))
	then
		pgrep -x -q Growl && \
		growlnotify --sticky --appIcon "Disk Utility" --identifier "$NAME" --message "$MSG" --title "$NAME at `date`"
	fi

	exit 0
fi

exit 0

#
#EOF
