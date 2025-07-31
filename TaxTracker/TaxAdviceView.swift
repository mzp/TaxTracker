//
//  TaxAdviceView.swift
//  TaxTracker
//
//  Created by Claude on 2025/07/31.
//

import CoreTaxTracker
import FoundationModels
import os.log
import SwiftData
import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct TaxAdviceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var models: [TaxTrackingModel]

    @State private var messages: [ChatMessage] = []
    @State private var currentInput: String = ""
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var session: LanguageModelSession?

    private let logger = Logger(subsystem: "com.taxtracker.app", category: "TaxAdviceView")

    private var taxModel: TaxTrackingModel? {
        models.first
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let model = taxModel {
                    TaxSummaryCard(model: model)
                        .padding()

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                if messages.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 48))
                                            .foregroundColor(.accentColor)
                                        Text("Tax AI Assistant")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        Text("Ask me anything about your taxes")
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)

                                        Button("Analyze My Tax Situation") {
                                            startInitialAnalysis()
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 60)
                                }

                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }

                                if isGenerating {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Thinking...")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.leading)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .onChange(of: messages.count) { _ in
                            if let lastMessage = messages.last {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    ChatInputView(
                        text: $currentInput,
                        isGenerating: isGenerating,
                        onSend: { sendMessage() }
                    )

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("No Tax Data Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Please set up your tax payment plan first")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Tax AI Chat")
            .onAppear {
                initializeSession()
            }
        }
    }

    private func initializeSession() {
        if session == nil {
            session = LanguageModelSession()
        }
    }

    private func startInitialAnalysis() {
        guard let model = taxModel else { return }
        let analysisPrompt = buildInitialAnalysisPrompt(for: model)
        sendMessage(analysisPrompt)
    }

    private func sendMessage(_ text: String? = nil) {
        let messageText = text ?? currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty, !isGenerating else { return }

        let userMessage = ChatMessage(content: messageText, isUser: true, timestamp: Date())
        messages.append(userMessage)

        if text == nil {
            currentInput = ""
        }

        generateResponse(to: messageText)
    }

    private func generateResponse(to userMessage: String) {
        guard let session = session else { return }

        isGenerating = true
        errorMessage = nil

        Task {
            let contextualPrompt = buildContextualPrompt(userMessage: userMessage)
            logger.info("Sending prompt to AI: \(contextualPrompt.prefix(200), privacy: .public)...")

            // Create assistant message placeholder
            await MainActor.run {
                let assistantMessage = ChatMessage(content: "", isUser: false, timestamp: Date())
                messages.append(assistantMessage)
            }

            do {
                // Try non-streaming first for debugging
                let response = try await session.respond(to: contextualPrompt)
                logger.info("Received full response: \(response.content.prefix(200), privacy: .public)...")

                await MainActor.run {
                    if let lastIndex = messages.lastIndex(where: { !$0.isUser }) {
                        let updatedMessage = ChatMessage(
                            content: response.content,
                            isUser: false,
                            timestamp: messages[lastIndex].timestamp
                        )
                        messages[lastIndex] = updatedMessage
                    }
                    isGenerating = false
                }

            } catch {
                logger.error("AI Generation Error: \(error.localizedDescription, privacy: .public)")

                await MainActor.run {
                    // Remove the empty assistant message on error
                    if let lastIndex = messages.lastIndex(where: { !$0.isUser && $0.content.isEmpty }) {
                        messages.remove(at: lastIndex)
                    }
                    isGenerating = false
                    errorMessage = "Failed to generate response: \(error.localizedDescription)"
                }
            }
        }
    }

    private func buildInitialAnalysisPrompt(for model: TaxTrackingModel) -> String {
        let federalWithholding = model.paymentPlan.withholdings[.federal] ?? 0
        let stateWithholding = model.paymentPlan.withholdings[.state] ?? 0
        let federalPrevious = model.paymentPlan.previousYearTaxPayments[.federal] ?? 0
        let statePrevious = model.paymentPlan.previousYearTaxPayments[.state] ?? 0
        let federalSafeHarbor = model.safeHarborAmount[.federal] ?? 0
        let stateSafeHarbor = model.safeHarborAmount[.state] ?? 0
        let payrollInterval = model.paymentPlan.payrollInterval

        let currentYear = Calendar.current.component(.year, from: Date())
        let vestingInfo = model.paymentPlan.vestingSchedule
            .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
            .map { event in
                "\(DateFormatter.shortDate.string(from: event.date)): \(event.shares) shares"
            }.joined(separator: ", ")

        let stockPrice = model.paymentPlan.stockPrice

        return """
        Look at my tax setup and give me a quick take. Be casual and brief - 1-2 sentences max. Respond in Japanese.

        - Federal withholding: $\(String(format: "%.2f", federalWithholding)) per payroll (every \(payrollInterval) days)  
        - State withholding: $\(String(format: "%.2f", stateWithholding)) per payroll
        - Last year federal: $\(String(format: "%.2f", federalPrevious))
        - Last year state: $\(String(format: "%.2f", statePrevious))
        - Safe harbor federal: $\(String(format: "%.2f", federalSafeHarbor))
        - Safe harbor state: $\(String(format: "%.2f", stateSafeHarbor))
        - Stock price: $\(String(format: "%.2f", stockPrice))
        - This year's vesting: \(vestingInfo.isEmpty ? "None" : vestingInfo)

        Quick assessment - how's it looking?
        """
    }

    private func buildContextualPrompt(userMessage: String) -> String {
        guard let model = taxModel else { return userMessage }

        let federalWithholding = model.paymentPlan.withholdings[.federal] ?? 0
        let stateWithholding = model.paymentPlan.withholdings[.state] ?? 0
        let federalPrevious = model.paymentPlan.previousYearTaxPayments[.federal] ?? 0
        let statePrevious = model.paymentPlan.previousYearTaxPayments[.state] ?? 0
        let federalSafeHarbor = model.safeHarborAmount[.federal] ?? 0
        let stateSafeHarbor = model.safeHarborAmount[.state] ?? 0
        let payrollInterval = model.paymentPlan.payrollInterval

        let conversationHistory = messages.suffix(6).map { message in
            "\(message.isUser ? "User" : "Assistant"): \(message.content)"
        }.joined(separator: "\n")

        let currentYear = Calendar.current.component(.year, from: Date())
        let vestingInfo = model.paymentPlan.vestingSchedule
            .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
            .map { event in
                "\(DateFormatter.shortDate.string(from: event.date)): \(event.shares) shares"
            }.joined(separator: ", ")

        let stockPrice = model.paymentPlan.stockPrice

        return """
        Answer tax questions casually and keep it short. Be direct, no fluff. Respond in Japanese.

        My tax info:
        - Federal: $\(String(format: "%.2f", federalWithholding))/payroll (every \(payrollInterval) days)
        - State: $\(String(format: "%.2f", stateWithholding))/payroll  
        - Last year federal: $\(String(format: "%.2f", federalPrevious))
        - Last year state: $\(String(format: "%.2f", statePrevious))
        - Safe harbor: Federal $\(String(format: "%.2f", federalSafeHarbor)), State $\(String(format: "%.2f", stateSafeHarbor))
        - Stock price: $\(String(format: "%.2f", stockPrice))
        - This year's vesting: \(vestingInfo.isEmpty ? "None" : vestingInfo)

        Recent chat:
        \(conversationHistory)

        Q: \(userMessage)

        Quick answer:
        """
    }
}

