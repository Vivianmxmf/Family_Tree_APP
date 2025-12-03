import SwiftUI
import AppKit
import Foundation
import CoreGraphics

// On edit tree view, this file combines the memberlist and the right-side plot
struct CombinedTreeView: View {
    @ObservedObject var treeManager: TreeDataManager
    @Binding var selectedTab: MenuTab?
    @Binding var positions: [UUID: CGPoint]
    @Binding var hasUnsavedChanges: Bool
    @State private var selectedMember: UUID?
    @State private var showTip = false
    
    var allMembers: [Member] {
        var members = [Member]()
        if let profile = treeManager.userProfile {
            members.append(profile)
        }
        members.append(contentsOf: treeManager.members)
        return members
    }
    
    // The order of the left side member list is dynamic, depending on the number of the lines that attach to it and the age
    // More lines and bigger age will be placed topper
    var sortedMembers: [Member] {
        allMembers.sorted { m1, m2 in
            let count1 = m1.getTotalConnections()
            let count2 = m2.getTotalConnections()
            if count1 != count2 {
                return count1 > count2
            }
            return m1.age >= m2.age // Both metrics are equal, then randomly select one
        }
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Left side Member List: users can drag the member card from the member list to the right side plot
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Members")
                            .font(.title2)
                            .padding(.leading)
                        
                        ForEach(sortedMembers) { member in
                            MemberCard(
                                member: member,
                                treeManager: treeManager,
                                onTap: {},
                                onDelete: member.id == treeManager.userProfile?.id ? nil : {
                                    treeManager.deleteMember(member)
                                    hasUnsavedChanges = true
                                }
                            )
                            .onDrag {
                                hasUnsavedChanges = true
                                return NSItemProvider(object: member.id.uuidString as NSString)
                            }
                        }
                    }
                    .padding()
                }
                .frame(width: 300)
                .background(Color.white)
                
                Divider()
                
                // Tree Visualization: the lines with member cards
                ZStack {
                    FamilyTreeViewWithDrop(
                        treeManager: treeManager,
                        positions: $positions,
                        hasUnsavedChanges: $hasUnsavedChanges
                    )
                }
                .background(Color.white)
            }
            
            // the Tip Button is on the surface
            VStack {
                HStack {
                    Spacer()
                    TipButton(showTip: $showTip)
                        .padding(.top, 20)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
            
            // After clicking on the tip button, the content will show up
            VStack {
                HStack {
                    Spacer()
                    TipBoxView(isShowing: $showTip, tipText: TipTexts.editTree)
                        .padding(.top, 20)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
        }
        .background(Color.white)
    }
}

struct CombinedTreeView_Previews: PreviewProvider {
    @State static var selectedTab: MenuTab? = .editTree
    @State static var positions: [UUID: CGPoint] = [:]
    @State static var hasUnsavedChanges: Bool = false
    
    static var previews: some View {
        CombinedTreeView(
            treeManager: TreeDataManager(),
            selectedTab: $selectedTab,
            positions: $positions,
            hasUnsavedChanges: $hasUnsavedChanges
        )
    }
}
