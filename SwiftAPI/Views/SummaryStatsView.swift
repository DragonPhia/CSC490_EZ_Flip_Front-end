//
//  SummaryStatsView.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 4/9/25.
//

import SwiftUI

struct SummaryStatsView: View {
    @ObservedObject var viewModel: InventoryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📊 Summary Stats")
                .font(.headline)

            HStack {
                statBox(title: "Sold Items", value: "\(viewModel.totalSold)")
                statBox(title: "Total Cost", value: String(format: "$%.2f", viewModel.totalSoldPurchaseCost))
                statBox(title: "Profit", value: String(format: "$%.2f", viewModel.totalSoldValue - viewModel.totalSoldPurchaseCost))
            }
        }
        .padding()
    }

    // Simple reusable stat box
    func statBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
