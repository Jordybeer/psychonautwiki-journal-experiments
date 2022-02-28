import SwiftUI

struct SearchTab: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sortedSubstances) { substance in
                    Text(substance.nameUnwrapped)
                }
            }
            .navigationTitle("Substances")
        }
        .searchable(text: $viewModel.searchText)
    }
}

struct SearchTab_Previews: PreviewProvider {
    static var previews: some View {
        SearchTab(viewModel: SearchTab.ViewModel(isPreview: true))
    }
}
