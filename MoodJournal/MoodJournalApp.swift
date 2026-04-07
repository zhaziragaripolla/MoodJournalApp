// MoodJournal.swift
// ─────────────────────────────────────────────────────────────────
// MoodJournal — AI-Powered Mood Journal with Physics Emoji Picker
//
// Features:
//  ✦ Physics-based floating emoji bubbles (size = frequency)
//  ✦ Smooth spring animations & haptic feedback
//  ✦ Claude AI reflections after each entry
//  ✦ Typing animation for AI responses
//  ✦ Weekly mood history with expandable cards
//  ✦ Streak tracking & mood statistics
//  ✦ Dark theme with soft glows
//
// Setup:
//  1. Xcode → File → New → Project → iOS → App (SwiftUI)
//  2. Replace all generated code with this single file
//  3. Set your Claude API key in ClaudeService.apiKey
//  4. Deployment target: iOS 17.0+
//  5. Build & run
// ─────────────────────────────────────────────────────────────────

import SwiftUI
import Combine

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - App Entry
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@main
struct MoodJournal: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Design Tokens
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum Theme {
    static let bg        = Color(red: 0.047, green: 0.043, blue: 0.063)
    static let surface   = Color(red: 0.082, green: 0.075, blue: 0.106)
    static let surfaceAlt = Color(red: 0.110, green: 0.102, blue: 0.137)
    static let border    = Color.white.opacity(0.06)
    static let accent    = Color(red: 0.424, green: 0.388, blue: 1.0)
    static let accentSoft = Color(red: 0.424, green: 0.388, blue: 1.0).opacity(0.15)
    static let textPri   = Color(red: 0.91, green: 0.90, blue: 0.94)
    static let textSec   = Color(red: 0.545, green: 0.537, blue: 0.627)
    static let textDim   = Color(red: 0.36, green: 0.353, blue: 0.44)
    static let cyan      = Color(red: 0.133, green: 0.827, blue: 0.933)
    static let green     = Color(red: 0.27, green: 0.83, blue: 0.45)
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Models
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MoodOption: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
    let color: Color
    let glowColor: Color

    static let all: [MoodOption] = [
        MoodOption(emoji: "😊", label: "Happy",      color: Color(red: 0.27, green: 0.83, blue: 0.45), glowColor: Color(red: 0.27, green: 0.83, blue: 0.45)),
        MoodOption(emoji: "😌", label: "Calm",       color: Color(red: 0.39, green: 0.63, blue: 0.92), glowColor: Color(red: 0.39, green: 0.63, blue: 0.92)),
        MoodOption(emoji: "🥰", label: "Loved",      color: Color(red: 0.92, green: 0.47, blue: 0.63), glowColor: Color(red: 0.92, green: 0.47, blue: 0.63)),
        MoodOption(emoji: "🤩", label: "Excited",    color: Color(red: 0.98, green: 0.75, blue: 0.20), glowColor: Color(red: 0.98, green: 0.75, blue: 0.20)),
        MoodOption(emoji: "🤗", label: "Grateful",   color: Color(red: 0.31, green: 0.78, blue: 0.67), glowColor: Color(red: 0.31, green: 0.78, blue: 0.67)),
        MoodOption(emoji: "😴", label: "Tired",      color: Color(red: 0.55, green: 0.55, blue: 0.67), glowColor: Color(red: 0.55, green: 0.55, blue: 0.67)),
        MoodOption(emoji: "😢", label: "Sad",        color: Color(red: 0.51, green: 0.43, blue: 0.86), glowColor: Color(red: 0.51, green: 0.43, blue: 0.86)),
        MoodOption(emoji: "😤", label: "Frustrated", color: Color(red: 0.92, green: 0.35, blue: 0.27), glowColor: Color(red: 0.92, green: 0.35, blue: 0.27)),
        MoodOption(emoji: "😰", label: "Anxious",    color: Color(red: 0.71, green: 0.51, blue: 0.90), glowColor: Color(red: 0.71, green: 0.51, blue: 0.90)),
        MoodOption(emoji: "🥱", label: "Bored",      color: Color(red: 0.63, green: 0.63, blue: 0.63), glowColor: Color(red: 0.63, green: 0.63, blue: 0.63)),
        MoodOption(emoji: "😡", label: "Angry",      color: Color(red: 0.86, green: 0.24, blue: 0.24), glowColor: Color(red: 0.86, green: 0.24, blue: 0.24)),
        MoodOption(emoji: "🫣", label: "Shy",        color: Color(red: 0.90, green: 0.67, blue: 0.51), glowColor: Color(red: 0.90, green: 0.67, blue: 0.51)),
    ]
}

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let moodEmoji: String
    let moodLabel: String
    var note: String
    var aiReflection: String?

    init(id: UUID = .init(), date: Date = .now, mood: MoodOption, note: String = "", aiReflection: String? = nil) {
        self.id = id
        self.date = date
        self.moodEmoji = mood.emoji
        self.moodLabel = mood.label
        self.note = note
        self.aiReflection = aiReflection
    }

    // For frequency tracking
    var moodKey: String { moodLabel }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Bubble Physics Engine
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct Bubble: Identifiable {
    let id: UUID
    let mood: MoodOption
    var radius: CGFloat
    var position: CGPoint
    var velocity: CGPoint = .zero
    var phase: CGFloat = CGFloat.random(in: 0...(.pi * 2))
    var frequency: Int
}

