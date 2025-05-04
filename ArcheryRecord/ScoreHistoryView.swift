import SwiftUI

struct ScoreHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Score.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.date, ascending: false)]
    ) var savedScores: FetchedResults<Score>
    
    @State private var showFilter = false
    @State private var selectedDistance: String? = nil
    @State private var selectedTargetType: String? = nil
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    
    let distances = ["18m", "30m", "50m", "70m"]
    let targetTypes = ["大的", "40cm的", "三つ目的"]
    
    var filteredScores: [Score] {
        savedScores.filter { score in
            let matchDistance = selectedDistance == nil || score.distance == selectedDistance
            let matchTarget = selectedTargetType == nil || score.targetType == selectedTargetType
            let matchStartDate = startDate == nil || (score.date ?? Date()) >= startDate!
            let matchEndDate = endDate == nil || (score.date ?? Date()) <= endDate!
            return matchDistance && matchTarget && matchStartDate && matchEndDate
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("スコア履歴")
                        .font(.title)
                        .bold()
                    Spacer()
                    Button(action: { showFilter.toggle() }) {
                        Text(showFilter ? "フィルターを隠す" : "フィルターを表示")
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                if showFilter {
                    Form {
                        Section(header: Text("フィルター設定")) {
                            Picker("距離", selection: $selectedDistance) {
                                Text("すべて").tag(nil as String?)
                                ForEach(distances, id: \.self) { Text($0).tag($0 as String?) }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Picker("的の種類", selection: $selectedTargetType) {
                                Text("すべて").tag(nil as String?)
                                ForEach(targetTypes, id: \.self) { Text($0).tag($0 as String?) }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            DatePicker("開始日", selection: Binding(
                                get: { startDate ?? Date() },
                                set: { startDate = $0 }
                            ), displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP")) // ✅ 日本語表記
                            .datePickerStyle(CompactDatePickerStyle())
                            
                            DatePicker("終了日", selection: Binding(
                                get: { endDate ?? Date() },
                                set: { endDate = $0 }
                            ), displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP")) // ✅ 日本語表記
                            .datePickerStyle(CompactDatePickerStyle())
                            
                            
                            Button("リセット") {
                                selectedDistance = nil
                                selectedTargetType = nil
                                startDate = nil
                                endDate = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                List {
                    ForEach(filteredScores) { score in
                        NavigationLink(destination: ScoreDetailView(score: score)) {
                            VStack(alignment: .leading) {
                                Text("📅 日付: \(score.date ?? Date(), formatter: dateFormatter)")
                                    .font(.headline)
                                Text("📍 場所: \(score.location ?? "不明な場所")")
                                Text("🔢 得点: \(score.totalScore)（平均: \(calculateAverage(score: score), specifier: "%.2f")）")
                            }
                            .padding()
                        }
                    }
                    .onDelete(perform: deleteScore)
                }
            }
        }
    }
    
    /// ** 平均の計算**
    private func calculateAverage(score: Score) -> Double {
        let scoreArray = score.scores?.split(separator: ",").map { String($0) } ?? []
        let total = scoreArray.reduce(0) { sum, val in
            switch val {
            case "X": return sum + 10
            case "M": return sum + 0
            default: return sum + (Int(val) ?? 0)
            }
        }
        return scoreArray.isEmpty ? 0.0 : Double(total) / Double(scoreArray.count)
    }
    
    /// **エンドの計算**
    private func calculateEnds(score: Score) -> Int {
        let shotCount = score.scores?.split(separator: ",").count ?? 0
        let shotsPerEnd = (score.targetType == "大的") ? 6 : 3
        return shotCount / shotsPerEnd
    }
    
    /// **スコア削除処理**
    private func deleteScore(at offsets: IndexSet) {
        for index in offsets {
            let scoreToDelete = filteredScores[index]
            viewContext.delete(scoreToDelete)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("❌ エラー: スコアの削除に失敗しました - \(error.localizedDescription)")
        }
    }
}
