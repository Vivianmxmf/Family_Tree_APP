import SwiftUI
import AppKit
import Foundation
import CoreGraphics

// “MY Tree” feature on Menu
// TreeView structure specifies two subviews' structures: MemberList and TreeView
// The Tip box is still on the surface as other pages
struct TreeView: View {
    @StateObject private var treeManager: TreeDataManager
    @Binding var layoutPositions: [UUID: CGPoint]
    @State private var selectedViewMode = 0 
    @State private var selectedMember: Member?
    @State private var showMemberDetails = false
    @State private var showDeleteConfirmation = false
    @State private var memberToDelete: Member?
    @State private var hiddenMembers: Set<UUID> = []
    @State private var showSaveButton = false
    @State private var showTip = false
    
    init(treeManager: TreeDataManager, layoutPositions: Binding<[UUID: CGPoint]>) {
        _treeManager = StateObject(wrappedValue: treeManager)
        _layoutPositions = layoutPositions
    }
    var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        members.append(contentsOf: treeManager.members)
        return members
    }
    
    var body: some View {
        ZStack {
            VStack {
                Picker("View Mode", selection: $selectedViewMode) {
                    Text("Member List").tag(0)
                    Text("Tree View").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedViewMode == 0 {
                    MemberListView(
                        treeManager: treeManager,
                        selectedMember: $selectedMember,
                        showMemberDetails: $showMemberDetails,
                        showDeleteConfirmation: $showDeleteConfirmation,
                        memberToDelete: $memberToDelete
                    )
                } else {
                    TreeViewContent(
                        treeManager: treeManager,
                        layoutPositions: $layoutPositions,
                        selectedMember: $selectedMember,
                        hiddenMembers: $hiddenMembers,
                        showSaveButton: $showSaveButton
                    )
                }
            }
            
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
                    TipBoxView(isShowing: $showTip, tipText: TipTexts.myTree)
                        .padding(.top, 20)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showMemberDetails) {
            if let member = selectedMember {
                MemberDetailView(member: member, treeManager: treeManager)
            }
        }
        .alert("Remove this family member?", isPresented: $showDeleteConfirmation) {
            VStack {
                Text("Delete the member and cut up the connection?")
                    .font(.headline)
                HStack(spacing: 50) {
                    Button("No", role: .cancel) {
                        memberToDelete = nil
                    }
                    .foregroundColor(.red)
                    Button("Yes", role: .destructive) {
                        if let member = memberToDelete {
                            treeManager.deleteMember(member)
                        }
                        memberToDelete = nil
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// This sturcture determines the content of TreeView subview
// The TreeView subview has left memberlist-alike which users can click on eye button to block that member being visible on right side plot
// The right side plot is aglined with the right side of edit tree page's right side plot, displaying the family tree
struct TreeViewContent: View {
    let treeManager: TreeDataManager
    @Binding var layoutPositions: [UUID: CGPoint]
    @Binding var selectedMember: Member?
    @Binding var hiddenMembers: Set<UUID>
    @Binding var showSaveButton: Bool
    
    var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        members.append(contentsOf: treeManager.members)
        return members
    }
    
    var body: some View {
        HStack(spacing: 0) {
            MemberListSidebar(
                treeManager: treeManager,
                hiddenMembers: $hiddenMembers,
                showSaveButton: $showSaveButton,
                allMembers: allMembers
            )
            
            TreeVisualizer(
                treeManager: treeManager,
                layoutPositions: $layoutPositions,
                selectedMember: $selectedMember,
                hiddenMembers: hiddenMembers,
                showSaveButton: $showSaveButton,
                allMembers: allMembers
            )
        }
    }
}

// This structure determines the left memberlist on Treeview subview
struct MemberListSidebar: View {
    @ObservedObject var treeManager: TreeDataManager
    @Binding var hiddenMembers: Set<UUID>
    @Binding var showSaveButton: Bool
    let allMembers: [Member]
    
    var body: some View {
        VStack {
            Text("Members")
                .font(.title)
                .foregroundColor(.green)
                .padding()
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(allMembers) { member in
                        MemberListRow(
                            member: member,
                            treeManager: treeManager,
                            hiddenMembers: $hiddenMembers,
                            showSaveButton: $showSaveButton
                        )
                    }
                }
                .padding()
            }
        }
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// This structure determines the member card on the left-side member list
// Each member card has its profile emoji, role, and age (info)
// the eye button is selected to block the visiablity of the corresponding member card at the right side plot
struct MemberListRow: View {
    let member: Member
    let treeManager: TreeDataManager
    @Binding var hiddenMembers: Set<UUID>
    @Binding var showSaveButton: Bool
    
    var body: some View {
        HStack {
            Text(member.emoji)
                .font(.system(size: 40))
            VStack(alignment: .leading) {
                Text(member.name)
                    .font(.headline)
                    .foregroundColor(.green)
                Text("\(member.age) years")
                    .foregroundColor(.green)
                if member.relationship != "Self" {
                    Text(member.relationship)
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            Spacer()
            if member.id != treeManager.userProfile?.id {
                Button(action: {
                    if hiddenMembers.contains(member.id) {
                        hiddenMembers.remove(member.id)
                    } else {
                        hiddenMembers.insert(member.id)
                        treeManager.removeConnectionsForMember(member.id)
                    }
                    showSaveButton = true
                }) {
                    Image(systemName: hiddenMembers.contains(member.id) ? "eye.slash" : "eye")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// This structure is to be aligned with the tree layout on edit tree page (the connection lines and the profile cards)
// the following ConnectionsView and NodesView sturcture are the same with the tree layout on edit tree page
// Removing the delete connections function since it should be on edit tree page
struct TreeVisualizer: View {
    @ObservedObject var treeManager: TreeDataManager
    @Binding var layoutPositions: [UUID: CGPoint]
    @Binding var selectedMember: Member?
    let hiddenMembers: Set<UUID>
    @Binding var showSaveButton: Bool
    let allMembers: [Member]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ConnectionsView(
                    treeManager: treeManager,
                    layoutPositions: layoutPositions,
                    hiddenMembers: hiddenMembers,
                    allMembers: allMembers
                )
                NodesView(
                    treeManager: treeManager,
                    layoutPositions: $layoutPositions,
                    selectedMember: $selectedMember,
                    hiddenMembers: hiddenMembers,
                    showSaveButton: $showSaveButton,
                    allMembers: allMembers,
                    geometry: geometry
                )
            }
        }
    }
}
struct ConnectionsView: View {
    let treeManager: TreeDataManager
    let layoutPositions: [UUID: CGPoint]
    let hiddenMembers: Set<UUID>
    let allMembers: [Member]
    
    var body: some View {
        ForEach(allMembers) { member in
            if !hiddenMembers.contains(member.id) {
                ForEach(member.connections, id: \.self) { connectionId in
                    if !hiddenMembers.contains(connectionId),
                       let startPos = layoutPositions[member.id],
                       let endPos = layoutPositions[connectionId] {
                        ConnectionLine(
                            start: startPos,
                            end: endPos,
                            isSelected: false
                        )
//                        .onTapGesture(count: 2) {
//                            deleteConnection(between: member.id, and: connectionId)
//                        }
                    }
                }
            }
        }
    }
    
//    private func deleteConnection(between id1: UUID, and id2: UUID) {
//        if var member1 = treeManager.members.first(where: { $0.id == id1 }) ?? (id1 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
//            member1.removeConnection(id2)
//            if member1.id == treeManager.userProfile?.id {
//                treeManager.setUserProfile(member1)
//            } else {
//                treeManager.updateMember(member1)
//            }
//        }
//        if var member2 = treeManager.members.first(where: { $0.id == id2 }) ?? (id2 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
//            member2.removeConnection(id1)
//            if member2.id == treeManager.userProfile?.id {
//                treeManager.setUserProfile(member2)
//            } else {
//                treeManager.updateMember(member2)
//            }
//        }
//    }
}

struct NodesView: View {
    @ObservedObject var treeManager: TreeDataManager
    @Binding var layoutPositions: [UUID: CGPoint]
    @Binding var selectedMember: Member?
    let hiddenMembers: Set<UUID>
    @Binding var showSaveButton: Bool
    let allMembers: [Member]
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(allMembers) { member in
            if !hiddenMembers.contains(member.id) {
                let position = layoutPositions[member.id] ?? CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                MemberNode(
                    member: member,
                    position: position,
                    isSelected: selectedMember?.id == member.id
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            layoutPositions[member.id] = value.location
                            showSaveButton = true
                        }
                )
                .onTapGesture {
                    selectedMember = selectedMember?.id == member.id ? nil : member
                }
            }
        }
    }
}

// This structure determines thw Memberlist subview structure
// Similarly, this memberlist has member card which contains member info and a delete button for deleting member
// But this time, the member card has connections section if this member is connected to someone in the family tree
struct MemberListView: View {
    @ObservedObject var treeManager: TreeDataManager
    @Binding var selectedMember: Member?
    @Binding var showMemberDetails: Bool
    @Binding var showDeleteConfirmation: Bool
    @Binding var memberToDelete: Member?
    
    private func findConnectedMember(_ connectionId: UUID) -> Member? {
        if connectionId == treeManager.userProfile?.id {
            return treeManager.userProfile
        }
        return treeManager.members.first(where: { $0.id == connectionId })
    }
    
    var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        members.append(contentsOf: treeManager.members)
        return members
    }
    
    var body: some View {
        if allMembers.isEmpty {
            Text("No family members added yet")
                .font(.title2)
                .foregroundColor(.gray)
                .padding()
        } else {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(allMembers) { member in
                        VStack(alignment: .leading, spacing: 12) {
                            memberInfoSection(member)
                            if !member.connections.isEmpty {
                                connectionSection(member)
                            }
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
    }
    
    private func memberInfoSection(_ member: Member) -> some View {
        HStack(spacing: 15) {
            Text(member.emoji)
                .font(.system(size: 50))
            VStack(alignment: .leading, spacing: 8) {
                Text(member.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text("Age: \(member.age) years")
                    .font(.title3)
                    .foregroundColor(.black)
                Text("Role: \(member.relationship)")
                    .font(.title3)
                    .foregroundColor(.black)
            }
            Spacer()
            if member.id != treeManager.userProfile?.id {
                deleteButton(for: member)
            }
        }
    }
    
    private func deleteButton(for member: Member) -> some View {
        Button(action: {
            memberToDelete = member
            showDeleteConfirmation = true
        }) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundColor(.red)
                .padding(10)
                .background(Circle().stroke(Color.red, lineWidth: 2))
        }
    }
    
    private func connectionSection(_ member: Member) -> some View {
        VStack(alignment: .leading) {
            Text("Family Connections:")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.top, 5)
            ForEach(member.connections, id: \.self) { connectionId in
                if let connected = findConnectedMember(connectionId) {
                    Text("• \(connected.relationship): \(connected.name)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                }
            }
        }
    }
}

// When a member is created, the member list will catch its info and put it in a member card
// When a member is connected with other member, both members' cards will appear the connection section
struct MemberCard: View {
    let member: Member
    let treeManager: TreeDataManager
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    private func findConnectedMember(_ connectionId: UUID) -> Member? {
        if connectionId == treeManager.userProfile?.id {
            return treeManager.userProfile
        }
        return treeManager.members.first(where: { $0.id == connectionId })
    }

    private func getRelationText(for connected: Member, isProfile: Bool) -> String {
        if isProfile {
            return "\(connected.relationship): \(connected.name)"
        } else if connected.id == treeManager.userProfile?.id {
            return "My \(member.relationship)"
        } else {
            return "\(connected.relationship): \(connected.name)"
        }
    }

    private var familyRelations: [String] {
        var relations: [String] = []
        for connectedId in member.connections {
            if let connected = findConnectedMember(connectedId) {
                let isProfile = member.id == treeManager.userProfile?.id
                let relation = getRelationText(for: connected, isProfile: isProfile)
                relations.append(relation)
            }
        }
        return relations
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                Text(member.emoji)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(member.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Age: \(member.age) years")
                        .font(.title3)
                        .foregroundColor(.black)
                    
                    Text("Role: \(member.relationship)")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Circle().stroke(Color.red, lineWidth: 2))
                    }
                }
            }
            
            if !familyRelations.isEmpty {
                Text("Family Connections:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.top, 5)
                
                ForEach(familyRelations, id: \.self) { relation in
                    Text("• \(relation)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .onTapGesture(perform: onTap)
    }
}

// This is the how member info is displyed on its member card
struct MemberDetailView: View {
    let member: Member
    let treeManager: TreeDataManager
    @Environment(\.presentationMode) var presentationMode
    
    private func findConnectedMember(_ connectionId: UUID) -> Member? {
        if connectionId == treeManager.userProfile?.id {
            return treeManager.userProfile
        }
        return treeManager.members.first(where: { $0.id == connectionId })
    }

    private func getRelationText(for connected: Member, isProfile: Bool) -> String {
        if isProfile {
            return "\(connected.relationship): \(connected.name)"
        } else if connected.id == treeManager.userProfile?.id {
            return "My \(member.relationship)"
        } else {
            return "\(connected.relationship): \(connected.name)"
        }
    }

    private var familyRelations: [String] {
        var relations: [String] = []
        for connectedId in member.connections {
            if let connected = findConnectedMember(connectedId) {
                let isProfile = member.id == treeManager.userProfile?.id
                let relation = getRelationText(for: connected, isProfile: isProfile)
                relations.append(relation)
            }
        }
        return relations
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(member.emoji)
                        .font(.system(size: 80))
                    Text(member.name)
                        .font(.title)
                    VStack(alignment: .leading, spacing: 15) {
                        detailRow("Age", value: "\(member.age) years")
                        detailRow("Relationship", value: member.relationship)
                        if !familyRelations.isEmpty {
                            Text("Family Connections")
                                .font(.headline)
                                .padding(.top)
                            ForEach(familyRelations, id: \.self) { relation in
                                Text("• \(relation)")
                                    .font(.body)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    private func detailRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(treeManager: TreeDataManager())
    }
}
