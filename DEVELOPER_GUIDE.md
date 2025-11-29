# Инструкция для разработчика - Начальный экран и управление файлами

## Обзор реализации

Реализованы следующие компоненты для улучшения UX приложения Bools:

### 1. Структура файлов

```
Bools/
├── Models/
│   └── RecentFilesManager.swift          # Менеджер недавних файлов
├── Views/
│   ├── StartScreenView.swift             # Начальный экран
│   └── CloseConfirmationModifier.swift   # Модификатор для диалога закрытия
├── ViewModels/
│   └── WorkspaceViewModel.swift          # (обновлен)
├── BoolsApp.swift                        # (обновлен)
└── ContentView.swift                     # (обновлен)
```

### 2. Поток данных

```
BoolsApp
  └── AppRootView
      ├── @StateObject recentFilesManager: RecentFilesManager
      ├── @StateObject vm: WorkspaceViewModel
      └── @State showStartScreen: Bool
          │
          ├─ if showStartScreen
          │   └── StartScreenView
          │       ├── recentFilesManager (ObservedObject)
          │       └── callbacks: onNewDocument, onOpenDocument, onOpenRecentFile
          │
          └─ else
              └── ContentView
                  ├── vm (ObservedObject)
                  ├── recentFilesManager (ObservedObject)
                  ├── showStartScreen (Binding)
                  └── .closeConfirmation(viewModel: vm, ...)
```

### 3. Компоненты

#### RecentFilesManager

**Назначение:** Управление списком недавних файлов

**Ключевые методы:**
```swift
func addRecentFile(_ url: URL)      // Добавить файл в список
func removeRecentFile(_ url: URL)   // Удалить файл из списка
func clearRecentFiles()             // Очистить весь список
```

**Хранилище:** UserDefaults с использованием Security-Scoped Bookmarks

#### StartScreenView

**Назначение:** Начальный экран приложения

**Структура:**
- `FeatureRow` - строка с описанием функции
- `RecentFileRow` - строка с информацией о файле

**Callbacks:**
- `onNewDocument: () -> Void` - создание нового документа
- `onOpenDocument: () -> Void` - открытие диалога выбора файла
- `onOpenRecentFile: (URL) -> Void` - открытие конкретного файла

#### CloseConfirmationModifier

**Назначение:** Диалог подтверждения при закрытии окна

**Реализация:**
- Использует NSViewRepresentable для доступа к NSWindow
- Coordinator реализует NSWindowDelegate
- Перехватывает `windowShouldClose(_:)`

**Логика:**
```swift
if !hasUnsavedChanges {
    return true  // Разрешить закрытие
}

// Показать диалог
let response = alert.runModal()

switch response {
    case .alertFirstButtonReturn:    // Сохранить
        onSave()
        return !viewModel.hasUnsavedChanges
    case .alertSecondButtonReturn:   // Не сохранять
        onDiscard()
        return true
    default:                          // Отменить
        return false
}
```

### 4. WorkspaceViewModel изменения

#### Новые свойства

```swift
@Published var hasUnsavedChanges: Bool = false
@Published var currentFileURL: URL? = nil
```

#### Отслеживание изменений

```swift
// В init()
Publishers.Merge($gates, $wires)
    .dropFirst()  // Пропускаем начальное значение
    .sink { [weak self] in
        self?.hasUnsavedChanges = true
    }
    .store(in: &cancellables)
```

#### Обновленные методы

```swift
func saveToURL(_ url: URL) throws {
    // ... сохранение ...
    hasUnsavedChanges = false
    currentFileURL = url
}

func loadFromURL(_ url: URL) throws {
    // ... загрузка ...
    hasUnsavedChanges = false
    currentFileURL = url
}

func newDocument() {
    gates.removeAll()
    wires.removeAll()
    // ... очистка остальных полей ...
    hasUnsavedChanges = false
    currentFileURL = nil
}
```

### 5. Интеграция в приложение

#### В BoolsApp.swift

```swift
struct AppRootView: View {
    @StateObject private var vm = WorkspaceViewModel()
    @ObservedObject var recentFilesManager: RecentFilesManager
    @State private var showStartScreen = true
    
    var body: some View {
        Group {
            if showStartScreen {
                StartScreenView(...)
            } else {
                ContentView(...)
                    .closeConfirmation(viewModel: vm, ...)
            }
        }
    }
}
```

#### В ContentView.swift

Изменена сигнатура:
```swift
struct ContentView: View {
    @ObservedObject var vm: WorkspaceViewModel
    @ObservedObject var recentFilesManager: RecentFilesManager
    @Binding var showStartScreen: Bool
    // ...
}
```

Обновлены методы сохранения:
```swift
func saveWorkspace() {
    if let url = vm.currentFileURL {
        // Быстрое сохранение
    } else {
        // Диалог "Сохранить как"
    }
}

func saveWorkspaceAs() {
    // Всегда показывает диалог
}
```

### 6. Тестирование

#### Сценарии для тестирования:

1. **Запуск приложения**
   - Должен показаться начальный экран
   - Список недавних файлов должен быть пуст при первом запуске

2. **Создание нового документа**
   - Клик на "Создать новую схему" скрывает начальный экран
   - Открывается пустой холст

3. **Работа с файлами**
   - Создайте схему, сохраните её
   - Перезапустите приложение
   - Файл должен появиться в списке недавних

4. **Закрытие с изменениями**
   - Создайте схему, добавьте вентиль
   - Попытайтесь закрыть окно
   - Должен появиться диалог с тремя кнопками

5. **Управление недавними файлами**
   - Откройте несколько файлов
   - Проверьте, что они появляются в списке
   - Удалите один файл из списка
   - Очистите весь список

### 7. Отладка

#### Логирование

Для отладки можно добавить print в ключевые места:

```swift
// В RecentFilesManager
func addRecentFile(_ url: URL) {
    print("📁 Adding recent file: \(url.lastPathComponent)")
    // ...
}

// В WorkspaceViewModel
var hasUnsavedChanges: Bool {
    didSet {
        print("💾 Has unsaved changes: \(hasUnsavedChanges)")
    }
}
```

#### Проверка состояния

В Xcode можно добавить breakpoint и проверить:
- `recentFilesManager.recentFiles` - список файлов
- `vm.hasUnsavedChanges` - флаг изменений
- `vm.currentFileURL` - текущий файл

### 8. Известные ограничения

1. Список недавних файлов ограничен 10 элементами
2. Диалог закрытия работает только на macOS (iOS требует другого подхода)
3. Security-Scoped Bookmarks требуют правильной настройки entitlements

### 9. Будущие улучшения

- [ ] Добавить превью схем в список недавних файлов
- [ ] Реализовать автосохранение
- [ ] Добавить поддержку восстановления последнего сеанса
- [ ] Улучшить производительность при большом количестве недавних файлов
- [ ] Добавить поиск в списке недавних файлов
