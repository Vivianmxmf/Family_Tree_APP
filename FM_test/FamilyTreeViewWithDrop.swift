import SwiftUI
import AppKit
import Foundation

struct FamilyTreeViewWithDrop: View {
    @ObservedObject var treeManager: TreeDataManager
    @Binding var positions: [UUID: CGPoint]
    @State private var selectedMember: UUID?
    @State private var isDrawingLine = false
    @State private var lineStart: CGPoint = .zero
    @State private var lineEnd: CGPoint = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var selectedConnection: (UUID, UUID)?
    @State private var showDeleteConnectionAlert = false
    @State private var showSaveButton = false
    @State private var draggedMember: Member?
    @Binding var hasUnsavedChanges: Bool
    @State private var deleteMode: DeleteMode = .one
    
    enum DeleteMode {
        case one, all
    }
    
    var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        let sortedOtherMembers = treeManager.members.sorted { m1, m2 in
            let count1 = m1.getTotalConnections()
            let count2 = m2.getTotalConnections()
            if count1 != count2 {
                return count1 > count2
            }
            return m1.age > m2.age
        }
        members.append(contentsOf: sortedOtherMembers)
        return members
    }
    // The righ side plot structure
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ZStack {
                    connectionsView
                    drawingLineView
                    membersView(geometry: geometry)
                }
                .scaleEffect(scale)
                .offset(offset)
                .gesture(magnificationGesture)
                .gesture(dragGesture)
                .onDrop(of: ["public.text"], isTargeted: nil) { providers, location in
                    handleDrop(providers: providers, at: location, in: geometry)
                }
            }
            if showSaveButton {
                saveButton
            }
        }
        .alert("Delete Connection?", isPresented: $showDeleteConnectionAlert) {
            deleteConnectionAlert
        }
    }
    // The connection line functionality as other pages
    private func connectionLines(for member: Member, connectionId: UUID) -> some View {
        Group {
            if let startPos = positions[member.id],
               let endPos = positions[connectionId] {
                let count = member.getConnectionCount(connectionId)
                ForEach(0..<count, id: \.self) { index in
                    let offset = CGFloat(index - (count - 1) / 2) * 3
                    ConnectionLine(
                        start: offsetPoint(startPos, by: offset),
                        end: offsetPoint(endPos, by: offset),
                        isSelected: selectedConnection.map { $0 == (member.id, connectionId) } ?? false
                    )
                    .onTapGesture(count: 2) {
                        selectedConnection = (member.id, connectionId)
                        showDeleteConnectionAlert = true
                    }
                }
            }
        }
    }

    private func connectionsForMember(_ member: Member) -> some View {
        Group {
            ForEach(member.connections, id: \.self) { connectionId in
                connectionLines(for: member, connectionId: connectionId)
            }
        }
    }

    private var connectionsView: some View {
        ZStack {
            ForEach(allMembers) { member in
                connectionsForMember(member)
            }
        }
    }
    // The lines are extended along with moving the member cards
    private var drawingLineView: some View {
        Group {
            if isDrawingLine {
                Path { path in
                    path.move(to: lineStart)
                    path.addLine(to: lineEnd)
                }
                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))
            }
        }
    }
    // All members start in center position: represent all family members come from one root
    private func getInitialPosition(for member: Member, in geometry: GeometryProxy) -> CGPoint {
        return CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
    // The layout for the member cards on the right side plot
    private func membersView(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(allMembers.filter { $0.id != treeManager.userProfile?.id }) { member in
                MemberNode(
                    member: member,
                    position: positions[member.id] ?? getInitialPosition(for: member, in: geometry),
                    isSelected: selectedMember == member.id
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            positions[member.id] = value.location
                            hasUnsavedChanges = true
                        }
                )
                .onTapGesture {
                    handleNodeTap(member)
                }
            }
            if let profile = treeManager.userProfile {
                MemberNode(
                    member: profile,
                    position: positions[profile.id] ?? getInitialPosition(for: profile, in: geometry),
                    isSelected: selectedMember == profile.id
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            positions[profile.id] = value.location
                            hasUnsavedChanges = true
                        }
                )
                .onTapGesture {
                    handleNodeTap(profile)
                }
            }
        }
    }
    // At last, the saving is automatic
    private var saveButton: some View {
        VStack {
            Spacer()
            Button(action: saveLayout) {
                Text("Save Layout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
    }
    // The alert box for deleting lines
    private var deleteConnectionAlert: some View {
        VStack {
            Text("Delete Connection?")
                .font(.headline)
            
            HStack {
                Button("Cancel", role: .cancel) {
                    selectedConnection = nil
                }
                .foregroundColor(.red)
                
                Button("OK") {
                    if let (id1, id2) = selectedConnection {
                        deleteConnection(between: id1, and: id2)
                    }
                    selectedConnection = nil
                }
                .foregroundColor(.blue)
            }
        }
    }
    

    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale *= delta
            }
            .onEnded { _ in
                lastScale = 1.0
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    // When dragging member cards from member list on the left list,converting drop location into local coordinates.
    private func handleDrop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        let dropLocation = location
        if let provider = providers.first {
            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
                if let data = data as? Data,
                   let idString = String(data: data, encoding: .utf8),
                   let uuid = UUID(uuidString: idString) {
                    DispatchQueue.main.async {
                        positions[uuid] = dropLocation
                        hasUnsavedChanges = true
                    }
                }
            }
        }
        return true
    }
    
    // The connection section is depedning on the roles of two profiles' roles
    // Two main ways: when two profiles are the same and when not
    // When same: two pets, two counsins,two child, two parent,two grandparent, two relatives
    // When not: the logic should be common sense
    // My profile and pet profile are different
    private func getRelationshipMapping(_ role1: String, _ role2: String, isWithProfile: Bool) -> (String, String) {
        // Special handling for pets
        if role1 == "Pet" && role2 == "Pet" {
            return ("Pet Friend", "Pet Friend")
        }
        if role1 == "Pet" {
            return ("Pet", "Owner")
        }
        if role2 == "Pet" {
            return ("Owner", "Pet")
        }

        // Handle profile-related connections
        if isWithProfile {
            switch role1 {
                case "Child": return ("Parent", "Child")
                case "Parent": return ("Child", "Parent")
                case "Grandparent": return ("Grandchild", "Grandparent")
                case "Spouse": return ("Spouse", "Spouse")
                case "Cousin": return ("Cousin", "Cousin")
                case "Relatives": return ("Relatives", "Relatives")
                default: return (role1, role2)
            }
        }

        // Handle same role connections
        if role1 == role2 {
            switch role1 {
                case "Parent", "Grandparent": return ("Spouse", "Spouse")
                case "Child": return ("Sibling", "Sibling")
                case "Cousin": return ("Cousin", "Cousin")
                case "Relatives": return ("Relatives", "Relatives")
                default: return (role1, role2)
            }
        }

        // Handle different role connections
        switch role1 {
            case "Grandparent":
                switch role2 {
                    case "Parent": return ("Parent", "Child")
                    case "Child": return ("Great-grandparent", "Great-grandchild")
                    case "Cousin", "Relatives": return ("Relatives", "Relatives")
                    case "Spouse": return ("Spouse", "Spouse")
                    default: return (role1, role2)
                }
            case "Parent":
                switch role2 {
                    case "Grandparent": return ("Child", "Parent")
                    case "Child": return ("Parent", "Child")
                    case "Cousin": return ("Cousin", "Cousin")
                    case "Spouse": return ("Parent", "Child")
                    case "Relatives": return ("Relatives", "Relatives")
                    default: return (role1, role2)
                }
            case "Child":
                switch role2 {
                    case "Parent": return ("Grandparent", "GrandChild")
                    case "Grandparent": return ("Great-grandparent", "Great-grandchild")
                    case "Spouse": return ("Parent", "Child")
                    case "Cousin", "Relatives": return ("Relatives", "Relatives")
                    default: return (role1, role2)
                }
            case "Spouse":
                switch role2 {
                    case "Child": return ("Parent", "Child")
                    case "Parent": return ("Child", "Parent")
                    case "Grandparent": return ("Grandchild", "Grandparent")
                    case "Cousin": return ("Cousin", "Cousin")
                    case "Relatives": return ("Relatives", "Relatives")
                    default: return ("Spouse", "Spouse")
                }
            case "Cousin", "Relatives":
                return ("Relatives", "Relatives")
            default:
                return (role1, role2)
        }
    }
    // The way that users connect two member profiles is through tapping on one of them
    // The blue boarder means that a member is succesfully selected
    // Then click on the other profile, the line is connected
    private func handleNodeTap(_ member: Member) {
        if let selected = selectedMember {
            if selected != member.id {
                var firstMember = treeManager.members.first(where: { $0.id == selected }) ?? treeManager.userProfile!
                var secondMember = member
                
                let isWithProfile = firstMember.id == treeManager.userProfile?.id || secondMember.id == treeManager.userProfile?.id
                let (_, _) = getRelationshipMapping(firstMember.relationship, secondMember.relationship, isWithProfile: isWithProfile)
                
                // Add connections in both directions without modifying roles
                firstMember.addConnection(secondMember.id)
                secondMember.addConnection(firstMember.id)
                
                // Update the members in tree manager
                if firstMember.id == treeManager.userProfile?.id {
                    treeManager.setUserProfile(firstMember)
                } else {
                    treeManager.updateMember(firstMember)
                }
                
                if secondMember.id == treeManager.userProfile?.id {
                    treeManager.setUserProfile(secondMember)
                } else {
                    treeManager.updateMember(secondMember)
                }
                
                hasUnsavedChanges = true
            }
            selectedMember = nil
            isDrawingLine = false
        } else {
            selectedMember = member.id
            if let position = positions[member.id] {
                lineStart = position
                lineEnd = position
                isDrawingLine = true
            }
        }
    }
    
    // The deleteconnection functionality: double click on the lines so that an alert box pops up
    // Users can choose to delete the line or cancel it
    private func deleteConnection(between id1: UUID, and id2: UUID) {
        if var member1 = treeManager.members.first(where: { $0.id == id1 }) ?? (id1 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
            member1.removeConnection(id2)
            if member1.id == treeManager.userProfile?.id {
                treeManager.setUserProfile(member1)
            } else {
                treeManager.updateMember(member1)
            }
        }
        if var member2 = treeManager.members.first(where: { $0.id == id2 }) ?? (id2 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
            member2.removeConnection(id1)
            if member2.id == treeManager.userProfile?.id {
                treeManager.setUserProfile(member2)
            } else {
                treeManager.updateMember(member2)
            }
        }
        hasUnsavedChanges = true
    }
    
    private func deleteAllConnections(between id1: UUID, and id2: UUID) {
        if var member1 = treeManager.members.first(where: { $0.id == id1 }) ?? (id1 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
            member1.removeAllConnections(id2)
            if member1.id == treeManager.userProfile?.id {
                treeManager.setUserProfile(member1)
            } else {
                treeManager.updateMember(member1)
            }
        }
        if var member2 = treeManager.members.first(where: { $0.id == id2 }) ?? (id2 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
            member2.removeAllConnections(id1)
            if member2.id == treeManager.userProfile?.id {
                treeManager.setUserProfile(member2)
            } else {
                treeManager.updateMember(member2)
            }
        }
        hasUnsavedChanges = true
    }
    
    private func offsetPoint(_ point: CGPoint, by offset: CGFloat) -> CGPoint {
        let angle = atan2(lineEnd.y - lineStart.y, lineEnd.x - lineStart.x) + .pi/2
        return CGPoint(
            x: point.x + cos(angle) * offset,
            y: point.y + sin(angle) * offset
        )
    }
    
    // At last, the saving is automatic
    private func saveLayout() {
        showSaveButton = false
    }
}

struct FamilyTreeViewWithDrop_Previews: PreviewProvider {
    static var previews: some View {
        FamilyTreeViewWithDrop(
            treeManager: TreeDataManager(),
            positions: .constant([:]),
            hasUnsavedChanges: .constant(false)
        )
    }
}
