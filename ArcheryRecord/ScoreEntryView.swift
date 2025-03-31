import SwiftUI

struct ScoreEntryView: View {
    @Binding var scores: [[String]]
    @Binding var range: String
    @Binding var targetType: String
    @State private var selectedScores: [String] = []
    @State private var showError = false
    @Environment(\.presentationMode) var presentationMode
    let scoreOptions = ["X", "10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "M"]

    init(scores: Binding<[[String]]>, range: Binding<String>, targetType: Binding<String>) {
        self._scores = scores
        self._range = range
        self._targetType = targetType
        self._selectedScores = State(initialValue: Array(repeating: "", count: ScoreEntryView.getShotCount(range: range.wrappedValue, targetType: targetType.wrappedValue)))
    }

    var body: some View {
        Form {
            Section(header: Text("スコア入力")) {
                ForEach(0..<selectedScores.count, id: \.self) { row in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("矢 \(row + 1)")
                            .font(.caption)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: scoreOptions.count), spacing: 6) {
                            ForEach(scoreOptions, id: \.self) { score in
                                Text(score)
                                    .font(.caption)
                                    .minimumScaleFactor(0.6)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, minHeight: 28)
                                    .padding(.vertical, 4)
                                    .background(selectedScores[row] == score ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedScores[row] == score ? .white : .primary)
                                    .cornerRadius(6)
                                    .onTapGesture {
                                        selectedScores[row] = score
                                    }
                            }
                        }
                        .padding(.vertical, 2)
                    }
//                    .padding(.vertical, 2)
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
                    selectedScores = Array(repeating: "", count: ScoreEntryView.getShotCount(range: range, targetType: targetType))
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("スコア入力")
        .onChange(of: range, updateShotCount)
        .onChange(of: targetType, updateShotCount)
    }

    private func updateShotCount() {
        let numShots = (range == "18m") ? (targetType == "大的" ? 6 : 3) : 6
        selectedScores = Array(repeating: "", count: numShots)
        print("🔄 矢数更新: \(numShots) 本")
    }

    static func getShotCount(range: String, targetType: String) -> Int {
        return (range == "18m") ? (targetType != "大的" ? 3 : 6) : 6
    }
}
