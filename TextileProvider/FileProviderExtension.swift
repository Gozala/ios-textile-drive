//
//  TextileThread.swift
//  TextileProvider
//
//  Created by Irakli Gozalishvili on 6/5/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import FileProvider
//import Textile

class FileProviderExtension: NSFileProviderExtension {
  private lazy var fileManager = FileManager()
  private var recoveryPhrase:String?
  
//  override init() {
//    do {
//      try Textile.initialize(withDebug: false, logToDisk: false)
//      // Return phrase to the user for secure, out of app, storage
//      // Set the Textile delegate to self so we can make use of events such nodeStarted
//      Textile.instance().delegate = self as TextileDelegate
//    } catch {
//      print("Unexpected error: \(error).")
//    }
//  }
//  func nodeStarted() {
//    print("Textile - node started.")
//  }
//  func nodeStopped() {
//    print("Textile - node stopped.")
//  }
//  private func nodeFailedToStartWithError(error:NSError) {
//    print("Textile - node failed to start: \(error).")
//  }
//  private func nodeFailedToStopWithError(error:NSError) {
//    print("Textile -  node failed to stop: \(error).")
//  }
//  func nodeOnline() {
//    print("Textile - node online")
//  }
//  private func willStopNodeInBackgroundAfterDelay(seconds:TimeInterval) {
//    print("Textile - will stop node after delay: %f", seconds)
//  }
//  func canceledPendingNodeStop() {
//    print("Textile - canceled pending stop")
//  }
  
  
  override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
    guard let reference = MediaItemReference(itemIdentifier: identifier) else {
      throw NSError.fileProviderErrorForNonExistentItem(withIdentifier: identifier)
    }
    return FileProviderItem(reference: reference)
  }
  
  override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
    guard let item = try? item(for: identifier) else {
      return nil
    }
    
    return NSFileProviderManager.default.documentStorageURL
      .appendingPathComponent(identifier.rawValue, isDirectory: true)
      .appendingPathComponent(item.filename)
  }
  
  override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
    let identifier = url.deletingLastPathComponent().lastPathComponent
    return NSFileProviderItemIdentifier(identifier)
  }
  
  private func providePlaceholder(at url: URL) throws {
    guard
      let identifier = persistentIdentifierForItem(at: url),
      let reference = MediaItemReference(itemIdentifier: identifier)
      else {
        throw FileProviderError.unableToFindMetadataForPlaceholder
    }
    
    try fileManager.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true,
      attributes: nil
    )
    
    let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
    let item = FileProviderItem(reference: reference)
    
    try NSFileProviderManager.writePlaceholder(
      at: placeholderURL,
      withMetadata: item
    )
  }

  override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
    do {
      try providePlaceholder(at: url)
      completionHandler(nil)
    } catch {
      completionHandler(error)
    }
  }
  
  // Enumeration
  
  override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
    if containerItemIdentifier == .rootContainer {
      return ThreadEnumerator(path:"/")
//      return FileProviderEnumerator(path: "/")
    }

    guard
      let ref = MediaItemReference(itemIdentifier: containerItemIdentifier),
      ref.isDirectory
      else {
        throw FileProviderError.notAContainer
    }

    return FileProviderEnumerator(path: ref.path)
  }

  // Thumbnails

  override func fetchThumbnails(
    for itemIdentifiers: [NSFileProviderItemIdentifier],
    requestedSize size: CGSize,
    perThumbnailCompletionHandler: @escaping (NSFileProviderItemIdentifier, Data?, Error?) -> Void,
    completionHandler: @escaping (Error?) -> Void)
      -> Progress {
    let progress = Progress(totalUnitCount: Int64(itemIdentifiers.count))

    for itemIdentifier in itemIdentifiers {
      let itemCompletion: (Data?, Error?) -> Void = { data, error in
        perThumbnailCompletionHandler(itemIdentifier, data, error)

        if progress.isFinished {
          DispatchQueue.main.async {
            completionHandler(nil)
          }
        }
      }

      guard
        let reference = MediaItemReference(itemIdentifier: itemIdentifier),
        !reference.isDirectory
        else {
          progress.completedUnitCount += 1
          let error = NSError.fileProviderErrorForNonExistentItem(withIdentifier: itemIdentifier)
          itemCompletion(nil, error)
          continue
      }

//      let name = reference.filename
//      let path = reference.containingDirectory

//      let task = NetworkClient.shared.downloadMediaItem(named: name, at: path) { url, error in
//
//        guard
//          let url = url,
//          let data = try? Data(contentsOf: url, options: .alwaysMapped)
//          else {
//            itemCompletion(nil, error)
//            return
//        }
//        itemCompletion(data, nil)
//      }
//
//      progress.addChild(task.progress, withPendingUnitCount: 1)
    }

    return progress
  }


  override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
    guard !fileManager.fileExists(atPath: url.path) else {
      completionHandler(nil)
      return
    }

    guard
      let identifier = persistentIdentifierForItem(at: url),
      let reference = MediaItemReference(itemIdentifier: identifier)
      else {
        completionHandler(FileProviderError.unableToFindMetadataForItem)
        return
    }

//    let name = reference.filename
//    let path = reference.containingDirectory
//    NetworkClient.shared.downloadMediaItem(named: name, at: path, isPreview: false) { fileURL, error in
//      guard let fileURL = fileURL else {
//        completionHandler(error)
//        return
//      }
//
//      do {
//        try self.fileManager.moveItem(at: fileURL, to: url)
//        completionHandler(nil)
//      } catch {
//        completionHandler(error)
//      }
//    }
  }

  override func stopProvidingItem(at url: URL) {
    try? fileManager.removeItem(at: url)
    try? providePlaceholder(at: url)
  }
}
