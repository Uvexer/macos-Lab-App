import SwiftUI

class FileHandler {
    func selectFile(completion: (URL) -> Void) {
        let dialog = NSOpenPanel()
        dialog.title = "Выберите CSV файл"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canChooseFiles = true
        dialog.allowedContentTypes = [.commaSeparatedText]
        
        if dialog.runModal() == .OK, let url = dialog.url {
            completion(url)
        }
    }
    
    func loadFileContents(at url: URL, completion: (String) -> Void) {
        do {
            let contents = try String(contentsOf: url)
            completion(contents)
        } catch {
            print("Error reading file: \(error)")
        }
    }
}

