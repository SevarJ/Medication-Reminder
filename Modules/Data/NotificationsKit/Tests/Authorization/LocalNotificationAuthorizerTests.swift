//
//  LocalNotificationAuthorizerTests.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import DomainTesting
import Testing
import UserNotifications
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
    
    @Test func mapsSystemStatusToAccess() async throws {
        let cases: [(UNAuthorizationStatus, NotificationAccess)] = [
            (.notDetermined, .notDetermined),
            (.denied, .denied),
            (.authorized, .authorized),
            (.provisional, .authorized)
        ]
        
        for (status, expected) in cases {
            let sut = LocalNotificationAuthorizer(center: MockUserNotificationCenter(status: status))
            
            #expect(await sut.access() == expected)
        }
    }
}
