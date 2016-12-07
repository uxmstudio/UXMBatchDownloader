//
//  UXMConcurrentOperation.swift
//  Pods
//
//  Created by Chris Anderson on 6/8/16.
//
//

import Foundation

class UXMConcurrentOperation : Operation {
    
    override var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if (_executing != newValue) {
                self.willChangeValue(forKey: "isExecuting")
                _executing = newValue
                self.didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished: Bool = false;
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if (_finished != newValue) {
                self.willChangeValue(forKey: "isFinished")
                _finished = newValue
                self.didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    /// This will result in the appropriate KVN of isFinished and isExecuting
    func completeOperation() {
        isExecuting = false
        isFinished  = true
    }
    
    override func start() {
        if (isCancelled) {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        main()
    }
}
