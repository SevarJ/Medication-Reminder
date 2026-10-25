//
//  PaywallViewModel.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import Observation

@MainActor
@Observable
final class PaywallViewModel {
    enum Notice: Equatable {
        case pending
        case nothingToRestore
        case failed
    }

    private(set) var isRestoring = false
    private(set) var isFinished = false
    var notice: Notice?

    private let entitlements: any EntitlementProviding
    private let analytics: any AnalyticsTracking

    init(entitlements: any EntitlementProviding, analytics: any AnalyticsTracking) {
        self.entitlements = entitlements
        self.analytics = analytics
    }

    func appear() async {
        await analytics.track(.paywallShown)
    }

    func finishPurchase(_ outcome: PurchaseOutcome) async {
        await analytics.track(.purchaseFinished(outcome))

        switch outcome {
        case .purchased:
            isFinished = true
        case .pending:
            notice = .pending
        case .cancelled:
            break
        case .failed:
            notice = .failed
        }
    }

    func restore() async {
        guard !isRestoring else { return }

        isRestoring = true
        defer { isRestoring = false }

        do {
            let entitlement = try await entitlements.restorePurchases()

            await analytics.track(.purchasesRestored(entitlement == .pro ? .restored : .nothingToRestore))

            if entitlement == .pro {
                isFinished = true
            }
            else {
                notice = .nothingToRestore
            }
        }
        catch {
            await analytics.track(.purchasesRestored(.failed))
            notice = .failed
        }
    }

    func close() {
        isFinished = true
    }
}
