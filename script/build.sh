#!/bin/sh

set -e

DIR="$(cd "$(dirname "$0")/../" && pwd)"

FLAGS="-std=c++11 -Wall -Wextra -pedantic -I$DIR -L$DIR/build -lwebview"
if [ "$(uname)" = "Darwin" ]; then
	FLAGS="$FLAGS -DWEBVIEW_COCOA  -framework WebKit"
else
	FLAGS="$FLAGS -DWEBVIEW_GTK $(pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0)"
fi

if command -v clang-format >/dev/null 2>&1 ; then
	echo "Formatting..."
	clang-format -i \
		"$DIR/webview.h" \
		"$DIR/webview_test.cc" \
		"$DIR/main.cc"
else
	echo "SKIP: Formatting (clang-format not installed)"
fi

if command -v clang-tidy >/dev/null 2>&1 ; then
	echo "Linting..."
	clang-tidy "$DIR/main.cc" -- $FLAGS
	clang-tidy "$DIR/webview_test.cc" -- $FLAGS
else
	echo "SKIP: Linting (clang-tidy not installed)"
fi

echo "Building webview"
mkdir build && cd build
cmake .. && cmake --build . && cd ..

echo "Building example"
c++ main.cc $FLAGS -o webview

echo "Building test app"
c++ webview_test.cc $FLAGS -o webview_test

echo "Running tests"
if [ "$(uname)" = "Darwin" ]; then
  DYLD_LIBRARY_PATH=$DIR/build ./webview_test
else
  LD_LIBRARY_PATH=$DIR/build ./webview_test
fi

if command -v go >/dev/null 2>&1 ; then
	echo "Running Go tests"
	CGO_ENABLED=1 go test
else
	echo "SKIP: Go tests"
fi
