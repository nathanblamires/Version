# Version

`Version` is a one file library that provides a `Version` data structure, designed to represent a software version.
It follows the [Semantic Versioning 2.0 specification](https://semver.org/), providing validation whenever a `Version` is initialised.

## Why This Library
- Simple one file implementation
- Conforms to `Comparable`, `Hashable` and `Codable`
- Enforces versions conform to the SemVer 2.0 specification.
- MIT license

## Usage

### Init

When using semantic versioning, there are strict rules about what is and is not a valid version string.
For this reasion, the standard initialiser is marked with `throws`, leaving it up to the caller to decide what to do if an error arrises.
```swift
let version = try Version(major: 1)
let version = try Version(major: 1, minor: 2)
let version = try Version(major: 1, minor: 2, patch: 3)
let version = try Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
let version = try Version(major: 1, minor: 2, patch: 3, metadata: "qwer.asdf")
let version = try Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "qwer.asdf")
```

You can however also initialise a `Version` directly from a `String`.
```swift
let version: Version = "1"
let version: Version = "1.2"
let version: Version = "1.2.3"
let version: Version = "1.2.3-beta"
let version: Version = "1.2.3+qwer.asdf"
let version: Version = "1.2.3-beta+qwer.asdf"
```
This initialiser cannot fail, as that is required by the protocol `ExpressibleByStringLiteral`.
For this reason, if an invalid value is provided, an error message will be logged and the version `0.0.0` returned.

### Compare
The `Version` struct conforms to the `Comparable` protocol.

```swift
if version1 < version2 { ... }
if version1 > version2 { ... }
if version1 == version2 { ... }  // ignores metadata
if version1 === version2 { ... } // includes metadata
```

### Common Errors
The following are requirements according to the semantic versioning specification. 
These requirements are however often overlooked, and thus are a common source of error. 
- Major, minor and patch must be positive integers
- Prerelease string must only contain letters, numbers and hyphens. A period (.) can also be included to delimeter identifiers.  
- Metadata string must only contain letters, numbers and hyphens. A period (.) can also be included to delimeter identifiers.  

## Installation
### Swift Package Manager (SPM)
Xcode 11 enables you to easily add packages from your project settings.
You can also manually edit your `Package.swift`, adding the following line.
`package.append(.package(url: "https://github.com/nathanblamires/Version.git", from: "1.0.0"))`

### Copy `Version` File
This is a lightweight library contained entierely in one file. For this reason, you may wish to simply copy/paste the `Version` file into your project.
