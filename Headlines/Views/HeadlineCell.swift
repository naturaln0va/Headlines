
import UIKit

class HeadlineCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!

    static let identifier = String(describing: HeadlineCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.cornerRadius = 3
        iconImageView.backgroundColor = .systemGroupedBackground
        websiteLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
    }
    
    func configure(with headline: Headline) {
        titleLabel.text = headline.title
        descriptionLabel.text = headline.description
        websiteLabel.text = headline.url.prettyHost
    }
    
}
