//
//  DownloadOperation.swift
//  Pods
//
//  Created by Chris Anderson on 6/8/16.
//
//

import Foundation

class UXMDownloadOperation: UXMConcurrentOperation {
    
    let url: String
    let destination: String
    let networkOperationCompletionHandler: (url: String, destination: String, data: NSData?, error: NSError?) -> ()
    
    weak var task:NSURLSessionTask?
    
    init(url: String, destination: String?, networkOperationCompletionHandler: (url: String, destination: String, data: NSData?, error: NSError?) -> ()) {
        self.url = url
        self.destination = destination ?? (url as NSString).lastPathComponent
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        super.init()
    }
    
    override func main() {
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        self.task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let data = data {
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(self.destination)
                data.writeToFile(filename, atomically: true)
            }
            
            self.networkOperationCompletionHandler(url: self.url, destination: self.destination, data: data, error: error)
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