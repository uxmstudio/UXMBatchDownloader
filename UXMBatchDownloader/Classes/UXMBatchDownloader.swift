//
//  UXMBatchDownloader.swift
//  Pods
//
//  Created by Chris Anderson on 6/8/16.
//
//

import Foundation

public class UXMBatchDownloader: NSObject {
    
    public var maximumConcurrentDownloads:Int = 2 {
        didSet {
            self.queue.maxConcurrentOperationCount = self.maximumConcurrentDownloads
        }
    }
    public var completion:((urls: [String]) -> ())?
    public var progress:((file: String, error: NSError?, progress: Float) -> ())?
    
    private var urls:[String:String?] = [:]
    private var successfulUrls:[String] = []
    private var queue = NSOperationQueue()
    private var step = 0
    private var isRunning = false
    private var operationQueueCompletion:NSBlockOperation!
    
    /// Returns a downloader to begin having files added to
    public override init() {
        
        self.queue = NSOperationQueue()
        
        super.init()
        
        self.setupCompletion()
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
        
        self.setupCompletion()
    }
    
    /// Returns a downloader with the list of urls being
    /// downloaded using their existing file names
    ///
    /// - Parameter urlsWithDestinations: List of string URL's to be downloaded
    ///     with their corresponding filename to be saved as
    public init(urlsWithDestinations: [String : String]) {

        super.init()
        
        for (url, destination) in urlsWithDestinations {
            self.addUrl(url, destination: destination)
        }
        
        self.setupCompletion()
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
    /// - Parameter urlsWithDestinations: List of string URL's to be downloaded
    ///     with their corresponding filename to be saved as
    /// - Parameter completion: A block to be called at finish with a list of
    ///     successfully downloaded urls
    public convenience init(urlsWithDestinations: [String : String], completion: ((urls: [String]) -> ())?) {
        
        self.init(urlsWithDestinations: urlsWithDestinations)
        self.completion = completion
    }
    
    private func setupCompletion() {
        
        self.operationQueueCompletion = NSBlockOperation(block: {
            self.completion?(urls: self.successfulUrls)
        })
        self.queue.addOperation(operationQueueCompletion)
    }
    
    /// Begin downloading the files
    public func start() {
        
        self.isRunning = true
        self.step = 0
        for (url, destination) in urls {
            self.download(url, destination: destination)
        }
    }
    
    /// Add a single url to the downloader. If running already, 
    ///     will beginning download, else just add to queue.
    ///     File will be downloaded using existing name.
    ///
    /// - Parameter urls: A URL to be downloaded
    public func addUrl(url: String) {
        self.addUrl(url, destination: nil)
    }
    
    /// Add a single url to the downloader. If running already,
    ///     will beginning download, else just add to queue.
    ///     File will be downloaded using existing name.
    ///
    /// - Parameter url: A URL to be downloaded
    /// - Parameter url: A name or path to save the file in the documents folder in
    public func addUrl(url: String, destination: String?) {
        self.urls[url] = destination
        if isRunning {
            self.download(url, destination: destination)
        }
    }
    
    /// Stop downloading and cancel all pending operations
    public func cancel() {
        queue.cancelAllOperations()
    }
    
    private func download(url: String) {
        self.download(url, destination: nil)
    }
    
    private func download(url: String, destination: String?) {

        let operation = UXMDownloadOperation(url: url, destination: destination) { (url, destination, data, error) in
            
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