//
//  CounterModel.swift
//  Immersive Ball Shooter
//
//  Created by Henry Lam on 29/2/2024.
//
import Foundation

class CounterModel: ObservableObject {
    @Published var ballCounter = 0
    @Published var ballMax = 50
}
