//
// Copyright 2022 Bundesrepublik Deutschland
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

// https://stackoverflow.com/questions/40336819/how-to-use-commoncrypto-for-pbkdf2-in-swift-2-3

import Foundation
import CommonCrypto

extension String {

    func pbkdf2(saltData: Data,
                keyByteCount: Int = 16,
                prf: CCPseudoRandomAlgorithm = CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256),
                rounds: Int = 100_000) throws -> Data {
        guard
            let passwordData = self.data(using: .utf8) else {
                throw CryptoError.general
            }
        var derivedKeyData = Data(count: keyByteCount)
        let result: Int32 = try derivedKeyData.withUnsafeMutableBytes {
            guard let pointer = $0.baseAddress else {
                throw CryptoError.general
            }
            let keyBuffer: UnsafeMutablePointer<UInt8> = pointer.assumingMemoryBound(to: UInt8.self)
            let result: Int32 = try saltData.withUnsafeBytes {
                guard let pointer = $0.baseAddress else { throw CryptoError.general }
                let saltBuffer: UnsafePointer<UInt8> = pointer.assumingMemoryBound(to: UInt8.self)
                return CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    self,
                    passwordData.count,
                    saltBuffer,
                    saltData.count,
                    prf,
                    UInt32(rounds),
                    keyBuffer,
                    keyByteCount)
            }
            return result
        }
        guard result == kCCSuccess else {
            throw CryptoError.general
        }
        return derivedKeyData
    }
}