@Observable
final class BubbleEngine {
    var bubbles: [Bubble] = []
    private var timer: Timer?
    private var containerSize: CGSize = CGSize(width: 350, height: 420)

    private let minRadius: CGFloat = 22
    private let maxRadius: CGFloat = 52
    private let padding: CGFloat = 4

    func setup(frequencies: [String: Int], size: CGSize) {
        containerSize = size

        let maxFreq = max(1, frequencies.values.max() ?? 1)
        let minFreq = frequencies.values.min() ?? 0

        bubbles = MoodOption.all.map { mood in
            let freq = frequencies[mood.label] ?? 0
            let t = maxFreq > minFreq ? CGFloat(freq - minFreq) / CGFloat(maxFreq - minFreq) : 0.5
            let radius = minRadius + t * (maxRadius - minRadius)

            let cx = size.width / 2 + CGFloat.random(in: -60...60)
            let cy = size.height / 2 + CGFloat.random(in: -60...60)

            return Bubble(
                id: mood.id,
                mood: mood,
                radius: max(minRadius, radius),
                position: CGPoint(x: cx, y: cy),
                frequency: freq
            )
        }

        startSimulation()
    }

    func updateFrequencies(_ frequencies: [String: Int]) {
        let maxFreq = max(1, frequencies.values.max() ?? 1)
        let minFreq = frequencies.values.min() ?? 0

        for i in bubbles.indices {
            let freq = frequencies[bubbles[i].mood.label] ?? 0
            let t = maxFreq > minFreq ? CGFloat(freq - minFreq) / CGFloat(maxFreq - minFreq) : 0.5
            bubbles[i].radius = minRadius + t * (maxRadius - minRadius)
            bubbles[i].frequency = freq
        }
    }

    private func startSimulation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        let cx = containerSize.width / 2
        let cy = containerSize.height / 2
        let now = CACurrentMediaTime()

        for i in bubbles.indices {
            // Gravity toward center
            let dx = cx - bubbles[i].position.x
            let dy = cy - bubbles[i].position.y
            let dist = sqrt(dx * dx + dy * dy)
            if dist > 1 {
                bubbles[i].velocity.x += (dx / dist) * 0.06
                bubbles[i].velocity.y += (dy / dist) * 0.06
            }

            // Organic float
            let phase = bubbles[i].phase
            bubbles[i].velocity.y += sin(CGFloat(now) * 0.7 + phase) * 0.03
            bubbles[i].velocity.x += cos(CGFloat(now) * 0.5 + phase * 1.3) * 0.025
        }

