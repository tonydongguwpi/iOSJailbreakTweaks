
THEOS_DEVICE_IP = 192.168.0.8
ARCHS = armv7 armv7s arm64
TWEAK_NAME = CaptchaCatcher
CaptchaCatcher_FILES = Tweak.xm
include /opt/theos/makefiles/common.mk
include /opt/theos/makefiles/tweak.mk
after-install::
	install.exec "killall -9 SpringBoard"