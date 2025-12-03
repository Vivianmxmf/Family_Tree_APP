
import SwiftUI
import AppKit
import Foundation

// The navigation bar is called menu
struct MainMenuView: View {
    @ObservedObject var treeManager: TreeDataManager
    @State private var showMenu = false
    @State private var selectedTab: MenuTab?
    @State private var imageScale: CGFloat = 1.0
    @State private var showLandingPage = false
    @State private var layoutPositions: [UUID: CGPoint] = [:]
    @State private var hasUnsavedChanges: Bool = false
    
    // The main structure of menu page
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 70)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    .overlay(
                        ZStack {
                            HStack {
                                Spacer()
                                Text("Family Tree")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            HStack {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showMenu.toggle()
                                        imageScale = showMenu ? 0.8 : 1.0
                                    }
                                }) {
                                    Image(systemName: "tree")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        selectedTab = nil
                                        showLandingPage = true
                                        imageScale = 1.0
                                        showMenu = false
                                    }
                                }) {
                                    Image(systemName: "house")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    )
                // When users clicks on a button, the interface will lead them to the corresponding page
                ScrollView {
                    if let selectedTab = selectedTab {
                        switch selectedTab {
                        case .story:
                            StoryView()
                        case .myTree:
                            TreeView(treeManager: treeManager, layoutPositions: $layoutPositions)
                        case .myProfile:
                            ProfileSetupView(treeManager: treeManager, selectedTab: $selectedTab)
                        case .addMember:
                            AddMemberView(treeManager: treeManager, selectedTab: $selectedTab)
                        case .editMember:
                            EditMemberView(treeManager: treeManager, selectedTab: $selectedTab)
                        case .editTree:
                            CombinedTreeView(
                                treeManager: treeManager,
                                selectedTab: $selectedTab,
                                positions: $layoutPositions,
                                hasUnsavedChanges: $hasUnsavedChanges
                            )
                        }
                    } else {
                        if showLandingPage {
                            VStack {
                                Text("Welcome to Your Family Tree")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .padding()
                                    .foregroundColor(.green)
                                Text("Select an option from the menu (Top Left Tree Icon) to get started")
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .foregroundColor(.green)
                                Image("background")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 400)
                                    .scaleEffect(imageScale)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: imageScale)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack {
                                Text("Welcome to Your Family Tree")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .padding()
                                    .foregroundColor(.green)
                                Text("Select an option from the menu (Top Left Tree Icon) to get started")
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .foregroundColor(.green)
                                Image("background")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 400)
                                    .scaleEffect(imageScale)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: imageScale)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // The zooming in and out animation for the background picture
            if showMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showMenu = false
                            imageScale = 1.0
                        }
                    }
                HStack {
                    MenuView(selectedTab: $selectedTab, showMenu: $showMenu, showLandingPage: $showLandingPage, imageScale: $imageScale)
                        .frame(width: 300)
                        .background(Color.white)
                        .transition(.move(edge: .leading))
                    Spacer()
                }
            }
        }
    }
}

// Side Menu View on every pages
struct MenuView: View {
    @Binding var selectedTab: MenuTab?
    @Binding var showMenu: Bool
    @Binding var showLandingPage: Bool
    @Binding var imageScale: CGFloat
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Menu")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .padding(.top, 40)
            VStack(spacing: 15) {
                menuButton("Story", tab: .story, icon: "leaf.fill", color: .green)
                menuButton("My Tree", tab: .myTree, icon: "tree")
                menuButton("My Profile", tab: .myProfile, icon: "person.circle")
                menuButton("Add Member", tab: .addMember, icon: "person.badge.plus")
                menuButton("Edit Member", tab: .editMember, icon: "person.crop.circle.badge.checkmark")
                menuButton("Edit Tree", tab: .editTree, icon: "pencil")
            }
            .padding(.top, 30)
            Spacer()
        }
        .padding(.bottom, 30)
        .padding(.horizontal)
    }
    // The styling for each menu button and the layout of this menu
    private func menuButton(_ title: String, tab: MenuTab, icon: String, color: Color = .black) -> some View {
        Button(action: {
            showLandingPage = false
            selectedTab = tab
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showMenu = false
                imageScale = 1.0
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 30)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                Spacer()
            }
            .padding()
            .foregroundColor(.black)
            .background(selectedTab == tab ? Color.green.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(treeManager: TreeDataManager())
    }
}
