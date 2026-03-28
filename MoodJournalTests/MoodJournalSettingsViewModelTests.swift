import Foundation
import Testing
@testable import MoodJournal

struct MoodJournalSettingsViewModelTests {
    @MainActor
    @Test
    func handleReminderToggleEnablesReminderOnSuccess() async {
        let store = MockMoodJournalStore()
        store.reminderTime = makeDate(year: 2026, month: 3, day: 20, hour: 20)
        let viewModel = MoodJournalSettingsViewModel(
            store: store,
            reminderScheduler: MockReminderScheduler(),
            privacyAuthenticator: MockPrivacyAuthenticator()
        )

        await viewModel.handleReminderToggle(true)

        #expect(store.reminderEnabled)
        #expect(viewModel.reminderFeedback.contains("Daily reminder scheduled"))
    }

    @MainActor
    @Test
    func updateReminderTimeDisablesReminderOnFailure() async {
        let store = MockMoodJournalStore()
        store.reminderEnabled = true
        let viewModel = MoodJournalSettingsViewModel(
            store: store,
            reminderScheduler: MockReminderScheduler(
                scheduleHandler: { _ in throw MockError(message: "Notifications disabled") }
            ),
            privacyAuthenticator: MockPrivacyAuthenticator()
        )

        await viewModel.updateReminderTime(makeDate(year: 2026, month: 3, day: 20, hour: 21))

        #expect(!store.reminderEnabled)
        #expect(viewModel.reminderFeedback == "Notifications disabled")
    }

    @MainActor
    @Test
    func handlePrivacyToggleEnablesLockOnSuccess() async {
        let store = MockMoodJournalStore()
        let viewModel = MoodJournalSettingsViewModel(
            store: store,
            reminderScheduler: MockReminderScheduler(),
            privacyAuthenticator: MockPrivacyAuthenticator()
        )

        await viewModel.handlePrivacyToggle(true)

        #expect(store.privacyLockEnabled)
        #expect(viewModel.privacyLockFeedback == "Privacy lock enabled.")
    }

    @MainActor
    @Test
    func handlePrivacyToggleStoresFailureMessage() async {
        let store = MockMoodJournalStore()
        let viewModel = MoodJournalSettingsViewModel(
            store: store,
            reminderScheduler: MockReminderScheduler(),
            privacyAuthenticator: MockPrivacyAuthenticator(
                authenticateHandler: { _ in throw MockError(message: "Authentication unavailable") }
            )
        )

        await viewModel.handlePrivacyToggle(true)

        #expect(!store.privacyLockEnabled)
        #expect(viewModel.privacyLockFeedback == "Authentication unavailable")
    }
}
