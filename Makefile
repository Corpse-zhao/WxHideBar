TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += mainapp
SUBPROJECTS += kbd

include $(THEOS_MAKE_PATH)/aggregate.mk
