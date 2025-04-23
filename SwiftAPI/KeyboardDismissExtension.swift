//
//  KeyboardDismissExtension.swift
//  SwiftAPI
//
//  Created by Dragon P on 4/22/25.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif
