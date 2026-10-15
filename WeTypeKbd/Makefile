TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WxHideBarKbd
WxHideBarKbd_FILES = Tweak.x
WxHideBarKbd_CFLAGS = -fobjc-arc -Wno-unused-function
WxHideBarKbd_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
