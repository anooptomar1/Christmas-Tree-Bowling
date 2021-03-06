#!/bin/bash
#
# Use this script as a "run script" phase for your tvOS target to use the dynamic framework version of AudioKit.
# You may either copy the contents of this script or reference the file from the run phase.
#

for lib in CsoundLib libsndfile; do
    install_name_tool -change $lib @rpath/$lib.framework/$lib "$TARGET_BUILD_DIR/$EXECUTABLE_PATH"
    # If building for devices, strip the Intel slices from the libraries
    if ! test "$CURRENT_ARCH" = x86_64; then
	libpath="$CODESIGNING_FOLDER_PATH/Frameworks/$lib.framework/$lib"
        lipo "$libpath" -verify_arch x86_64 && lipo -remove x86_64 "$libpath" -output "$libpath"
    fi
done
exit 0

