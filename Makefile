SWIFTC=swiftc

ifeq ($(shell uname -s), Darwin)
XCODE=$(shell xcode-select -p)
SDK=$(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
TARGET=x86_64-apple-macosx10.10
SWIFTC=swiftc -target $(TARGET) -sdk $(SDK) -Xlinker -all_load
endif

build:
	@swift build