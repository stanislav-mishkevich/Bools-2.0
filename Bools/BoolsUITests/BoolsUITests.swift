//
//  Bools_2_0UITests.swift
//  Bools 2.0UITests
//
//  Создано Mishkevich Stanislav 11/11/25
//

import XCTest

final class BoolsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Разместите код подготовки здесь, этот метод вызывается перед запуском каждого теста в классе

        // В UI тестах обычно лучше сразу останавливаться при ошибке
        continueAfterFailure = false
        // В UI тестах важно установить начальное состояние, например ориентацию интерфейса, необходимую для тестов, метод setUp подходит для этого
    }

    override func tearDownWithError() throws {
        // Разместите код очистки здесь, этот метод вызывается после каждого теста в классе
    }

    @MainActor
    func testExample() throws {
        // UI тесты должны запускать тестируемое приложение
        let app = XCUIApplication()
        app.launch()

        // Используйте XCTAssert и связанные функции для проверки корректности результатов тестов
    }

    @MainActor
    func testLaunchPerformance() throws {
        // Это измеряет время, необходимое для запуска приложения
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
