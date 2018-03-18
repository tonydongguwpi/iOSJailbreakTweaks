include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HazeStatusBarPref
ADDITIONAL_OBJCFLAGS = -fobjc-arc
ARCHS = armv7 arm64
HazeStatusBarPref_FILES = $(wildcard *.m *.mm *.x *.xm)
HazeStatusBarPref_INSTALL_PATH = /Library/PreferenceBundles
HazeStatusBarPref_FRAMEWORKS = UIKit
HazeStatusBarPref_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HazeStatusBarPref.plist$(ECHO_END)
