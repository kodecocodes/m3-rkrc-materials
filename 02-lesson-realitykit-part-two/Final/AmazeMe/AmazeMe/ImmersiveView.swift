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
  @State var mazeA = Entity()
  
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let _ = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                //content.add(scene)
              
              /* Occluded floor */
              let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
              floor.generateCollisionShapes(recursive: false)
              floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
              )
              content.add(floor)
              
              /* steel ball */
              let ball = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .white, isMetallic: true)])
              ball.position.y = 1.0 // 1 meter (m) above the floor
              ball.position.z = -1.5 // 1.5m in front of the user
              ball.position.x = 0.5 // 0.5m right of center
              ball.generateCollisionShapes(recursive: false)
              // Enable interactions on the entity.
              ball.components.set(InputTargetComponent())
              ball.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.05)]))
              // gravity to PhysicsBody
              ball.components[PhysicsBodyComponent.self] = .init(
                PhysicsBodyComponent(
                  // mass in kilograms
                  massProperties: .init(mass: 5.0),
                  material: .generate(
                    staticFriction: 0.0,
                    dynamicFriction: 0.0,
                    restitution: 0.5
                  ),
                  mode: .dynamic
                )
              )
              // editor - need to research this
              // ball.physicsMotion = PhysicsMotionComponent()
              // add gravity
              ball.components[PhysicsBodyComponent.self]?.isAffectedByGravity = true
              // editor - need to research this.
              //              let visDebug = ModelDebugOptionsComponent(visualizationMode: .textureCoordinates)
              //              ball.modelDebugOptions = visDebug
              content.add(ball)
              
              // maze piece
              // dimensions
              let mazeX: Float = 1.0
              let mazeY: Float = 0.1
              let mazeZ: Float = 0.1
              mazeA = ModelEntity(mesh: .generateBox(width: mazeX, height: mazeY, depth: mazeZ), materials: [SimpleMaterial()])
              
              mazeA.components.set(CollisionComponent(shapes: [.generateBox(width: mazeX, height: mazeY, depth: mazeZ)]))

              mazeA.components[PhysicsBodyComponent.self] = .init(
                PhysicsBodyComponent(
                  massProperties: .default,
                  material: .generate(
                    staticFriction: 0.8,
                    dynamicFriction: 0.0,
                    restitution: 0.0
                  ),
                  mode: .kinematic
                )
              )
              
              mazeA.position.y = 0.9
              mazeA.position.z = -1.5
              content.add(mazeA)
       
            }
        }
        .gesture(dragGesture)
    }
  var dragGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
        .onChanged { value in
          value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
          value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
        }
        .onEnded { value in
          value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
         }
  }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
