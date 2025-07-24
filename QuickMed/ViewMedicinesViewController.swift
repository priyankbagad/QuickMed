import UIKit
import CoreData

class ViewMedicinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var medicines: [Medicine] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchMedicines()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
            
            
        


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMedicines()
    }

    // MARK: - Fetching Data

    func fetchMedicines() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]

        do {
            medicines = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("❌ Failed to fetch medicines: \(error)")
        }
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell", for: indexPath) as? MedicineTableViewCell else {
            return UITableViewCell()
        }

        let med = medicines[indexPath.row]
        let timeString = formattedTime(med.time)
        let days = med.selectedDays ?? "-"

        cell.titleLabel.text = med.name
        cell.subtitleLabel.text = "Days: \(days) | Time: \(timeString)"

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents) // Prevent duplicate actions
        cell.deleteButton.addTarget(self, action: #selector(deleteMedicine(_:)), for: .touchUpInside)

        return cell
    }

    // Optional: Deselect row on tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Formatter

    func formattedTime(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Delete Action

    @objc func deleteMedicine(_ sender: UIButton) {
        let index = sender.tag
        let medToDelete = medicines[index]

        // 🔕 Cancel notifications if present
        if let idsString = medToDelete.notificationIDs {
            let ids = idsString.components(separatedBy: ",")
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }

        // 🗑 Delete from Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(medToDelete)

        do {
            try context.save()
            medicines.remove(at: index)
            tableView.reloadData()
        } catch {
            print("❌ Failed to delete medicine: \(error)")
        }
    }

}
