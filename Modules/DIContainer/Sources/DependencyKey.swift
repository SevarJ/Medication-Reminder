//
//  DependencyKey.swift
//  DIContainer
//
//  Created by Sevar Jafarli on 01.08.26.
//

public protocol DependencyKey {
    associatedtype Value: Sendable
    static var liveValue: Value { get }
}
