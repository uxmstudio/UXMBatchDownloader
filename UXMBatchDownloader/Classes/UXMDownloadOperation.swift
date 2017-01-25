//
//  DownloadOperation.swift
//  Pods
//
//  Created by Chris Anderson on 6/8/16.
//
//

import Foundation

class UXMDownloadOperation: UXMConcurrentOperation {
    
    var object: UXMBatchObject
    var destination: String
    var networkOperationCompletionHandler: (_ url: String, _ destination: String, _ data: Data?, _ error: Error?) -> ()
    var numberOfRetries: Int = 0
    var session: URLSession?
    
    weak var task: URLSessionTask?
    
    init(object: UXMBatchObject,
         numberOfRetries: Int = 0,
         session: URLSession? = nil,
         networkOperationCompletionHandler: @escaping (_ url: String, _ destination: String, _ data: Data?, _ error: Error?) -> ()) {
        self.object = object
        self.destination = object.destination ?? (object.url as NSString).lastPathComponent
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        self.numberOfRetries = numberOfRetries
        self.session = session
        
        super.init()
    }
    
    override func main() {
        
        self.startRequest()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    func startRequest() {
        
        if (session == nil) {
            let sessionConfig = URLSessionConfiguration.default
            self.session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        }
        
        guard let url = URL(string: object.url) else {
            
            self.networkOperationCompletionHandler(self.object.url, self.destination, nil, nil)
            self.completeOperation()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        self.task = session!.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if let data = data {
                let filename = self.getDocumentsDirectory().appendingPathComponent(self.destination)
                try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
                
                let url = URL(fileURLWithPath: filename)
                try! (url as NSURL).setResourceValue(!self.object.backupToCloud,
                                                     forKey: URLResourceKey.isExcludedFromBackupKey)
            }
            
            if let _ = error, self.numberOfRetries > 0 {
                self.retry()
            }
            else {
                
                self.networkOperationCompletionHandler(
                    self.object.url,
                    self.destination,
                    data,
                    error
                )
                self.completeOperation()
            }
        })
        task?.resume()
    }
    
    func retry() {
        
        self.numberOfRetries -= 1
        self.startRequest()
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
}
