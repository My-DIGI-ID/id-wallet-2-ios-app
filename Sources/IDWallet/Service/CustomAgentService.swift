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

class CustomAgentService {
    private static let id = "ID"
    private static let key = "KEY"
    private static let genesis = "idw_eesditest"
    
    func setup() async throws {
        guard let url = Bundle.main.url(forResource: Self.genesis, withExtension: nil)?.path else {
            return
        }
        
        // First time setup of the agent
        try await Aries.agent.setup(with: Self.id, Self.key, url)
        
        // Set the first master secret to enable credential handling
        try await Aries.agent.run {
            try? await Aries.provisioning.update(Self.id, with: $0)
        }
    }
}
