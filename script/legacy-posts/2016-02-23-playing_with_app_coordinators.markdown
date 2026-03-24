---
layout: post 
title: Swift - Coordinators
date: 2016-02-23 15:30:58 
author: Skye Freeman 
categories: Programming
---

This past week I came across an interesting talk post by [Soroush Khanlou][souroushLink] introducing the idea of using coordinators when building iOS apps.  I decided to take a crack at the concept by building out a small login/sign up workflow using coordinators to drive my app logic, in short, the experience was a revelation.

To give a little back story, here's the idea behind coordinators:

Coordinators drive the navigation and business facing logic of your app. They handle navigation between view controllers, and respond to input from those view controllers.  This sounds simple enough, but isn't this just moving code from one file to another?

Essentially, yes.  But the benefits of doing so aren't immediately obvious.  Traditionally, view controllers have been the least reusable parts of our apps.  In theory, a view controller should have one job, controlling the view.  In practice though, they tend to absorb functionality far beyond their scope. A few examples of what are 'beyond scope' are: model manipulation, navigation, triggering a web request etc... The iOS community has collectively come up with some [great ways][objcIOLink] of decoupling view controllers in an attempt to combat 'Massive View Controller' syndrome.  But in my opinion, they are still doing too much.  What if view controllers were just dumb objects like their model and view comrades?

**Enter the Coordinator.**

A coordinator strips the view controller of it's privileges, allowing the view controller to only lay out their subviews, and let the coordinator know about user input. By adding a protocol to the view controller, we can also be explicit about the interactions our coordinator responds to. Put simply, the coordinator bosses around the view controller.

Let's walk through some examples.  Here's what an AppDelegate might look like when using a coordinator:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var appCoordinator: AppCoordinator = {
       return AppCoordinator(window: self.window!)
    }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appCoordinator.start()
        return true
    }
}
```

Here we immediately pass off the responsibility of starting our app to the AppCoordinator.  The AppCoordinator is the top most coordinator that is in charge of initializing and directing to child coordinators. After first initializing our UIWindow object, we then lazily initialize our AppCoordinator passing the window. Next we call start() signifying the coordinator to start making decisions.  Here's what the AppCoordinator might look like:

```swift
class AppCoordinator: LoginCoordinatorDelegate {
    let window: UIWindow
    let rootViewController: UINavigationcontroller
    let childCoordinators: NSMutableArray
    
    init(window: UIWindow) {
        self.childCoordinators = NSMutableArray()
        self.rootViewController = UINavigationController()
        
        self.window = window
        self.window.backgroundColor = UIColor.whiteColor()
        self.window.rootViewController = self.rootViewController
        self.window.makeKeyAndVisible()
    }
    
    func start() {
        let loginCoordinator = LoginCoordinator(navigationcontroller: self.rootViewController)
        self.childCoordinators.addObject(loginCoordinator)
        
        loginCoordinator.start()
    }
}
```

Nothing crazy. We hold a reference to the UIWindow just in case we want to manipulate it, then initialize and set a root view controller.  It may seem odd to do UIWindow's work here instead of the AppDelegate, and is totally optional.  I felt that trimming down the AppDelegate one step further to be a big win.

The start() method is where things get really interesting.  First the AppCoordinator initializes the LoginCoordinator while passing along the root view controller.  Next, the LoginCoordinator is added to a mutable array called childCoordinators. This part is necessary so the currently active coordinator's don't get deallocated.  Lastly the start() method is called on loginCoordinator, beginning the cycle again.  Now the LoginCoordinator takes over control in setting up the first view controller in our app.

```swift
class LoginCoordinator: LoginViewControllerDelegate {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationcontroller) {
        self.navigationController = navigationController
    }
    
    func start() {
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        self.navigationController.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    // MARK: LoginViewControllerDelegate
    func loginButtonPressed(username: String, password: String) {
        if (username.characters.count == 0) { return }
        if (password.characters.count == 0) { return }

	print("Login pressed")
    }
    
    func signUpButtonPressed() {
        print("Sign up pressed")
    }
}
```

Here is where all the magic happens. In init() we store a reference to the root view controller which in this case is the navigation controller we defined in the AppCoordinator. Next in start() we initialize and push the LoginViewController onto the stack, setting its delegate along the way.  Now all we do is wait until the user presses the Log in or Sign Up buttons defined in our LoginViewController, then respond to those messages as needed. By creating a protocol for our LoginViewController, we can easily pass along the relevant data the LoginCoordinator needs to perform its tasks.  We can see that in action from this method:

```swift
func loginButtonPressed(username: String, password: String) {
     // Do login stuff
}
```

In a production app, the coordinator would then presumably perform the necessary requests needed to login a user, then make the decision on the next step for the app.  For example, a logical next step would be to signal the AppCoordinator that the login process has finished, remove the LoginCoordinator from the coordinator stack, then instantiate a new coordinator and start the process all over again.

The biggest win we get from using coordinators in my opinion is that we strip view controller's of the ability to navigate and make decisions.  Before, it was common for view controller's to be aware of their location on the navigation stack. Now, we totally strip down a view controller's responsibility to the minimum, while also turning them into reusable components.  By pushing the app's logic up one level into a coordinator our code can be far more expressive, clean, and minimal.

It may be too soon to call it a best practice, but I can already see myself using coordinator's extensively in my future projects. At the least, it's another powerful tool in the toolchain.

[souroushLink]: https://vimeo.com/144116310
[objcIOLink]: https://www.objc.io/issues/1-view-controllers/
