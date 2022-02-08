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

class CustomCredentialService {
    func credentials() async throws -> [CredentialRecord] {
        try await Aries.agent.run {
            try await Aries.record.search(CredentialRecord.self, in: $0.wallet, with: .none, count: nil, skip: nil)
        }
    }
    
    func request(with connectionId: String) async throws -> String {
        try await Aries.agent.run {
            let connection = try await Aries.record.get(ConnectionRecord.self, for: connectionId, from: $0.wallet)
            
            guard let service = connection.theirDocument().services?.first else {
                return ""
            }
            
            var credentialPreview = CredentialPreview()
            credentialPreview.attributes.append(contentsOf: [
                CredentialAttribute(name: "firstName", value: "Erika"),
                CredentialAttribute(name: "lastName", value: "Mustermann"),
                CredentialAttribute(name: "firmName", value: "MESA Deutschland GmbH"),
                CredentialAttribute(name: "firmSubject", value: "Identitäten"),
                CredentialAttribute(name: "firmCity", value: "Berlin"),
                CredentialAttribute(name: "firmPostalcode", value: "51145"),
                CredentialAttribute(name: "firmStreet", value: "Musterstrasse 2")
            ])
            
            var credentialProposal: CredentialProposalMessage = try await Aries.credential.proposal()
            credentialProposal.credentialId = "akaikNikeYARE9DnS9Jox:3:CL:23:Arbeitgeberbescheinigung_Test3"
            credentialProposal.proposal = credentialPreview
            
            let credentialProposalRequest = MessageRequest(
                message: credentialProposal,
                recipientKeys: service.recipientKeys ?? [],
                senderKey: connection.myVerkey,
                endpoint: service.endpoint
            )
            
            let credentialProposalResponse: MessageResponse<CredentialOfferMessage> = try await Aries.message
                .sendReceive(credentialProposalRequest, with: $0.wallet)
            
            let credentialOffer = credentialProposalResponse.message
            
            let id = try await Aries.credential.process(credentialOffer, for: connectionId, with: $0)
            
            let credentialRequest = try await Aries.credential.request(for: id, with: $0)
            
            let credentialRequestRequest = MessageRequest(
                message: credentialRequest,
                recipientKeys: service.recipientKeys ?? [],
                senderKey: connection.myVerkey,
                endpoint: service.endpoint
            )
            
            let credentialRequestResponse: MessageResponse<CredentialIssueMessage> = try await Aries.message
                .sendReceive(credentialRequestRequest, with: $0.wallet)
            
            let credentialIssue = credentialRequestResponse.message
            
            return try await Aries.credential.process(credentialIssue, with: $0)
        }
    }
}
