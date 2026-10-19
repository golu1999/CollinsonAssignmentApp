# Engineering Planning Notes & AI Collaboration Diary

This document outlines the end-to-end design evolution, prompt architecture, and strict verification logic applied during this exercise.

## 🗺️ 1. Architectural Evolution & Verification Milestones
AI tools were systematically used to spin up structural wireframes. However, engineering judgment was continuously applied to audit and break implicit design anti-patterns:

- **The Dependency Direction Audit (Critical Fix):** Early AI code configurations mistakenly injected the `CalculateActivitySuitabilityUseCaseProtocol` directly inside the concrete `WeatherRepository` layer. I caught this structural violation of the **Dependency Inversion Principle**. I refactored the codebase to ensure repositories remain pure data gateways, shifting orchestration boundaries exclusively back into the domain layer use cases.
- **Swift 6 Strict Concurrency Mitigation:** Initial generic async token streams threw data-isolation boundary warnings (`Main actor-isolated conformance of Decodable cannot satisfy Sendable`). I audited the compiler metadata behavior and resolved this by declaring data models explicitly as `nonisolated struct` objects to guarantee true compile-time thread safety.
- **Idempotency Guard Implementation:** I identified an issue where navigating back and forth through the SwiftUI stack thrashed the network by initiating redundant duplicate API calls for identical text inputs. I implemented a `lastSearchedQuery` state cache filter layer directly inside the ViewModel to block useless socket traffic.

## 🛠️ 2. Architectural Trade-offs Decisions
- **Why Clean Architecture over standard MVVM for a 2-Screen App?**
  While MVVM would require less boilerplate code, this layout serves as an enterprise blueprint for Collinson's ecosystem scale. The core intellectual property—the weather scoring heuristic—is completely isolated from presentation styling, meaning it can be instantly deployed into independent micro-modules or alternative Apple targets (e.g., watchOS, Widgets) without duplicating lines.
- **Why Native Task Cancellation over Combine Publishers?**
  Using native `Task.sleep` and `Task.isCancelled` provides a highly optimized cooperative cancellation debouncer that aligns natively with Swift 6 actors, fully eliminating the memory leak overhead (`[weak self]`, `AnyCancellable` tracking arrays) typical of Combine pipelines.


