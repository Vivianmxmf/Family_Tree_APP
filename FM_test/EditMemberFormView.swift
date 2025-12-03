
import SwiftUI
// Similar to my profile page, this page has member's info to be edited (Name, age, relationship)
struct EditMemberFormView: View {
    @ObservedObject var treeManager: TreeDataManager
    let member: Member
    let onSave: (Member) -> Void
    let onDelete: (() -> Void)?
    
    @State private var selectedEmoji: String
    @State private var name: String
    @State private var age: String
    @State private var relationship: String
    @State private var showEmojiPicker = false
    @State private var showSuccessMessage = false
    @State private var showTip = false
    
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
    let relationships = ["Parent", "Child", "Sibling", "Spouse", "Grandparent", "Cousin", "Relatives", "Pet"]
    
    // Update the member's data with treedatamanager
    init(treeManager: TreeDataManager, member: Member, onSave: @escaping (Member) -> Void, onDelete: (() -> Void)? = nil) {
        self.treeManager = treeManager
        self.member = member
        self.onSave = onSave
        self.onDelete = onDelete
        _selectedEmoji = State(initialValue: member.emoji)
        _name = State(initialValue: member.name)
        _age = State(initialValue: String(member.age))
        _relationship = State(initialValue: member.relationship)
    }
    
    // Similar format with my profile page, but each member card will show up when the corresponding member on the left member list is selected
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
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
                    // Member's name will automatically show in the form, same to age,relationship
                    VStack(spacing: 15) {
                        VStack(alignment: .leading) {
                            Text("Name:")
                                .font(.title3)
                                .foregroundColor(.gray)
                            TextField("Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Age:")
                                .font(.title3)
                                .foregroundColor(.gray)
                            TextField("Age", text: $age)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title3)
                                .foregroundColor(.gray)
                                .onChange(of: age) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        age = filtered
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Relationship")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(relationships, id: \.self) { rel in
                                        Text(rel)
                                            .font(.title3)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(relationship == rel ? Color.green : Color.gray.opacity(0.2))
                                            )
                                            .foregroundColor(relationship == rel ? .white : .gray)
                                            .onTapGesture {
                                                relationship = rel
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    // When a member's info is successfully updated, a sign will pop up to let users know.
                    if showSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Member updated successfully!")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    HStack(spacing: 20) {
                        if let onDelete = onDelete {
                            Button(action: {
                                onDelete()
                            }) {
                                Text("Delete")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            saveMember()
                            withAnimation {
                                showSuccessMessage = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSuccessMessage = false
                                }
                            }
                        }) {
                            // Users must click on the save button, otherwise, no info changes will be kept or updated
                            Text("Save")
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            // Tip box is on the surface as other page
            VStack {
                HStack {
                    Spacer()
                    TipButton(showTip: $showTip)
                        .padding(.top, 20)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    TipBoxView(isShowing: $showTip, tipText: TipTexts.editMember)
                        .padding(.top, 20)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
        }
    }
    
    // After clicking on save button, the info changes will be stored in the treedatamanager
    private func saveMember() {
        guard let ageInt = Int(age) else { return }
        
        var updatedMember = member
        updatedMember.emoji = selectedEmoji
        updatedMember.name = name
        updatedMember.age = ageInt
        updatedMember.relationship = relationship
        
        treeManager.updateMember(updatedMember)
        onSave(updatedMember)
    }
}
