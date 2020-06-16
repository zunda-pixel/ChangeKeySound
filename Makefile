include $(THEOS)/makefiles/common.mk

export TARGET = Iphone:clang:latest:latest
export ARCHS = arm64 arm64e

export TWEAK_NAME = ChangeKeySound
export BUNDLE_NAME = ChangeKeySound

SUBPROJECTS += Tweak
SUBPROJECTS += Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk