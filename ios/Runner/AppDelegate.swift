import UIKit
import Flutter
import MSAL
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] =
   [:]) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCuAkVVciCZDS4dPHPw-slMiEEBrGCvaSM")
    return MSALPublicClientApplication.handleMSALResponse(url,
    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }


}
