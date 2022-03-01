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
import Mediator

class CustomCredentialService {
    
    private let mapping = [
        "firstName": "Vorname",
        "lastName": "Nachname",
        "firmName": "Firmenname",
        "firmSubject": "Abteilung",
        "firmStreet": "Straße",
        "firmPostalcode": "PLZ",
        "firmCity": "Stadt"
    ]
    
    func credentials() async throws -> [CredentialPreview] {
        try await Aries.agent.run {
            try await Aries.record.search(CredentialRecord.self, with: $0, matching: .none, count: nil, skip: nil)
        }.map { record in
            var preview = CredentialPreview()
            preview.attributes = record.attributes.map { attr in
                CredentialAttribute(name: mapping[attr.name]!, value: attr.value)
            }
            return preview
        }
    }
    
    func preview(for connectionId: String) async throws -> (String, CredentialPreview) {
        try await Aries.agent.run { context in
            // Loop query for offer message
            var offer: CredentialOfferMessage!
            
            while true {
                var data: Data?
                for item in try await MediatorService(urlString: nil).getInboxItems().items {
                    guard let d = item.data.data(using: .utf8) else { continue }
                    
                    let header: HeaderMessage = try await Aries.message.receive(d, with: context.wallet).message
                    if header.type == MessageType.credentialOffer.rawValue {
                        data = d
                        break
                    }
                }
                
                guard let d = data else {
                    try await Task.sleep(nanoseconds: 100_000)
                    continue
                }
                
                offer = try await Aries.message.receive(d, with: context.wallet).message
                break
            }
            
            let id = try await Aries.credential.process(offer, for: connectionId, with: context)
            
            var preview = offer.preview!
            preview.attributes = preview.attributes.map { attr in
                CredentialAttribute(name: mapping[attr.name]!, value: attr.value)
            }
            return (id, preview)
        }
    }
    
    func request(with id: String) async throws -> String {
        try await Aries.agent.run {
            let record = try await Aries.record.get(CredentialRecord.self, for: id, with: $0)
            let connection = try await Aries.record
                .get(ConnectionRecord.self, for: record.tags[Tags.connectionKey]!, with: $0)
            guard let service = connection.theirDocument().services?.first else {
                throw AriesError.notFound("No service found to send the credential request to")
            }
            
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
