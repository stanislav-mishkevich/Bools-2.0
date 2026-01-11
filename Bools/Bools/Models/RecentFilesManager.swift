//
//  RecentFilesManager.swift
//  Bools
//
//  Управление списком недавних файлов
//

import Foundation
import Combine

class RecentFilesManager: ObservableObject {
    @Published var recentFiles: [URL] = []
    
    private let userDefaultsKey = "BoolsRecentFiles"
    private let maxRecentFiles = 10
    
    init() {
        loadRecentFiles()
    }
    
    func addRecentFile(_ url: URL) {
        // Удаляем дубликаты
        recentFiles.removeAll { $0 == url }
        
        // Добавляем в начало списка
        recentFiles.insert(url, at: 0)
        
        // Ограничиваем количество
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        saveRecentFiles()
    }
    
    func removeRecentFile(_ url: URL) {
        recentFiles.removeAll { $0 == url }
        saveRecentFiles()
    }
    
    func clearRecentFiles() {
        recentFiles.removeAll()
        saveRecentFiles()
    }
    
    private func loadRecentFiles() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            let bookmarks = try JSONDecoder().decode([Data].self, from: data)
            recentFiles = bookmarks.compactMap { bookmarkData -> URL? in
                var isStale = false
                do {
                    let url = try URL(resolvingBookmarkData: bookmarkData, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    return isStale ? nil : url
                } catch {
                    return nil
                }
            }
        } catch {
            print("Ошибка загрузки недавних файлов: \(error)")
        }
    }
    
    private func saveRecentFiles() {
        let bookmarks = recentFiles.compactMap { url -> Data? in
            do {
                return try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            } catch {
                print("Ошибка создания bookmark для \(url): \(error)")
                return nil
            }
        }
        
        do {
            let data = try JSONEncoder().encode(bookmarks)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Ошибка сохранения недавних файлов: \(error)")
        }
    }
}
