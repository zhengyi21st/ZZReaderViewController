//
//  HomeViewController.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/3.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit
import ZZReaderViewController

struct ZZExample {
    enum ExampleType {
        case pageCurl
        case translationHorizontally
        case translationVertically
        case scrollHorizontally
        case scrollVertically
    }
    var title: String
    var type: ExampleType
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView =  {
        $0.delegate = self
        $0.dataSource = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        $0.backgroundColor = .clear
        $0.tableFooterView = UIView()
        return $0
    }(UITableView(frame: .zero, style: .plain))

    var examples: [ZZExample] = [
        .init(title: "翻页 - 仿真", type: .pageCurl),
        .init(title: "翻页 - 水平平移", type: .translationHorizontally),
        .init(title: "翻页 - 垂直平移", type: .translationVertically),
        .init(title: "翻页 - 水平滚动", type: .scrollHorizontally),
        .init(title: "翻页 - 垂直滚动", type: .scrollVertically)
    ]

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        title = "ZZReaderViewController"
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        view.addSubview(tableView)
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = examples[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = examples[indexPath.row]
        if item.type == .pageCurl {
            navigationController?.pushViewController(ExampleViewController<ZZReaderPageViewController>(), animated: true)
        } else if item.type == .translationHorizontally {
            let vc = ExampleViewController<ZZReaderCollectionViewController>()
            vc.readerVC.set(scrollStyle: .translationHorizontally)
            navigationController?.pushViewController(vc, animated: true)
        } else if item.type == .translationVertically {
            let vc = ExampleViewController<ZZReaderCollectionViewController>()
            vc.readerVC.set(scrollStyle: .translationVertically)
            navigationController?.pushViewController(vc, animated: true)
        } else if item.type == .scrollHorizontally {
            let vc = ExampleViewController<ZZReaderCollectionViewController>()
            vc.readerVC.set(scrollStyle: .scrollHorizontally)
            navigationController?.pushViewController(vc, animated: true)
        } else if item.type == .scrollVertically {
            let vc = ExampleViewController<ZZReaderCollectionViewController>()
            vc.readerVC.set(scrollStyle: .scrollVertically)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
}
