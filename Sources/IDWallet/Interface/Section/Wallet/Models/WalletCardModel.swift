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

/// Model that represents an entry in the Wallet CollectionView
struct WalletCardModel: Hashable, Equatable {
    
    /// Specifies the image-type for the wallet-background. Can either be named (from Assets) or stored (via file-url)
    enum ImageType: Hashable, Equatable {
        case named(String)
        case stored(URL)
    }
    
    /// Depending on the background it might be necessary to either display the cards text in light or dark color
    enum TextStyle: Hashable, Equatable {
        case light
        case dark
    }
    
    /// Specifies the title-value pairs displayed on either the left (i.e. name) or the right (i.e. validity)
    struct Values: Hashable, Equatable {
        let title: String
        let value: String
    }
    
    /// Defines the background-image used for the Wallet-Card
    let backgroundImage: ImageType
    
    /// Defines the text-color that is used for the Wallet-Card (sould be choosen according to the backgroundImages color)
    let textStyle: TextStyle = .light
    
    /// Title displayed for the Wallet-Card
    let title: String
    
    /// Values displayed on the left half of the card
    let primaryValues: [Values]
    
    /// Values displayed on the right half of the card
    let secondaryValues: [Values]
}
