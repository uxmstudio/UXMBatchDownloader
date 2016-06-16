//
//  UXMBatchDownloader.swift
//  Pods
//
//  Created by Chris Anderson on 6/8/16.
//
//

import Foundation

public class UXMBatchObject {
    
    public var url:String
    public var destination:String?
    public var backupToCloud:Bool = false
    
    public init(url: String, destination: String?, backupToCloud: Bool = false) {
        self.url = url
        self.destination = destination
        self.backupToCloud = backupToCloud
    }
}

public class UXMBatchDownloader: NSObject {
    
    public var maximumConcurrentDownloads:Int = 2 {
        didSet {
            self.queue.maxConcurrentOperationCount = self.maximumConcurrentDownloads
        }
    }
    public var completion:((urls: [String]) -> ())?
    public var progress:((file: String, error: NSError?, progress: Float) -> ())?
    
    private var urls:[UXMBatchObject] = []
    private var successfulUrls:[String] = []
    private var queue = NSOperationQueue()
    private var step = 0
    private var isRunning = false
    private var operationQueueCompletion:NSBlockOperation!
    
    /// Returns a downloader to begin having files added to
    public override init() {
        
        self.queue = NSOperationQueue()
        
        super.init()
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter urls: List of string URL's to be downloaded
    public init(urls: [String]) {
        
        self.queue = NSOperationQueue()

        super.init()
        
        for url in urls {
            self.addUrl(url)
        }
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter objects: List of batch objects to be downloaded
    public init(objects: [UXMBatchObject]) {

        super.init()
        
        for object in objects {
            self.addUrl(object)
        }
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter urls: List of string URL's to be downloaded
    /// - Parameter completion: A block to be called at finish with a list of 
    ///     successfully downloaded urls
    public convenience init(urls: [String], completion: ((urls: [String]) -> ())?) {
        
        self.init(urls: urls)
        self.completion = completion
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter objects: List of batch objects to be downloaded
    /// - Parameter completion: A block to be called at finish with a list of
    ///     successfully downloaded urls
    public convenience init(objects: [UXMBatchObject], completion: ((urls: [String]) -> ())?) {
        
        self.init(objects: objects)
        self.completion = completion
    }
    
    /// Begin downloading the files
    public func start() {
        
        self.isRunning = true
        self.step = 0
        
        self.operationQueueCompletion = NSBlockOperation(block: {
            self.completion?(urls: self.successfulUrls)
        })

        for object in urls {
            self.download(object)
        }
    
        self.queue.addOperation(operationQueueCompletion)
    }
    
    /// Add a single url to the downloader. If running already, 
    ///     will beginning download, else just add to queue.
    ///     File will be downloaded using existing name.
    ///
    /// - Parameter urls: A URL to be downloaded
    public func addUrl(url: String) {
        self.addUrl(UXMBatchObject(url: url, destination: nil))
    }
    
    /// Add a single url to the downloader. If running already,
    ///     will beginning download, else just add to queue.
    ///     File will be downloaded to the provided name.
    ///
    /// - Parameter object: A batch object to be downloaded
    public func addUrl(object: UXMBatchObject) {
        self.urls.append(object)
        if isRunning {
            self.download(object)
        }
    }
    
    /// Add a group of url to the downloader. If running already,
    ///     files will beginning download, else just add to queue.
    ///
    /// - Parameter objects: Array of batch objects to be downloaded
    public func addUrls(objects: [UXMBatchObject]) {
        for object in objects {
            self.addUrl(object)
        }
    }
    
    /// Stop downloading and cancel all pending operations
    public func cancel() {
        queue.cancelAllOperations()
    }
    
    private func download(object: UXMBatchObject) {

        let operation = UXMDownloadOperation(object: object) { (url, destination, data, error) in
            
            /// Always increment step
            self.step += 1
            
            /// If no error, add to list of urls successfully downloaded
            if error == nil {
                self.successfulUrls.append(url)
            }
            
            /// Pass progress back on the main thread
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.progress?(file: destination, error: error, progress: Float(self.step) / Float(self.urls.count))
            }
        }
        self.operationQueueCompletion.addDependency(operation)
        self.queue.addOperation(operation)
    }
}