        // Collision
        for i in 0..<bubbles.count {
            for j in (i + 1)..<bubbles.count {
                let dx = bubbles[j].position.x - bubbles[i].position.x
                let dy = bubbles[j].position.y - bubbles[i].position.y
                let dist = sqrt(dx * dx + dy * dy)
                let minDist = bubbles[i].radius + bubbles[j].radius + padding

                if dist < minDist && dist > 0.01 {
                    let force = (minDist - dist) * 0.12
                    let nx = dx / dist
                    let ny = dy / dist
                    bubbles[i].velocity.x -= nx * force
                    bubbles[i].velocity.y -= ny * force
                    bubbles[j].velocity.x += nx * force
                    bubbles[j].velocity.y += ny * force
                }
            }
        }

        // Apply velocity + damping + bounds
        for i in bubbles.indices {
            bubbles[i].velocity.x *= 0.9
            bubbles[i].velocity.y *= 0.9
            bubbles[i].position.x += bubbles[i].velocity.x
            bubbles[i].position.y += bubbles[i].velocity.y

            let r = bubbles[i].radius
            bubbles[i].position.x = max(r, min(containerSize.width - r, bubbles[i].position.x))
            bubbles[i].position.y = max(r, min(containerSize.height - r, bubbles[i].position.y))
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Claude API Service
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

actor ClaudeService {
    // ⚠️ In production, use Keychain or your own backend
    private static let apiKey = "YOUR_CLAUDE_API_KEY"

    struct Msg: Codable { let role: String; let content: String }
    struct Req: Codable { let model: String; let max_tokens: Int; let messages: [Msg] }
    struct Block: Codable { let type: String; let text: String? }
    struct Res: Codable { let content: [Block] }

    func reflect(mood: String, note: String, recentMoods: [String]) async throws -> String {
        let history = recentMoods.joined(separator: ", ")

        let prompt = """
        You are a warm, insightful journaling companion. The user just logged their mood in a mood journal app. \
        Give a brief (2-3 sentence) personalized reflection. Acknowledge their feeling genuinely, \
        offer a gentle insight or pattern observation, and end with encouragement. \
        If they wrote a note, reference it naturally. Keep it warm but not saccharine.

        Mood: \(mood)
        Note: \(note.isEmpty ? "(none)" : note)
        Recent moods: \(history.isEmpty ? "First entry!" : history)
        """

        let body = Req(
            model: "claude-sonnet-4-20250514",
            max_tokens: 200,
            messages: [Msg(role: "user", content: prompt)]
        )

        var req = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue(Self.apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.httpBody = try JSONEncoder().encode(body)
        req.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let res = try JSONDecoder().decode(Res.self, from: data)
        return res.content.compactMap(\.text).joined()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - ViewModel
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Observable
final class JournalVM {
    // Data
    var entries: [JournalEntry] = []

    // Mood picker state
    var selectedMood: MoodOption? = nil
    var showNoteSheet = false
    var noteText = ""

    // AI state
    var isLoadingAI = false
    var aiTypingText = ""
    var showAICard = false

    // Success
    var showSuccess = false

    // Services
    private let claude = ClaudeService()
    let bubbleEngine = BubbleEngine()

    // MARK: - Computed

    var moodFrequencies: [String: Int] {
        var freq: [String: Int] = [:]
        // Initialize all moods with a base frequency so they all appear
        for mood in MoodOption.all {
            freq[mood.label] = 1
        }
        // Add actual logged counts
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: .now)!
        for entry in entries where entry.date >= thirtyDaysAgo {
            freq[entry.moodLabel, default: 1] += 1
        }
        return freq
    }

    var streak: Int {
        let cal = Calendar.current
        let days = Set(entries.map { cal.startOfDay(for: $0.date) }).sorted(by: >)
        guard let first = days.first,
              cal.isDateInToday(first) || cal.isDateInYesterday(first) else { return 0 }

        var count = 1
        for i in 1..<days.count {
            if cal.dateComponents([.day], from: days[i], to: days[i - 1]).day == 1 {
                count += 1
            } else { break }
        }
        return count
    }

    var todayEntry: JournalEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }

    // MARK: - Actions

    func selectMood(_ mood: MoodOption) {
        withAnimation(.spring(duration: 0.4, bounce: 0.25)) {
            selectedMood = mood
        }
        // Haptic
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func confirmMood() {
        showNoteSheet = true
    }

    func submitEntry() {
        guard let mood = selectedMood else { return }
        let entry = JournalEntry(mood: mood, note: noteText)

        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            entries.insert(entry, at: 0)
        }

        // Update bubble sizes
        bubbleEngine.updateFrequencies(moodFrequencies)

        // Fetch AI reflection
        fetchReflection(for: entry)

        // Reset
        noteText = ""
        selectedMood = nil
        showNoteSheet = false

        // Show success
        withAnimation(.spring(duration: 0.35)) { showSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { self.showSuccess = false }
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func fetchReflection(for entry: JournalEntry) {
        isLoadingAI = true
        showAICard = true
        aiTypingText = ""

        let recentMoods = Array(entries.prefix(7).map(\.moodLabel))

        Task {
            do {
                let reflection = try await claude.reflect(
                    mood: "\(entry.moodEmoji) \(entry.moodLabel)",
                    note: entry.note,
                    recentMoods: recentMoods
                )
                await MainActor.run {
                    animateTyping(reflection, entryID: entry.id)
                }
            } catch {
                await MainActor.run {
                    let fallback = "Every moment you check in with yourself is a step toward deeper self-awareness. Keep going. 💫"
                    animateTyping(fallback, entryID: entry.id)
                }
            }
        }
    }

    private func animateTyping(_ text: String, entryID: UUID) {
        let chars = Array(text)
        aiTypingText = ""

        for (i, char) in chars.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.018) {
                self.aiTypingText.append(char)
                if i == chars.count - 1 {
                    if let idx = self.entries.firstIndex(where: { $0.id == entryID }) {
                        self.entries[idx].aiReflection = text
                    }
                    self.isLoadingAI = false
                }
            }
        }
    }

    func setupBubbles(size: CGSize) {
        bubbleEngine.setup(frequencies: moodFrequencies, size: size)
    }

    // Demo data
    func seedDemoData() {
        guard entries.isEmpty else { return }
        let cal = Calendar.current
        let demoMoods: [(Int, MoodOption, String, String)] = [
            (-1, MoodOption.all[0], "Productive morning, great energy", "Your energy shines through in everything you do. Ride this wave!"),
            (-2, MoodOption.all[1], "Peaceful evening walk", "Finding calm in movement — that's a beautiful practice."),
            (-3, MoodOption.all[0], "Fun day with kids", "Joy multiplied is joy shared. These are the golden days."),
            (-4, MoodOption.all[3], "Got a great idea for content", "Excitement is creative fuel — capture that spark while it's hot!"),
            (-5, MoodOption.all[6], "Missing home a little", "Homesickness is just love with nowhere to go right now."),
            (-6, MoodOption.all[4], "Thankful for small wins", "Gratitude turns what we have into enough. Beautiful practice."),
            (-7, MoodOption.all[0], "Good filming session", "You're building something real, one session at a time."),
        ]

        for (offset, mood, note, reflection) in demoMoods {
            let date = cal.date(byAdding: .day, value: offset, to: .now)!
            entries.append(JournalEntry(date: date, mood: mood, note: note, aiReflection: reflection))
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Main Tab View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MainTabView: View {
    @State private var vm = JournalVM()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MoodPickerScreen(vm: vm)
                .tabItem {
                    Image(systemName: "face.smiling.inverse")
                    Text("Mood")
                }
                .tag(0)

            HistoryScreen(vm: vm)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("History")
                }
                .tag(1)

            InsightsScreen(vm: vm)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Insights")
                }
                .tag(2)
        }
        .tint(Theme.accent)
        .onAppear {
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()
            tabAppearance.backgroundColor = UIColor(Theme.bg)
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Mood Picker Screen (Bubbles!)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MoodPickerScreen: View {
    @Bindable var vm: JournalVM
    @State private var appeared = false
    @State private var showBubblePop = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -16)

                // Subtitle
                Text("Tap a bubble to log your mood")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textDim)
                    .padding(.top, 4)
                    .opacity(appeared ? 1 : 0)

                // Bubble area
                GeometryReader { geo in
                    ZStack {
                        ForEach(vm.bubbleEngine.bubbles) { bubble in
                            BubbleView(
                                bubble: bubble,
                                isSelected: vm.selectedMood?.id == bubble.mood.id,
                                onTap: { vm.selectMood(bubble.mood) }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        vm.seedDemoData()
                        vm.setupBubbles(size: geo.size)
                    }
                }
                .padding(.horizontal, 12)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.92)

                Spacer(minLength: 0)

                // Selection bar
                if let mood = vm.selectedMood {
                    selectedMoodBar(mood)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // Success overlay
            if vm.showSuccess {
                successOverlay
            }

            // AI reflection card (slides up after logging)
            if vm.showAICard {
                aiReflectionOverlay
            }

            // Bubble pop animation
            if showBubblePop, let mood = vm.selectedMood {
                let radius = vm.bubbleEngine.bubbles.first { $0.mood.id == mood.id }?.radius ?? 30
                BubblePopOverlay(mood: mood, bubbleRadius: radius) {
                    showBubblePop = false
                    vm.confirmMood()
                }
            }
        }
        .animation(.spring(duration: 0.5, bounce: 0.2), value: vm.selectedMood?.id)
        .animation(.spring(duration: 0.4), value: vm.showSuccess)
        .sheet(isPresented: $vm.showNoteSheet) {
            NoteInputSheet(vm: vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(Theme.surface)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appeared = true }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(greeting)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSec)
                Text("How are you?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPri)
            }

            Spacer()

            if vm.streak > 0 {
                HStack(spacing: 5) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(vm.streak)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPri)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Theme.surfaceAlt, in: Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: .now)
        if h < 12 { return "Good morning" }
        if h < 17 { return "Good afternoon" }
        return "Good evening"
    }

    // MARK: - Selected Mood Bar

    private func selectedMoodBar(_ mood: MoodOption) -> some View {
        HStack(spacing: 14) {
            Text(mood.emoji)
                .font(.system(size: 30))

            VStack(alignment: .leading, spacing: 2) {
                Text(mood.label)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPri)

                let freq = vm.moodFrequencies[mood.label] ?? 0
                Text("Logged \(freq) time\(freq == 1 ? "" : "s") this month")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSec)
            }

            Spacer()

            Button(action: { showBubblePop = true }) {
                Text("Log")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(
                        LinearGradient(
                            colors: [Theme.accent, Theme.accent.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 13)
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.accentSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.accent.opacity(0.25), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.green)
                Text("Mood logged!")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPri)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - AI Reflection Overlay

    private var aiReflectionOverlay: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .symbolEffect(.pulse, isActive: vm.isLoadingAI)
                    Text("Claude's reflection")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.cyan)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Spacer()
                    Button {
                        withAnimation { vm.showAICard = false }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.textDim)
                            .padding(6)
                            .background(Theme.surfaceAlt, in: Circle())
                    }
                }

