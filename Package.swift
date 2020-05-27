// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "kfortran",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(name: "kfortran", targets: ["kfortran"]),
        .library(name: "kfortran_Runtime", type: .static, targets: ["Runtime"]),
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(name: "LLVM", url: "https://github.com/llvm-swift/LLVMSwift", .revision("188bfbb5")),
        .package(name: "Curry", url: "https://github.com/thoughtbot/Curry.git", from: "4.0.2"),
    ],
    targets: [
        .target(
            name: "kfortran",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "CodeGen"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "LLVM", package: "LLVM"),
            ]),
        .target(name: "Parser", dependencies: [
            .product(name: "Curry", package: "Curry")
        ]),
        .target(name: "CodeGen", dependencies: [
                .target(name: "Parser"),
                .product(name: "LLVM", package: "LLVM"),
        ]),
        .target(name: "Runtime", dependencies: []),
        .testTarget(
            name: "kfortranTests",
            dependencies: ["Parser"]),
    ]
)
