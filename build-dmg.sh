cd /Users/beckmst/Documents/repos/build-timecop-Desktop_Qt_5_6_0_clang_64bit-Release
defaults write timecop.app/Contents/Info LSUIElement 1
/usr/local/qtcommercial/5.6/clang_64/bin/macdeployqt timecop.app -dmg -qmldir=../timecop/
