import SnapshotTesting
import UIKit

private func fittingSize(forView view: UIView, traits: UITraitCollection, width: CGFloat?, height: CGFloat?) -> CGSize {
    let viewController = UIViewController()
    viewController.view.addSubview(view)
    
    let rootViewController = UIViewController()
    rootViewController.addChild(viewController)
    viewController.view.frame = rootViewController.view.frame
    rootViewController.view.addSubview(viewController.view)

    let window: UIWindow = .init()
    window.isHidden = false
    
    rootViewController.setOverrideTraitCollection(traits, forChild: viewController)
    viewController.didMove(toParent: rootViewController)
    window.rootViewController = rootViewController

    rootViewController.beginAppearanceTransition(true, animated: false)
    rootViewController.endAppearanceTransition()

    rootViewController.view.setNeedsLayout()
    rootViewController.view.layoutIfNeeded()
    
    var size: CGSize = {
        switch (width, height) {
        case let (.some(w), .some(h)):
            return CGSize(width: w, height: h)
        case let (.some(w), .none):
            let targetSize = CGSize(width: w, height: UIView.layoutFittingCompressedSize.height)
            return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        case let (.none, .some(h)):
            let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: h)
            return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        case (.none, .none):
            let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: UIView.layoutFittingCompressedSize.height)
            return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel)
        }
    }()
    size.width = ceil(size.width)
    size.height = ceil(size.height)
    
    return size
}

/**
 Runs the snapshot test for the provided view and configuration

 Will fail with a "zero size" assertion if size cannot be determined.
*/
public func assertImageSnapshot(
    matching view: @autoclosure () -> UIView,
    config: ImageSnapshotConfig,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    let viewImageConfig = config.viewImageConfig
    let width: CGFloat? = config.fixedSize?.width
    let height: CGFloat? = config.fixedSize?.height
    
    let v: UIView = {
        switch (width, height) {
        case (.none, .none):
            return SnapshotContainer(view())
        default:
            return view()
        }
    }()    
    let size = fittingSize(forView: v, traits: viewImageConfig.traits, width: width, height: height)
    
    diffTool = SnapshotTestConfig.diffTool

    assertSnapshot(
        matching: v,
        as: .image(size: size, traits: viewImageConfig.traits),
        named: name,
        record: recording || SnapshotTestConfig.record,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}

public func assertImageSnapshot(
    matching vc: UIViewController,
    config: ViewImageConfig,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    diffTool = SnapshotTestConfig.diffTool

    assertSnapshot(
        matching: vc,
        as: .image(on: config),
        named: name,
        record: recording || SnapshotTestConfig.record,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}

public enum SnapshotTestConfig {
    public static var record = false
    public static var diffTool: String? = "ksdiff"

    
    public enum View {
        /**
         Used to test how the view looks like in **small width phones**.
         
         Generates one single iPhoneSe size configuration (iPhoneX
         for WorkCo) with **fixed width and flexible height**.
         
         ~~~
         SnapshotTestConfig.View.small { config in
             assertImageSnapshot(matching: aView, config: config)
         }
         ~~~

        - Parameter testing: The closure that returns the configuration to be tested.
        */
        public static func small(testing: (ImageSnapshotConfig) -> Void) {
            testing(
                .iPhoneSe(
                    userInterfaceStyle: .light,
                    preferredContentSizeCategory: .large
                )
            )
        }

        /**
         Used to test how the view looks like in **small and large width phones**.
         
         Generates two size configurations (one for iPhoneSe and one for iPhone8Plus
         (iPhoneX and iPhoneSe for WorkCo) with **fixed width and flexible height**.
         
         ~~~
         SnapshotTestConfig.View.all { config in
             assertImageSnapshot(matching: aView, config: config)
         }
         ~~~

        - Parameter testing: The closure that returns the configurations to be tested.
         Called twice, once per configuration returned.
        */
        public static func all(testing: (ImageSnapshotConfig) -> Void) {
            let configs: [ImageSnapshotConfig] = [
                .iPhoneSe(
                    userInterfaceStyle: .light,
                    preferredContentSizeCategory: .extraExtraExtraLarge
                ),
                .iPhone8Plus(
                    userInterfaceStyle: .dark,
                    preferredContentSizeCategory: .extraSmall
                ),
            ]
            combos(configs: configs, testing: testing)
        }

        static func combos(configs: [ImageSnapshotConfig], testing: (ImageSnapshotConfig) -> Void) {
            configs.forEach { config in
                testing(config)
            }
        }

        /**
         Used to test how the view looks like in **custom fixed size**.
         
         Generates one single size configuration with either **fixed width
         and flexible height** or **fixed width and height**.
         
         ~~~
         SnapshotTestConfig.View.fixed(.width(200)) { config in
             assertImageSnapshot(matching: aView, config: config)
         }
         ~~~
         
         or
         
         ~~~
         SnapshotTestConfig.View.fixed(.widthAndHeight(200, 100)) { config in
             assertImageSnapshot(matching: aView, config: config)
         }
         ~~~

        - Parameter testing: The closure that returns the configurations to be tested.
        */
        public static func fixed(_ fixedSize: ImageSnapshotConfig.FixedSize, testing: (ImageSnapshotConfig) -> Void) {
            testing(
                .fixed(fixedSize,
                       userInterfaceStyle: .light,
                       preferredContentSizeCategory: .large)
            )
        }
        
        public static func free(testing: (ImageSnapshotConfig) -> Void) {
            testing(
                .fixed(nil,
                userInterfaceStyle: .light,
                preferredContentSizeCategory: .large)
            )
        }
    }

    // config generation for view controllers
    public enum VC {
        public static func small(testing: (ViewImageConfig) -> Void) {
            configs(configs: .small, testing: testing)
        }
        
        public static func large(testing: (ViewImageConfig) -> Void) {
            configs(configs: .large, testing: testing)
        }
        
        public static func all(testing: (ViewImageConfig) -> Void) {
            configs(configs: .small, .large, testing: testing)
        }
        
        public static func configs(configs: ViewImageConfig..., testing: (ViewImageConfig) -> Void) {
            configs.forEach { config in
                testing(config)
            }
        }
    }
}


public extension ViewImageConfig {
    static let small: ViewImageConfig = {
        var config: ViewImageConfig = .iPhoneSe
        config.traits = UITraitCollection(traitsFrom: [
            config.traits,
            .init(preferredContentSizeCategory:.extraExtraExtraLarge)
        ])
        return config
    }()
    
    static let large: ViewImageConfig = {
        var config: ViewImageConfig = .iPhone8Plus
        config.traits = UITraitCollection(traitsFrom: [
            config.traits,
            .init(preferredContentSizeCategory: .large)
        ])
        return config
    }()
}
