//  Copyright (c) 2017 TAEJUN KIM <korean.darren@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import FaceCropper

final class ExampleController: UIViewController {
  
  let imageView: UIImageView
  let collectionView: UICollectionView
  let pickButton: UIButton
  var faces: [UIImage] = []
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: Initializer
  
  init() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = CGSize(width: 100, height: 100)
    
    self.imageView = UIImageView()
    self.imageView.contentMode = .scaleAspectFit
    self.imageView.backgroundColor = .black
    
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    self.collectionView.backgroundColor = .white
    self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    self.collectionView.register(FaceCollectionViewCell.self,
                                 forCellWithReuseIdentifier: "Cell")
    
    self.pickButton = UIButton()
    self.pickButton.backgroundColor = .black
    self.pickButton.setTitle("Pick the image", for: .normal)
    self.pickButton.setTitleColor(.white, for: .normal)
    self.pickButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    
    super.init(nibName: nil, bundle: nil)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError("init(nibName:bundle:) has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    self.collectionView.dataSource = self
    self.pickButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
    self.view.addSubview(self.imageView)
    self.view.addSubview(self.collectionView)
    self.view.addSubview(self.pickButton)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
    self.collectionView.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: self.view.frame.height-200-50)
    self.pickButton.frame = CGRect(x: 0, y: self.view.frame.height-50, width: self.view.frame.width, height: 50)
  }
  
  
  // MARK: Action
  
  func pickImage() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    self.present(imagePicker, animated: true)
  }
  
  func configure(image: UIImage?) {
    self.imageView.image = image
    
    guard let image = image else {
      self.faces = []
      self.collectionView.reloadData()
      return
    }
    
    image.face.crop { result in
      switch result {
      case .success(let faces):
        self.faces = faces
        self.collectionView.reloadData()
      case .notFound:
        self.showAlert("couldn't find any face")
      case .failure(let error):
        self.showAlert(error.localizedDescription)
      }
    }
  }
    
  func drawRectangles(image: UIImage) {
    imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

    image.face.detect { [weak self] result in
        switch result {
        case .success(let rects):
            for rect in rects {
              guard let layer = self?.configureRect(rect: rect, image: image, parent: self?.imageView) else {
                continue
              }
              self?.imageView.layer.addSublayer(layer)
            }
        case .notFound:
            self?.showAlert("couldn't find any face")
        case .failure(let error):
            self?.showAlert(error.localizedDescription)
        }
    }
  }
  
  func configureRect(rect: CGRect, image: UIImage, parent view: UIImageView?) -> CAShapeLayer? {
    guard let view = view else {
      return nil
    }
    
    let size = imageSizeAspectFit(imgview: view)
    
    // Make appropriate calculations to draw rectangle
    let width = rect.width * CGFloat(size.width)
    let height = rect.height * CGFloat(size.height)
    
    let offsetX = (view.bounds.width - size.width) / 2
    let x = rect.origin.x * CGFloat(size.width) + offsetX
    
    let offsetY = image.size.height > view.bounds.height ? height : rect.height * CGFloat(view.bounds.height) / 2
    let y = (1 - rect.origin.y) * CGFloat(size.height) - offsetY
    
    let drawRect = CGRect(x: x, y: y, width: width, height: height)
    
    // Create rect layer
    let layer = CAShapeLayer()
    layer.frame = drawRect
    layer.borderColor = UIColor.yellow.cgColor
    layer.borderWidth = 1
    layer.cornerRadius = 3
    return layer
  }
  
  func isPortrait(image: UIImage) -> Bool {
    return image.size.height >= image.size.width
  }
  
  func showAlert(_ message: String) {
    let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Close", style: .cancel)
    alert.addAction(action)
    self.present(alert, animated: true)
  }
  
  // Get the image size after applying aspect fit for the image in an UIImageView
  func imageSizeAspectFit(imgview: UIImageView) -> CGSize {
    var newwidth: CGFloat
    var newheight: CGFloat
    let image: UIImage = imgview.image!
    
    if image.size.height >= image.size.width {
      newheight = imgview.frame.size.height;
      newwidth = (image.size.width / image.size.height) * newheight
      if newwidth > imgview.frame.size.width {
        let diff: CGFloat = imgview.frame.size.width - newwidth
        newheight = newheight + diff / newheight * newheight
        newwidth = imgview.frame.size.width
      }
    }
    else {
      newwidth = imgview.frame.size.width
      newheight = (image.size.height / image.size.width) * newwidth
      if newheight > imgview.frame.size.height {
        let diff: CGFloat = imgview.frame.size.height - newheight
        newwidth = newwidth + diff / newwidth * newwidth
        newheight = imgview.frame.size.height
      }
    }
    
    return CGSize(width: newwidth, height: newheight)
  }
  
}


extension ExampleController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true) {
      guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
        self.configure(image: nil)
        return
      }
      self.configure(image: image)
      self.drawRectangles(image: image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.configure(image: nil)
    }
  }
  
}

extension ExampleController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FaceCollectionViewCell
    let face = self.faces[indexPath.item]
    cell.configure(face: face)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.faces.count
  }
  
}

