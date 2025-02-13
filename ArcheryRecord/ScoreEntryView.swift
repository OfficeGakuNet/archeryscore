//
//  ScoreEntryView.swift
//  ArcheryRecord
//
//  Created by オフィス岳 on 2025/01/31.
//
import SwiftUI

struct ScoreEntryView: View {
    @Binding var scores: [[String]]
    @Binding var range: String
    @Binding var targetType: String
    @State private var selectedScores: [String]
    @State private var showError = false
    @Environment(\.presentationMode) var presentationMode
    let scoreOptions = ["X", "10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "M"]
    
    init(scores: Binding<[[String]]>, range: Binding<String>, targetType: Binding<String>) {
        self._scores = scores
        self._range = range
        self._targetType = targetType
        
        let numShots = (range.wrappedValue == "18m") ? (targetType.wrappedValue != "大的" ? 3 : 6) : 6
        self._selectedScores = State(initialValue: Array(repeating: "", count: numShots))
    }

    var body: some View {
        Form {
            Section(header: Text("スコア入力")) {
                ForEach(0..<selectedScores.count, id: \.self) { row in
                    HStack {
                        Text("矢 \(row + 1)")
                        Spacer()
                        Picker("", selection: $selectedScores[row]) {
                            ForEach(scoreOptions, id: \.self) { score in
                                Text(score).tag(score)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            if showError {
                Text("すべてのスコアを選択してください。")
                    .foregroundColor(.red)
            }
            
            Button("Commit") {
                if selectedScores.contains("") {
                    showError = true
                } else {
                    showError = false
                    scores.append(selectedScores)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("スコア入力")
    }
}


