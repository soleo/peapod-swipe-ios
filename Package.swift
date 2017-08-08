// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "peapod-swipe",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4),
        .Package(url: "https://github.com/hkellaway/Gloss.git", majorVersion: 1, minor: 2)
    ]

)
