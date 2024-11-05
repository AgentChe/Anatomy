//
//  APIFormDataRequestBody.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 04.11.2024.
//

import Alamofire

protocol APIFormDataRequestBody {
    var url: String { get }
    var parameters: [String: Data]? { get }
    var headers: HTTPHeaders? { get }
    var image: UIImage { get }
}
