//
//  ResponseModels.swift
//  CatsAndDogs
//
//  Created by Борисов Тимофей on 28.12.2021.
//

import Foundation

struct URLResponse: Decodable {

    let message: String
}

struct TextResponse: Decodable {

    let fact: String
}
