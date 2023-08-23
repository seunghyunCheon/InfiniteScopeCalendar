//
//  CoreDataLottoEntityPersistenceService.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/23.
//

import Foundation
import Combine

fileprivate enum CoreDataLottoEntityPersistenceServiceError: LocalizedError {
    
    case failedToInitializeCoreDataContainer
    case failedToCreateGoalAmount
    case failedToFetchGoalAmount
    
    var errorDescription: String? {
        switch self {
        case .failedToInitializeCoreDataContainer:
            return "CoreDataContainer 초기화에 실패했습니다."
        case .failedToCreateGoalAmount:
            return "GoalAmount 엔티티 생성에 실패했습니다."
        case .failedToFetchGoalAmount:
            return "GoalAmount 엔티티 불러오기에 실패했습니다."
        }
    }
}

final class CoreDataLottoEntityPersistenceService {
    
    private let coreDataPersistenceService: CoreDataPersistenceService
    
    init(coreDataPersistenceService: CoreDataPersistenceService) {
        self.coreDataPersistenceService = coreDataPersistenceService
    }
    
    func fetchGoalAmount(date: Date) -> AnyPublisher<[Lotto], Error> {
        guard let context = coreDataPersistenceService.backgroundContext else {
            return Fail(error: CoreDataLottoEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                let fetchRequest = Lotto.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "date == %@", date as CVarArg)
                do {
                    let fetchResult = try context.fetch(fetchRequest)
                    promise(.success(fetchResult))
                } catch {
                    promise(.failure(CoreDataLottoEntityPersistenceServiceError.failedToFetchGoalAmount))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func saveGoalAmountEntity(_ date: Date) -> AnyPublisher<Void, Error> {
        guard let context = coreDataPersistenceService.backgroundContext else {
            return Fail(error: CoreDataLottoEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                do {
                    let newLotto = Lotto(context: context)
                    newLotto.date = date
                    newLotto.amount = 10000
                    newLotto.type = "스피또"
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(CoreDataLottoEntityPersistenceServiceError.failedToCreateGoalAmount))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

