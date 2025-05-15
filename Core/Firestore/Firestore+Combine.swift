//
//  Core/Firestore/Firestore+Combine.swift
//

import Combine
import FirebaseFirestore

extension Query {

    /// Combine publisher that decodes each snapshot into the supplied `Decodable` type.
    func snapshotPublisher<T: Decodable>(as type: T.Type) -> AnyPublisher<[T], Error> {
        Future { promise in
            self.addSnapshotListener { snap, err in
                if let err { promise(.failure(err)); return }

                let models = snap?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                promise(.success(models))
            }
        }
        .eraseToAnyPublisher()
    }
}
