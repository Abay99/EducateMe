//
//  AppConfiguration.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

/*
 Open your Project Build Settings and search for “Swift Compiler – Custom Flags” … “Other Swift Flags”.
 Add “-DDEVELOPMENT” to the Debug section
 Add “-DQA” to the QA section
 Add “-DSTAGING” to the Staging section
 Add “-DPRODUCTION” to the Release section
 */
enum Environment: String {
    case development
    case qa
    case staging
    case production

    /**
     Returns application selected build configuration/environment

     - returns: An application selected build configuration/environment. Default is Development.
     */
    static func currentEnvironment() -> Environment {

        #if QA
            return Environment.qa
        #elseif STAGING
            return Environment.staging
        #elseif PRODUCTION
            return Environment.production
        #else // Default configuration - DEVELOPMENT
            return Environment.development
        #endif

        /* let environment = Bundle.main.infoDictionary?["ActiveConfiguration"] as? String
         return environment */
    }
}

final class AppConfiguration {
    /**
     * Application Configuration
     */
    struct Configuration {
        var environment: Environment
        var apiEndPoint: String
        var analyticsKey: String
        var analyticsTrackingEnabled: Bool

        fileprivate static func debugConfiguration() -> Configuration {
            // localIP - https://10.1.167.169/steve-php/public/api/
            return Configuration(environment: .development,
                                 apiEndPoint: "https://dev.stevefindsjobs.com/steve-php/public/api/",
                                 analyticsKey: "",
                                 analyticsTrackingEnabled: false)
        }

        fileprivate static func qaConfiguration() -> Configuration {
            return Configuration(environment: .qa,
                                 apiEndPoint: "https://qa.stevefindsjobs.com/steve-php/public/api/",
                                 analyticsKey: "",
                                 analyticsTrackingEnabled: false)
        }

        fileprivate static func stagingConfiguration() -> Configuration {
            return Configuration(environment: .staging,
                                 apiEndPoint: "https://staging.stevefindsjobs.com/steve-php/public/api/",
                                 analyticsKey: "",
                                 analyticsTrackingEnabled: true)
        }

        fileprivate static func productionConfiguration() -> Configuration {
            return Configuration(environment: .production,
                                 apiEndPoint: "https://www.stevefindsjobs.com/api/",
                                 analyticsKey: "",
                                 analyticsTrackingEnabled: true)
        }
    }

    // MARK: - Singleton Instance
    class var shared: AppConfiguration {
        struct Singleton {
            static let instance = AppConfiguration()
        }
        return Singleton.instance
    }

    public private(set) var activeConfiguration: Configuration!

    private init() {
        // Load application selected environment and its configuration
        activeConfiguration = configurationForEnvironment(Environment.currentEnvironment())
    }

    /**
     Returns application active configuration

     - parameter environment: An application selected environment

     - returns: An application configuration structure based on selected environment
     */
    private func configurationForEnvironment(_ environment: Environment) -> Configuration {

        switch environment {
        case .development:
            return Configuration.debugConfiguration()
        case .qa:
            return Configuration.qaConfiguration()
        case .staging:
            return Configuration.stagingConfiguration()
        case .production:
            return Configuration.productionConfiguration()
        }
    }
}
