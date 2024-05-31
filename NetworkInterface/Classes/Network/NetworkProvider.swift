//
//  NetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/21/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A type capable of executing data, data stream, download, upload, multipart form data, and polling requests.
public protocol NetworkProvider: // swiftlint:disable:this
    AdvancedDataNetworkProvider,
    DataNetworkProvider,
    DataStreamNetworkProvider,
    DownloadNetworkProvider,
    MultipartFormDataNetworkProvider,
    PollingNetworkProvider,
    UploadNetworkProvider {}
