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
    public var progress:((file: String, progress: Float) -> ())?
    
    private var urls:[String:String?] = [:]
    private var successfulUrls:[String] = []
    private var queue = NSOperationQueue()
    private var step = 0
    private var isRunning = false
    private var operationQueueCompletion:NSBlockOperation!
    
    public init(urls: [String]) {
        
        self.queue = NSOperationQueue()

        super.init()
        
        for url in urls {
            self.addUrl(url)
        }
        
        self.operationQueueCompletion = NSBlockOperation(block: {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.completion?(urls: self.successfulUrls)
            }
        })
        self.queue.addOperation(operationQueueCompletion)
    }
    
    public init(urlsWithDestinations: [String : String]) {

        super.init()
        
        for (url, destination) in urlsWithDestinations {
            self.addUrl(url, destination: destination)
        }
        
        self.operationQueueCompletion = NSBlockOperation(block: {
            self.completion?(urls: self.successfulUrls)
        })
        self.queue.addOperation(operationQueueCompletion)
    }
    
    convenience init(urls: [String], completion: ((urls: [String]) -> ())?) {
        
        self.init(urls: urls)
        self.completion = completion
    }
    
    convenience init(urlsWithDestinations: [String : String], completion: ((urls: [String]) -> ())?) {
        
        self.init(urlsWithDestinations: urlsWithDestinations)
        self.completion = completion
    }
    
    public func start() {
        
        self.isRunning = true
        self.step = 0
        for (url, destination) in urls {
            self.download(url, destination: destination)
        }
    }
    
    public func addUrl(url: String) {
        self.addUrl(url, destination: nil)
    }
    
    public func addUrl(url: String, destination: String?) {
        self.urls[url] = destination
        if isRunning {
            self.download(url, destination: destination)
        }
    }
    
    public func cancel() {
        queue.cancelAllOperations()
    }
    
    func download(url: String) {
        self.download(url, destination: nil)
    }
    
    func download(url: String, destination: String?) {

        let operation = UXMDownloadOperation(url: url, destination: destination) { (url, destination, data, error) in
            self.step += 1
            self.successfulUrls.append(url)
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.progress?(file: destination, progress: Float(self.step) / Float(self.urls.count))
            }
        }
        self.operationQueueCompletion.addDependency(operation)
        self.queue.addOperation(operation)
    }
}