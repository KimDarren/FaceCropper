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
  
  func showAlert(_ message: String) {
    let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Close", style: .cancel)
    alert.addAction(action)
    self.present(alert, animated: true)
  }
  
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true) {
      guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
        self.configure(image: nil)
        return
      }
      self.configure(image: image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.configure(image: nil)
    }
  }
  
}

extension ViewController: UICollectionViewDataSource {
  
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

