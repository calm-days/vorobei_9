//
//  ContentView.swift
//  vorobei_9
//
//  Created by Raman Liukevich on 23/12/2024.
//

import SwiftUI

struct ContentView: View {
    var initialLocation: CGPoint = CGPoint(x: 200, y: 350)
    @State private var location: CGPoint = CGPoint(x: 200, y: 350)

    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil

    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation

            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }
            .onEnded { _ in
                withAnimation(.bouncy) {
                    location = initialLocation
                }
            }
    }

    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }

    var body: some View {
        ZStack {
            Color.final
            Circle().fill(.base).frame(width: 210).blur(radius: 12).position(initialLocation)

            ZStack {
                Color.black

                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.5, color: .base))
                    context.addFilter(.blur(radius: 15))

                    context.drawLayer { ctx in
                        for index in [1,2] {
                            if let resolvedView = context.resolveSymbol(id: index){
                                ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                        }
                    }
                } symbols: {
                    Ball(frame: 140, color: .black)
                        .tag(2)
                        .position(location)

                    Ball(frame: 140, color: .black)
                        .tag(1)
                        .position(initialLocation)
                }

                Ball(frame: 138, color: .black)
                    .position(initialLocation)
                    .blendMode(.destinationOut)

                Ball(frame: 138, color: .black)
                    .position(location)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()

            Image(systemName: "cloud.sun.rain.fill")
                .symbolRenderingMode(.palette)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .position(location)
                .gesture(simpleDrag.simultaneously(with: fingerDrag))
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    func Ball(frame: CGFloat, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: frame)
        }
    }
}

#Preview {
    ContentView()
}



