# OneNetwork

Minimalistic networking library with SwiftUI in mind.

- Build simple  UI components with 1:1 connection to views.
- Automatically parse to your `Codable` models from the response JSON.
- Predestine your network responses during development, making your `PreviewProvider` implementations network independent.

## Example usage
In a view we'd like to list some articles, we have already created our model that fulfills `Codable` & `Identifiable`, so we head straight on the network,

### The Network Implementation
```swift
class ArticlesNetwork: OneNetwork {

    @Published private(set) var articles: [Article] = [] {
        willSet { objectWillChange.send() }
    }

    func updateArticleList() {
        let url = URL(string: "your endpoint url")
        let request = URLRequest(url: url) // Apply authentication if needed.
        get(request: request) { [weak self] (result: [Article]?) in
            self?.articles = result ?? []
        }
    }

}
```

### Inside the View

```swift
struct ContentView: View {

    @ObservedObject var network: ArticlesNetwork

    var body: some View {
        List(network.articles) { article in
            Text(article.title)
        }.onAppear(perform: self.network.updateArticleList)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // By supplying a predestined cache here,
        // the view will be able to behave like it is networking like normal.
        ContentView(network: ArticlesNetwork(cache: .predestinedArticlesCache))
    }
}
```

## Example app
The example macOS app built with SwiftUI included, to show how little is needed to get it up and running.
Requires API key from here: https://dictionaryapi.com/products/api-collegiate-thesaurus
