# OneNetwork

Minimalistic networking library with SwiftUI in mind.

- Build simple UI components with 1:1 network connection to views.
- Automatically parse to your `Codable` models from the response JSON.
- Predestine your network responses during development, making your `PreviewProvider` implementations network independent. No need to muck about with complex mocking solutions for unit & UI tests either.
- OAUth authentication, with predefined authentications for Google & Spotify, both available as login examples in the bundled Example app (needs Client ID etc.).
- Support for Async / Await.
- Example app with implementations of network requests and and different authentication options.

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

## Async / Await

OneNetwork also support Async / Await, which can be used outside of SwiftUI.
Here we see how the type is inferred from the result type of the fetch function.

```swift
class AsyncNetwork: OneNetwork {

    func fetchItems() async -> [Item]? {
        await get(
            request: URLRequest(
                url: URL(string: "your endpoint url")
            )
        )
    }

}
```

## OAuth

There is a standardized interface to perform OAuth authentication on iOS, where custom implementations can be supplied.
Both Google and Spotify authentications for iOS is available prebuilt.

### Code example with Google OAuth

```swift
class AuthenticationNetwork: OneNetwork {

    func login(onDone: @escaping (_ success: Bool) -> Void) {
        authenticate(
            with: OneGoogleOAuthLogin(
                clientID: "Your Google API app client ID",
                urlScheme: "Your Google API app URL scheme",
                scopes: ["API scope accesses that will be requested."]
            ),
            onLoggedIn: { [weak self] session in
                /// Save the `session` for future use.
                onDone(true)
            },
            onFail: { error in
                onDone(false)
            }
        )
    }

}
```

### Code example with Spotify OAuth

```swift
class AuthenticationNetwork: OneNetwork {

    func login(onDone: @escaping (_ success: Bool) -> Void) {
        authenticate(
                with: OneSpotifyOAuthLogin(
                clientID: "Your client ID",
                clientSecret: "Your client secret",
                redirectURI: "Your redirect URI",
                scopes: ["API scope accesses that will be requested."]
            ),
            onLoggedIn: { [weak self] session in
                /// Save the `session` for future use.
                onDone(true)
            },
            onFail: { error in
                onDone(false)
            }
        )
    }

}
```

## Example app
The example iOS app is built with SwiftUI and is using predestined requests for network free previews, both basic and OAuth authentication, as well as pagination.
You will need to supply clientID & urlScheme from your API app, as well what API scopes it supports.
Uses the public example API from: https://reqres.in made by [@benhowdle89](https://github.com/benhowdle89)
