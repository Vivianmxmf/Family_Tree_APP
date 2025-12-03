
import Foundation
import SwiftUI
import CoreGraphics

//member-related data including basic information (ID, name, age, emoji), relationship types, and connection tracking (for the rank on edit tree page)
public struct Member: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var age: Int
    public var emoji: String
    public var relationship: String
    public var connections: [UUID]
    public var connectionCounts: [UUID: Int]
    public init(id: UUID = UUID(), name: String, age: Int, emoji: String, relationship: String, connections: [UUID] = []) {
        self.id = id
        self.name = name
        self.age = age
        self.emoji = emoji
        self.relationship = relationship
        self.connections = connections
        self.connectionCounts = [:]
        
        for connection in connections {
            self.connectionCounts[connection] = 1
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, age, emoji, relationship, connections, connectionCounts
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        emoji = try container.decode(String.self, forKey: .emoji)
        relationship = try container.decode(String.self, forKey: .relationship)
        connections = try container.decode([UUID].self, forKey: .connections)
        
        if let counts = try? container.decode([UUID: Int].self, forKey: .connectionCounts) {
            connectionCounts = counts
        } else {
            connectionCounts = [:]
            for connection in connections {
                connectionCounts[connection] = 1
            }
        }
    }
    
    //The following is connection functionalities for handling relationships between members, including adding, removing, and counting connections.
    mutating func addConnection(_ memberId: UUID) {
        if !connections.contains(memberId) {
            connections.append(memberId)
            connectionCounts[memberId] = 1
        } else if let count = connectionCounts[memberId], count < 5 {
            connectionCounts[memberId] = count + 1
        }
    }
    
    mutating func removeConnection(_ memberId: UUID) {
        if let count = connectionCounts[memberId] {
            if count > 1 {
                connectionCounts[memberId] = count - 1
            } else {
                connections.removeAll { $0 == memberId }
                connectionCounts.removeValue(forKey: memberId)
            }
        }
    }
    
    mutating func removeAllConnections(_ memberId: UUID) {
        connections.removeAll { $0 == memberId }
        connectionCounts.removeValue(forKey: memberId)
    }
    
    func getConnectionCount(_ memberId: UUID) -> Int {
        return connectionCounts[memberId] ?? 0
    }
    
    func getTotalConnections() -> Int {
        return connectionCounts.values.reduce(0, +)
    }
}
