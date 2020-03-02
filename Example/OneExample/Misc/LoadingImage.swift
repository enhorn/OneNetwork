//
//  LoadingImage.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct LoadingImage : View {

	private static let session = URLSession(configuration: .default)
	@State private var task: URLSessionDataTask?

	let url: URL
    let label: String

	@State var image: Image

	var body: some View {
		image
			.resizable()
			.onAppear {
				let task = LoadingImage.session.dataTask(with: self.url) { data, _, _ in
					guard let data = data, let img = UIImage(data: data), let cgImage = img.cgImage else { return }
                    self.image = Image(cgImage, scale: UIScreen.main.scale, label: Text(self.label))
					self.task = nil
				}
				task.resume()
				self.task = task

			}
			.onDisappear {
				self.task?.cancel()
				self.task = nil
			}
	}

}
