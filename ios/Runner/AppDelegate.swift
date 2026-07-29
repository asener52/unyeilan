import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let configRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppConfig")
    let configChannel = FlutterMethodChannel(
      name: "tr.gov.unye.unyeIlan/config",
      binaryMessenger: configRegistrar.messenger()
    )
    configChannel.setMethodCallHandler { call, result in
      guard call.method == "hasFirebaseConfig" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil)
    }
  }
}
