//
//  OnboardingConfiguration.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

func Init<Type>(_ value : Type, block: (_ object: Type) -> Void) -> Type {
  block(value)
  return value
}
