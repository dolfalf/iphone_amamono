//
//  AmazonRequest.swift
//  iphone_amamono
//
//  Created by P1506 on 2019/10/25.
//  Copyright © 2019 archive-asia. All rights reserved.
//

import Foundation
import CryptoSwift
import SwiftyXMLParser

enum AmazonProductAdvertising: String {
    case StandardRegion = "webservices.amazon.co.jp"
    case AWSAccessKey = "AWSAccessKeyId"
    case TimestampKey = "Timestamp"
    case SignatureKey = "Signature"
    case VersionKey = "Version"
    case AssociateTagKey = "AssociateTag"
    case CurrentVersion = "2019-10-25"
}

class AmazonRequest {
    
//    AWSの
//    AccessKeyId
//    SecretKey
//    AssociateTag
    let accessKey: String
    let secret: String
    
    let isbn = "isbn number"
    
    var region: String = AmazonProductAdvertising.StandardRegion.rawValue
    var formatPath: String = "/onca/xml"
    
    init(key: String, secret sec: String) {
        self.secret = sec
        self.accessKey = key
    }
    
    func amazonRequest(parameters: [String: Any]? = nil) -> URLRequest? {
        
        var mutableParameters = parameters!

//        var parameters = "AWSAccessKeyId=" + accessKey
//        parameters += "&AssociateTag=" + "DEFAULT_TAG"
//        parameters += "&IdType=" + "ISBN"
//        parameters += "&ItemId=" + isbn
//        parameters += "&Operation=" + "ItemLookup"
//        parameters += "&SearchIndex=" + "Books"
//        parameters += "&Service=" + "AWSECommerceService"
//        parameters += "&Timestamp=" + Date().jpDate("yyyy-MM-dd'T'HH:mm:ssZZZZZ").urlAWSQueryEncoding()

        if mutableParameters[AmazonProductAdvertising.AWSAccessKey.rawValue] == nil {
            mutableParameters[AmazonProductAdvertising.AWSAccessKey.rawValue] = self.accessKey
        }

        mutableParameters[AmazonProductAdvertising.VersionKey.rawValue] = AmazonProductAdvertising.CurrentVersion.rawValue;
        mutableParameters[AmazonProductAdvertising.TimestampKey.rawValue] = Date().jpDate("yyyy-MM-dd'T'HH:mm:ssZZZZZ").urlAWSQueryEncoding()
        
        //parameterをalphabet順にソート
        let sortedKeys = mutableParameters.keys.sorted {$0 < $1}
        var canonicalStringArray = [String]()
        
        for key in sortedKeys {
            canonicalStringArray.append("\(key)=\(mutableParameters[key]!)")
        }
        
        let canonicalString = canonicalStringArray.joined(separator: "&")
        let encodedCanonicalString = canonicalString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        let target = "GET\n\(region)\n\(formatPath)\n\(encodedCanonicalString)"
        let signature = target.hmac(key: "YOUR SECRET KEY").urlAWSQueryEncoding()
        let urlString = "https://" + region + formatPath + "?\(encodedCanonicalString)&Signature=\(signature)"

        guard let url = URL(string: urlString) else {
            return nil
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        return req
    }
    
    func test(completion: @escaping (Bool, [Product]?) -> Void ) {
        
        let amazonParams = [
            "Service" : "AWSECommerceService",
            "Operation" : "ItemLookup",
            "ResponseGroup" : "Images,ItemAttributes",
            "IdType" : "ASIN",
            "ItemId" : "test",
            "AssociateTag" : "associate_tag_default",
            "Condition" : "All"
        ]
        
        guard let request = amazonRequest(parameters: amazonParams) else {
            return
        }
        
        URLSession().dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                return completion(false, nil)
            }
            
            guard let target = data else {
                return completion(false, nil)
            }
            
            print("parse before: \(target)")
            
            let result = XML.parse(target)
            
            print("parse after: \(result.description)")
            
            let product = Product()
            completion(true, [product])
        }.resume()
    }
    
}

extension Date {
    func jpDate(_ format: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String {
    func urlAWSQueryEncoding() -> String {
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "-")
        if let ret = self.addingPercentEncoding(withAllowedCharacters: allowedCharacters ) {
            return ret
        }
        return ""
    }
    
    func hmac(key: String) -> String {
        guard let keyBytes = key.data(using: .utf8)?.bytes, let mesBytes = self.data(using: .utf8)?.bytes else {
            return ""
        }
        let hmac = try! HMAC(key: keyBytes, variant: .sha256).authenticate(mesBytes)
        return Data(hmac).base64EncodedString()
    }
}
