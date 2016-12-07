//
//  UXMBatchDownloader.swift
//  Pods
//
//  Created by Chris Anderson on 6/8/16.
//
//

import Foundation

open class UXMBatchObject {
    
    open var url: String
    open var destination: String?
    open var backupToCloud: Bool = false
    open var numberOfRetries: Int = 0
    
    public init(url: String, destination: String?, backupToCloud: Bool = false, numberOfRetries: Int = 0) {
        self.url = url
        self.destination = destination
        self.backupToCloud = backupToCloud
        self.numberOfRetries = numberOfRetries
    }
}

open class UXMBatchDownloader: NSObject {
    
    open var maximumConcurrentDownloads: Int = 2 {
        didSet {
            self.queue.maxConcurrentOperationCount = self.maximumConcurrentDownloads
        }
    }
    open var completion: ((_ urls: [String]) -> ())?
    open var progress: ((_ file: String, _ error: Error?, _ progress: Float) -> ())?
    
    fileprivate var urls: [UXMBatchObject] = []
    fileprivate var successfulUrls: [String] = []
    fileprivate var queue = OperationQueue()
    fileprivate var step = 0
    fileprivate var isRunning = false
    fileprivate var operationQueueCompletion:BlockOperation!
    
    /// Returns a downloader to begin having files added to
    public override init() {
        
        self.queue = OperationQueue()
        
        super.init()
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter urls: List of string URL's to be downloaded
    public init(urls: [String]) {
        
        self.queue = OperationQueue()
        
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
    public convenience init(urls: [String], completion: ((_ urls: [String]) -> ())?) {
        
        self.init(urls: urls)
        self.completion = completion
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter objects: List of batch objects to be downloaded
    /// - Parameter completion: A block to be called at finish with a list of
    ///     successfully downloaded urls
    public convenience init(objects: [UXMBatchObject], completion: ((_ urls: [String]) -> ())?) {
        
        self.init(objects: objects)
        self.completion = completion
    }
    
    /// Begin downloading the files
    open func start() {
        
        self.isRunning = true
        self.step = 0
        
        self.operationQueueCompletion = BlockOperation(block: {
            OperationQueue.main.addOperation() {
                self.completion?(self.successfulUrls)
            }
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
    open func addUrl(_ url: String) {
        self.addUrl(UXMBatchObject(url: url, destination: nil))
    }
    
    /// Add a single url to the downloader. If running already,
    ///     will beginning download, else just add to queue.
    ///     File will be downloaded to the provided name.
    ///
    /// - Parameter object: A batch object to be downloaded
    open func addUrl(_ object: UXMBatchObject) {
        self.urls.append(object)
        if isRunning {
            self.download(object)
        }
    }
    
    /// Add a group of url to the downloader. If running already,
    ///     files will beginning download, else just add to queue.
    ///
    /// - Parameter objects: Array of batch objects to be downloaded
    open func addUrls(_ objects: [UXMBatchObject]) {
        for object in objects {
            self.addUrl(object)
        }
    }
    
    /// Stop downloading and cancel all pending operations
    open func cancel() {
        queue.cancelAllOperations()
        self.urls.removeAll()
    }
    
    fileprivate func download(_ object: UXMBatchObject) {
        
        let operation = UXMDownloadOperation(object: object, numberOfRetries: object.numberOfRetries) { (url, destination, data, error) in
            
            /// Always increment step
            self.step += 1
            
            /// If no error, add to list of urls successfully downloaded
            if error == nil {
                self.successfulUrls.append(url)
            }
            
            /// Pass progress back on the main thread
            OperationQueue.main.addOperation() {
                self.progress?(destination, error, Float(self.step) / Float(self.urls.count))
            }
        }
        self.operationQueueCompletion.addDependency(operation)
        self.queue.addOperation(operation)
    }
}
