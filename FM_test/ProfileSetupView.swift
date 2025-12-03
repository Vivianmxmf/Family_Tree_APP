
import SwiftUI

//create their profile by entering personal information including an emoji avatar, name, age, and relationship status
struct ProfileSetupView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var treeManager: TreeDataManager
    @Binding var selectedTab: MenuTab?
    @State private var showTip = false
    @State private var selectedEmoji: String
    @State private var name: String
    @State private var age: String
    @State private var showEmojiPicker = false
    
    let emojis = [
        "👤", "👨", "👩", "👶", "👧", "👦",
        "👨‍🦰", "👩‍🦰", "👴", "👵", "🧑",
        "🧑‍🦰", "🧑‍🦱", "🧑‍🦳", "🧑‍🦲",
        "👨‍🦱", "👨‍🦳", "👨‍🦲", "👩‍🦱", "👩‍🦳", "👩‍🦲",
        "👱‍♂️", "👱‍♀️", "👲", "🧔", "🧔‍♂️", "🧔‍♀️",
        "👨‍👩‍👦", "👨‍👩‍👧", "👨‍👩‍👧‍👦", "👨‍👩‍👦‍👦", "👨‍👩‍👧‍👧",
        "🐕", "🐶", "🐩", "🐈", "🐱", "🐰", "🐇", "🐹",
        "🐦", "🦜", "🦮", "🐠", "🐟", "🐢"
    ]
//    static let relationships = ["Parent", "Child", "Sibling", "Spouse", "Grandparent", "Cousin"]
    
    // Set up the default emoji
    init(treeManager: TreeDataManager, selectedTab: Binding<MenuTab?>) {
        self.treeManager = treeManager
        self._selectedTab = selectedTab
        
        if let profile = treeManager.userProfile {
            _selectedEmoji = State(initialValue: profile.emoji)
            _name = State(initialValue: profile.name)
            _age = State(initialValue: String(profile.age))
        } else {
            _selectedEmoji = State(initialValue: "👤")
            _name = State(initialValue: "")
            _age = State(initialValue: "")
        }
    }
    
    // Determines the form sturcture on my profile page
    var body: some View {
        ZStack {
            VStack(spacing: 25) {
                Text(treeManager.userProfile == nil ? "Create Your Profile" : "Edit Your Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.top, 30)
                VStack(spacing: 15) {
                    Text(selectedEmoji)
                        .font(.system(size: 80))
                        .padding(20)
                        .background(
                            Circle()
                                .fill(Color.green.opacity(0.1))
                        )
                        .onTapGesture {
                            showEmojiPicker = true
                        }
                    
                    Text("Tap to change emoji")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .sheet(isPresented: $showEmojiPicker) {
                    EmojiPickerView(
                        selectedEmoji: $selectedEmoji,
                        showPicker: $showEmojiPicker,
                        emojis: emojis
                    )
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(.gray)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .frame(height: 40)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(.gray)
                        TextField("Enter your age", text: $age)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .frame(height: 40)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        selectedTab = nil
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 45)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                    }
                    
                    // navigate to the main menu upon successful profile creation
                    Button(action: {
                        saveProfile()
                        selectedTab = nil
                    }) {
                        Text(treeManager.userProfile == nil ? "Create" : "Update")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 45)
                            .background(isFormValid ? Color.green : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.bottom, 30)
            }
            
            // Tip Button is on the surface
            VStack {
                HStack {
                    Spacer()
                    TipButton(showTip: $showTip)
                        .padding()
                }
                Spacer()
            }
            
            // After clicking on tip button, the tip box shows up
            VStack {
                HStack {
                    Spacer()
                    TipBoxView(isShowing: $showTip, tipText: TipTexts.myProfile)
                        .padding()
                }
                Spacer()
            }
        }
        .padding()
        .navigationTitle("")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                }
            }
        }
    }
    
    // Validation check
    private var isFormValid: Bool {
        !name.isEmpty && !age.isEmpty && Int(age) != nil
    }
    
    // Save profile automatically
    private func saveProfile() {
        guard let ageInt = Int(age) else { return }
        let profile = Member(
            name: name,
            age: ageInt,
            emoji: selectedEmoji,
            relationship: "Self"
        )
        treeManager.setUserProfile(profile)
        print("Profile saved, dismissing profile setup")
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        let treeManager = TreeDataManager()
        treeManager.setUserProfile(Member(name: "John Doe", age: 30, emoji: "👤", relationship: "Self"))
        return ProfileSetupView(treeManager: treeManager, selectedTab: .constant(nil))
    }
}
