
import UIKit
import SafariServices

class HeadlinesViewController: UITableViewController {
    
    private let client: APIClient
    private var headlines = [Headline]()
    private let cellIdentifier = "reuseIdentifier"
    
    private let imageCache = NSCache<NSURL, UIImage>()
    
    private var currentPage = 1
    private var isLoadingPage = false
    
    private var canLoadPage: Bool {
        return !isLoadingPage && currentPage > 0
    }
    
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
        
        tableView.register(
            UINib(nibName: HeadlineCell.identifier, bundle: nil),
            forCellReuseIdentifier: HeadlineCell.identifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        
        setUpRefreshControl()
        
        fetchData()
        clearsSelectionOnViewWillAppear = true
    }
    
    // MARK: - Actions
    
    @objc private func refreshDidBegin(_ sender: UIRefreshControl) {
        currentPage = 1
        headlines.removeAll()
        
        fetchData {
            DispatchQueue.delay(0.5) {
                sender.endRefreshing()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshDidBegin(_:)),
            for: .valueChanged
        )
        
        self.refreshControl = refreshControl
    }

    private func fetchData(_ completion: (() -> Void)? = nil) {
        guard canLoadPage else {
            completion?()
            return
        }
        
        isLoadingPage = true
        
        var request = APIRequest(method: .get, path: "top-headlines")
        request.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "page", value: String(currentPage))
        ]
        
        client.perform(request) { result in
            switch result {
            case .success(let response):
                do {
                    let response = try response.decode(to: HeadlinePage.self)
                    let page = response.body
                    self.headlines.append(contentsOf: page.headlines)
                    self.currentPage = page.hasNextPage ? self.currentPage + 1 : 0
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch {
                    let errorMessage = "Error: \(error.localizedDescription)"
                    
                    print(errorMessage)
                }
//                if let response = try? response.decode(to: HeadlinePage.self) {
//                    let page = response.body
//                    self.headlines.append(contentsOf: page.headlines)
//                    self.currentPage = page.hasNextPage ? self.currentPage + 1 : 0
//
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//                else if let error = try? response.decode(to: HeadlineError.self) {
//                    if error.body.isMaximumResultsReached {
//                        self.currentPage = 0
//                    }
//                    else {
//                        print("API error: \(error.body.description)")
//                    }
//                }
//                else {
//                    print("Decoding failed")
//                }
            case .failure:
                print("The network request failed")
            }
            
            self.isLoadingPage = false
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return headlines.isEmpty ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeadlineCell.identifier) as? HeadlineCell else {
            fatalError()
        }
        
        let headline = headlines[indexPath.row]
        cell.configure(with: headline)
        
        if let imageURL = headline.imageURL {
            if let image = imageCache.object(forKey: imageURL as NSURL) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let headline = headlines[indexPath.row]
        
        let sfVC = SFSafariViewController(url: headline.url)
        present(sfVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == headlines.count - 1 else {
            return
        }
        
        fetchData()
    }

}
