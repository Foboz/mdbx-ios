//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/19/21.
//

import Foundation

public struct MDBXGeometry {
  public let sizeLower: Int
  public let sizeNow: Int
  public let sizeUpper: Int
  public let growthStep: Int
  public let shrinkThreshold: Int
  public let pageSize: Int
  
  public init(sizeLower: Int, sizeNow: Int, sizeUpper: Int, growthStep: Int, shrinkThreshold: Int, pageSize: Int) {
    self.sizeLower = sizeLower
    self.sizeNow = sizeNow
    self.sizeUpper = sizeUpper
    self.growthStep = growthStep
    self.shrinkThreshold = shrinkThreshold
    self.pageSize = pageSize
  }
}
