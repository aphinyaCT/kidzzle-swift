//
//  HistoryLabelText.swift
//  Kidzzle
//
//  Created by aynnipa on 3/5/2568 BE.
//

import SwiftUI

struct HistoryLabelText: View {
   let title: String
   let value: String
   var sfIcon: String

   var body: some View {
       VStack(alignment: .leading, spacing: 4) {
           HStack(spacing: 6) {
               Image(systemName: sfIcon)
                   .font(.system(size: 16))
                   .foregroundColor(.jetblack)

               Text(title)
                   .font(customFont(type: .bold, textStyle: .body))
                   .foregroundColor(.jetblack)
           }

           Text(value)
               .font(customFont(type: .regular, textStyle: .body))
               .foregroundColor(.jetblack)
       }
   }
}
