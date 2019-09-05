
import UIKit
import SafariServices

class HeadlinesViewController: UITableViewController {
    
    private let client: APIClient
    private let cellIdentifier = "reuseIdentifier"
    private let imageCache = NSCache<NSURL, UIImage>()
    
    private lazy var dataSource = createDataSource()
    
    init() {
        guard let filePath = Bundle.main.url(forResource: "api_key", withExtension: "txt"), let apiKey = try? String(contentsOf: filePath) else {
            fatalError("An API key is needed. Get one here: https://newsapi.org/register")
        }
        
        client = APIClient(apiKey: apiKey)

        super.init(style: .insetGrouped)
        
        title = "Headlines"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        clearsSelectionOnViewWillAppear = true
        
        tableView.register(
            UINib(nibName: HeadlineCell.identifier, bundle: nil),
            forCellReuseIdentifier: HeadlineCell.identifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isMovingToParent else {
            return
        }
        
        fetchData()
    }
        
    // MARK: - Helpers
    
    private func fetchData() {
        let pageSize = 20
        var request = APIRequest(method: .get, path: "top-headlines")
        request.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
                
        client.perform(request) { result in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: HeadlinePage.self) {
                    let page = response.body
                    self.appendHeadlines(page.headlines)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else if let error = try? response.decode(to: HeadlineError.self) {
                    print("API error: \(error.body.description)")
                }
                else {
                    print("Decoding failed")
                }
            case .failure:
                print("The network request failed")
            }
        }
    }
    
}

internal extension HeadlinesViewController {
    
    enum HeadlineSection: CaseIterable {
        case content
    }
    
    private func createDataSource() -> UITableViewDiffableDataSource<HeadlineSection, Headline> {
        return UITableViewDiffableDataSource(tableView: tableView) { table, indexPath, headline in
            guard let cell = table.dequeueReusableCell(withIdentifier: HeadlineCell.identifier) as? HeadlineCell else {
                fatalError()
            }
            
            cell.configure(with: headline)
            
            if let imageURL = headline.imageURL {
                if let image = self.imageCache.object(forKey: imageURL as NSURL) {
                    cell.iconImageView.image = image
                }
                else {
                    URLSession.requestImage(at: imageURL, size: CGSize(square: 96)) { image in
                        guard let image = image else {
                            return
                        }
                        
                        self.imageCache.setObject(image, forKey: imageURL as NSURL)
                        cell.iconImageView.image = image
                    }
                }
            }

            return cell
        }
    }
    
    private func appendHeadlines(_ headlines: [Headline], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<HeadlineSection, Headline>()
        
        snapshot.appendSections(HeadlineSection.allCases)
        snapshot.appendItems(headlines, toSection: .content)

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let headline = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let sfVC = SFSafariViewController(url: headline.url)
        present(sfVC, animated: true)
    }
    
}
