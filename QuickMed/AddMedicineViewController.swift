import UIKit
import CoreData
import UserNotifications

class AddMedicineViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var medicineNameTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyStepper: UIStepper!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!

    // Day buttons
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tueButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thuButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    @IBOutlet weak var sunButton: UIButton!

    var selectedDays: Set<String> = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        medicineNameTextField.delegate = self
        dosageTextField.delegate = self

        frequencyStepper.minimumValue = 1
        frequencyStepper.maximumValue = 10
        frequencyStepper.value = 1
        frequencyLabel.text = "Frequency: 1"

        [monButton, tueButton, wedButton, thuButton, friButton, satButton, sunButton].forEach {
            styleDayButton($0)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - UI Helpers
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func styleDayButton(_ button: UIButton?) {
        guard let button = button else { return }
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
    }

    func weekdayIndex(for shortDay: String) -> Int? {
        // Calendar's weekday values: Sunday = 1, Monday = 2, ..., Saturday = 7
        let map = ["SUN": 1, "MON": 2, "TUE": 3, "WED": 4, "THU": 5, "FRI": 6, "SAT": 7]
        return map[shortDay.uppercased()]
    }

    // MARK: - Notification Scheduling
    func scheduleNotifications(for medicineName: String, desiredHour: Int, desiredMinute: Int, selectedDays: Set<String>, startDate: Date, endDate: Date) -> [String] {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        var allScheduledIDs: [String] = []

        // Start iteration from the beginning of the start date
        var loopDate = calendar.startOfDay(for: startDate)
        // Ensure we iterate up to and including the end date
        let endOfEndDate = calendar.startOfDay(for: endDate)

        while loopDate <= endOfEndDate {
            let weekday = calendar.component(.weekday, from: loopDate)
            let shortDay = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][weekday - 1]

            if selectedDays.contains(shortDay) {
                // Construct the actual medicine time for *this specific loopDate*
                // This ensures the correct date part is combined with the desired time
                var actualMedicineTimeComponents = calendar.dateComponents([.year, .month, .day], from: loopDate)
                actualMedicineTimeComponents.hour = desiredHour
                actualMedicineTimeComponents.minute = desiredMinute
                actualMedicineTimeComponents.second = 0

                guard let actualMedicineTime = calendar.date(from: actualMedicineTimeComponents) else {
                    print("❌ Could not create actual medicine time for \(loopDate)")
                    loopDate = calendar.date(byAdding: .day, value: 1, to: loopDate)!
                    continue
                }

                let now = Date() // Get 'now' inside the loop for accuracy

                // Schedule 10-minute prior notification
                if let fireDate10Min = calendar.date(byAdding: .minute, value: +10, to: actualMedicineTime) {
                    // Critical check: only schedule if the fireDate is strictly in the future.
                    // This covers both today's and future dates correctly.
                    if fireDate10Min > now {
                        let content = UNMutableNotificationContent()
                        content.title = "Medicine Reminder 💊 (10 min warning)"
                        content.body = "Just 10 minutes until your \(medicineName)!"
                        content.sound = .default

                        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate10Min)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false) // Specific date, not repeating weekly
                        let id = UUID().uuidString
                        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                        center.add(request) { error in
                            if let error = error {
                                print("Error scheduling 10-min notification \(id): \(error.localizedDescription)")
                            } else {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .short
                                formatter.timeStyle = .short
                                print("🔔 Scheduled \(medicineName) (10 min) at ⏰ \(formatter.string(from: fireDate10Min)) (ID: \(id))")
                                allScheduledIDs.append(id)
                            }
                        }
                    } else {
                        // Log with the full date of the *fire date* for clarity
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        print("⛔️ Skipping 10-min notification for \(medicineName) on \(formatter.string(from: loopDate)) at \(formatter.string(from: fireDate10Min)) — time in past.")
                    }
                }

                // Schedule 5-minute prior notification
                if let fireDate5Min = calendar.date(byAdding: .minute, value: +5, to: actualMedicineTime) {
                    // Critical check: only schedule if the fireDate is strictly in the future.
                    if fireDate5Min > now {
                        let content = UNMutableNotificationContent()
                        content.title = "Medicine Reminder 💊 (5 min warning)"
                        content.body = "Time to take your \(medicineName) in 5 minutes!"
                        content.sound = .default

                        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate5Min)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                        let id = UUID().uuidString
                        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                        center.add(request) { error in
                            if let error = error {
                                print("Error scheduling 5-min notification \(id): \(error.localizedDescription)")
                            } else {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .short
                                formatter.timeStyle = .short
                                print("🔔 Scheduled \(medicineName) (5 min) at ⏰ \(formatter.string(from: fireDate5Min)) (ID: \(id))")
                                allScheduledIDs.append(id)
                            }
                        }
                    } else {
                        // Log with the full date of the *fire date* for clarity
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        print("⛔️ Skipping 5-min notification for \(medicineName) on \(formatter.string(from: loopDate)) at \(formatter.string(from: fireDate5Min)) — time in past.")
                    }
                }
            }
            // Move to the next day
            loopDate = calendar.date(byAdding: .day, value: 1, to: loopDate)!
        }
        return allScheduledIDs
    }

    // MARK: - Actions
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        frequencyLabel.text = "Frequency: \(Int(sender.value))"
    }

    @IBAction func dayButtonTapped(_ sender: UIButton) {
        guard let day = sender.titleLabel?.text else { return }
        if selectedDays.contains(day) {
            selectedDays.remove(day)
            sender.isSelected = false
            sender.backgroundColor = .systemGray5
        } else {
            selectedDays.insert(day)
            sender.isSelected = true
            sender.backgroundColor = .systemBlue
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = medicineNameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter medicine name")
            return
        }

        guard let dosage = dosageTextField.text, !dosage.isEmpty else {
            showAlert(message: "Please enter dosage")
            return
        }

        guard !selectedDays.isEmpty else {
            showAlert(message: "Please select at least one day")
            return
        }

        let frequency = Int16(frequencyStepper.value)
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date

        // Ensure the exact hour and minute from the picker are extracted.
        let calendar = Calendar.current
        let desiredHour = calendar.component(.hour, from: startDatePicker.date)
        let desiredMinute = calendar.component(.minute, from: startDatePicker.date)

        // For storage, create a Date object using the extracted components
        // and the startDatePicker's actual date component.
        guard let selectedTimeForStorage = calendar.date(bySettingHour: desiredHour,
                                                            minute: desiredMinute,
                                                            second: 0,
                                                            of: startDatePicker.date) else {
            showAlert(message: "Could not determine selected time for storage.")
            return
        }

        let daysString = selectedDays.joined(separator: ",")

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let medicine = Medicine(context: context)
        medicine.name = name
        medicine.dosage = dosage
        medicine.frequency = frequency
        medicine.startDate = startDate
        medicine.endDate = endDate
        medicine.time = selectedTimeForStorage // Store this
        medicine.selectedDays = daysString
        print("Parameters :s")
        print(desiredHour,desiredMinute,startDate, endDate, selectedDays);
        // Schedule notifications using the new function parameters
        let allIDs = scheduleNotifications(for: name, desiredHour: desiredHour, desiredMinute: desiredMinute, selectedDays: selectedDays, startDate: startDate, endDate: endDate)
        medicine.notificationIDs = allIDs.joined(separator: ",")

        do {
            try context.save()
            showAlertAndNavigate(message: "Medicine saved & reminders scheduled ✅")
        } catch {
            showAlert(message: "❌ Save failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Alerts
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showAlertAndNavigate(message: String) {
        let alert = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
