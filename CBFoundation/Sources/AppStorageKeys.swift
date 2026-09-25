//
//  AppStorageKeys.swift
//  CBFoundation
//
//  Created by Codex on 2026/8/9.
//

import Sharing

public enum AppStorageKeys {
  public static let infoIntroChecked = "info-intro-checked"
  public static let adminFullAccess = "admin_full_access"
}

public extension SharedKey where Self == AppStorageKey<Bool>.Default {
  static var infoIntroChecked: Self {
    Self[.appStorage(AppStorageKeys.infoIntroChecked), default: false]
  }

  static var adminFullAccess: Self {
    Self[.appStorage(AppStorageKeys.adminFullAccess), default: false]
  }
}
