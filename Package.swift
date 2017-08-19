// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "review-helper",
    dependencies: [
        
        // parsing command line options
        .Package(
            url: "https://github.com/kylef/Commander.git",
            majorVersion: 0
        ),
        
        // http client that looks reasonable to use
        .Package(
            url: "https://github.com/JustHTTP/Just.git",
            majorVersion: 0, minor: 5
        )
    ]
)
