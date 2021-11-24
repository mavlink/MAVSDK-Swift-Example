//
//  ImageViewModel.swift
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 7/30/21.
//

import Foundation
import Combine

class ImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var error: String?

    init(urlString:String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                self?.error = String(describing: error)
                MessageViewModel.shared.message = "Failed to download image: \(error).\nImageURL: \(url)"
                return
            }

            DispatchQueue.main.async {
                guard let data = data, let image = UIImage(data: data) else {
                    MessageViewModel.shared.message = "Failed to download image response code: \((response as! HTTPURLResponse).statusCode)"
                    self?.error = "Error response code: \((response as! HTTPURLResponse).statusCode)"
                    return
                }
                self?.image = image
            }
        }
        
        task.resume()
    }
}
