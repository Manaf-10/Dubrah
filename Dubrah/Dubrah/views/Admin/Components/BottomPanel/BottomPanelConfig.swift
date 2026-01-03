//
//  BottomPanelConfig.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

struct BottomPanelAction {
    let title: String
    let style: Style
    let handler: () -> Void

    enum Style {
        case primary
        case outline
        case destructive
    }
}

struct BottomPanelConfig {
    let actions: [BottomPanelAction]
}
