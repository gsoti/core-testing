import Foundation

// Configuration matrix
//
//          device      theme   font
// -----------------------------------
// large:   iPhoneX     dark    large
// small:   iPhoneSE    light   XXXLarge

public extension ImageSnapshotConfig {
    static let small: ImageSnapshotConfig = {
        return .iPhoneSe(
            userInterfaceStyle: .dark,
            preferredContentSizeCategory: .extraExtraExtraLarge
        )
    }()
    
    static let large: ImageSnapshotConfig = {
        return .iPhoneX(
            userInterfaceStyle: .light,
            preferredContentSizeCategory: .large
        )
    }()
}

public extension SnapshotTestConfig {
    // config generation for views
    enum View {}
}


extension SnapshotTestConfig.View {
    
    /**
     Used to test how the view looks like in the **small (fixed width, dynamic height) phone**
     
     Usually used when the view has already been tested how it looks like
     in another test using the **all** devices configurations
     
     ~~~
     SnapshotTestConfig.View.small { config in
         assertImageSnapshot(matching: aView, config: config)
     }
     ~~~

    - Parameter testing: The closure that returns the configuration to be tested.
    */
    public static func small(testing: (ImageSnapshotConfig) -> Void) {
        combos(configs: .small, testing: testing)
    }
    
    /**
     Used to test how the view looks like in the **large (fixed width, dynamic height) phone**
     
     Usually used when the view has already been tested how it looks like
     in another test using the **all** devices configurations
     
     ~~~
     SnapshotTestConfig.View.large { config in
         assertImageSnapshot(matching: aView, config: config)
     }
     ~~~

    - Parameter testing: The closure that returns the configuration to be tested.
    */
    public static func large(testing: (ImageSnapshotConfig) -> Void) {
        combos(configs: .large, testing: testing)
    }
    
    /**
     Used to test how the view looks like in **(fixed small and large width, dynamic height) phones**.
     Every view should include at least one such test.
     
     ~~~
     SnapshotTestConfig.View.all { config in
         assertImageSnapshot(matching: aView, config: config)
     }
     ~~~

    - Parameter testing: The closure that returns the configurations to be tested.
    */
    public static func all(testing: (ImageSnapshotConfig) -> Void) {
        combos(configs: .small, .large, testing: testing)
    }
    
    /**
     Used to test how the view looks like for dynamic width and height.

    - Parameter testing: The closure that returns the configurations to be tested.
     */
    public static func free(testing: (ImageSnapshotConfig) -> Void) {        
        let small = ImageSnapshotConfig.fixed(
            nil,
            userInterfaceStyle: ImageSnapshotConfig.small.viewImageConfig.traits.userInterfaceStyle,
            preferredContentSizeCategory: ImageSnapshotConfig.small.viewImageConfig.traits.preferredContentSizeCategory
        )
        let large = ImageSnapshotConfig.fixed(
            nil,
            userInterfaceStyle: ImageSnapshotConfig.large.viewImageConfig.traits.userInterfaceStyle,
            preferredContentSizeCategory: ImageSnapshotConfig.large.viewImageConfig.traits.preferredContentSizeCategory
        )
        combos(configs: small, large, testing: testing)
    }
    
    /**
     Used to test how the view looks like in the provided configurations.

    - Parameter testing: The closure that returns the configurations to be tested.
     */
    public static func combos(configs: ImageSnapshotConfig..., testing: (ImageSnapshotConfig) -> Void) {
        combos(configs: configs, testing: testing)
    }
    
    /**
     Used to test how the view looks like in the provided configurations.

    - Parameter testing: The closure that returns the configurations to be tested.
     */
    public static func combos(configs: [ImageSnapshotConfig], testing: (ImageSnapshotConfig) -> Void) {
        configs.forEach { config in
            testing(config)
        }
    }
}
