//
//  AppDelegate.swift
//  Monasba
//
//  Created by Amal Elgalant on 12/04/2023.
//

import UIKit
import MOLH

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var currentUser = User()

    static var defaults:UserDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UIApplication.shared.statusBarView?.backgroundColor = UIColor(named: "#0EBFB1")
        MOLH.setLanguageTo( "en")

        getCounties()
        getCities()
        return true
    }
    
    func getCounties(){
        CountryController.shared.getCountries(completion: {
            countries, check,msg in
            Constants.COUNTRIES = countries
        })
    }
    func getCities(){
        CountryController.shared.getCities(completion: {
            countries, check,msg in
            Constants.CITIES = countries
        }, countryId: 6)
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

