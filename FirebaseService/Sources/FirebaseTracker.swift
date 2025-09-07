//
//  FirebaseTracker.swift
//
//
//  Created by Yi-Chin Hsu on 2025/9/6.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct FirebaseTracker {
  public var configure: () -> Void
  public var logEvent: (_ event: FirebaseEvent) -> Void
}

extension FirebaseTracker: TestDependencyKey {
  public static var testValue = Self()
}

public extension DependencyValues {
  var firebaseTracker: FirebaseTracker {
    get { self[FirebaseTracker.self] }
    set { self[FirebaseTracker.self] = newValue }
  }
}

public enum FirebaseEvent: Equatable {
  case viewModeListPg(parameters: [String: Any])
  case viewClassicCheckInPg(parameters: [String: Any])
  case viewInfoIntroPg(parameters: [String: Any])
  case viewSettingsPg(parameters: [String: Any])
  case clickClassicCheckInPgPickBtn(parameters: [String: Any])
  case clickClassicCheckInPgPreviousBtn(parameters: [String: Any])
  case clickClassicCheckInPgUrlBtn(parameters: [String: Any])
  case clickClassicCheckInPgWelcomeMessageDoneBtn(parameters: [String: Any])
  case clickInfoIntroPgDoneBtn(parameters: [String: Any])
  case clickModeListPgThemeBoxCard(parameters: [String: Any])
  case clickModeListPgCheckInCard(parameters: [String: Any])
  case clickSettingsPgShareBtn(parameters: [String: Any])
  case clickSettingsPgFeedbackFormBtn(parameters: [String: Any])
  case clickSettingsPgAuthorProfileBtn(parameters: [String: Any])
  case clickSettingsPgSubmitQuestionsBtn(parameters: [String: Any])
  case clickSettingsPgSubmitAppReviewBtn(parameters: [String: Any])

  public var name: String {
    switch self {
    case .viewModeListPg:
      "View_ModeListPg"
    case .viewClassicCheckInPg:
      "View_CheckInPg"
    case .viewInfoIntroPg:
      "View_InfoIntroPg"
    case .viewSettingsPg:
      "View_SettingPg"
    case .clickClassicCheckInPgPickBtn:
      "Click_ClassicCheckInPg_PickBtn"
    case .clickClassicCheckInPgPreviousBtn:
      "Click_ClassicCheckInPg_PreviousBtn"
    case .clickClassicCheckInPgUrlBtn:
      "Click_ClassicCheckInPg_UrlBtn"
    case .clickClassicCheckInPgWelcomeMessageDoneBtn:
      "Click_ClassicCheckInPg_WelcomeMessageDoneBtn"
    case .clickInfoIntroPgDoneBtn:
      "Click_InfoIntroPg_DoneBtn"
    case .clickModeListPgThemeBoxCard:
      "Click_ModeListPg_ThemeBoxCard"
    case .clickModeListPgCheckInCard:
      "Click_ModeListPg_CheckInCard"
    case .clickSettingsPgShareBtn:
      "Click_SettingsPg_ShareBtn"
    case .clickSettingsPgFeedbackFormBtn:
      "Click_SettingsPg_FeedbackFormBtn"
    case .clickSettingsPgAuthorProfileBtn:
      "Click_SettingsPg_AuthorProfileBtn"
    case .clickSettingsPgSubmitQuestionsBtn:
      "Click_SettingsPg_SubmitQuestionsBtn"
    case .clickSettingsPgSubmitAppReviewBtn:
      "Click_SettingsPg_SubmitAppReviewBtn"
    }
  }

  public var parameters: [String: Any] {
    switch self {
    case let .viewModeListPg(parameters: parameters),
         let .viewClassicCheckInPg(parameters: parameters),
         let .viewInfoIntroPg(parameters: parameters),
         let .viewSettingsPg(parameters: parameters),
         let .clickClassicCheckInPgPickBtn(parameters: parameters),
         let .clickClassicCheckInPgPreviousBtn(parameters: parameters),
         let .clickClassicCheckInPgUrlBtn(parameters: parameters),
         let .clickClassicCheckInPgWelcomeMessageDoneBtn(parameters: parameters),
         let .clickInfoIntroPgDoneBtn(parameters: parameters),
         let .clickModeListPgThemeBoxCard(parameters: parameters),
         let .clickModeListPgCheckInCard(parameters: parameters),
         let .clickSettingsPgShareBtn(parameters: parameters),
         let .clickSettingsPgFeedbackFormBtn(parameters: parameters),
         let .clickSettingsPgAuthorProfileBtn(parameters: parameters),
         let .clickSettingsPgSubmitQuestionsBtn(parameters: parameters),
         let .clickSettingsPgSubmitAppReviewBtn(parameters: parameters):
      return parameters
    }
  }

  public static func == (lhs: FirebaseEvent, rhs: FirebaseEvent) -> Bool {
    lhs.name == rhs.name && (lhs.parameters as NSDictionary) == (rhs.parameters as NSDictionary)
  }
}
