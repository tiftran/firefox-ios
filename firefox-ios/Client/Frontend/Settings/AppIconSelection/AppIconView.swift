// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Common

struct AppIconView: View, ThemeApplicable {
    let appIcon: AppIcon
    let isSelected: Bool
    let windowUUID: WindowUUID

    let setAppIcon: (AppIcon) -> Void

    // MARK: - Theming
    // FIXME FXIOS-11472 Improve our SwiftUI theming
    @Environment(\.themeManager)
    var themeManager
    @State private var themeColors: ThemeColourPalette = LightTheme().colors

    struct UX {
        static let checkedCircleImageIdentifier = "checkmark.circle.fill"
        static let uncheckedCircleImageIdentifier = "circle"
        static let cornerRadius: CGFloat = 10
        static let itemPadding: CGFloat = 10
        static let appIconSize: CGFloat = 50
        static let appIconBorderWidth: CGFloat = 1
    }

    var selectionImageIdentifier: String {
        return isSelected
               ? UX.checkedCircleImageIdentifier
               : UX.uncheckedCircleImageIdentifier
    }

    var body: some View {
        Group {
            if let image = UIImage(named: appIcon.imageSetAssetName) {
                Button(action: { setAppIcon(appIcon) }) {
                    HStack {
                        Image(systemName: selectionImageIdentifier)
                            .padding(.trailing, UX.itemPadding)
                            .tint(themeColors.actionPrimary.color)
                            .accessibilityLabel("TODO") // TODO FXIOS-11471 strings

                        Image(uiImage: image)
                            .resizable()
                            .frame(width: UX.appIconSize, height: UX.appIconSize)
                            .cornerRadius(UX.cornerRadius)
                            .overlay(
                                // Add rounded border
                                RoundedRectangle(cornerRadius: UX.cornerRadius)
                                    .stroke(themeColors.borderPrimary.color, lineWidth: UX.appIconBorderWidth)
                            )
                            .padding(.trailing, UX.itemPadding)
                            .accessibilityLabel("TODO") // TODO FXIOS-11471 strings

                        Text(appIcon.displayName)
                            .tint(themeColors.textPrimary.color)

                        Spacer()
                    }
                    .padding(.all, UX.itemPadding)
                }
                .background(Color.clear)
            } else {
                // TODO FXIOS-11475 Add placeholder image and FXIOS-11471 image accessibility label strings
                Text("No image")
                    .tint(themeColors.layer1.color)
            }
        }
        .onAppear {
            applyTheme(theme: themeManager.getCurrentTheme(for: windowUUID))
        }
        .onReceive(NotificationCenter.default.publisher(for: .ThemeDidChange)) { notification in
            guard let uuid = notification.windowUUID, uuid == windowUUID else { return }
            applyTheme(theme: themeManager.getCurrentTheme(for: windowUUID))
        }
    }

    func applyTheme(theme: Theme) {
        self.themeColors = theme.colors
    }
}
