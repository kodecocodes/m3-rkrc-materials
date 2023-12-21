//
//  QHoopsApp.swift
//  QHoops
//
//  Created by Tim Mitra on 2023-12-20.
//

import SwiftUI

@main
struct QHoopsApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }.windowStyle(.volumetric)
    
    ImmersiveSpace(id: "ImmersiveSpace") {
      ImmersiveView()
    }
  }
}
