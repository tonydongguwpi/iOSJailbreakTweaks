THEOS_DEVICE_IP = 192.168.123.30
ARCHS = armv7 arm64
TWEAK_NAME = HazeStatusBar
HazeStatusBar_FILES = $(wildcard *.m *.mm *.x *.xm)
SUBPROJECTS += hazestatusbarpref
HazeStatusBar_LIBRARIES = activator

include /opt/theos/makefiles/common.mk
include /opt/theos/makefiles/tweak.mk
include /opt/theos/makefiles/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"

