import SwiftUI

// This file is for emoji pop up box
// A fancy view for selceting emojis
// This conponent will be shared on edit member page,my profile page, add member page.
struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Binding var showPicker: Bool
    let emojis: [String]
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Select an Emoji")
                    .font(.headline)
                    .padding()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 40))
                            .padding(10)
                            .background(selectedEmoji == emoji ? Color.gray.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedEmoji = emoji
                                showPicker = false
                            }
                    }
                }
                .padding()
            }
        }
        .frame(width: 300, height: 400)
    }
} 
