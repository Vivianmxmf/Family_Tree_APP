// The basic component stuctures including member card, member info, and connections lines on plots

import SwiftUI
import AppKit

// The green connection lines
struct ConnectionLine: View {
    let start: CGPoint
    let end: CGPoint
    let isSelected: Bool
    
    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(isSelected ? Color.red : Color.green, lineWidth: isSelected ? 3 : 2)
    }
}

// The styling for member cards on the plot
private extension View {
    func memberNodeStyle(isSelected: Bool = false) -> some View {
        self.padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: isSelected ? 5 : 2)
    }
}

// The member card on the plot (either on My tree page or edit tree page)
struct EditableNode: View {
    let member: Member
    let position: CGPoint
    let onDrag: (CGPoint) -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            Text(member.emoji)
                .font(.system(size: 35))
            Text(member.name)
                .font(.caption)
                .foregroundColor(.black)
        }
        .memberNodeStyle()
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in onDrag(value.location) }
        )
    }
}

// The info for each member
struct MemberNode: View {
    let member: Member
    let position: CGPoint
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text(member.emoji)
                .font(.system(size: 35))
            Text(member.name)
                .font(.caption)
                .foregroundColor(.black)
        }
        .memberNodeStyle(isSelected: isSelected)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .position(position)
    }
}

// The floating light button for giving users tips
struct TipButton: View {
    @Binding var showTip: Bool
    @State private var dragOffset = CGSize.zero
    @State private var lastDragPosition: CGSize = .zero
    
    var body: some View {
        Button(action: {
            // Random animation because why not?
            if Bool.random() {
                withAnimation(.spring()) { showTip.toggle() }
            } else {
                showTip.toggle()
            }
        }) {
            Text("💡")
                .font(.system(size: 22))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.green.opacity(0.3), radius: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: dragOffset.width + lastDragPosition.width, 
                y: dragOffset.height + lastDragPosition.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        lastDragPosition.width += value.translation.width
                        lastDragPosition.height += value.translation.height
                        dragOffset = .zero
                    }
                }
        )
    }
}

// Help box that pops up when users clicks on the light button on the interface
struct TipBoxView: View {
    @Binding var isShowing: Bool
    let tipText: String
    var body: some View {
        ZStack {
            if isShowing {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: Color.green.opacity(0.2), radius: 15)
                    .overlay(
                        VStack(spacing: 20) {
                            HStack {
                                Text("Tips for You! ✨")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.green)
                                Spacer()
                                Button(action: { isShowing = false }) {
                                    Text("✕")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                        .padding(8)
                                }
                            }
                            
                            Text(tipText)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(8)
                            
                            Spacer()
                        }
                        .padding(25)
                    )
                    .frame(width: 350, height: 550)
                    .transition(.opacity)
            }
        }
        .frame(width: 350, height: 550)
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
}

// Help text for different pages
struct TipTexts {
    static let myTree = """
    🌳 Hey there, tree explorer!
    
    Here's what you can do:
    - Check out your family list
    - Switch to tree view to see connections
    - Hide folks you don't want to see right now
    - Drag people around to explore relationships
    
    Go wild with your family tree! 🌟
    """
    
    static let myProfile = """
    🌟 Make it yours!
    
    Quick setup:
    - Pick an emoji that feels like "you"
    - Add your name (nicknames work too!)
    - Pop in your age
    - Hit save when you're done
    
    This is your spot in the family tree! 🎉
    """
    
    static let addMember = """
    👥 Growing the family tree!
    
    Quick steps:
    - Grab a fun emoji for them
    - Type in their name
    - Add their age
    - Pick how they fit in your family
    
    Hit 'Add' and watch your tree grow! 🌱
    """
    
    static let editMember = """
    ✏️ Time for some tweaks!
    
    You can:
    - Tap anyone to edit their info
    - Switch up their emoji if you want
    - Update their details
    - Remove them if needed (oops!)
    - Save your changes!
    
    Keep your tree up to date! 🎨
    """
    
    static let editTree = """
    🛠️ Time to arrange your tree!
    
    Quick tips:
    - Drag folks wherever you want
    - Click two people to connect them
    - Double-click lines to undo connections
    - Try dragging from the list to the tree!
    
    Don't worry if you mess up - you can always fix it! 😅
    """
} 
