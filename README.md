# Weather & Activity Suitability Analyzer (Collinson Technical Exercise)

A production-grade, offline-safe native iOS application built using **Swift 6 Strict Concurrency** rules. The application dynamically evaluates the next 7 days' suitability for specific sports and tourism activities based on Open-Meteo's localized forecast dimensions.

---

## 🧠 Part 1: How I Worked & Engineering Judgments

This solution prioritizes **maintainability, sound architectural boundaries, and extensive verification** over feature volume. Below is the step-by-step reasoning that drove this project:

### 🚀 1. The Design Matrix (Pragmatic Architecture over Dogma)
While a 2-screen application can easily be built with basic **MVVM**, I implemented strict **Clean Architecture (Data-Domain-Presentation)** principles coupled with protocol-driven interfaces. Here is why:
- **Separation of Core IP:** The activity scoring logic is the core intellectual property of the business. Wrapping it tightly inside a `CalculateActivitySuitabilityUseCase` keeps it decoupled from UI platforms and native API formats, making it ready to be shared with a `watchOS` module or a Widget target in the future.
- **Strict Inversion of Control:** Adhering strictly to the **Dependency Inversion Principle**, the presentation layer (`ViewModels`) never communicates with the Data layer (`Repositories`). Furthermore, Repository protocols live entirely inside the **Domain Layer**, forcing the Data Layer to look inwards, safeguarding the business rule boundaries.

### 🔄 2. AI Collaboration & Verification Paradigm
In compliance with the guidelines, AI tools were leveraged to build the boilerplate structure. However, **rigorous engineering verification was manually applied** to handle compiler limitations and runtime edge cases:
- **Swift 6 Concurrency Alignment:** Initial compiler compilation flags raised isolation barriers (`Main actor-isolated conformance of Decodable cannot satisfy Sendable`). Instead of ignoring or bypassing the security flags, I refactored the data models using `nonisolated struct` tokens, breaking the context inference chain and guaranteeing true compile-time thread safety.
- **Bidirectional Refactoring:** I intentionally rejected an initial structural draft where the repository handled use cases. I refactored the design to ensure repositories remain pure data gateways, shifting the orchestration responsibilities exclusively back into the domain layer use cases.

---

## 🛠️ Part 2: Technical Specifications & Heuristics

### 🌦️ 1. Committed Activity Criteria (Assumptions)
Since suitability formulas were open-ended, the following deterministic rules were committed to the domain logic engine:
- **Skiing:** Requires freezing thresholds (Maximum Temperature <= 5°C), penalizes missing snowfall, and rewards active winter precipitation mapped directly from WMO weather codes.
- **Surfing:** Optimizes heavily for an absolute surface wind speed sweet-spot (12 km/h to 28 km/h) while strictly downvoting cold climates or dense precipitation sums.
- **Outdoor Sightseeing:** Scores at a maximum (100%) during clear sky codes with mild, pleasant localized temperatures (18°C to 26°C), applying linear deductions for rain volume.
- **Indoor Sightseeing:** Functions as a counter-cyclic fallback; suitability ranking dynamically climbs if external climate conditions become hostile (heavy downpours or radical temperature clips).

### ⚡ 2. Performance & Resource Constraints (Idempotency Guards)
- **Advanced Concurrency Debouncing:** To protect the Open-Meteo infrastructure, textfield tracking handles key-strokes through a custom 300ms `Task.sleep` mechanism. It leverages cooperative double-cancellation guards (`Task.isCancelled`) to cancel previous pending sockets instantly.
- **Navigation Idempotency:** The search engine saves the state of the `lastSearchedQuery`. If a user moves back and forth through the navigation stack, redundant API calls are automatically blocked if the text value has not changed.

---

## ⚙️ How to Build and Run Locally

1. Clone this public repository:
   ```bash
   git clone https://github.com
   ```
2. Open `CollinsonWeatherApp.xcodeproj` using Xcode 16+.
3. Ensure the active build scheme is targeting an active **iOS Simulator**.
4. Press **`Cmd + R`** to run the app.
   - Open the Xcode debug window (`Cmd + Shift + Y`) to monitor real-time structured out-going requests and incoming JSON payloads printed cleanly by our custom debug network wrappers.
5. Press **`Cmd + U`** to run the unit test target. The tests execute completely offline via isolation test doubles (`MockWeatherRepository`), running deterministic score calculations under milliseconds.

---

## 📉 Architectural Trade-offs for Future Scale
1. **In-Memory Caching:** Currently, search and city lists are held inside short-lived in-memory publishers due to the 48-hour challenge scope. For enterprise production, a local cache repository utilizing `SwiftData` or `CoreData` would be injected behind the existing `WeatherRepositoryProtocol`.
2. **Micro-Modularization:** To support multi-team parallel development in an enterprise setup, the current group boundaries are pre-wired to be moved out into separate local **Swift Package Manager (SPM)** modules (e.g., `DomainCore`, `NetworkEngine`, `WeatherFeature`).


