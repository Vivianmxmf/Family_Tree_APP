import SwiftUI

// Put the box in the center of the story page
// Put the motivations of this project
struct StoryView: View {
    private let cardWidth: CGFloat = 600
    private let cardHeight: CGFloat = 700
    private let sideSpace: CGFloat = 300
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer(minLength: geo.size.width / 2 - sideSpace)
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .shadow(color: Color.green.opacity(0.2), radius: 15)
                            
                            VStack(spacing: 25) {
                                Text("Preface")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                    .padding(.top, 30)
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("🍃When I was a child, I wanted to build my own family tree. But coming from a small family—being the only child of busy parents—I often felt my tree looked emptier than others.")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .lineSpacing(8)
                                        .foregroundColor(.black)
                                    
                                    Text("🌳Spending much of my time alone, I longed for a deeper connection with my family when I was a naive kid. That's what inspired me to create a family tree that is about strengthening bonds (including pets). I designed it to be child-friendly, making it easy for kids to build their family trees together with their parents. For families with many relatives, it helps children recognize and understand their family members and relationships.")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .lineSpacing(8)
                                        .foregroundColor(.black)
                                    
                                    Text("❤️More than just a tool, I hope this project brings families closer, turning a simple tree into something full of love, connection, and shared memories.")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .lineSpacing(8)
                                        .foregroundColor(.black)
                                    
                                    Text("Now, please click on \"MyProfile\" button on the menu to start building your family tree!")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .lineSpacing(8)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 40)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 40)
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        Spacer(minLength: geo.size.width / 2 - sideSpace)
                    }
                    .frame(minWidth: geo.size.width)
                }
            }
        }
    }
}

