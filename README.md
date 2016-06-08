# UXMBatchDownloader

[![CI Status](http://img.shields.io/travis/Chris Anderson/UXMBatchDownloader.svg?style=flat)](https://travis-ci.org/Chris Anderson/UXMBatchDownloader)
[![Version](https://img.shields.io/cocoapods/v/UXMBatchDownloader.svg?style=flat)](http://cocoapods.org/pods/UXMBatchDownloader)
[![License](https://img.shields.io/cocoapods/l/UXMBatchDownloader.svg?style=flat)](http://cocoapods.org/pods/UXMBatchDownloader)
[![Platform](https://img.shields.io/cocoapods/p/UXMBatchDownloader.svg?style=flat)](http://cocoapods.org/pods/UXMBatchDownloader)

Easily download massive numbers of files.

# Installation
## CocoaPods
UXMBatchDownloader is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "UXMBatchDownloader"
```

# Usage
## Start download
```swift
let urls = [ "image_url_1" : "file1.jpg", "image_url_2" : "file2.jpg" ]

let downloader = UXMBatchDownloader(urlsWithDestinations: urls)
downloader.maximumConcurrentDownloads = 5
downloader.progress = { (file, progress) in
    print("Finished Step \(progress) : \(file)")
}
downloader.start()
```

## Interface
```swift
var maximumConcurrentDownloads:Int
var completion:((urls: [String]) -> ())?
var progress:((file: String, progress: Float) -> ())?

init(urls: [String])
init(urls: [String], completion: ((urls: [String]) -> ())?)
init(urlsWithDestinations: [String : String])
init(urlsWithDestinations: [String : String], completion: ((urls: [String]) -> ())?)

func start()

func addUrl(url: String)
func addUrl(url: String, destination: String?)

```


# Author
Chris Anderson:
- chris@uxmstudio.com
- [Home Page](http://uxmstudio.com)

# License

UXMBatchDownloader is available under the MIT license. See the LICENSE file for more info.
