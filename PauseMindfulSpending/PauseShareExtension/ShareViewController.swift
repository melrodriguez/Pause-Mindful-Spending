import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extractSharedContent()
    }

    private func extractSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            cancel()
            return
        }

        let attachments = extensionItem.attachments ?? []
        let group = DispatchGroup()

        var extractedTitle: String? = nil
        var extractedImageData: Data? = nil
        var extractedURL: String? = nil

        for provider in attachments {

            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
                    if let url = item as? URL {
                        extractedURL = url.absoluteString
                    }
                    group.leave()
                }
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                    if let text = item as? String, extractedTitle == nil {
                        print("DEBUG plain text payload:", text)
                        extractedTitle = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    group.leave()
                }
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.image.identifier) { item, _ in
                    if let image = item as? UIImage {
                        extractedImageData = image.jpegData(compressionQuality: 0.7)
                    } else if let url = item as? URL,
                              let data = try? Data(contentsOf: url) {
                        extractedImageData = data
                    }
                    group.leave()
                }
            }

            if provider.hasItemConformingToTypeIdentifier("com.apple.property-list") {
                group.enter()
                provider.loadItem(forTypeIdentifier: "com.apple.property-list") { item, _ in
                    if let dict = item as? [String: Any] {
                        print("DEBUG plist payload:", dict)
                        if let title = dict["title"] as? String {
                            extractedTitle = title
                        }
                        if let urlString = dict["url"] as? String {
                            extractedURL = urlString
                        }
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            let cleanedTitle = Self.cleanTitle(extractedTitle)

            // Try to fetch price from the URL if we have one
            if let urlString = extractedURL, let url = URL(string: urlString) {
                Self.fetchPrice(from: url) { price in
                    self.saveToSharedDefaults(
                        title: cleanedTitle,
                        price: price,
                        imageData: extractedImageData,
                        url: extractedURL
                    )
                    self.openMainApp()
                }
            } else {
                self.saveToSharedDefaults(
                    title: cleanedTitle,
                    price: nil,
                    imageData: extractedImageData,
                    url: extractedURL
                )
                self.openMainApp()
            }
        }
    }

    // MARK: - Title cleanup

    private static func cleanTitle(_ title: String?) -> String? {
        guard let title = title, !title.isEmpty else { return nil }

        let separators = [" - ", " | ", " – ", " — ", ": "]
        for sep in separators {
            if let range = title.range(of: sep) {
                let before = String(title[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                if before.count > 5 { return before }
            }
        }

        if let commaRange = title.range(of: ", ") {
            let before = String(title[..<commaRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            if before.count > 5 { return before }
        }

        return title.count > 60 ? String(title.prefix(60)) : title
    }

    // MARK: - Price fetching

    private static func fetchPrice(from url: URL, completion: @escaping (String?) -> Void) {
        // Only attempt for known shopping domains to keep it fast
        let host = url.host ?? ""
        let shoppingDomains = ["amazon.com", "amazon.co.uk", "amazon.ca", "ebay.com",
                               "walmart.com", "target.com", "bestbuy.com", "etsy.com"]
        guard shoppingDomains.contains(where: { host.contains($0) }) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url, timeoutInterval: 5)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
                         forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }

            let price = extractPrice(from: html)
            DispatchQueue.main.async {
                completion(price)
            }
        }.resume()
    }

    // MARK: - Price extraction

    private static func extractPrice(from text: String) -> String? {
        let pattern = #"[\$£€¥]\s*\d{1,5}(?:[.,]\d{1,2})?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let range = Range(match.range, in: text)
        else { return nil }

        return String(text[range])
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: " ", with: "")
    }

    // MARK: - Shared storage

    private func saveToSharedDefaults(
        title: String?,
        price: String?,
        imageData: Data?,
        url: String?
    ) {
        let defaults = UserDefaults(suiteName: "group.utcs.PauseMindfulSpending")
        defaults?.set(title, forKey: "shared_item_name")
        defaults?.set(price, forKey: "shared_item_price")
        defaults?.set(imageData, forKey: "shared_item_image")
        defaults?.set(url, forKey: "shared_item_url")
        defaults?.set(true, forKey: "has_pending_shared_item")
        defaults?.synchronize()
    }

    // MARK: - Open main app

    private func openMainApp() {
        guard let url = URL(string: "pause://add-item") else {
            cancel()
            return
        }

        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                break
            }
            responder = responder?.next
        }

        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(
            domain: "com.pause.share",
            code: 0,
            userInfo: nil
        ))
    }
}
