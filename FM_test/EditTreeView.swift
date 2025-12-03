import SwiftUI
import Foundation
import AppKit

// determine the right part structure of edit tree page: the plots when users can drag member cards, add connection line, and remove connection lines
struct EditTreeView: View {
    @ObservedObject var treeManager: TreeDataManager
    @State private var selectedConnection: (UUID, UUID)?
    @State private var showDeleteConnectionAlert = false
    @State private var positions: [UUID: CGPoint] = [:]
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        members.append(contentsOf: treeManager.members)
        return members
    }
    // record the members' position and keep updated with the tree view mode on my tree page
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(allMembers) { member in
                    ForEach(member.connections, id: \.self) { connectionId in
                        if let startPos = positions[member.id],
                           let endPos = positions[connectionId] {
                            ConnectionLine(
                                start: startPos,
                                end: endPos,
                                isSelected: selectedConnection.map { $0 == (member.id, connectionId) } ?? false
                            )
                            // Double click on the lines to remove only one line
                            .onTapGesture(count: 2) {
                                deleteConnection(between: member.id, and: connectionId)
                            }
                        }
                    }
                }
                
                ForEach(allMembers) { member in
                    let position = positions[member.id] ?? CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    EditableNode(
                        member: member,
                        position: position,
                        onDrag: { newPosition in
                            positions[member.id] = newPosition
                        }
                    )
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value.magnitude
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
            )
        }
    }
    // Removing the connection line, the system has to undate for both members that are attached to the line.
    private func deleteConnection(between id1: UUID, and id2: UUID) {
        if var member1 = treeManager.members.first(
            where: { $0.id == id1 }) ??
            (id1 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
            member1.removeConnection(id2)
            if member1.id == treeManager.userProfile?.id {
                treeManager.setUserProfile(member1)
            } else {
                treeManager.updateMember(member1)
            }
        }
        if var member2 = treeManager.members.first(
            where: { $0.id == id2 }) ??
            (id2 == treeManager.userProfile?.id ? treeManager.userProfile : nil) {
            member2.removeConnection(id1)
            if member2.id == treeManager.userProfile?.id {
                treeManager.setUserProfile(member2)
            } else {
                treeManager.updateMember(member2)
            }
        }
    }
} 
