//
//  ContentAPIService.swift
//  CatsAndDogs
//
//  Created by Борисов Тимофей on 28.12.2021.
//

import Combine
import Foundation

protocol ContentAPIServiceProtocol {
    func getContentForCats() -> AnyPublisher<String, Error>
    func getContentForDogs() -> AnyPublisher<URL, Error>
}

final class ContentAPIService: ContentAPIServiceProtocol {


    private enum Constants {
        static let catsURL = "https://catfact.ninja/fact"
        static let dogsURL = "https://dog.ceo/api/breeds/image/random"
    }



    private let decoder = JSONDecoder()



    func getContentForCats() -> AnyPublisher<String, Error> {
        guard
            let url = URL(string: Constants.catsURL)
        else {
            return Fail(error: URLError(.resourceUnavailable)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { $0.data }
            .decode(type: TextResponse.self, decoder: decoder)
            .compactMap({
                $0.fact
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getContentForDogs() -> AnyPublisher<URL, Error> {
        guard
            let url = URL(string: Constants.dogsURL)
        else {
            return Fail(error: URLError(.resourceUnavailable)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { $0.data }
            .decode(type: URLResponse.self, decoder: decoder)
            .compactMap({
                URL(string: $0.message)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

