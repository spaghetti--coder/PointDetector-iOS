default:
	xcodebuild -scheme pdTestwithJenkins -workspace pointdetector.xcworkspace -arch i386 -configuration Release clean build BUILD_AFTER_TEST=YES ONLY_ACTIVE_ARCH=NO

clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -scheme pdTestwithJenkins -workspace pointdetector.xcworkspace -arch i386 -configuration Release clean build CODE_SIGN_IDENTITY=iPhone Developer:\ Akiko Narita\ \(CJFZLVMJ75\) BUILD_AFTER_TEST=YES ONLY_ACTIVE_ARCH=NO WRITE_JUNIT=YES JUNIT_XML_DIR=build
