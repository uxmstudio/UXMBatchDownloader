![UXM Token Field](https://uxmstudio.com/public/images/uxmbatchdownloader.png)

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
## Simple example
```swift
let urls = [ "image_url_1", "image_url_2" ]

let downloader = UXMBatchDownloader(urls: urls)
downloader.maximumConcurrentDownloads = 5
downloader.progress = { (file, progress) in
    print("Finished Step \(progress) : \(file)")
}
downloader.start()
```
URL's can be passed with or without a destination path. If no destination paths are passed, files will simply be downloaded to the documents folder with their original name.

## Interface
```swift
var maximumConcurrentDownloads:Int
var completion:((urls: [String]) -> ())?
var progress:((file: String, progress: Float) -> ())?

init(urls: [String])
init(urls: [String], completion: ((urls: [String]) -> ())?)
init(objects: [UXMBatchObject])
init(objects: [UXMBatchObject], completion: ((urls: [String]) -> ())?)

func start()

func addUrl(url: String)
func addUrl(object: UXMBatchObject)
func addUrls(objects: [UXMBatchObject])

```

## Batch Object
Instead of passing in just a URL's, batch objects (UXMBatchObject) can be passed that contain a url, destination url, as well as options for number of download retries and whether or not the file should be backed up to iCloud.
```swift
var url:String
var destination:String?
var backupToCloud:Bool = false
var numberOfRetries:Int = 0

init(url: String, destination: String?, backupToCloud: Bool = false, numberOfRetries: Int = 0)
```


# Author
Chris Anderson:
- chris@uxmstudio.com
- [Home Page](http://uxmstudio.com)

# License

UXMBatchDownloader is available under the MIT license. See the LICENSE file for more info.
