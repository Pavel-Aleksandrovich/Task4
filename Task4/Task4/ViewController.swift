//
//  ViewController.swift
//  Task4
//
//  Created by pavel mishanin on 11/2/24.
//

import UIKit

final class ViewController: UIViewController {

    struct Model {
        let id = UUID()
        let index: Int
        var isSelected = false
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var dataSource: [Model] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear

        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        let font = UIFont.systemFont(ofSize: 18, weight: .medium)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
        
        title = "Task 4"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        
        let shuffleButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleDidTap))
        navigationItem.rightBarButtonItem = shuffleButton
        
        dataSource = Array(0..<30).enumerated().map { Model(index: $0.offset+1) }
    }

    @objc func shuffleDidTap() {
        let oldList = dataSource
        dataSource.shuffle()
        
        tableView.performBatchUpdates({
            var alreadyMoved = Set<UUID>()
            
            for newIndex in dataSource.indices {
                let movedModel = dataSource[newIndex]

                guard !alreadyMoved.contains(movedModel.id) else { continue }
                
                if let oldIndex = oldList.firstIndex(where: { $0.id == movedModel.id }) {
                    
                    tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))

                    alreadyMoved.insert(movedModel.id)
                }
            }
        }, completion: { _ in
            self.tableView.reloadData()
        })
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isSelected = !dataSource[indexPath.row].isSelected
        dataSource[indexPath.row].isSelected = isSelected
        
        let toIndexPath = IndexPath(row: 0, section: indexPath.section)
        
        if isSelected {
            let item = dataSource.remove(at: indexPath.row)
            dataSource.insert(item, at: 0)
            
            tableView.performBatchUpdates({
                tableView.moveRow(at: indexPath, to: toIndexPath)
            }, completion: { _ in
                self.tableView.reloadRows(at: [toIndexPath], with: .automatic)
                tableView.deselectRow(at: toIndexPath, animated: true)
            })
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let model = dataSource[indexPath.row]
        
        cell.backgroundColor = .white
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.textLabel?.text = "\(model.index)"
        
        return cell
    }
}
