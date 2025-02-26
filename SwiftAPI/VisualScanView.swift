//
//  VisualScanView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI

struct VisualScanView: View {

    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }

    var body: some View {
        Text("Visual Scan View")
    }
}

#Preview {
    VisualScanView()
}
