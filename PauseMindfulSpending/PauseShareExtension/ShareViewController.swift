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
        var extractedPrice: String? = nil
        var extractedImageData: Data? = nil
        var extractedURL: String? = nil

        for provider in attachments {

            // URL — parse title and try to extract price from page title
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
                    if let url = item as? URL {
                        extractedURL = url.absoluteString
                        // try to get product name in the URL or page title
                    }
                    group.leave()
                }
            }

            // Plain text — page title or a copied price
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                    if let text = item as? String {
                        // Try to pull a price out of the text (e.g. "$24.99")
                        if let price = Self.extractPrice(from: text) {
                            extractedPrice = price
                        }
                        // Use the text as the item name if we don't have one yet
                        if extractedTitle == nil {
                            extractedTitle = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    group.leave()
                }
            }

            // Image
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

            // Property list (Safari sends this with page title + URL together)
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
            self.saveToSharedDefaults(
                title: extractedTitle,
                price: extractedPrice,
                imageData: extractedImageData,
                url: extractedURL
            )
            self.openMainApp()
        }
    }

    // MARK: - Price extraction

    // Looks for patterns like $24.99, £12, €8.50 in a string
    private static func extractPrice(from text: String) -> String? {
        let pattern = #"[\$£€¥]\s*\d+(?:[.,]\d{1,2})?"#
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
        // IMPORTANT: Replace "group.com.yourcompany.pause" with your actual
        // App Group identifier (set up in Signing & Capabilities for both
        // the main app target AND this extension target)
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
        // Deep link URL — register "pause://" as a URL scheme in your main
        // app's Info.plist under URL Types
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
