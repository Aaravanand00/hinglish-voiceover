import SwiftUI

/// Testing harness / Simulator allowing developers & testers to type or inject Hinglish phrases and inspect the pipeline.
public struct TestSimulatorView: View {
    @ObservedObject var viewModel: AssistantViewModel
    @State private var inputTestPhrase: String = "kal 5 baje meeting ka reminder laga do"
    
    // Quick test buttons
    private let presetTests = [
        "kal 5 baje meeting ka reminder laga do",
        "Rahul ko call lagao",
        "Pooja ko message bhejo ki main late ho jaunga",
        "home screen pe wapas jao",
        "subah 6 baje ka alarm set karo",
        "settings kholo",
        "ye kya hai screen padho",
        "aaj shaam 7 baje gym yaad dila dena"
    ]
    
    public init(viewModel: AssistantViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Test Hinglish Command Pipeline")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Input TextField
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type or Select Hinglish Phrase:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Type phrase here...", text: $inputTestPhrase)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Run") {
                            viewModel.processTranscript(inputTestPhrase)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                // Presets Quick Chips
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preset Test Phrases:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(presetTests, id: \.self) { preset in
                                Button(action: {
                                    inputTestPhrase = preset
                                    viewModel.processTranscript(preset)
                                }) {
                                    Text(preset)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Pipeline Results Breakdown
                if let command = viewModel.lastParsedCommand {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pipeline Step-by-Step Breakdown")
                            .font(.headline)
                        
                        IntentResultCard(command: command, tokens: viewModel.detectedTokens)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Test Simulator")
    }
}
