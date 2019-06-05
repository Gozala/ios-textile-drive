//
//  TextileThread.swift
//  TextileProvider
//
//  Created by Irakli Gozalishvili on 6/5/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import FileProvider


class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
  private let path: String
  init(path: String) {
    self.path = path
    super.init()
  }
  
  func invalidate() {
  }
  
  func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
      // TODO: Use Textile API for enumration instead.
      let mediaItems:[MediaItem] = [MediaItem(name:"Hello", size:0)]
      let items = mediaItems.map { mediaItem -> FileProviderItem in
        let ref = MediaItemReference(path: self.path, filename: mediaItem.name)
        return FileProviderItem(reference: ref)
      }

      observer.didEnumerate(items)
      observer.finishEnumerating(upTo: nil)
  }
}

class ThreadContentEnumerator: NSObject, NSFileProviderEnumerator {
  private let path: String
  init(path: String) {
    self.path = path
    super.init()
  }
  
  func invalidate() {
  }
  
  func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
    // TODO: Use Textile API for enumration instead.
    let mediaItems:[MediaItem] = [MediaItem(name:"Hello", size:0)]
    let items = mediaItems.map { mediaItem -> FileProviderItem in
      let ref = MediaItemReference(path: self.path, filename: mediaItem.name)
      return FileProviderItem(reference: ref)
    }
    
    observer.didEnumerate(items)
    observer.finishEnumerating(upTo: nil)
  }
}

class ThreadEnumerator: NSObject, NSFileProviderEnumerator {
  private let path: String
  init(path: String) {
    self.path = path
    super.init()
  }
  func invalidate() {
  }
  
  func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
    
    // TODO: Use Textile API for enumration instead.
    let mediaItems:[TextileThread] = [
      TextileThread(name:"Account Pages", key: "", id: "", type:"READ_ONLY"),
      TextileThread(name:"Profile Images", key: "profile", id: "", type:""),
      TextileThread(name:"Basic", key: "", id: "", type:"")
    ]
    let items = mediaItems.map { mediaItem -> FileProviderItem in
      let ref = MediaItemReference(path: self.path, filename: mediaItem.name)
      return FileProviderItem(reference: ref)
    }
    
    observer.didEnumerate(items)
    observer.finishEnumerating(upTo: nil)
  }
}
