//
//  ViewModel.swift
//  CatsAndDogs
//
//  Created by Борисов Тимофей on 28.12.2021.
//

import Combine
import Foundation

class ViewModel {


    @Published var type: ContentType = .cats
    @Published var text: String?
    @Published var imageURL: URL?
    @Published var catsCount: Int = 0
    @Published var dogsCount: Int = 0

    enum ContentType {
        case cats
        case dogs
    }


    private let service: ContentAPIServiceProtocol = ContentAPIService()
    private var disposables = Set<AnyCancellable>()



    func fetchContent() {
        switch type {
        case .cats:
            service.getContentForCats()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .failure:
                            self.text = nil
                        case .finished:
                            self.catsCount += 1
                            break
                        }
                    },
                    receiveValue: { [weak self] text in
                        guard let self = self else { return }
                        self.text = text
                    })
                .store(in: &disposables)

        case .dogs:
            service.getContentForDogs()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .failure:
                            self.imageURL = nil
                        case .finished:
                            self.dogsCount += 1
                            break
                        }
                    },
                    receiveValue: { [weak self] url in
                        guard let self = self else { return }
                        self.imageURL = url
                    })
                .store(in: &disposables)
        }
    }
}
