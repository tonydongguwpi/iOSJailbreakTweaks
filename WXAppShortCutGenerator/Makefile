THEOS_DEVICE_IP = 172.18.37.235
ARCHS = armv7 arm64
TWEAK_NAME = WXAppShortCutGenerator
WXAppShortCutGenerator_FILES = WAWebViewController.xm SpringBoard.xm WAGameViewController.xm
WXAppShortCutGenerator_CFLAGS = -I/usr/lib/libxml2 
WXAppShortCutGenerator_OBJ_FILES += /Users/mfw/Desktop/iOSJailbreakPlugIns/WXAppShortCutGenerator/libCocoaHTTPServer.a 
WXAppShortCutGenerator_FRAMEWORKS = Foundation UIKit CFNetwork Security CoreGraphics 
include /opt/theos/makefiles/common.mk
include /opt/theos/makefiles/tweak.mk
after-install::
	install.exec "killall -9 SpringBoard"