# Исправление логики физических элементов

## Описание проблем и решений

### 1. BATTERY (Батарея)
**Проблема:** Логика выходов батареи была неправильной.

**Исправление:** 
- Верхний контакт (+): всегда выдаёт `1` (логическую единицу)
- Нижний контакт (-): всегда выдаёт `0` (логический нуль, земля)
- Выходы батареи независимы от входов - это источник питания

**Код:**
```swift
case "BATTERY":
    if g.outputPins.indices.contains(0) { g.outputPins[0].value = true }   // + контакт
    if g.outputPins.indices.contains(1) { g.outputPins[1].value = false }  // - контакт (земля)
```

### 2. LED, BULB, BUZZER (Индикаторы)
**Проблема:** Логика активации должна быть правильной - индикаторы должны работать при разнице потенциалов между контактами, а не при обоих активных контактах.

**Исправление:**
- Индикатор загорается, когда есть **разница потенциалов** между контактами
- Это значит: + контакт должен быть на логической `1`, а - контакт на логическом `0` (земля)
- Входы: `[0]` = +, `[1]` = -

**Код:**
```swift
case "LED", "BULB", "BUZZER":
    let posContact = inputs.count > 0 ? inputs[0] : false
    let negContact = inputs.count > 1 ? inputs[1] : false
    // Индикатор включается при напряжении (+ высокий, - низкий)
    let isLit = posContact && !negContact
    g.isIndicatorActive = isLit
```

### 3. RELAY (Реле)
**Проблема:** Комментарии были неточными относительно логики.

**Исправление:**
- Катушка активируется, когда оба входа подключены в цепь (+ и -)
- COM (выход [0]): проводит в зависимости от состояния катушки
- NO (выход [1]): нормально открытый контакт, замыкается при активации
- NC (выход [2]): нормально закрытый контакт, размыкается при активации

**Код:**
```swift
case "RELAY":
    let coilActive = inputs.count >= 2 ? (inputs[0] && inputs[1]) : false
    if g.outputPins.indices.contains(0) { g.outputPins[0].value = coilActive ? true : false }
    if g.outputPins.indices.contains(1) { g.outputPins[1].value = coilActive }
    if g.outputPins.indices.contains(2) { g.outputPins[2].value = !coilActive }
```

### 4. BJT_NPN и BJT_PNP (Биполярные транзисторы)
**Проблема:** Логика не различала между NPN и PNP транзисторами правильно.

**Исправление:**
- **NPN**: Коллектор-Эмиттер проводит, когда база активна (положительный логический уровень)
- **PNP**: Коллектор-Эмиттер проводит, когда база неактивна (логический нуль)
- Входы: `[0]` = База (B)
- Выходы: `[0]` = Коллектор (C), `[1]` = Эмиттер (E)

**Код:**
```swift
case "BJT_NPN", "BJT_PNP":
    let baseActive = inputs.first ?? false
    let isNPN = g.baseName == "BJT_NPN"
    let conducts = isNPN ? baseActive : !baseActive
    if g.outputPins.indices.contains(0) { g.outputPins[0].value = conducts }
    if g.outputPins.indices.contains(1) { g.outputPins[1].value = conducts }
```

### 5. MOSFET_N и MOSFET_P (Полевые транзисторы)
**Проблема:** Логика была неправильной для разных типов MOSFET.

**Исправление:**
- **N-канальный MOSFET**: Сток-Исток проводит, когда затвор имеет положительный потенциал
- **P-канальный MOSFET**: Сток-Исток проводит, когда затвор имеет отрицательный потенциал
- Входы: `[0]` = Затвор (G)
- Выходы: `[0]` = Сток (D), `[1]` = Исток (S)

**Код:**
```swift
case "MOSFET_N", "MOSFET_P":
    let gateActive = inputs.first ?? false
    let conducts = (g.baseName == "MOSFET_N") ? gateActive : !gateActive
    if g.outputPins.indices.contains(0) { g.outputPins[0].value = conducts }
    if g.outputPins.indices.contains(1) { g.outputPins[1].value = conducts }
```

