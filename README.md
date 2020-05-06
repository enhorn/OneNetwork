# OneNetwork

Minimalistic networking library with SwiftUI in mind.

- Build simple  UI components with 1:1 connection to views.
- Automatically parse to your `Codable` models from the response JSON.
- Predestine your network responses during development, making your `PreviewProvider` implementations network independent.
- Basic OAUth implementation.

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
        let request = URLRequest(url: url) // Apply any custom authentication if needed.
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

## OAuth

There is a standardized interface to perform OAuth authentication, where custom implementations can be supplied.
Google authentication for iOS is available prebuilt as an example.

### Code example

```swift
extension ArticlesNetwork {

    func login(onDone: @escaping (success: Bool) -> Void) {
        authenticate(
            with: OneGoogleOAuthLogin(
                clientID: "Your Google API app client ID",
                urlScheme: "Your Google API app URL scheme",
                scopes: ["API scope accesses that will be requested."]
            ),
            onLoggedIn: { [weak self] token in
                self?.save(token: token)
                onDone(success: true)
            },
            onFail: { _ in
                onDone(success: false)
            }
        )
    }

    func save(token: String) {
        // Or what ever you want to do with it.
    }

}
```

## Example app
The example iOS app is built with SwiftUI and is using predestined requests for network free previews, both basic and OAuth authentication, as well as pagination.
You will need to supply clientID & urlScheme from your API app, as well what API scopes it supports.
Uses the public example API from: https://reqres.in made by [@benhowdle89](https://github.com/benhowdle89)
