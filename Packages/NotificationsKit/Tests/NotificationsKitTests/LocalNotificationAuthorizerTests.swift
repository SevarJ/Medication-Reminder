//
//  LocalNotificationAuthorizerTests.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Testing
@testable import NotificationsKit

struct LocalNotificationAuthorizerTests {
    @Test func promptsWhenStatusNotDetermined() async throws {
        let center = MockUserNotificationCenter(status: .notDetermined)
        let sut = LocalNotificationAuthorizer(center: center)
        
        #expect(try await sut.requestAuthorization())
        #expect(await center.requestedOptions != nil)
    }
    
    @Test func doesNotPromptWhenAlreadyAuthorized() async throws {
        let center = MockUserNotificationCenter(status: .authorized)
        let sut = LocalNotificationAuthorizer(center: center)
        
        #expect(try await sut.requestAuthorization())
        #expect(await center.requestedOptions == nil)
    }
    
    @Test func returnsFalseWhenDenied() async throws {
        let center = MockUserNotificationCenter(status: .denied)
        let sut = LocalNotificationAuthorizer(center: center)
        
        #expect(try await sut.requestAuthorization() == false)
    }
}
