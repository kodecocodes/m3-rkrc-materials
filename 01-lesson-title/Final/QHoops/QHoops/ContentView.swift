//
//  ContentView.swift
//  QHoops
//
//  Created by Tim Mitra on 2023-12-20.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
  @State private var showImmersiveSpace = false
  @State private var immersiveSpaceIsShown = false
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  
  var body: some View {
    VStack {
      VStack (spacing: 12) {
        Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
          .font(.title)
      }
      .frame(width: 360)
      .padding(36)
      .glassBackgroundEffect()
    }
    .onChange(of: showImmersiveSpace) { _, newValue in
      Task {
        if newValue {
          switch await openImmersiveSpace(id: "ImmersiveSpace") {
          case .opened:
            immersiveSpaceIsShown = true
          case .error, .userCancelled:
            fallthrough
          @unknown default:
            immersiveSpaceIsShown = false
            showImmersiveSpace = false
          }
        } else if immersiveSpaceIsShown {
          await dismissImmersiveSpace()
          immersiveSpaceIsShown = false
        }
      }
    }
  }
}

#Preview(windowStyle: .volumetric) {
  ContentView()
}