                Text(vm.isLoadingAI ? vm.aiTypingText + "▌" : (vm.entries.first?.aiReflection ?? vm.aiTypingText))
                    .font(.system(size: 15, design: .serif))
                    .foregroundStyle(Theme.textPri.opacity(0.9))
                    .lineSpacing(4)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Theme.cyan.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: Theme.cyan.opacity(0.08), radius: 20, y: -4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Bubble Pop Overlay
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BubblePopOverlay: View {
    let mood: MoodOption
    let bubbleRadius: CGFloat
    let onComplete: () -> Void

    @State private var circleScale: CGFloat = 1
    @State private var circleOpacity: Double = 1
    @State private var emojiScale: CGFloat = 1
    @State private var emojiOpacity: Double = 1
    @State private var bgOpacity: Double = 0
    @State private var showParticles = false

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(bgOpacity * 0.4)
                .ignoresSafeArea()

            // Expanding bubble circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [mood.color.opacity(0.35), mood.color.opacity(0.12)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: bubbleRadius * 2, height: bubbleRadius * 2)
                .scaleEffect(circleScale)
                .opacity(circleOpacity)

            // Burst particles (emoji copies that scatter outward)
            if showParticles {
                ForEach(0..<8, id: \.self) { i in
                    BubbleParticle(emoji: mood.emoji, index: i)
                }
            }

            // Centered emoji
            Text(mood.emoji)
                .font(.system(size: 64))
                .scaleEffect(emojiScale)
                .opacity(emojiOpacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear { animate() }
    }

    private func animate() {
        // Phase 1: Expand bubble
        withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
            circleScale = 12
            emojiScale = 1.8
            bgOpacity = 1
        }

        // Phase 2: Pop!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            showParticles = true

            // Burst the circle outward + fade
            withAnimation(.easeOut(duration: 0.3)) {
                circleScale = 18
                circleOpacity = 0
            }

            // Emoji: quick scale-up then shrink away
            withAnimation(.spring(duration: 0.2, bounce: 0.6)) {
                emojiScale = 2.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.25)) {
                    emojiScale = 0.3
                    emojiOpacity = 0
                    bgOpacity = 0
                }
            }

            // Complete — show the note sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                onComplete()
            }
        }
    }
}

