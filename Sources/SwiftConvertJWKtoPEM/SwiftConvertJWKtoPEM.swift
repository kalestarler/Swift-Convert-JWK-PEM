//
//  SwiftConvertJWKtoPEM.swift
//  SwiftConvertJWKtoPEM
//
//  Created by kalestarler on 12 Nov 2023.
//

import Foundation
import Security

class SwiftConvertJWKtoPEM {
    
    // MARK: - Public Functions
    
    static public func getPublicKey(jwksURL: URL, completion: @escaping (Result<String, swiftConvertJWKPEMError>) -> Void) {
        
        DispatchQueue.global().async {
            
            URLSession.shared.dataTask(with: jwksURL) { data, response, error in
                if let error = error {
                    
                    DispatchQueue.main.async {
                        completion(.failure(.retrieveJWKSError(reason: "Error loading JWKS from URL: " + error.localizedDescription)))
                    }
                    return
                }
                
                guard let data = data else {
                    
                    DispatchQueue.main.async {
                        completion(.failure(.retrieveJWKSError(reason: "Error loading JWKS from URL")))
                    }
                    return
                }
                
                do {
                    
                    let jwks = try JSONDecoder().decode(JWKS.self, from: data)
                    
                    guard let jwk = jwks.keys.first(where: { $0.use == "sig" && $0.kty == "RSA" }) else {
                        
                        DispatchQueue.main.async {
                            completion(.failure(.retrieveJWKSError(reason: "Error decoding JWKS data from URL")))
                        }
                        return
                    }
                    
                    if let pemKey = self.convertJWKToPEM(jwk: jwk) {

                        DispatchQueue.main.async {
                            completion(.success(pemKey))
                        }
                        return
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        completion(.failure(.retrieveJWKSError(reason: "Error decoding JWKS data from URL")))
                    }
                    return
                }
                
            }.resume()
        }
    }
    
    // MARK: - Private Functions
    
    static private func base64URLDecode(_ base64URL: String) -> Data? {
        var base64 = base64URL
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64.count % 4 != 0 {
            base64 += "="
        }
        
        return Data(base64Encoded: base64)
    }
    
    static private func encodeASN1Integer(_ data: Data) -> Data {
        
        guard !data.isEmpty else {
            print("Data not valid, cannot proceed with AS1 encoding.")
            return Data()
        }
        
        var result = Data()
        
        // If the first bit of the byte is 1, prepend 0x00 to indicate it's a positive integer
        if data.first! & 0x80 != 0 {
            result.append(0x00)
        }
        
        result.append(data)
        
        // Prepend the ASN.1 INTEGER identifier
        let encodedLength = encodeLength(result.count)
        return Data([0x02]) + encodedLength + result
    }
    
    static private func encodeLength(_ length: Int) -> Data {
        if length < 128 {
            // Short form length encoding
            return Data([UInt8(length)])
        } else {
            // Long form length encoding
            let lengthBytes = withUnsafeBytes(of: length.bigEndian) { Data($0) }.drop(while: { $0 == 0 })
            let lengthOfLengthByte = UInt8(128 + lengthBytes.count)
            return Data([lengthOfLengthByte]) + lengthBytes
        }
    }
    
    static private func createPublicKeyASN1Sequence(modulus: Data, exponent: Data) -> Data {
        let modulusASN1 = encodeASN1Integer(modulus)
            let exponentASN1 = encodeASN1Integer(exponent)

            let totalLength = modulusASN1.count + exponentASN1.count
            let encodedLength = encodeLength(totalLength)

            // ASN.1 SEQUENCE identifier (0x30) followed by the encoded length
            return Data([0x30]) + encodedLength + modulusASN1 + exponentASN1
    }
    
    static private func convertToPEMFormat(derEncodedSequence: Data) -> String {
        let base64Encoded = derEncodedSequence.base64EncodedString(options: .lineLength64Characters)
        return "-----BEGIN PUBLIC KEY-----\n\(base64Encoded)\n-----END PUBLIC KEY-----"
    }
    
    static func convertJWKToPEM(jwk: JWK) -> String? {
        
        guard let modulusData = base64URLDecode(jwk.n),
              let exponentData = base64URLDecode(jwk.e) else {
            return nil
        }
        
        let asn1Sequence = createPublicKeyASN1Sequence(modulus: modulusData, exponent: exponentData)
        return convertToPEMFormat(derEncodedSequence: asn1Sequence)
    }
}

struct JWKS: Codable {
    var keys: [JWK]
}

struct JWK: Codable {
    var kty: String
    var use: String?
    var kid: String
    var alg: String
    var n: String   // Modulus
    var e: String   // Exponent
}

enum swiftConvertJWKPEMError: Error {
    case retrieveJWKSError(reason: String)
    case convertJWKtoPEMError(reason: String)
}
