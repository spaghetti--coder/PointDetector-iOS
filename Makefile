default:
	xcodebuild -scheme pdTestwithJenkins -sdk iphonesimulator6.1 -workspace pointdetector.xcworkspace -arch i386 -configuration Debug clean build BUILD_AFTER_TEST=YES ONLY_ACTIVE_ARCH=NO

clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -scheme pdTestwithJenkins -sdk iphonesimulator6.1 -workspace pointdetector.xcworkspace -arch i386 -configuration Debug clean build BUILD_AFTER_TEST=YES ONLY_ACTIVE_ARCH=NO RUN_UNIT_TEST_WITH_IOS_SIM=YES
