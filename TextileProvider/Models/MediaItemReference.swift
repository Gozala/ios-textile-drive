//
//  TextileThread.swift
//  TextileProvider
//
//  Created by Irakli Gozalishvili on 6/5/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import FileProvider
import MobileCoreServices

struct MediaItemReference {
  static let scheme:String = "textile"
  private let urlRepresentation: URL
  
  private var isRoot: Bool {
    return urlRepresentation.path == "/"
  }
  
  private init(urlRepresentation: URL) {
    self.urlRepresentation = urlRepresentation
  }
  
  init(path: String, filename: String) {
    let isDirectory = filename.components(separatedBy: ".").count == 1
    let pathComponents = path.components(separatedBy: "/").filter {
      !$0.isEmpty
    } + [filename]
    
    var absolutePath = "/" + pathComponents.joined(separator: "/")
    if isDirectory {
      absolutePath.append("/")
    }
    absolutePath = absolutePath.addingPercentEncoding(
      withAllowedCharacters: .urlPathAllowed
    ) ?? absolutePath
    
    self.init(urlRepresentation: URL(string: "\(MediaItemReference.scheme)://\(absolutePath)")!)
  }
  
  init?(itemIdentifier: NSFileProviderItemIdentifier) {
    guard itemIdentifier != .rootContainer else {
      self.init(urlRepresentation: URL(string: "\(MediaItemReference.scheme):///")!)
      return
    }
    
    guard let data = Data(base64Encoded: itemIdentifier.rawValue),
      let url = URL(dataRepresentation: data, relativeTo: nil) else {
        return nil
    }
    
    self.init(urlRepresentation: url)
  }

  var itemIdentifier: NSFileProviderItemIdentifier {
    if isRoot {
      return .rootContainer
    } else {
      return NSFileProviderItemIdentifier(
        rawValue: urlRepresentation.dataRepresentation.base64EncodedString()
      )
    }
  }

  var isDirectory: Bool {
    return urlRepresentation.hasDirectoryPath
  }

  var path: String {
    return urlRepresentation.path
  }

  var containingDirectory: String {
    return urlRepresentation.deletingLastPathComponent().path
  }

  var filename: String {
    return urlRepresentation.lastPathComponent
  }

  var typeIdentifier: String {
    guard !isDirectory else {
      return kUTTypeFolder as String
    }
    
    let pathExtension = urlRepresentation.pathExtension
    let unmanaged = UTTypeCreatePreferredIdentifierForTag(
      kUTTagClassFilenameExtension,
      pathExtension as CFString,
      nil
    )
    let retained = unmanaged?.takeRetainedValue()
    
    return (retained as String?) ?? ""
  }

  var parentReference: MediaItemReference? {
    guard !isRoot else {
      return nil
    }
    return MediaItemReference(
      urlRepresentation: urlRepresentation.deletingLastPathComponent()
    )
  }
}
