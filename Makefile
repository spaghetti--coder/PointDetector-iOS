default:
	# Set default make action here
	xcodebuild -target pointdetectorTests -configuration Debug -sdk iphonesimulator5.1 build	

clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild RUN_APPLICATION_TESTS_WITH_IOS_SIM=YES -target pointdetectorTests -configuration Debug -sdk iphonesimulator5.1 build	

