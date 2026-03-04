// Package.swift
// 放在项目根目录
// name 用项目名
// swift-tools-version: 6.2.3
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/abhay/PrivacyScreen", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Entitlement",
            dependencies: ["PrivacyScreen"]
        )
    ]
)