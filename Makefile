run:
	swift build 
	.build/debug/Monitor 
	#.build/debug/UnitTests && .build/debug/Monitor || echo "There are failed Unit Tests" 

release:
	swift build -v --configuration release
	.build/release/Monitor 

verbose:
	swift build -v
	.build/debug/Monitor 

quick:
	swift-build-tool -v -f ~/projects/swift/Monitor-swift/.build/debug/Monitor.o/llbuild.yaml
	.build/debug/Monitor 

clean: 
	swift build --clean

cleanall:
	rm -rf .build Packages/*
