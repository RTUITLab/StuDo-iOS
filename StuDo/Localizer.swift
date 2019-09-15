//
//  Localizer.swift
//  StuDo
//
//  Created by Andrew on 8/23/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

enum LozalizerString: String {
    
    case done
    case save
    case back
    case okay
    case cancel
    case delete
    case edit
    case create
    case search
    
    case redThemeName
    case orangeThemeName
    case yellowThemeName
    case greenThemeName
    case tealBlueThemeName
    case blueThemeName
    case purpleThemeName
    case pinkThemeName
    
    case feedTitleMyAds
    case feedTitleAllAds
    case feedNoAdsTitle
    case feedNoAdsDescription
    case feedNoOwnAdsDescription
    case feedNoOrganizationAdsDescription
    case feedPublishedBy
    case feedViewUser
    case feedViewOrganization
    case feedCreatorPage
    
    case navigationMenuAllAds
    case navigationMenuMyAds
    case navigationMenuOrganizationAds
    case navigationMenuBookmarks
    
    case accountTitle
    case accountMyProfiles
    case accountAddNewProfile
    case accountProfileSectionDescription
    case accountOrganizations
    case accountOrganizationsSectionDescription
    case accountSettings
    case accountAbout
    
    case settingsTitle
    case settingsLanguage
    case settingsAccentColor
    
    case aboutTitle
    case aboutVersion
    case aboutFeedback
    case aboutRate
    case aboutRTULab
    
    case accountDetailFirstName
    case accountDetailLastName
    case accountDetailNameSectionDescription
    case accountDetailStudentID
    case accountDetailEmail
    case accountDetailPassword
    case accountDetailLogout
    case accountDetailChangeAlertMessage
    case accountDetailChangeAlertCancel
    
    case emailChangeSectionHeader
    case emailChangeSectionDescription
    case emailChangeAlertMessage
    
    case passwordCurrentSectionHeader
    case passwordEnterCurrent
    case passwordNewSectionHeader
    case passwordEnterNew
    case passwordRepeatNew
    case passwordNewSectionDescription
    case passwordChangeAlertTitle
    case passwordChangeAlertMessage
    
    case profileNameSectionHeader
    case profileNamePlaceholder
    case profileNameSectionFooter
    case profileDescriptionSectionHeader
    case profileDescriptionSectionFooter
    
    case authEmail
    case authPassword
    case authRepeatPassword
    case authForgotPassword
    case authName
    case authSurname
    case authSignIn
    case authSignUp
    case authRegistrationAlertTitle
    case authRegistrationAlertMessage
    case authPasswordRestorationAlertMessage
    
    case adEditorFindPeople
    case adEditorEditAd
    case adEditorDeleteAd
    case adEditorDeleteAlertMessage
    case adEditorCancelCreatingAlertMessage
    case adEditorCancelEditingAlertMessage
    case adEditorDiscardChanges
    case adEditorCancelAdCreation
    case adEditorReturnToEditor
    case adEditorEditingModeTitle
    case adEditorCreationModeTitle
    case adEditorNamePlaceholder
    case adEditorDescriptionPlaceholder
    case adEditorBeginDateLabel
    case adEditorEndDateLabel
    case adEditorDurationLabel
    case adEditorPublishAdAlertMessage
    
    case organizationTitleAllOrganizations
    case organizationTitleMyOrganizations
    case organizationListTitle
    case organizationInfoHeaderTitle
    case organizationNamePlaceholder
    case organizationDescriptionPlaceholder
    case organizationMembersHeaderTitle
    case organizationAdmin
    case organizationJoin
    case organizationLeave
    case organizationDeletionAlertMessage
    
    case userPublicProfilesSectionHeader
    case userPublicAdsSectionHeader
    
    case notificationSetReminder
    case notificationReminderAlertTitle
    case notificationRemindBefore15m
    case notificationRemindBefore1h
    case notificationEventReminderMessageBefore15m
    case notificationEventReminderMessageBefore1h
    case notificationsDisabledAlertTitle
    case notificationsDisabledSettings
}

class Localizer: NSObject {
    
    static func getLocale(for language: StuDoAvailableLanguage) -> Locale {
        if language == .Russian {
            return Locale(identifier: "ru")
        }
        return Locale(identifier: "en")
    }
    
    static var currentLocale: Locale {
        let currentLanguage = PersistentStore.shared.currentLanguage
        return getLocale(for: currentLanguage)
    }
    
    private static func getLocalizedStrings(for: StuDoAvailableLanguage) -> [String: String] {
        
        var languageName = "English"
        switch PersistentStore.shared.currentLanguage {
        case .Russian:
            languageName = "Russian"
        default:
            break
        }
        
        // TODO: will saving the plist in memory increase the performance?
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "\(languageName)Strings", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
        
        return nsDictionary as! [String: String]
    }
    
    
    static func string(for text: LozalizerString) -> String {
        let plist = getLocalizedStrings(for: PersistentStore.shared.currentLanguage)
        let keyString = text.rawValue
        return plist[keyString]!
    }
    
}
