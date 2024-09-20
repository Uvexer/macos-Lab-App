import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                FileSelectButton {
                    withAnimation {
                        viewModel.selectFile()
                    }
                }

                ExperimentDurationView(duration: viewModel.experimentDuration)

                DataListView(data: viewModel.data)

                NavigationButtonsView(data: viewModel.data, computeFFT: viewModel.computeFFT)
            }
        }
    }
}

