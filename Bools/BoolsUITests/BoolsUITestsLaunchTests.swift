//
//  Bools_2_0UITestsLaunchTests.swift
//  Bools 2.0UITests
//
//  Создано Mishkevich Stanislav 11/11/25
//

import XCTest

final class BoolsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Добавьте шаги для выполнения после запуска приложения, перед созданием скриншота,
        // например вход в тестовый аккаунт, или переход в нужный экран приложения

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
