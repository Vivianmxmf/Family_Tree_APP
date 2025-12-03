


import SwiftUI
import Combine
import Foundation

//member creation, updates, deletions, and position management.
//The state of the family tree, manages member relationships
//functionality for member selection, position tracking.
public class TreeDataManager: ObservableObject {
    @Published public var members: [Member] = []
    @Published public var selectedMember: Member?
    @Published public var memberPositions: [UUID: CGPoint] = [:]
    @Published public var showAddMemberView = false
    @Published public var showEditMemberView = false
    @Published public var showStoryView = false
    @Published public var userProfile: Member?
    
    private let positionsKey = "memberPositions"
    private let membersKey = "members"
    private let userProfileKey = "userProfile"
    
    public init() {
        loadData()
    }
    
    // Create a new member
    public func addMember(_ member: Member) {
        members.append(member)
        saveData()
    }
    
    // Update a member's info (either my profile or member profile)
    public func updateMember(_ updatedMember: Member) {
        if let index = members.firstIndex(where: { $0.id == updatedMember.id }) {
            members[index] = updatedMember
            saveData()
        }
    }
    
    // Delete a member
    public func deleteMember(_ member: Member) {
        members.removeAll { $0.id == member.id }
        memberPositions.removeValue(forKey: member.id)
        saveData()
    }
    
    // When dragging a member card on the plot, the position info will be updated
    public func updatePosition(for member: Member, to position: CGPoint) {
        memberPositions[member.id] = position
        savePositions()
    }
    
    public func setUserProfile(_ member: Member) {
        userProfile = member
        saveData()
    }
    // Remove connections from the member being hidden
    public func removeConnectionsForMember(_ memberId: UUID) {
        if var member = members.first(where: { $0.id == memberId }) {
            member.connections.removeAll()
            updateMember(member)
        }
        
        // Remove connections to this member from other members
        for var otherMember in members {
            if otherMember.connections.contains(memberId) {
                otherMember.removeConnection(memberId)
                updateMember(otherMember)
            }
        }
        
        // Update member profile connections when members are connected
        if var profile = userProfile {
            if profile.connections.contains(memberId) {
                profile.removeConnection(memberId)
                setUserProfile(profile)
            }
        }
        
        saveData()
    }
    
    // Load the data
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: membersKey) {
            if let decoded = try? JSONDecoder().decode([Member].self, from: data) {
                members = decoded
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: positionsKey) {
            if let decoded = try? JSONDecoder().decode([UUID: CGPoint].self, from: data) {
                memberPositions = decoded
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: userProfileKey) {
            if let decoded = try? JSONDecoder().decode(Member.self, from: data) {
                userProfile = decoded
            }
        }
    }
    
    // Sava the data
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(encoded, forKey: membersKey)
        }
        if let profile = userProfile, let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
        savePositions()
    }
    
    // Save members' positions on the plots
    private func savePositions() {
        if let encoded = try? JSONEncoder().encode(memberPositions) {
            UserDefaults.standard.set(encoded, forKey: positionsKey)
        }
    }
}
