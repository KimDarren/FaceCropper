//
//  FaceCollectionViewCell.swift
//  FaceCropper_Example
//
//  Created by KimTae jun on 2017. 7. 10..
//  Copyright © 2017년 CocoaPods. All rights reserved.
//

import UIKit

class FaceCollectionViewCell: UICollectionViewCell {
  
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.imageView.contentMode = .scaleAspectFit
    self.contentView.addSubview(self.imageView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.imageView.frame = self.contentView.bounds
  }
  
  func configure(face: UIImage) {
    self.imageView.image = face
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageView.image = nil
  }
}
