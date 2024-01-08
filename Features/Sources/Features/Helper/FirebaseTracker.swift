//
//  FirebaseTracker.swift
//
//
//  Created by Yi-Chin Hsu on 2023/12/29.
//

import Dependencies
import FirebaseAnalytics

struct FirebaseTracker {
  var logEvent: (_ event: FirebaseEvent) -> Void
}

extension FirebaseTracker: DependencyKey {
  static var liveValue: FirebaseTracker = FirebaseTracker { event in
    Analytics.logEvent(event.name, parameters: event.parameters)
  }
}

extension FirebaseTracker: TestDependencyKey {
  static var testValue: FirebaseTracker = FirebaseTracker { _ in
    unimplemented("FirebaseTracker_logEvent")
  }
}

extension DependencyValues {
  var firebaseTracker: FirebaseTracker {
    get { self[FirebaseTracker.self] }
    set { self[FirebaseTracker.self] = newValue }
  }
}

enum FirebaseEvent: Equatable {
  case viewModeListPg(parameters: [String: Any])
  case viewClassicCheckInPg(parameters: [String: Any])
  case viewSettingsPg(parameters: [String: Any])
  case clickClassicCheckInPgPickBtn(parameters: [String: Any])
  case clickClassicCheckInPgPreviousBtn(parameters: [String: Any])
  case clickClassicCheckInPgUrlBtn(parameters: [String: Any])
  case clickClassicCheckInPgWelcomeMessageDoneBtn(parameters: [String: Any])
  case clickSettingsPgShareBtn(parameters: [String: Any])
  case clickSettingsPgGiftCardBtn(parameters: [String: Any])
  case clickSettingsPgFeedbackFormBtn(parameters: [String: Any])
  case clickSettingsPgAuthorProfileBtn(parameters: [String: Any])
  case clickSettingsPgSubmitQuestionsBtn(parameters: [String: Any])

  var name: String {
    switch self {
    case .viewModeListPg:
      "View_ModeListPg"
    case .viewClassicCheckInPg:
      "View_ClassicCheckInPg"
    case .viewSettingsPg:
      "View_SettingsPg"
    case .clickClassicCheckInPgPickBtn:
      "Click_ClassicCheckInPg_PickBtn"
    case .clickClassicCheckInPgPreviousBtn:
      "Click_ClassicCheckInPg_PreviousBtn"
    case .clickClassicCheckInPgUrlBtn:
      "Click_ClassicCheckInPg_UrlBtn"
    case .clickClassicCheckInPgWelcomeMessageDoneBtn:
      "Click_ClassicCheckInPg_WelcomeMessageDoneBtn"
    case .clickSettingsPgShareBtn:
      "Click_SettingsPg_ShareBtn"
    case .clickSettingsPgGiftCardBtn:
      "Click_SettingsPg_GiftCardBtn"
    case .clickSettingsPgFeedbackFormBtn:
      "Click_SettingsPg_FeedbackFormBtn"
    case .clickSettingsPgAuthorProfileBtn:
      "Click_SettingsPg_AuthorProfileBtn"
    case .clickSettingsPgSubmitQuestionsBtn:
      "Click_SettingsPg_SubmitQuestionsBtn"
    }
  }

  var parameters: [String: Any] {
    switch self {
    case let .viewModeListPg(parameters: parameters),
         let .viewClassicCheckInPg(parameters: parameters),
         let .viewSettingsPg(parameters: parameters),
         let .clickClassicCheckInPgPickBtn(parameters: parameters),
         let .clickClassicCheckInPgPreviousBtn(parameters: parameters),
         let .clickClassicCheckInPgUrlBtn(parameters: parameters),
         let .clickClassicCheckInPgWelcomeMessageDoneBtn(parameters: parameters),
         let .clickSettingsPgShareBtn(parameters: parameters),
         let .clickSettingsPgGiftCardBtn(parameters: parameters),
         let .clickSettingsPgFeedbackFormBtn(parameters: parameters),
         let .clickSettingsPgAuthorProfileBtn(parameters: parameters),
         let .clickSettingsPgSubmitQuestionsBtn(parameters: parameters):
      return parameters
    }
  }
  
  static func == (lhs: FirebaseEvent, rhs: FirebaseEvent) -> Bool {
    lhs.name == rhs.name && (lhs.parameters as NSDictionary) == (rhs.parameters as NSDictionary)
  }
}
