ARCHS = arm64
include theos/makefiles/common.mk

TWEAK_NAME = Mesalation
Mesalation_FILES = Tweak.xm
Mesalation_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"
