//
//  TextileThread.swift
//  TextileProvider
//
//  Created by Irakli Gozalishvili on 6/5/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import FileProvider

final class FileProviderItem: NSObject {
  let reference: MediaItemReference

  init(reference: MediaItemReference) {
    self.reference = reference
    super.init()
  }
}


extension FileProviderItem: NSFileProviderItem {
  var itemIdentifier: NSFileProviderItemIdentifier {
    return reference.itemIdentifier
  }
  
  var parentItemIdentifier: NSFileProviderItemIdentifier {
    return reference.parentReference?.itemIdentifier ?? itemIdentifier
  }
  
  var filename: String {
    return reference.filename
  }
  
  var typeIdentifier: String {
    return reference.typeIdentifier
  }

  var capabilities: NSFileProviderItemCapabilities {
    if reference.isDirectory {
      return [.allowsReading, .allowsContentEnumerating]
    } else {
      return [.allowsReading]
    }
  }

  var documentSize: NSNumber? {
    return nil
  }
}
