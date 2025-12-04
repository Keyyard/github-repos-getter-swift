//
//  ContentView.swift
//  swiftui-learn-1
//
//  Created by Trinh Minh Hieu on 4/12/25.
//

import SwiftUI

struct Repo: Identifiable, Codable { // it is Identifiable because we need to use it in a List
// Codable to decode JSON data
// Identifiable and Codable are both type protocols, we can declare multiple
    let id: Int
    let name: String
    let stargazers_count: Int
    let language: String?
    let html_url: String
    let fork: Bool
    }

struct ContentView: View {
    @State private var username = ""
    @State private var repos: [Repo] = []
    @State private var isLoading = false
    //State is a state management :)

    var body: some View {
        NavigationStack { // NatigationStack is used to create a navigation-based interface
            VStack(spacing: 20) { //VStack is used to arrange views vertically
                TextField("GitHub username", text: $username) // input
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)
                
                Button("Fetch repos") {
                    Task { await loadRepos() } // task is used to run asynchronous code
                    //if it is not async, we can just call loadRepos() like { loadRepos() }
                }
                .disabled(isLoading || username.isEmpty)
                
                if isLoading {
                    ProgressView("Loading…")
                }
                
                List(repos) { repo in //repo will automately be understood as element in repos array because there is only one parameter in the closure
// for multiple, it would be like: List(array1, array 2) { item1 in array1, item2 in array2 }
                    VStack(alignment: .leading) {
                        Text(repo.name)
                            .font(.headline)
                        HStack { // HStack is used to arrange views horizontally
                            Text("Stars: \(repo.stargazers_count)")
                            Spacer()
                            Text(repo.language ?? "—")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("GitHub Repos")
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func loadRepos() async {
        isLoading = true
        defer { isLoading = false }
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let url = URL(string: "https://api.github.com/users/\(username)/repos")!
        var request = URLRequest(url: url)
        request.setValue("swiftui-app", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let allRepos = try JSONDecoder().decode([Repo].self, from: data)
            repos = allRepos.filter { !$0.fork }
            .sorted { $0.stargazers_count > $1.stargazers_count }
        } catch {
            print("Error: \(error)")
        }
    }
}

/*
HStack & VStack is like div in HTML, with direction
styling can be done with modifiers, like .font(), .padding(), .foregroundStyle(), etc in chain instead of css styles..


guard is like if else for a variable in short, without using guard it be like:
let input, if input is nil { return } else { use input }

@ is used for property wrappers, like @State, @Binding, @ObservedObject, etc
They are used to manage state and data flow in SwiftUI

popular wrappers:
@State: for local state management within a view
@Binding: for passing state between views
@ObservedObject: for observing changes in a data model

*/



#Preview {
    ContentView()
}
