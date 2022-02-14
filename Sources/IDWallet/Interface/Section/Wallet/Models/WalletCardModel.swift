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

import UIKit

/// Model that represents an entry in the Wallet CollectionView
struct WalletCardModel: Hashable, Equatable {
    
    /// Specifies the background-type for the wallet-background. Can either be named (from Assets), stored (via url) or a color
    enum BackgroundType: Hashable, Equatable {
        case namedImage(ImageNameIdentifier)
        case storedImage(URL)
        case color(UIColor)
    }
    
    /// Depending on the background it might be necessary to either display the cards text in light or dark color
    enum TextStyle: Hashable, Equatable {
        case light
        case dark
    }
    
    /// Specifies the title-value pairs displayed on either the left (i.e. name) or the right (i.e. validity)
    struct WalletValue: Hashable, Equatable {
        let title: String
        let value: String
    }
    
    /// Unique identifier for the credential this Wallet-Card represents
    let id: String
    
    /// Defines the background used for the Wallet-Card. Can either be a stored/named image or a color
    let background: BackgroundType
    
    /// Defines the color of the header-area in the Wallet-Card. Defaults to clear
    let headerBackgroundColor: UIColor
    
    /// Defines the text-color that is used for the Wallet-Card (sould be choosen according to the background color/image)
    let textStyle: TextStyle
    
    /// Title displayed for the Wallet-Card
    let title: String
    
    /// Values displayed on the left half of the card
    let primaryValues: [WalletValue]
    
    /// Values displayed on the right half of the card
    let secondaryValues: [WalletValue]
    
    /// Date when the Wallet-Card the expires
    let expiryDate: Date
    
    init(id: String,
         background: BackgroundType,
         headerBackgroundColor: UIColor = .clear,
         textStyle: TextStyle = .light,
         title: String,
         primaryValues: [WalletValue],
         secondaryValues: [WalletValue],
         expiryDate: Date) {
        self.id = id
        self.background = background
        self.headerBackgroundColor = headerBackgroundColor
        self.textStyle = textStyle
        self.title = title
        self.primaryValues = primaryValues
        self.secondaryValues = secondaryValues
        self.expiryDate = expiryDate
    }
}