struct TaxSummaryCard: View {
    let model: TaxTrackingModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Tax Setup")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Federal Withholding:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", model.paymentPlan.withholdings[.federal] ?? 0))")
                        .fontWeight(.medium)
                }

                HStack {
                    Text("State Withholding:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", model.paymentPlan.withholdings[.state] ?? 0))")
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Payroll Frequency:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Every \(model.paymentPlan.payrollInterval) days")
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AdviceCard: View {
    let advice: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("AI Tax Advice")
                    .font(.headline)
            }

            Text(advice)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .background(.secondary)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .textSelection(.enabled)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    Text(DateFormatter.chatTime.string(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.accentColor)
                            .font(.caption)

                        Text(message.content.isEmpty ? "..." : message.content)
                            .textSelection(.enabled)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Text(DateFormatter.chatTime.string(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 24)
                }
                Spacer()
            }
        }
    }
}

struct ChatInputView: View {
    @Binding var text: String
    let isGenerating: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask about your taxes...", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1 ... 4)
                .onSubmit {
                    if !isGenerating {
                        onSend()
                    }
                }

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating ? .gray : .accentColor)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
        }
        .padding()
        .background(.secondary)
    }
}

extension DateFormatter {
    static let chatTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaxTrackingModel.self, configurations: config)

    let model = TaxTrackingModel()
    model.paymentPlan.withholdings[.federal] = 500.0
    model.paymentPlan.withholdings[.state] = 150.0
    model.paymentPlan.previousYearTaxPayments[.federal] = 8000.0
    model.paymentPlan.previousYearTaxPayments[.state] = 2000.0

    container.mainContext.insert(model)

    return TaxAdviceView()
        .modelContainer(container)
}
