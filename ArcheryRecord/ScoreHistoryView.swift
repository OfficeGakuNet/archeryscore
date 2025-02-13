import SwiftUI

struct ScoreHistoryView: View {
    @FetchRequest(
        entity: Score.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.date, ascending: false)]
    ) var savedScores: FetchedResults<Score>

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        NavigationStack {
            List {
                ForEach(savedScores) { score in
                    NavigationLink(destination: ScoreDetailView(score: score)) {
                        VStack(alignment: .leading) {
                            Text("📅 日付: \(score.date ?? Date(), formatter: dateFormatter)") // ✅ 日付が表示されるか確認
                                .font(.headline)
                            Text("📍 場所: \(score.location ?? "不明な場所")")
                            Text("🎯 距離: \(score.distance ?? "0")m")
                            Text("的の種類: \(score.targetType ?? "不明")")
                            Text("🏹 エンド: \(calculateEnds(score: score))")
                            Text("🔢 合計スコア: \(score.totalScore)")
                            Text("コメント： \(score.comment ?? "なし")")
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("スコア履歴")
        }
    }

    private func calculateEnds(score: Score) -> Int {
        let shotCount = score.scores?.split(separator: ",").count ?? 0
        let shotsPerEnd = (score.targetType == "大的") ? 6 : 3
        return shotCount / shotsPerEnd
    }
}
