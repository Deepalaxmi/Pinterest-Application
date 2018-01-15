//
//  APIClient.swift
//  PinterestApplication
//
//  Created by Gary Tokman on 12/6/17.
//  Copyright © 2017 Gary Tokman. All rights reserved.
//

import Foundation

enum Either<T> {
    case success(T)
    case error(Error)
}

enum APIError: Error {
    case unknown, badResponse, jsonDecoder
}

protocol APIClient {
    var session: URLSession { get }
    func get<T: Codable>(with request: URLRequest, completion: @escaping (Either<[T]>) -> Void)
}

extension APIClient {

    var session: URLSession {
        return URLSession.shared
    }

    func get<T: Codable>(with request: URLRequest, completion: @escaping (Either<[T]>) -> Void) {
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.error(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(.error(APIError.badResponse))
                return
            }

            guard let value = try? JSONDecoder().decode([T].self, from: data!) else {
                completion(.error(APIError.jsonDecoder))
                return
            }

            DispatchQueue.main.async {
                completion(.success(value))
            }
        }
        task.resume()
    }
}