## Файлы, изменённые в этом обновлении

1. `/Bools/Bools/ViewModels/WorkspaceViewModel.swift`
   - Функция `simulate()` - логика для топологически упорядоченных схем
   - Цикличная симуляция - логика для схем с циклами

2. `/BoolsTests/SimulationTests.swift`
   - Добавлены новые тесты для проверки физических элементов:
     - `testLedIndicatorBothActive()` - LED при активных обоих контактах
     - `testLedIndicatorOnlyPositive()` - LED при активном только положительном контакте
     - `testBatteryOutputs()` - проверка выходов батареи
     - `testRelayCoilActivation()` - активация катушки реле
     - `testBjtNpnBaseControl()` - управление базой NPN транзистора

## Электрическая логика

Физические элементы теперь правильно моделируют поведение реальных электрических компонентов:

- **Источники** (BATTERY): выдают постоянное напряжение
- **Индикаторы** (LED, BULB, BUZZER): требуют замкнутой цепи между + и -
- **Переключатели** (RELAY): используют электромагнит для управления контактами
- **Транзисторы** (BJT, MOSFET): используют управляющий сигнал для коммутации

## Тестирование

Новые тесты проверяют корректность логики физических элементов в различных сценариях.
Запустите тесты с помощью Xcode или командной строки:

```bash
xcodebuild test -scheme Bools -destination 'platform=macOS'
```

### 6. DISPLAY8BIT (8-битный цифровой дисплей)

**Назначение:** Отображение 8-битного двоичного числа в десятичном формате на виртуальном дисплее.

**Входы:**
- B0-B7 (8 битов): В0 - младший бит (LSB), В7 - старший бит (MSB)
- + (питание): положительное питание (должно быть = 1)
- - (земля): отрицательное питание/земля (должно быть = 0)

**Логика:**
- Дисплей работает только при наличии питания (вход [8] = 1 И вход [9] = 0)
- При наличии питания: выводит число из битов 0-7 (0-255)
- При отсутствии питания: отображает 0

**Код (акциклическая часть):**
```swift
case "DISPLAY8BIT":
    // 8-битный дисплей: 8 входов для битов (0-7) + 2 входа для питания (+/-)
    // Входы 0-7: B0-B7 (B0 = LSB, B7 = MSB)
    // Входы 8-9: питание +/- (для активации)
    let powerOn = (inputs.count > 8 && inputs.count > 9) ? (inputs[8] && !inputs[9]) : false
    if powerOn {
        // Считаем 8-битное число из битов 0-7
        var value = 0
        for i in 0..<8 {
            if inputs.count > i && inputs[i] {
                value |= (1 << i)
            }
        }
        g.displayValue = value
    } else {
        g.displayValue = 0
    }
    gateMap[id] = g
    continue
```

**Пример использования:**
- Для отображения числа 42 (00101010 в двоичной системе) подключите:
  - B0 = 0, B1 = 1, B2 = 0, B3 = 1, B4 = 0, B5 = 1, B6 = 0, B7 = 0
  - + = 1 (от батареи)
  - - = 0 (от батареи)

## Файлы, изменённые в этом обновлении

1. `/Bools/Bools/Models/Gate.swift`
   - Добавлено поле `displayValue: Int` для хранения значения 8-битного дисплея
   - Добавлена конфигурация пинов для DISPLAY8BIT

2. `/Bools/Bools/ViewModels/WorkspaceViewModel.swift`
   - Добавлена обработка DISPLAY8BIT в методе `addGate()`
   - Добавлена логика симуляции для DISPLAY8BIT в обеих ветках (`topo` и `cyclic`)
   - Добавлены описания для DISPLAY8BIT в `shortDescriptionFor()` и `descriptionFor()`

3. Этот документ (`PHYSICAL_ELEMENTS_FIXES.md`)
   - Добавлена информация о 8-битном дисплее
