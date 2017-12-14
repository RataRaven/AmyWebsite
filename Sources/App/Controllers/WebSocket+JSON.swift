//
//  WebSocket+JSON.swift
//  amy_websitePackageDescription
//
//  Created by YangGuang on 11/18/17.
//

import Vapor

extension WebSocket {
    func send(_ json: JSON) throws {
        let js = try json.makeBytes()
        try send(js.makeString())
    }
}
