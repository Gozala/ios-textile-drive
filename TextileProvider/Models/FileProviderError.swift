//
//  TextileThread.swift
//  TextileProvider
//
//  Created by Irakli Gozalishvili on 6/5/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import Foundation

enum FileProviderError: Error {
  case unableToFindMetadataForPlaceholder
  case unableToFindMetadataForItem
  case notAContainer
  case unableToAccessSecurityScopedResource
  case invalidParentItem
  case noContentFromServer
}
