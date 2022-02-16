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

// swiftlint:disable line_length

import Foundation
import Aries
import Mediator
import DeviceCheck
import CryptoKit

class CustomAgentService {
    private static let id = "ID"
    private static let genesis = "idw_eesditest"
    
    func setup(with pin: String) async throws {
        guard let url = Bundle.main.url(forResource: Self.genesis, withExtension: nil)?.path else {
            return
        }

        let walletKey = try IDWalletSecurity.shared().getWalletKey(for: pin)

        // First time setup of the agent
        try await Aries.agent.initialize(with: Self.id, walletKey, url)
        try await Aries.agent.open(with: Self.id, walletKey)
        
        // Set the first master secret to enable credential handling
        try await Aries.agent.run {
            try? await Aries.provisioning.update(Self.id, with: $0)
            try? await Aries.provisioning.update(Owner(name: "ID Wallet"), with: $0)
            try? await Aries.provisioning.update(Endpoint(uri: "https://www.example.com"), with: $0)
        }
        
        let m = MediatorService(urlString: "https://mediator.dev.essid-demo.com/.well-known/agent-configuration")
        
        try await m.connect()

        let security = IDWalletSecurity(mobileSecret: "vU70ZrK1b5dyYNPq2T4jYngb6d4IkPYJ")
        // Reset Keychain on First Install
        try security.reset()
        let validation = try await security.getAttestionObject(challenge: Data())
        
        _ = try await m.createInbox(with: validation)
        
        try await m.addDeviceInfo(
            deviceId: UUID().uuidString.lowercased(),
            deviceMetadata: DeviceMetadata(
                push: "Polling",
                createdAt: Date().timeIntervalSince1970.rounded(.down)
            )
        )
    }
}
