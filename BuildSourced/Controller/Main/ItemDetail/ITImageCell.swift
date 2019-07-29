//
//  PendingCountCell.swift
//  BuildSourced
//
//  Created by Chance on 5/5/17.
//  Copyright © 2017 Chance. All rights reserved.
//

import UIKit

class ITImageCell: UITableViewCell {

    @IBOutlet var colvContent: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    public var arrImages: [String]!
    var nPageNo = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(){
        
    }

}

extension ITImageCell: UICollectionViewDataSource,UICollectionViewDelegate{
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = arrImages.count
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ITImageColvCell", for: indexPath as IndexPath) as! ITImageColvCell
        let _imgPath = arrImages[indexPath.row]
        let _imgUrl: URL!
        let _absPath = getAbsolutePath(aPath: _imgPath)
        if(FileManager.default.fileExists(atPath: _absPath))
        {
            _imgUrl = URL(fileURLWithPath: _absPath)
        }
        else{
            _imgUrl = URL(string: _imgPath)
        }
        cell.ivContent.sd_setImage(with: _imgUrl)
        //cell.initCell(aCoupon: arrRecentCoupons[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}

extension ITImageCell: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.colvContent.frame.width, height: self.colvContent.frame.height)
    }
}

extension ITImageCell: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        nPageNo = Int(scrollView.contentOffset.x / self.colvContent.frame.width);
        refreshUI()
    }
    
    func refreshUI(){
        pageControl.currentPage = nPageNo
        
    }
}

