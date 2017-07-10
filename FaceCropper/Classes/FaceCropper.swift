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
import Vision

public enum FaceCropResult<T> {
  case success([T])
  case notFound
  case failure(Error)
}

public struct FaceCropper<T> {
  let detectable: T
  init(_ detectable: T) {
    self.detectable = detectable
  }
}

public protocol FaceCroppable {
}

public extension FaceCroppable {
  var face: FaceCropper<Self> {
    return FaceCropper(self)
  }
}

public extension FaceCropper where T: CGImage {
  
  func crop(_ completion: @escaping (FaceCropResult<CGImage>) -> Void) {
    
    guard #available(iOS 11.0, *) else {
      return
    }
    
    let req = VNDetectFaceRectanglesRequest { request, error in
      guard error == nil else {
        completion(.failure(error!))
        return
      }
      
      let faceImages = request.results?.map({ result -> CGImage? in
        guard let face = result as? VNFaceObservation else { return nil }
        
        let width = face.boundingBox.width * CGFloat(self.detectable.width)
        let height = face.boundingBox.height * CGFloat(self.detectable.height)
        let x = face.boundingBox.origin.x * CGFloat(self.detectable.width)
        let y = (1 - face.boundingBox.origin.y) * CGFloat(self.detectable.height) - height
        
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        let faceImage = self.detectable.cropping(to: croppingRect)
        
        return faceImage
      }).flatMap { $0 }
      
      guard let result = faceImages, result.count > 0 else {
        completion(.notFound)
        return
      }
      
      completion(.success(result))
    }
    
    do {
      try VNImageRequestHandler(cgImage: self.detectable, options: [:]).perform([req])
    } catch let error {
      completion(.failure(error))
    }
  }
}

public extension FaceCropper where T: UIImage {
  
  func crop(_ completion: @escaping (FaceCropResult<UIImage>) -> Void) {
    guard #available(iOS 11.0, *) else {
      return
    }
    
    self.detectable.cgImage!.face.crop { result in
      switch result {
      case .success(let cgFaces):
        let faces = cgFaces.map { cgFace -> UIImage in
          return UIImage(cgImage: cgFace)
        }
        completion(.success(faces))
      case .notFound:
        completion(.notFound)
      case .failure(let error):
        completion(.failure(error))
      }
    }
    
  }
  
}

extension NSObject: FaceCroppable {}
extension CGImage: FaceCroppable {}