struct BubbleParticle: View {
    let emoji: String
    let index: Int

    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.7

    var body: some View {
        Text(emoji)
            .font(.system(size: 28))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(offset)
            .onAppear {
                let angle = Double(index) * (.pi * 2 / 8)
                let distance = CGFloat.random(in: 100...200)
                withAnimation(.easeOut(duration: 0.55)) {
                    offset = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance
                    )
                    scale = CGFloat.random(in: 0.15...0.35)
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                    opacity = 0
                }
            }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Bubble View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BubbleView: View {
    let bubble: Bubble
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let d = bubble.radius * 2

        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(bubble.mood.emoji)
                    .font(.system(size: max(16, bubble.radius * 0.6)))

                if bubble.radius > 30 {
                    Text(bubble.mood.label)
                        .font(.system(size: max(8, bubble.radius * 0.2), weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSec)
                }
            }
            .frame(width: d, height: d)
            .background {
                Circle()
                    .fill(bubble.mood.color.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        Circle()
                            .stroke(
                                bubble.mood.color.opacity(isSelected ? 0.7 : 0.25),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? bubble.mood.glowColor.opacity(0.35) : .clear,
                        radius: isSelected ? 16 : 0
                    )
            }
            .scaleEffect(isSelected ? 1.12 : 1.0)
        }
        .buttonStyle(.plain)
        .position(bubble.position)
        .animation(.spring(duration: 0.35, bounce: 0.2), value: isSelected)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Note Input Sheet
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct NoteInputSheet: View {
    @Bindable var vm: JournalVM
    @FocusState private var focused: Bool
    @State private var emojiFloat = false

    var body: some View {
        VStack(spacing: 24) {
            // Mood display with floating emoji
            if let mood = vm.selectedMood {
                VStack(spacing: 8) {
                    Text(mood.emoji)
                        .font(.system(size: 56))
                        .shadow(color: mood.color.opacity(0.4), radius: 12)
                        .offset(y: emojiFloat ? -5 : 5)
                        .scaleEffect(emojiFloat ? 1.05 : 0.95)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: emojiFloat
                        )

                    Text("Feeling \(mood.label.lowercased())")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPri)
                }
                .padding(.top, 8)
                .onAppear { emojiFloat = true }
            }

            // Note input
            VStack(alignment: .leading, spacing: 8) {
                Text("Add a note (optional)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSec)

                TextField("What's on your mind?", text: $vm.noteText, axis: .vertical)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Theme.textPri)
                    .lineLimit(3...6)
                    .focused($focused)
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.surfaceAlt)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(focused ? Theme.accent.opacity(0.4) : Theme.border, lineWidth: 1)
                            )
                    }
            }

            // Submit button
            Button(action: vm.submitEntry) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                    Text("Log & Get AI Reflection")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .shadow(color: Theme.accent.opacity(0.3), radius: 12, y: 4)
            }

            Spacer()
        }
        .padding(24)
        .onAppear { focused = true }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - History Screen
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct HistoryScreen: View {
    @Bindable var vm: JournalVM

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if vm.entries.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(vm.entries) { entry in
                                HistoryRow(entry: entry)
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("📝")
                .font(.system(size: 40))
            Text("No entries yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPri)
            Text("Log your first mood to get started")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textDim)
        }
    }
}

