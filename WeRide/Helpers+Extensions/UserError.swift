//
//  UserError.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import Foundation

enum UserError: LocalizedError {
    case ckError(Error)
       case couldNotUnwrap
       case unexpectedRecordsFound
       case noUserLoggedIn
}
