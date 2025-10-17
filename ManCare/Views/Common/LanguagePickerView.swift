//
//  LanguagePickerView.swift
//  ManCare
//
//  Language picker component for in-app language switching
//

import SwiftUI

struct LanguagePickerView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Language")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Show available languages (English + device locale if different)
            ForEach(LocalizationUtils.availableLanguagesForPicker()) { language in
                LanguageOptionRow(
                    language: language,
                    isSelected: localizationManager.currentLanguage == language.rawValue
                ) {
                    // Switch language
                    localizationManager.setLanguage(language)
                }
            }
        }
        .padding()
    }
}

struct LanguageOptionRow: View {
    let language: LocalizationManager.Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(language.nativeName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct LanguagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        LanguagePickerView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

