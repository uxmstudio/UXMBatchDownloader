//
//  ViewController.swift
//  UXMBatchDownloader
//
//  Created by Chris Anderson on 06/08/2016.
//  Copyright (c) 2016 Chris Anderson. All rights reserved.
//

import UIKit
import UXMBatchDownloader

class ViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var progressBar:UIProgressView!
    
    var downloads:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let urls = [
            UXMBatchObject(url: "https://images.unsplash.com/photo-1464013778555-8e723c2f01f8?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=960&q=80", destination: "file1.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=960&q=80", destination: "file2.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1463412855783-af97e375664b?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=961&q=80", destination: "file3.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1463003416389-296a1ad37ca0?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=1080&q=80", destination: "file4.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1462819067004-905a72ea3996?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=961&q=80", destination: "file5.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1461770354136-8f58567b617a?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=960&q=80", destination: "file6.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1461080639469-66d73688fb21?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=855&q=80", destination: "file7.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1460804198264-011ca89eaa43?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=1004&q=80", destination: "file8.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1460500063983-994d4c27756c?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=960&q=80", destination: "file9.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1458400411386-5ae465c4e57e?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=848&q=80", destination: "file10.jpg"),
            UXMBatchObject(url: "https://images.unsplash.com/photo-1452827073306-6e6e661baf57?format=auto&auto=compress&dpr=2&crop=entropy&fit=crop&w=1440&h=1080&q=80", destination: "file11.jpg")
        ]
        
        let downloader = UXMBatchDownloader(objects: urls)
        downloader.maximumConcurrentDownloads = 5
        downloader.progress = { (file, error, progress) in
            print("Finished Step \(progress) : \(file)")
            self.downloads.append(file)
            self.progressBar.progress = progress
            self.tableView.reloadData()
        }
        downloader.completion = { (urls) in
            print("Completed")
        }
        downloader.start()
    }
    
    func image(name: String) -> UIImage? {
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if paths.count > 0 {
            let readPath = (paths[0] as NSString).stringByAppendingPathComponent(name)
            return UIImage(contentsOfFile: readPath)
        }
        return nil
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloads.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath) as! ViewControllerCell
        let imageName = self.downloads[indexPath.row]
        cell.pictureView.image = nil
        cell.pictureView.image = self.image(imageName)
        cell.titleLabel.text = imageName
        
        return cell
    }
}


class ViewControllerCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var pictureView:UIImageView!
}

