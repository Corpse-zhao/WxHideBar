TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WxHideBar
WxHideBar_FILES = Tweak.x
WxHideBar_CFLAGS = -fobjc-arc -Wno-unused-function
WxHideBar_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
