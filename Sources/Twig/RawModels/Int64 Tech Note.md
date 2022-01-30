Many of Twitter's v1.1 IDs are 64-bit integers.
It might be prudent to mark these as `Int64` in our `Decodable` `struct`.

Instead, we represent these as `Int` (or `Int?` where optional).
1. All modern Apple devices are 64 bit. The app should not run on Intel Macs or the Apple Watch Series 3.
2. `Int64` does not currently conform to `Sendable`, making in inappropriate to use in concurrent code.
     - [Docs](https://developer.apple.com/documentation/swift/int64)
