import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers
import SystemConfiguration

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
        var extractedPlainText: String? = nil
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

            // Always accept plain text
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                    if let text = item as? String {
                        extractedPlainText = text.trimmingCharacters(in: .whitespacesAndNewlines)
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

            // Property list from Safari — contains actual page title, takes priority over plain text
            if provider.hasItemConformingToTypeIdentifier("com.apple.property-list") {
                group.enter()
                provider.loadItem(forTypeIdentifier: "com.apple.property-list") { item, _ in
                    if let dict = item as? [String: Any] {
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
            // Prefer plist title (Safari), fall back to plain text (Amazon app)
            let rawTitle = extractedTitle ?? extractedPlainText
            let cleanedTitle = Self.cleanTitle(rawTitle)

            if let urlString = extractedURL, let url = URL(string: urlString) {
                Self.fetchProductDetails(from: url) { htmlTitle, price, imageData in
                    let finalTitle = htmlTitle ?? cleanedTitle
                    self.saveToSharedDefaults(
                        title: finalTitle,
                        price: price,
                        imageData: imageData,
                        url: extractedURL
                    )
                    self.openMainApp()
                }
            } else {
                self.saveToSharedDefaults(
                    title: cleanedTitle,
                    price: nil,
                    imageData: nil,
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

        if title.count > 40 {
            let truncated = String(title.prefix(40))
            if let lastSpace = truncated.lastIndex(of: " ") {
                return String(truncated[..<lastSpace])
            }
            return truncated
        }

        return title
    }

    // MARK: - Fetch price and image from product page HTML

    private static func fetchProductDetails(
        from url: URL,
        completion: @escaping (String?, String?, Data?) -> Void  // title, price, imageData
    ) {
        var request = URLRequest(url: url, timeoutInterval: 8)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        session.dataTask(with: request) { data, response, error in

            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil, nil, nil)
                return
            }

            let price = extractPrice(from: html)
            
            let htmlTitle = extractTitle(from: html)

            let imageUrl = extractMainImageURL(from: html, originalURL: url)
            guard let imageUrlString = imageUrl,
                  let imgUrl = URL(string: imageUrlString) else {
                completion(htmlTitle, price, nil)
                return
            }

            URLSession.shared.dataTask(with: imgUrl) { imgData, _, _ in
                completion(htmlTitle, price, imgData)
            }.resume()

        }.resume()
    }

    private static func extractTitle(from html: String) -> String? {
        // Amazon puts the product title in id="productTitle"
        let patterns = [
            #"id="productTitle"[^>]*>\s*([^<]{5,}?)\s*<"#,
            #"<title>\s*Amazon\.com\s*:\s*([^<|]+)"#,
            #"<title>\s*([^<|:]{10,}?)\s*[\|:]"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(html.startIndex..., in: html)
            guard let match = regex.firstMatch(in: html, range: range),
                  match.numberOfRanges >= 2,
                  let titleRange = Range(match.range(at: 1), in: html) else { continue }
            let raw = String(html[titleRange])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let cleaned = cleanTitle(raw)
            if let cleaned = cleaned, cleaned.count > 5 { return cleaned }
        }

        return nil
    }

    // MARK: - Image extraction

    private static func extractMainImageURL(from html: String, originalURL: URL? = nil) -> String? {

        // Method 1: ASIN from URL + image ID from HTML
        if let originalURL = originalURL {
            let urlString = originalURL.absoluteString
            let asinPattern = #"/dp/([A-Z0-9]{10})"#
            if let regex = try? NSRegularExpression(pattern: asinPattern),
               let match = regex.firstMatch(
                in: urlString,
                range: NSRange(urlString.startIndex..., in: urlString)
               ),
               match.numberOfRanges >= 2,
               let asinRange = Range(match.range(at: 1), in: urlString) {

                let asin = String(urlString[asinRange])

                let imagePattern = #"\"([A-Za-z0-9\-_+]{10,})\._AC"#
                if let imgRegex = try? NSRegularExpression(pattern: imagePattern),
                   let imgMatch = imgRegex.firstMatch(
                    in: html,
                    range: NSRange(html.startIndex..., in: html)
                   ),
                   imgMatch.numberOfRanges >= 2,
                   let imgRange = Range(imgMatch.range(at: 1), in: html) {
                    let imageId = String(html[imgRange])
                    let constructed = "https://m.media-amazon.com/images/I/\(imageId)._AC_SL1000_.jpg"
                    return constructed
                }
            }
        }

        // Method 2: JSON image data embedded in page
        let jsonPatterns = [
            #""colorImages":\{"initial":\[.*?"hiRes":"(https://[^"]+)"#,
            #"'colorImages': \{'initial': \[.*?'hiRes': '(https://[^']+)'"#,
            #"ImageBlockATF.*?"hiRes":"(https://m\.media-amazon[^"]+\.jpg)"#,
            #"\"main\"\s*:\s*\{[^}]*"(https://m\.media-amazon[^"]+\.jpg)"#,
        ]

        for pattern in jsonPatterns {
            guard let regex = try? NSRegularExpression(
                pattern: pattern,
                options: [.dotMatchesLineSeparators]
            ) else { continue }
            let range = NSRange(html.startIndex..., in: html)
            guard let match = regex.firstMatch(in: html, range: range),
                  match.numberOfRanges >= 2,
                  let urlRange = Range(match.range(at: 1), in: html) else { continue }
            let url = String(html[urlRange])
            if url.hasPrefix("https://") { return url }
        }

        // Debug — show any ._AC image IDs present
        let acPattern = #"\"([A-Za-z0-9\-_+]{10,})\._AC"#
        if let acRegex = try? NSRegularExpression(pattern: acPattern) {
            let range = NSRange(html.startIndex..., in: html)
            var ids: [String] = []
            acRegex.enumerateMatches(in: html, range: range) { match, _, _ in
                guard let match = match, match.numberOfRanges >= 2,
                      let r = Range(match.range(at: 1), in: html) else { return }
                let id = String(html[r])
                if !ids.contains(id) { ids.append(id) }
            }
        }

        return nil
    }

    // MARK: - Price extraction

    private static func extractPrice(from text: String) -> String? {
        // Amazon sale price is in a-price-whole + a-price-fraction elements
        let salePricePattern = #"a-price-whole[^>]*>\s*(\d+)\s*<.*?a-price-fraction[^>]*>\s*(\d+)"#
        if let regex = try? NSRegularExpression(
            pattern: salePricePattern,
            options: [.dotMatchesLineSeparators]
        ),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           match.numberOfRanges == 3,
           let wholeRange = Range(match.range(at: 1), in: text),
           let fracRange = Range(match.range(at: 2), in: text) {
            let price = "\(String(text[wholeRange])).\(String(text[fracRange]))"
            return price
        }

        // Fallback: collect all prices, return lowest among most frequent
        let pattern = #"[\$£€¥]\s*(\d{1,5}(?:[.,]\d{1,2})?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)

        var prices: [Double] = []
        regex.enumerateMatches(in: text, range: range) { match, _, _ in
            guard let match = match,
                  match.numberOfRanges >= 2,
                  let r = Range(match.range(at: 1), in: text),
                  let val = Double(String(text[r]).replacingOccurrences(of: ",", with: "."))
            else { return }
            if val >= 1.0 { prices.append(val) }
        }

        guard !prices.isEmpty else { return nil }

        var frequency: [Double: Int] = [:]
        for p in prices { frequency[p, default: 0] += 1 }
        let maxFreq = frequency.values.max() ?? 0
        let candidates = frequency.filter { $0.value == maxFreq }.map { $0.key }
        let winner = candidates.min()

        guard let result = winner else { return nil }
        return result.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(result))
            : String(format: "%.2f", result)
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
        print("DEBUG saving - title:", title ?? "nil")
        print("DEBUG saving - price:", price ?? "nil")
        print("DEBUG saving - imageData bytes:", imageData?.count ?? 0)
        print("DEBUG suite:", defaults != nil ? "OK" : "FAILED")
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
