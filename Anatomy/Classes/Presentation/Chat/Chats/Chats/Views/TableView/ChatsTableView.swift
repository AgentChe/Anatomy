//
//  ChatsTableView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 28.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatsTableView: UITableView {
    private lazy var elements = [Chat]()
    
    private lazy var didSelectTrigger = PublishRelay<Chat>()
    private lazy var didDeleteTrigger = PublishRelay<Chat>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatsTableView {
    func setup(elements: [Chat]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Chat> {
        didSelectTrigger.asSignal()
    }
    
    var didDelete: Signal<Chat> {
        didDeleteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension ChatsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: ChatsTableCell.self), for: indexPath) as! ChatsTableCell
        cell.setup(chat: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension ChatsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(elements[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            didDeleteTrigger.accept(elements[indexPath.row])
        }
    }
}

// MARK: Private
private extension ChatsTableView {
    func initialize() {
        register(ChatsTableCell.self, forCellReuseIdentifier: String(describing: ChatsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
