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

import Foundation
import Aries

class CustomConnectionService {
    /// Gets the name and image url from an invitation
    func invitee(for url: String) throws -> (String?, String?)? {
        guard
            let components = URLComponents(string: url),
            let base64 = components.queryItems?.first(where: { $0.name == "c_i" })?.value,
            let decoded = Data(base64Encoded: base64) else {
                return nil
            }
        
        let message = try JSONDecoder().decode(ConnectionInvitationMessage.self, from: decoded)
        
        return (message.label, message.imageUrl)
    }
    
    /// Establishes a persistent connection to the inviting party
    func connect(with url: String) async throws -> String {
        try await Aries.agent.run {
            guard
                let components = URLComponents(string: url),
                let base64 = components.queryItems?.first(where: { $0.name == "c_i" })?.value,
                let decoded = Data(base64Encoded: base64) else {
                    return ""
                }
            
            let invitation = try JSONDecoder().decode(ConnectionInvitationMessage.self, from: decoded)
            
            let pair = try await Aries.connection
                .createRequest(for: invitation, with: $0)
            
            let record = pair.1
            var request = pair.0
            request.transport = TransportDecorator(mode: .all)
            
            let message = MessageRequest(
                message: request,
                recipientKeys: invitation.recipientKeys,
                senderKey: record.myVerkey,
                endpoint: invitation.endpoint
            )
            
            let response: ConnectionResponseMessage = try await Aries.message
                .sendReceive(message, with: $0.wallet)
                .message
            
            return try await Aries.connection.processResponse(response, with: record, $0)
        }
    }
}
