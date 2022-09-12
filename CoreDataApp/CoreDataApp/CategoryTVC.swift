//
//  CategoryTVC.swift
//  CoreDataApp
//
//  Created by Illya Gurkov on 12.09.22.
//

import CoreData
import UIKit
class CategoryTVC: UITableViewController {
    var categories = [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        alert.addTextField { texField in texField.placeholder = "Category" }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               text != "",
               let self = self
            {
                let newCategory = CategoryModel(context: self.context) // создаём модель и в неё вкидываем контекст
                newCategory.name = text
                self.categories.append(newCategory)
                self.saveCategories()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
            }
        }
        alert.addAction(cancel)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let name = categories[indexPath.row].name
        {
            let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            request.predicate = NSPredicate(format: "name==\(name)") //  условие по которому будет выполняться реквест
            if let categories = try? context.fetch(request) {
                for category in categories {
                    context.delete(category)
                }
                self.categories.remove(at: indexPath.row) // удаляем из массива
                saveCategories()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoListVC = segue.destination as? ToDoTVC,
           let indexPath = tableView.indexPathForSelectedRow
        {
            toDoListVC.selectedCategory = categories[indexPath.row]
        }
    }
    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
    private func loadCategories(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
}
