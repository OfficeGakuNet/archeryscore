import SwiftUI
import CoreData

struct ScoreInputView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var date = Date()
    @State private var location = ""
    @State private var title = ""
    @State private var comment = ""
    @State private var distance = "18m"
    @State private var targetType = "大的"
    @State private var weather = "晴れ"
    @State private var wind = "無風"
    
    let targetTypes = ["大的", "40cm的", "三つ目的"]
    let scoreOptions = ["X", "10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "M"]
    let weathers = ["晴れ", "曇り", "雨", "風"]
    let winds = ["無風", "弱風", "中風", "強風"]
    let ranges = ["18m", "30m", "50m", "70m"]
    
    @State private var scores: [[String]] = []
    @State private var showingScoreEntry = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showBasicInfo = true
    
    @FetchRequest(
        entity: Score.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.date, ascending: false)]
    ) var savedScores: FetchedResults<Score>
    
    var subtotalScores: [Int] {
        return scores.map { row in row.reduce(0) { $0 + scoreValue($1) } }
    }
    
    var totalScore: Int {
        return subtotalScores.reduce(0, +)
    }
    
    func scoreValue(_ score: String) -> Int {
        switch score {
        case "X": return 10
        case "M": return 0
        default: return Int(score) ?? 0
        }
    }
    
    func shotCount() -> Int{
        return (distance == "18m") ? (targetType != "大的") ? 3 : 6 : 6
    }
    func maxScore() -> Int {
        return shotCount() * 10
    }
    
    func updateScores() {
        let shotCount = shotCount()
        scores = Array(repeating: Array(repeating: "M", count: shotCount), count: shotCount)
    }
    
    func calculateTotalScore() -> Int {
        return scores.flatMap { $0 }.reduce(0) { $0 + scoreValue($1) }
    }
    
    func calculateAverageScore() -> Double {
        let totalSets = scores.count * shotCount()
        return totalSets > 0 ? Double(calculateTotalScore()) / Double(totalSets) : 0.0
    }
    
    func maxScores() -> Int {
        return scores.count * maxScore()
    }
    
    func saveScore() {
        let newScore = Score(context: viewContext)
        newScore.date = date
        newScore.location = location
        newScore.title = title
        newScore.weather = weather
        newScore.wind = wind
        newScore.distance = distance
        newScore.targetType = targetType
        newScore.scores = scores.flatMap { $0 }.joined(separator: ",")
        newScore.totalScore = Int16(totalScore)
        newScore.comment = comment
        
        do {
            try viewContext.save()
            print("Score saved successfully")
        } catch {
            print("Failed to save score: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    basicInfoSection
                    scoreInputSection
                    if !scores.isEmpty {
                        scoreResultSection
                    }
                }
            }
            .navigationTitle("アーチェリー スコア入力")
            .toolbar { bottomToolbar }
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: HStack {
            Text("基本情報")
            Spacer()
            Button(action: { showBasicInfo.toggle() }) {
                Text(showBasicInfo ? "隠す" : "表示")
                    .font(.subheadline)
                    .padding(6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }) {
            if showBasicInfo {
                DatePicker("📅 日付", selection: $date, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                Picker("☀️天候", selection: $weather) {
                    ForEach(weathers, id: \.self) { Text($0) }
                }
                Picker("🌪️風", selection: $wind) {
                    ForEach(winds, id: \.self) { Text($0) }
                }
                TextField("場所", text: $location)
                TextField("タイトル（任意）", text: $title)
                Picker("🎯 距離", selection: $distance) {
                    ForEach(ranges, id: \.self) { Text($0) }
                }
                Picker("的", selection: $targetType) {
                    ForEach(targetTypes, id: \.self) { Text($0) }
                }
                TextField("コメント", text: $comment)
            }
        }
    }
    
    private var scoreInputSection: some View {
        Section {
            NavigationLink(destination: ScoreEntryView(scores: $scores, range: $distance, targetType: $targetType)) {
                Text("スコア入力へ")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var scoreResultSection: some View {
        VStack {
            Section(header: Text("スコア結果")) {
                Text("累積合計スコア: \(calculateTotalScore()) / \(maxScores())（\(calculateAverageScore(), specifier: "%.2f")）")
                ForEach(scores.indices, id: \.self) { index in
                    HStack {
                        Text("No \(index + 1): \(scores[index].joined(separator: ", "))")
                        Spacer()
                        Text("小計 : \(subtotalScores[index])")
                    }
                }
                Button("Save") {
                    print("Saving score...")
                    saveScore()
                    scores.removeAll()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var bottomToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack {
                NavigationLink(destination: ScoreHistoryView()) {
                    Image(systemName: "list.bullet").padding()
                    Text("履歴")
                }
                Spacer()
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear").padding()
                    Text("設定")
                }
            }
        }
    }
}

struct ScoreInputView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreInputView()
    }
}
