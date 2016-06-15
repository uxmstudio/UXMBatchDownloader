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
    let networkOperationCompletionHandler: (url: String, destination: String, data: NSData?, error: NSError?) -> ()
    
    weak var task:NSURLSessionTask?
    
    init(object: UXMBatchObject, networkOperationCompletionHandler: (url: String, destination: String, data: NSData?, error: NSError?) -> ()) {
        self.object = object
        self.destination = object.destination ?? (object.url as NSString).lastPathComponent
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        super.init()
    }
    
    override func main() {
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: NSURL(string: object.url)!)
        request.HTTPMethod = "GET"
        
        self.task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let data = data {
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(self.destination)
                data.writeToFile(filename, atomically: true)
                
                var url = NSURL(fileURLWithPath: filename)
                try! url.setResourceValue(!self.object.backupToCloud,
                                          forKey: NSURLIsExcludedFromBackupKey)
            }
            
            self.networkOperationCompletionHandler(url: self.object.url, destination: self.destination, data: data, error: error)
            self.completeOperation()
        }
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}