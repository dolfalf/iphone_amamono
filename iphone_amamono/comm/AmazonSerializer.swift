//
//  AmazonSerializer.swift
//  iphone_amamono
//
//  Created by P1506 on 2019/10/25.
//  Copyright © 2019 archive-asia. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import Alamofire
import CryptoSwift

//enum AmazonProductAdvertising: String {
//    case StandardRegion = "webservices.amazon.com"
//    case AWSAccessKey = "AWSAccessKeyId"
//    case TimestampKey = "Timestamp"
//    case SignatureKey = "Signature"
//    case VersionKey = "Version"
//    case AssociateTagKey = "AssociateTag"
//    case CurrentVersion = "2011-08-01"
//}
//
//let AWSDateISO8601DateFormat3 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//
//
//func amazonRequest(parameters: [String: AnyObject]? = nil, serializer ser: AmazonSerializer?) -> Alamofire.Request {
//
//    let serializer: AmazonSerializer = {
//        if let s = ser {
//            return s
//        } else {
//            //TOOD: const宣言が必要
//            let aws_key_default = ""
//            let aws_secret_default = ""
//            let s = AmazonSerializer(key: aws_key_default, secret: aws_secret_default)
//            s.useSSL = false
//            return s
//        }
//    }()
//
//    let URL = serializer.endpointURL()
//
//    let e = Alamofire.ParameterEncoding.Custom(serializer.serializerBlock())
//
//    let mutableURLRequest = NSMutableURLRequest(URL: URL)
//
//    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
//
//    let encoded: URLRequestConvertible  = e.encode(mutableURLRequest, parameters: parameters).0
//
//    return Alamofire.request(encoded)
//}
//
//class AmazonSerializer {
//
//    let accessKey: String
//    let secret: String
//
//    var region: String = AmazonProductAdvertising.StandardRegion.rawValue
//    var formatPath: String = "/onca/xml"
//    var useSSL = true
//
//    init(key: String, secret sec: String) {
//        self.secret = sec
//        self.accessKey = key
//    }
//
//    func endpointURL() -> NSURL {
//        let scheme = useSSL ? "https" : "http"
//        let URL = NSURL(string: "\(scheme)://\(region)\(formatPath)")
//        return URL!
//    }
//
//    func serializerBlock() -> (URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
//        return { (req, params) -> (NSMutableURLRequest, NSError?) in
//
//            // TODO: if params == nil error out ASAP
//
//            var mutableParameters = params!
//
//            let timestamp = AmazonSerializer.ISO8601FormatStringFromDate(date: NSDate())
//
//            if mutableParameters[AmazonProductAdvertising.AWSAccessKey.rawValue] == nil {
//                mutableParameters[AmazonProductAdvertising.AWSAccessKey.rawValue] = self.accessKey
//            }
//
//
//            mutableParameters[AmazonProductAdvertising.VersionKey.rawValue] = AmazonProductAdvertising.CurrentVersion.rawValue;
//            mutableParameters[AmazonProductAdvertising.TimestampKey.rawValue] = timestamp;
//
//            var canonicalStringArray = [String]()
//
//            // alphabetize
//            let sortedKeys = Array(mutableParameters.keys).sort {$0 < $1}
//
//            for key in sortedKeys {
//                canonicalStringArray.append("\(key)=\(mutableParameters[key]!)")
//            }
//
//            let canonicalString = canonicalStringArray.joined(separator: "&")
//
//            let encodedCanonicalString = CFURLCreateStringByAddingPercentEscapes(
//                nil,
//                canonicalString,
//                nil,
//                ":,",//"!*'();:@&=+$,/?%#[]",
//                CFStringBuiltInEncodings.UTF8.rawValue
//            )
//
//            let method = req.URLRequest.HTTPMethod
//
//            let signature = "\(method)\n\(self.region)\n\(self.formatPath)\n\(encodedCanonicalString)"
//
//            let encodedSignatureData = signature.hmacSHA256(self.secret)
//            var encodedSignatureString = encodedSignatureData.base64EncodedString()
//
//            encodedSignatureString = CFURLCreateStringByAddingPercentEscapes(
//                nil,
//                encodedSignatureString,
//                nil,
//                "+=",//"!*'();:@&=+$,/?%#[]",
//                CFStringBuiltInEncodings.UTF8.rawValue
//            ) as String
//
//            let newCanonicalString = "\(encodedCanonicalString)&\(AmazonProductAdvertising.SignatureKey.rawValue)=\(encodedSignatureString)"
//
//            let absString = req.URLRequest.URL!.absoluteString
//
//            let urlString = req.URLRequest.URL?.query != nil ? "\(absString)&\(newCanonicalString)" : "\(absString)?\(newCanonicalString)"
//
//            let request = req.URLRequest.mutableCopy() as! NSMutableURLRequest
//            request.URL = NSURL(string: urlString)
//
//            return (request, nil)
//        }
//    }
//
//
//    private class func ISO8601FormatStringFromDate(date: NSDate) -> NSString {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.timeZone = NSTimeZone(name: "GMT")
//        dateFormatter.dateFormat = AWSDateISO8601DateFormat3//"YYYY-MM-dd'T'HH:mm:ss'Z'"
//        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//        return dateFormatter.stringFromDate(date)
//    }
//
//
//}
//
//
//// XML ResponseSerializer
//
//extension Request {
//    class func XMLResponseSerializer() -> GenericResponseSerializer<Dictionary<String,AnyObject>> {
//
//        return GenericResponseSerializer {
//            request, response, data in
//
//            guard data != nil else {
//                let failureReason = "Data could not be serialized. Input data was nil."
//                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//                return .Failure(data, error)
//            }
//
//            let parser = SHXMLParser()
//
//            if let document = parser.parseData(data) as? [String: AnyObject] {
//                return .Success(document)
//            } else {
//                let failureReason = "Data could not be serialized. for some unknwon reason"
//                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//                return .Failure(data, error as NSError)
//            }
//
//        }
//    }
//
//    public func responseXML(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Dictionary<String, AnyObject>?, ErrorType?) -> Void) -> Self {
//        let ser = Request.XMLResponseSerializer()
//
//        return response(queue: dispatch_get_main_queue(), responseSerializer: ser) {
//            req, res, xmlResult in
//
//            switch xmlResult {
//            case .Failure( _, let err): completionHandler(req, res, nil, err)
//            case .Success(let xml): completionHandler(req, res, xml, nil)
//            }
//
//        }
//    }
//}
//
//extension String {
//
////    Digest
////    let hash = "string".sha512
////    HMAC
////    let hmac = "string".digest(.SHA512, key: "some key")
//    func hmacSHA256(key: String) -> String {
//        let cKey = key.cString(using: String.Encoding.utf8)
//        let cData = self.cString(using: String.Encoding.utf8)
//        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
//        let hmacData:NSData = NSData(bytes: result, length: (Int(CC_SHA256_DIGEST_LENGTH)))
//        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
//        return String(hmacBase64)
//    }
//}
//
//extension AmazonSerializer {
//
//    let associate_tag_default = "weio-20"
//    let aws_key_default = "your amazon key"
//    let aws_secret_default = "your amazon secret"
//
//    let asin = "B00DVDMRX6" // an amazon id to search for
//    let serializer = AmazonSerializer(key: aws_key_default, secret: aws_secret_default)
//
//    let amazonParams = [
//        "Service" : "AWSECommerceService",
//        "Operation" : "ItemLookup",
//        "ResponseGroup" : "Images,ItemAttributes",
//        "IdType" : "ASIN",
//        "ItemId" : asin,
//        "AssociateTag" : associate_tag_default,
//        "Condition" : "All"
//    ]
//
//    amazonRequest(parameters: amazonParams, serializer: serializer).responseXML { (req, res, data, error) -> Void in
//        println("Got results! \(data)")
//    }
//    
//}
