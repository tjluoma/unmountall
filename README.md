unmountall
==========

When run, `unmountall.sh` will attempt to ‘unmount’ any drives which are currently mounted on OS X (except “MobileBackups” used for local Time Machine backups).

Upon completion:

* a sound will be played (different sound will be played depending on success/failure)
* a voice message will be spoken
* a Growl notification will be displayed (IFF [Growl][] is running _and_ [growlnotify][] is installed.)

Any of those notifications can easily be disabled by editing the script.


[Growl]:	http://growl.info/
[growlnotify]:	http://growl.info/downloads
