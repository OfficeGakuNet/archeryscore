import SwiftUI

struct ScoreDetailView: View {
    let score: Score

    let scoreOptions = ["X", "10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "M"]

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    // 1エンドの矢の本数（大的なら6、それ以外は3）
    var shotsPerEnd: Int {
        return score.targetType == "大的" ? 6 : 3
    }

    // スコアをエンドごとに分割
    var splitScores: [[String]] {
        guard let scores = score.scores?.split(separator: ",").map({ String($0) }) else { return [] }
        return stride(from: 0, to: scores.count, by: shotsPerEnd).map { Array(scores[$0..<min($0+shotsPerEnd, scores.count)]) }
    }

    // 各得点ごとの集計
    var scoreCounts: [String: Int] {
        var counts = Dictionary(uniqueKeysWithValues: scoreOptions.map { ($0, 0) })
        guard let scores = score.scores?.split(separator: ",").map({ String($0) }) else { return counts }
        
        for score in scores {
            if counts[score] != nil {
                counts[score]! += 1
            }
        }
        return counts
    }

    func scoreValue(_ score: String) -> Int {
        switch score {
        case "X": return 10
        case "M": return 0
        default: return Int(score) ?? 0
        }
    }

    var subtotalScores: [Int] {
        return splitScores.map { row in row.reduce(0) { $0 + scoreValue($1) } }
    }

    // アベレージ計算 (合計スコア ÷ 総射数)
    var averageScore: Double {
        let totalShots = splitScores.flatMap { $0 }.count
        return totalShots > 0 ? Double(score.totalScore) / Double(totalShots) : 0.0
    }

    var body: some View {
        VStack {
            // ✅ 日付を追加
            Text("📅 日付: \(score.date ?? Date(), formatter: dateFormatter)")
                .font(.headline)
                .padding(.bottom, 5)
            Text("🎯 距離: \(score.distance ?? "不明")")
            Text("的の種類: \(score.targetType ?? "不明")")

            // **合計スコア + アベレージ表示**
            Text("🔢 合計スコア: \(score.totalScore) (\(String(format: "%.2f", averageScore)))")
                .font(.headline)
                .foregroundColor(.blue)

            // エンドごとのスコア
            List {
                ForEach(splitScores.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("エンド \(index + 1)")
                            .font(.headline)
                        Text("スコア: \(splitScores[index].joined(separator: ", "))")
                        Text("小計: \(subtotalScores[index])")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 5)
                }
            }

            // 各得点ごとの集計
            VStack(alignment: .leading) {
                Text("得点分布")
                    .font(.headline)
                    .padding(.top, 10)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(scoreOptions, id: \.self) { score in
                        if let count = scoreCounts[score], count > 0 {
                            Text("\(score): \(count)")
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 5)
            }
            .padding()
        }
        .navigationTitle("スコア詳細")
    }
}
