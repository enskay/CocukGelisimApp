//
//  BackgroundImageView.swift
//  CocukGelisimApp
//
//  Created by Enes  on 24.05.2025.
//


import SwiftUI

struct BackgroundImageView: View {
    var body: some View {
        GeometryReader { geo in
            Image("backgroundImage")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(edges: .all) // TÜM SAFE AREA'YI İPTAL EDER!
        }
        .ignoresSafeArea(edges: .all)
    }
}