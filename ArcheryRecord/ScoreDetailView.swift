import SwiftUI

struct ScoreDetailView: View {
    let score: Score

    let scoreOptions = ["X", "10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "M"]

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    var shotsPerEnd: Int {
        return score.targetType == "大的" ? 6 : 3
    }

    var splitScores: [[String]] {
        guard let scores = score.scores?.split(separator: ",").map({ String($0) }) else { return [] }
        return stride(from: 0, to: scores.count, by: shotsPerEnd).map {
            Array(scores[$0..<min($0+shotsPerEnd, scores.count)])
        }
    }

    var scoreCounts: [String: Int] {
        var counts = Dictionary(uniqueKeysWithValues: scoreOptions.map { ($0, 0) })
        guard let scores = score.scores?.split(separator: ",").map({ String($0) }) else { return counts }

        for s in scores {
            if counts[s] != nil {
                counts[s]! += 1
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

    var averageScore: Double {
        let totalShots = splitScores.flatMap { $0 }.count
        return totalShots > 0 ? Double(score.totalScore) / Double(totalShots) : 0.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 基本情報（固定）
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 6) {
                Text("📅 : \(score.date ?? Date(), formatter: dateFormatter)")
                Text("📍 : \(score.location ?? "不明")")
                Text("📋 : \(score.title ?? "未設定")")
                Text("🔁 : \(score.distance ?? "不明")")
                Text("🎯 : \(score.targetType ?? "不明")")
                Text("☀️ : \(score.weather ?? "不明")")
                Text("🌪️ : \(score.wind ?? "不明")")
                Text("🏹 : \(splitScores.count)")
                Text("📢 : \(score.totalScore)（\(String(format: "%.2f", averageScore))）")
            }

            // コメント（全幅）
            if let comment = score.comment, !comment.isEmpty {
                Text("📝 : \(comment)")
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // スクロール可能なエンド一覧（中央）
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("エンドごとのスコア")
                        .font(.headline)
                    ForEach(splitScores.indices, id: \ .self) { index in
                        HStack {
                            Text("\(index + 1):")
                                .bold()
                                .monospacedDigit()
                                .frame(minWidth: 40, alignment: .leading)

                            HStack(spacing: 16) {
                                ForEach(splitScores[index], id: \ .self) { score in
                                    Text(score)
                                        .frame(width: 22, alignment: .center)
                                }
                            }

                            Spacer()

                            Text("(\(subtotalScores[index]))")
                                .foregroundColor(.blue)
                                .frame(alignment: .trailing)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 10)
            }

            // 得点分布（固定）
            VStack(alignment: .leading) {
                Text("得点分布")
                    .font(.headline)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(scoreOptions, id: \ .self) { score in
                        if let count = scoreCounts[score], count > 0 {
                            Text("\(score): \(count)")
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .navigationTitle("スコア詳細")
    }
}
