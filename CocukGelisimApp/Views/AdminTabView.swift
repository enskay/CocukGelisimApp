//
//  AdminTabView.swift
//  CocukGelisimApp
//
//  Created by Ekrem on 18.04.2025.
//


import SwiftUI

struct AdminTabView: View {
    var body: some View {
        TabView {
            AdminMainView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house")
                }

            AdminTaleplerView()
                .tabItem {
                    Label("Talepler", systemImage: "tray.and.arrow.down")
                }
        }
    }
}