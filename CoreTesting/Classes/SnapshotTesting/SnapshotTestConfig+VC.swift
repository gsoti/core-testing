import SnapshotTesting


// Configuration matrix
//
//          device      theme   font
// -----------------------------------
// large:   iPhoneX     dark    large
// small:   iPhoneSE    light   XXXLarge

public extension ViewImageConfig {
    static let small: ViewImageConfig = {
        var config: ViewImageConfig = .iPhoneSe
        config.traits = UITraitCollection(traitsFrom: [
            config.traits,
            .init(userInterfaceStyle: .dark),
            .init(preferredContentSizeCategory: .extraExtraExtraLarge),
        ])
        return config
    }()
    
    static let large: ViewImageConfig = {
        var config: ViewImageConfig = .iPhoneX
        config.traits = UITraitCollection(traitsFrom: [
            config.traits,
            .init(userInterfaceStyle: .light),
            .init(preferredContentSizeCategory: .large)
        ])
        return config
    }()
}


public extension SnapshotTestConfig {
    // config generation for view controllers
    enum VC {}
}


extension SnapshotTestConfig.VC {
    /**
     Used to test how a VC looks like in the **small ** configuration.
     
     ~~~
     SnapshotTestConfig.VC.small { config in
         assertImageSnapshot(matching: vc, config: config)
     }
     ~~~

    - Parameter testing: The closure that returns the configurations to be tested.
    */
    public static func small(testing: (ViewImageConfig) -> Void) {
        combos(configs: .small, testing: testing)
    }
    
    /**
     Used to test how a VC looks like in the **large ** configuration.
     
     ~~~
     SnapshotTestConfig.VC.large { config in
         assertImageSnapshot(matching: vc, config: config)
     }
     ~~~

    - Parameter testing: The closure that returns the configurations to be tested.
    */
    public static func large(testing: (ViewImageConfig) -> Void) {
        combos(configs: .large, testing: testing)
    }
    
    /**
     Used to test how a VC looks like in **small and large ** configurations.
     Every VC should include at least one such test. (The closure will be executed twice)
     
     ~~~
     SnapshotTestConfig.VC.all { config in
         assertImageSnapshot(matching: vc, config: config)
     }
     ~~~

    - Parameter testing: The closure that returns the configurations to be tested.
    */
    public static func all(testing: (ViewImageConfig) -> Void) {
        combos(configs: .small, .large, testing: testing)
    }
    
    /**
     Used to test how a VC looks like in the provided configurations.

    - Parameter testing: The closure that returns the configurations to be tested.
     */
    public static func combos(configs: ViewImageConfig..., testing: (ViewImageConfig) -> Void) {
        configs.forEach { config in
            testing(config)
        }
    }
}

