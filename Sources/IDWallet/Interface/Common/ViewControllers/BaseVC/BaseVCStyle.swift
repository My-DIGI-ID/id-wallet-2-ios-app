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

// MARK: - Style config for BaseViewController
// MARK: -

/// Defines the required structure of a style for view controllers using the
/// ``BaseViewController``.
///
///
/// ``themeContext`` is used to determine an appropriate status bar
/// style and also to provide the tools in ``ViewFactory`` with the necessary
/// information.
protocol BaseViewControllerStyle: ThemeContextDependent {
    associatedtype LayoutType: BaseViewControllerLayout
    
    /// This is used to expose parameters allowing a view controller
    /// to be customized witout requiring code changes. See ``BaseViewControllerLayout``
    var layout: LayoutType { get }
    
    /// This is used to provide a default status bar appearance as well as
    /// to support tools provided ``ViewFactory``
    var themeContext: ThemeContext { get }
    
    /// The default initializer is required to allow ``BaseViewController``
    /// to provide a status bar appearance even if the style is not yet set by
    /// the party configuring the view controller.
    init()
}
