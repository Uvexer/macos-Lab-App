import SwiftUI

struct FileSelectButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Выбрать файл")
                .fontWeight(.medium)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

