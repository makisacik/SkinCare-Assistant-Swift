//
//  UserProfileStore.swift
//  ManCare
//
//  Created by AI Assistant on 6.10.2025.
//

import Foundation
import Combine

final class UserProfileStore: ObservableObject {
    static let shared = UserProfileStore()

    @Published private(set) var currentProfile: UserProfile?

    private let storageKey = "user_profile_json"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        self.currentProfile = load()
    }

    func setProfile(_ profile: UserProfile) {
        currentProfile = profile
        save(profile)
    }

    func clearProfile() {
        currentProfile = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            print("❌ Failed to decode UserProfile: \(error)")
            return nil
        }
    }

    private func save(_ profile: UserProfile) {
        do {
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ Failed to encode UserProfile: \(error)")
        }
    }
}

// MARK: - Draft model for editing with validation

struct UserProfileDraft {
    var skinType: SkinType?
    var concerns: Set<Concern>
    var mainGoal: MainGoal?
    var fitzpatrickSkinTone: FitzpatrickSkinTone?
    var ageRange: AgeRange?
    var region: Region?
    var preferences: Preferences?

    init(from profile: UserProfile?) {
        self.skinType = profile?.skinType
        self.concerns = profile?.concerns ?? []
        self.mainGoal = profile?.mainGoal
        self.fitzpatrickSkinTone = profile?.fitzpatrickSkinTone
        self.ageRange = profile?.ageRange
        self.region = profile?.region
        self.preferences = profile?.preferences
    }

    init() {
        self.skinType = nil
        self.concerns = []
        self.mainGoal = nil
        self.fitzpatrickSkinTone = nil
        self.ageRange = nil
        self.region = nil
        self.preferences = nil
    }

    var isValid: Bool {
        return skinType != nil &&
               mainGoal != nil &&
               fitzpatrickSkinTone != nil &&
               ageRange != nil &&
               region != nil
        // Concerns optionality mirrors RoutineCreatorFlow (can be empty)
    }

    func toProfile() -> UserProfile? {
        guard let skinType,
              let mainGoal,
              let fitzpatrickSkinTone,
              let ageRange,
              let region else { return nil }
        return UserProfile(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            preferences: preferences,
            lifestyle: nil
        )
    }
}


