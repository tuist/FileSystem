# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.17.3] - 2026-05-07
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Make concurrent file writes race-safe by @pepicrft in [#342](https://github.com/tuist/FileSystem/pull/342)

## [0.17.0] - 2026-04-27
### Details
#### <!-- 0 -->🚀 Features
- Remove SwiftNIO backend from FileSystem by @pepicrft in [#333](https://github.com/tuist/FileSystem/pull/333)

## [0.16.4] - 2026-04-17
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Remove public extensions that silently shadow Foundation/stdlib by @pepicrft in [#327](https://github.com/tuist/FileSystem/pull/327)

## [0.16.2] - 2026-04-16
### Details
#### <!-- 4 -->⚡ Performance
- Make StringProtocol.range(of:) scan UTF-8 bytes by @pepicrft in [#325](https://github.com/tuist/FileSystem/pull/325)

## [0.16.1] - 2026-04-14
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Add Musl support to File System Primitives by @fortmarek in [#322](https://github.com/tuist/FileSystem/pull/322)

## [0.16.0] - 2026-04-12
### Details
#### <!-- 0 -->🚀 Features
- Add opt-in swift-file-system backend by @pepicrft in [#315](https://github.com/tuist/FileSystem/pull/315)

## [0.15.31] - 2026-04-08
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Handle concurrent mkdir race in NIO's createDirectory by @pepicrft in [#312](https://github.com/tuist/FileSystem/pull/312)

## [0.15.26] - 2026-04-01
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Bump minimum ZIPFoundation version to 0.9.21 by @asevko in [#308](https://github.com/tuist/FileSystem/pull/308)

## New Contributors
* @asevko made their first contribution in [#308](https://github.com/tuist/FileSystem/pull/308)
## [0.15.0] - 2026-02-27
### Details
#### <!-- 0 -->🚀 Features
- Add setAttributes API to FileSysteming protocol by @pepicrft in [#278](https://github.com/tuist/FileSystem/pull/278)

## [0.14.11] - 2026-01-26
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Ensure touch creates files immediately visible to Foundation APIs by @fortmarek in [#253](https://github.com/tuist/FileSystem/pull/253)

## [0.14.9] - 2026-01-12
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Handle paths with hash characters in glob function by @pepicrft in [#250](https://github.com/tuist/FileSystem/pull/250)

## [0.14.0] - 2025-12-12
### Details
#### <!-- 0 -->🚀 Features
- Add Sendable conformance to FileSysteming protocol by @Ryu0118 in [#237](https://github.com/tuist/FileSystem/pull/237)

## New Contributors
* @Ryu0118 made their first contribution in [#237](https://github.com/tuist/FileSystem/pull/237)
## [0.13.0] - 2025-09-26
### Details
#### <!-- 0 -->🚀 Features
- Implement contentsOfDirectory by @fortmarek in [#181](https://github.com/tuist/FileSystem/pull/181)

## [0.12.0] - 2025-09-22
### Details
#### <!-- 0 -->🚀 Features
- Update swift-nio by @fortmarek in [#174](https://github.com/tuist/FileSystem/pull/174)

## [0.11.0] - 2025-07-23
### Details
#### <!-- 0 -->🚀 Features
- Add API to get the metadata of a particular file by @pepicrft in [#148](https://github.com/tuist/FileSystem/pull/148)

## [0.10.0] - 2025-05-26
### Details
#### <!-- 0 -->🚀 Features
- Expose Glob target as a package product by @yhkaplan in [#130](https://github.com/tuist/FileSystem/pull/130)

## New Contributors
* @yhkaplan made their first contribution in [#130](https://github.com/tuist/FileSystem/pull/130)
## [0.9.0] - 2025-05-15
### Details
#### <!-- 0 -->🚀 Features
- Move FileSystemTestingTrait to a new library product FileSystemTesting by @fortmarek in [#126](https://github.com/tuist/FileSystem/pull/126)

## [0.8.0] - 2025-05-13
### Details
#### <!-- 0 -->🚀 Features
- Add a Swift Testing trait to create and scope a temporary directory to a test or suite lifecycle by @pepicrft
- Add a Swift Testing trait to create and scope a temporary directory to a test or suite lifecycle by @pepicrft

## [0.7.15] - 2025-04-25
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Infinite loop caused by symbolic links pointing to ancestor directories by @monchote in [#120](https://github.com/tuist/FileSystem/pull/120)

## New Contributors
* @monchote made their first contribution in [#120](https://github.com/tuist/FileSystem/pull/120)
## [0.7.13] - 2025-04-17
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Resolve relative symbolic link by @fortmarek in [#116](https://github.com/tuist/FileSystem/pull/116)

## [0.7.11] - 2025-04-15
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Ignore .gitkeep results when globbing by @dogo in [#115](https://github.com/tuist/FileSystem/pull/115)

## New Contributors
* @dogo made their first contribution in [#115](https://github.com/tuist/FileSystem/pull/115)
## [0.7.9] - 2025-03-24
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Crash from long strings when building in Debug by @waltflanagan in [#112](https://github.com/tuist/FileSystem/pull/112)

## New Contributors
* @waltflanagan made their first contribution in [#112](https://github.com/tuist/FileSystem/pull/112)
## [0.7.6] - 2025-02-05
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Temporary directory to return direct path instead of symlink by @fortmarek in [#106](https://github.com/tuist/FileSystem/pull/106)

## [0.7.4] - 2025-02-04
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Unstable ZIPFoundation version by @fortmarek in [#105](https://github.com/tuist/FileSystem/pull/105)

## [0.7.3] - 2025-02-04
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Update URLs APIs to work with linux by @ajkolean in [#103](https://github.com/tuist/FileSystem/pull/103)

## New Contributors
* @ajkolean made their first contribution in [#103](https://github.com/tuist/FileSystem/pull/103)
## [0.7.0] - 2025-01-09
### Details
#### <!-- 0 -->🚀 Features
- Handle relative symbolic links by @KaiOelfke in [#98](https://github.com/tuist/FileSystem/pull/98)

## New Contributors
* @KaiOelfke made their first contribution in [#98](https://github.com/tuist/FileSystem/pull/98)
## [0.6.24] - 2025-01-09
### Details
#### <!-- 7 -->⚙️ Miscellaneous Tasks
- Update Tuist setup to the latest conventions by @fortmarek in [#100](https://github.com/tuist/FileSystem/pull/100)

## [0.6.18] - 2024-11-15
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Recreating directory when on concurrent move by @fortmarek in [#92](https://github.com/tuist/FileSystem/pull/92)

## [0.6.17] - 2024-11-14
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Do not search recursively when a glob is a file name wildcard by @fortmarek in [#90](https://github.com/tuist/FileSystem/pull/90)

## [0.6.15] - 2024-11-11
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Glob with extension options by @fortmarek in [#88](https://github.com/tuist/FileSystem/pull/88)

## [0.6.13] - 2024-11-07
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Removing non-existing file or directory by @fortmarek in [#86](https://github.com/tuist/FileSystem/pull/86)

## [0.6.12] - 2024-11-07
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Use FileManager for file and directory removal to fix performance issues by @fortmarek in [#85](https://github.com/tuist/FileSystem/pull/85)

## [0.6.11] - 2024-11-05
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Ignore .DS_Store results when globbing by @fortmarek in [#84](https://github.com/tuist/FileSystem/pull/84)

## [0.6.10] - 2024-11-05
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Glob when base directory is a symlink by @fortmarek in [#83](https://github.com/tuist/FileSystem/pull/83)

## [0.6.9] - 2024-11-04
### Details
#### <!-- 2 -->🚜 Refactor
- Migrate used subset of swift-glob to FileSystem by @fortmarek in [#82](https://github.com/tuist/FileSystem/pull/82)

## [0.6.8] - 2024-11-04
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Path wildcard with constant component by @fortmarek in [#81](https://github.com/tuist/FileSystem/pull/81)

## [0.6.7] - 2024-11-04
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Matching files with double globstar by @fortmarek in [#80](https://github.com/tuist/FileSystem/pull/80)

## [0.6.5] - 2024-11-01
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Searching for files in symlinked directories by @fortmarek in [#78](https://github.com/tuist/FileSystem/pull/78)

## [0.6.4] - 2024-11-01
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Include hidden files by default by @fortmarek in [#77](https://github.com/tuist/FileSystem/pull/77)

## [0.6.2] - 2024-10-30
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Searching for a constant file by @fortmarek in [#74](https://github.com/tuist/FileSystem/pull/74)

## [0.6.1] - 2024-10-30
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Matching files with a trailing path wildcard by @fortmarek in [#72](https://github.com/tuist/FileSystem/pull/72)

## [0.6.0] - 2024-10-30
### Details
#### <!-- 0 -->🚀 Features
- Improve globbing performance by using parallelized Swift glob implementation by @fortmarek in [#68](https://github.com/tuist/FileSystem/pull/68)

## [0.5.1] - 2024-10-28
### Details
#### <!-- 7 -->⚙️ Miscellaneous Tasks
- Add conventional PR check by @fortmarek in [#64](https://github.com/tuist/FileSystem/pull/64)

## [0.5.0] - 2024-10-24
### Details
#### <!-- 0 -->🚀 Features
- Use different implementation of globbing for more stable behavior by @fortmarek in [#66](https://github.com/tuist/FileSystem/pull/66)

## [0.4.8] - 2024-10-24
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Glob returning paths with resolved symlinks by @fortmarek in [#63](https://github.com/tuist/FileSystem/pull/63)

## [0.4.0] - 2024-10-08
### Details
#### <!-- 0 -->🚀 Features
- Add support for getting the current working directory by @fortmarek in [#52](https://github.com/tuist/FileSystem/pull/52)

## [0.3.1] - 2024-10-07
### Details
#### <!-- 1 -->🐛 Bug Fixes
- Do not throw error when resolving symlink of a plain directory by @fortmarek in [#47](https://github.com/tuist/FileSystem/pull/47)

#### <!-- 7 -->⚙️ Miscellaneous Tasks
- Use TUIST_FILE_SYSTEM_RELEASE_TOKEN for auto-commit by @fortmarek in [#50](https://github.com/tuist/FileSystem/pull/50)
- Update git-cliff by @fortmarek
- Add changelog.md file by @fortmarek in [#49](https://github.com/tuist/FileSystem/pull/49)
- Update release workflow to use git cliff by @fortmarek in [#48](https://github.com/tuist/FileSystem/pull/48)

## New Contributors
* @fortmarek made their first contribution
## [0.1.0] - 2024-06-23
### Details
## New Contributors
* @pepicrft made their first contribution in [#17](https://github.com/tuist/FileSystem/pull/17)
* @renovate[bot] made their first contribution in [#16](https://github.com/tuist/FileSystem/pull/16)
[0.17.3]: https://github.com/tuist/FileSystem/compare/0.17.2..0.17.3
[0.17.0]: https://github.com/tuist/FileSystem/compare/0.16.9..0.17.0
[0.16.4]: https://github.com/tuist/FileSystem/compare/0.16.3..0.16.4
[0.16.2]: https://github.com/tuist/FileSystem/compare/0.16.1..0.16.2
[0.16.1]: https://github.com/tuist/FileSystem/compare/0.16.0..0.16.1
[0.16.0]: https://github.com/tuist/FileSystem/compare/0.15.38..0.16.0
[0.15.31]: https://github.com/tuist/FileSystem/compare/0.15.30..0.15.31
[0.15.26]: https://github.com/tuist/FileSystem/compare/0.15.25..0.15.26
[0.15.0]: https://github.com/tuist/FileSystem/compare/0.14.38..0.15.0
[0.14.11]: https://github.com/tuist/FileSystem/compare/0.14.10..0.14.11
[0.14.9]: https://github.com/tuist/FileSystem/compare/0.14.8..0.14.9
[0.14.0]: https://github.com/tuist/FileSystem/compare/0.13.53..0.14.0
[0.13.0]: https://github.com/tuist/FileSystem/compare/0.12.5..0.13.0
[0.12.0]: https://github.com/tuist/FileSystem/compare/0.11.23..0.12.0
[0.11.0]: https://github.com/tuist/FileSystem/compare/0.10.17..0.11.0
[0.10.0]: https://github.com/tuist/FileSystem/compare/0.9.2..0.10.0
[0.9.0]: https://github.com/tuist/FileSystem/compare/0.8.0..0.9.0
[0.8.0]: https://github.com/tuist/FileSystem/compare/0.7.18..0.8.0
[0.7.15]: https://github.com/tuist/FileSystem/compare/0.7.14..0.7.15
[0.7.13]: https://github.com/tuist/FileSystem/compare/0.7.12..0.7.13
[0.7.11]: https://github.com/tuist/FileSystem/compare/0.7.10..0.7.11
[0.7.9]: https://github.com/tuist/FileSystem/compare/0.7.8..0.7.9
[0.7.6]: https://github.com/tuist/FileSystem/compare/0.7.5..0.7.6
[0.7.4]: https://github.com/tuist/FileSystem/compare/0.7.3..0.7.4
[0.7.3]: https://github.com/tuist/FileSystem/compare/0.7.2..0.7.3
[0.7.0]: https://github.com/tuist/FileSystem/compare/0.6.24..0.7.0
[0.6.24]: https://github.com/tuist/FileSystem/compare/0.6.23..0.6.24
[0.6.18]: https://github.com/tuist/FileSystem/compare/0.6.17..0.6.18
[0.6.17]: https://github.com/tuist/FileSystem/compare/0.6.16..0.6.17
[0.6.15]: https://github.com/tuist/FileSystem/compare/0.6.14..0.6.15
[0.6.13]: https://github.com/tuist/FileSystem/compare/0.6.12..0.6.13
[0.6.12]: https://github.com/tuist/FileSystem/compare/0.6.11..0.6.12
[0.6.11]: https://github.com/tuist/FileSystem/compare/0.6.10..0.6.11
[0.6.10]: https://github.com/tuist/FileSystem/compare/0.6.9..0.6.10
[0.6.9]: https://github.com/tuist/FileSystem/compare/0.6.8..0.6.9
[0.6.8]: https://github.com/tuist/FileSystem/compare/0.6.7..0.6.8
[0.6.7]: https://github.com/tuist/FileSystem/compare/0.6.6..0.6.7
[0.6.5]: https://github.com/tuist/FileSystem/compare/0.6.4..0.6.5
[0.6.4]: https://github.com/tuist/FileSystem/compare/0.6.3..0.6.4
[0.6.2]: https://github.com/tuist/FileSystem/compare/0.6.1..0.6.2
[0.6.1]: https://github.com/tuist/FileSystem/compare/0.6.0..0.6.1
[0.6.0]: https://github.com/tuist/FileSystem/compare/0.5.4..0.6.0
[0.5.1]: https://github.com/tuist/FileSystem/compare/0.5.0..0.5.1
[0.5.0]: https://github.com/tuist/FileSystem/compare/0.4.9..0.5.0
[0.4.8]: https://github.com/tuist/FileSystem/compare/0.4.7..0.4.8
[0.4.0]: https://github.com/tuist/FileSystem/compare/0.3.2..0.4.0
[0.3.1]: https://github.com/tuist/FileSystem/compare/0.3.0..0.3.1

<!-- generated by git-cliff -->
