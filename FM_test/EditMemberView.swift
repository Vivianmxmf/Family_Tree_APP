
import SwiftUI
import AppKit
import Foundation

struct EditMemberView: View {
    @ObservedObject var treeManager: TreeDataManager
    @State private var selectedMember: Member?
    @Binding var selectedTab: MenuTab?
    @Environment(\.dismiss) private var dismiss
    
    // Keep aligned with members data
    private var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        members.append(contentsOf: treeManager.members)
        return members
    }
    
    // The main structure of edit member page, the left side is a member list,
    //the right side will show a member card when that member is clicked
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Members")
                    .font(.title)
                    .padding()
                
                // When no saved_data, the text will display to show there's no members
                if allMembers.isEmpty {
                    Text("No family members to edit")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(allMembers) { member in
                                MemberRowView(
                                    member: member,
                                    isSelected: selectedMember?.id == member.id,
                                    isProfile: member.id == treeManager.userProfile?.id
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        if selectedMember?.id == member.id {
                                            selectedMember = nil
                                        } else {
                                            selectedMember = member
                                        }
                                    }
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
            .frame(width: 350)
            .background(Color.white)
            // If users selected their own profiles on this page, they will see a button that will lead them to the my profile page to edit their own profile.
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                if let member = selectedMember {
                    if member.id == treeManager.userProfile?.id {
                        VStack(spacing: 20) {
                            Text("My Profile")
                                .font(.title)
                                .padding(.top)
                            
                            MemberRowView(
                                member: member,
                                isSelected: false,
                                isProfile: true
                            )
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.05))
                            )
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedTab = .myProfile
                            }) {
                                HStack {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.title2)
                                    Text("Edit My Profile")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        EditMemberFormView(
                            treeManager: treeManager,
                            member: member,
                            onSave: { updatedMember in
                                treeManager.updateMember(updatedMember)
                                selectedMember = updatedMember
                            },
                            onDelete: {
                                withAnimation {
                                    treeManager.deleteMember(member)
                                    selectedMember = nil
                                }
                            }
                        )
                    }
                } else {
                    VStack {
                        Text("Select a member to edit")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color.white)
    }
}

//The left member list which has member selection, member info display, and  real-time updates when a member is selected or edited
struct MemberRowView: View {
    let member: Member
    let isSelected: Bool
    let isProfile: Bool
    var body: some View {
        HStack(spacing: 15) {
            Text(member.emoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.name)
                        .font(.title2)
                        .foregroundColor(.gray)
                    if isProfile {
                        Text("(Profile)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .cornerRadius(6)
                    }
                }
                
                Text(member.relationship)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
    }
}
