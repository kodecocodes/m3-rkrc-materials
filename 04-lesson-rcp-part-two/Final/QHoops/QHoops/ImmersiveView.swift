/// Copyright (c) 2023 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
  @State private var goalEntity: Entity?
  @State private var goalScored: EventSubscription?
  @State private var goalCelebration: Bool = false
  @State private var confetti: Entity?
  
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(scene)
              
              /* Occluded floor */
              let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
              floor.generateCollisionShapes(recursive: false)
              floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
              )
              content.add(floor)
            }
          
          // detect a goal
          goalEntity = content.entities.first?.findEntity(named: "Goal")
          goalEntity?.components.set(OpacityComponent(opacity: 0.0))
          goalScored = content.subscribe(to: CollisionEvents.Began.self, on: goalEntity) { collisionEvent in
              print("Goal detected \(collisionEvent.entityA.name) and \(collisionEvent.entityB.name)")
              goalCelebration = true
          }
          confetti = content.entities.first?.findEntity(named: "ConfettiEmitter")
          confetti?.components.set(OpacityComponent(opacity: 0.0))
        } update: { content in
          if let _ = content.entities.first {
            if goalCelebration == true {
              confetti?.components.set(OpacityComponent(opacity: 1.0))
            }
          }
        }
        .gesture(dragGesture)
        .gesture(tapGesture)
    }
  var dragGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged { value in
        value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
        value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
      }
  }
  var tapGesture: some Gesture {
    TapGesture()
      .targetedToAnyEntity()
      .onEnded { value in
        // do nothing
        value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
        value.entity.components[PhysicsMotionComponent.self]?.linearVelocity = [0, 7,-5]
      }
  }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
