//
//  CSMA_CD_ProjectApp.swift
//  CSMA-CD-Project
//
//  Created by Gustavo Igor Goncalves Travassos on 19/06/23.
//

import SwiftUI

@main
struct CSMA_CD_ProjectApp: App {
    @State private var window: NSWindow?
    var body: some Scene {
        WindowGroup {
            Program()
                .frame(minWidth: 250, idealWidth: 250, maxWidth: 250,
                       minHeight: 200, idealHeight: 200, maxHeight: 200)
                .background(WindowAccessor(window: $window))
                .onChange(of: window) { newWindow in
                    newWindow?.contentAspectRatio = CGSize(width: 16, height: 9)
                }
        }
        .commands {
            SidebarCommands()
        }
        .windowResizability(.contentSize)
    }
}

struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