struct HistoryRow: View {
    let entry: JournalEntry
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    Text(entry.moodEmoji)
                        .font(.system(size: 28))
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.moodLabel)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPri)

                        if !entry.note.isEmpty {
                            Text(entry.note)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(Theme.textSec)
                                .lineLimit(expanded ? nil : 1)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(entry.date.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textDim)
                        Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Theme.textDim)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.textDim)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)
            .padding(14)

            // Expanded: AI reflection
            if expanded, let reflection = entry.aiReflection {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().overlay(Theme.border)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.cyan)
                        Text("AI Reflection")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.cyan)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }

                    Text(reflection)
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Theme.textSec)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.border, lineWidth: 0.5)
                )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Insights Screen
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct InsightsScreen: View {
    @Bindable var vm: JournalVM

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Stats row
                        statsRow

                        // Top moods
                        topMoodsCard

                        // Weekly chart
                        weeklyCard

                        // Latest AI reflection
                        if let latest = vm.entries.first, let reflection = latest.aiReflection {
                            latestReflectionCard(latest, reflection)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            statBox(icon: "flame.fill", value: "\(vm.streak)", label: "Streak", color: .orange)
            statBox(icon: "square.stack.fill", value: "\(vm.entries.count)", label: "Entries", color: Theme.accent)
            statBox(icon: "calendar", value: "\(uniqueDays)", label: "Days", color: Theme.green)
        }
    }

    private var uniqueDays: Int {
        Set(vm.entries.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    private func statBox(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPri)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 0.5))
        }
    }

    // MARK: - Top Moods

    private var topMoodsCard: some View {
        let sorted = vm.moodFrequencies.sorted { $0.value > $1.value }.prefix(5)
        let maxVal = sorted.first?.value ?? 1

        return VStack(alignment: .leading, spacing: 14) {
            Text("Top moods")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPri)

            ForEach(Array(sorted), id: \.key) { label, count in
                let mood = MoodOption.all.first { $0.label == label }
                HStack(spacing: 12) {
                    Text(mood?.emoji ?? "")
                        .font(.system(size: 20))
                        .frame(width: 28)

                    Text(label)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textPri)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(mood?.color.opacity(0.5) ?? Theme.accent.opacity(0.5))
                            .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxVal))
                    }
                    .frame(height: 8)

                    Text("\(count)")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Theme.textDim)
                        .frame(width: 24, alignment: .trailing)
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 0.5))
        }
    }

    // MARK: - Weekly Chart

    private var weeklyCard: some View {
        let cal = Calendar.current
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: .now)!.start
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        let days: [(String, JournalEntry?)] = (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: offset, to: startOfWeek)!
            let entry = vm.entries.first { cal.isDate($0.date, inSameDayAs: day) }
            return (formatter.string(from: day), entry)
        }

        return VStack(alignment: .leading, spacing: 14) {
            Text("This week")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPri)

            HStack(spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 8) {
                        if let entry = item.1 {
                            Text(entry.moodEmoji)
                                .font(.system(size: 22))
                        } else {
                            Circle()
                                .fill(Theme.border)
                                .frame(width: 8, height: 8)
                        }

                        Text(item.0)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textDim)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 0.5))
        }
    }

    // MARK: - Latest Reflection

    private func latestReflectionCard(_ entry: JournalEntry, _ reflection: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.cyan)
                Text("Latest reflection")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.cyan)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                Text(entry.moodEmoji)
                    .font(.system(size: 18))
            }

            Text(reflection)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Theme.textPri.opacity(0.85))
                .lineSpacing(4)

            Text(entry.date.formatted(.relative(presentation: .named)))
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Theme.textDim)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.cyan.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Theme.cyan.opacity(0.12), lineWidth: 0.5)
                )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Preview
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}

