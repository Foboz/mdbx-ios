//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/30/21.
//

import Foundation

protocol Incrementable {
  func increment() -> Self?
  func decrement() -> Self?
}

final class Generator<T: Incrementable> {
  private(set) var value: T
  
  init(value: T) {
    self.value = value
  }
  
  func increment() -> Bool {
    guard let incremented = value.increment() else {
      return false
    }
    
    value = incremented
    return true
  }
  
  func decrement() -> Bool {
    guard let decremented = value.decrement() else {
      return false
    }
    
    value = decremented
    return true
  }
}

extension Int: Incrementable {
  func increment() -> Int? {
    if self == Int.max {
      return nil
    }
    return self + 1
  }
  
  func decrement() -> Int? {
    if self == Int.min {
      return nil
    }
    
    return self - 1
  }
}
