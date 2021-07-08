import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productsGraphQL = """
query products {
  products(first: 10, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail {
          url
        }
      }
    }
  }
}
""";

void main() {
  final HttpLink httpLink = HttpLink("https://vercel.saleor.cloud/graphql/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  var app = GraphQLProvider(client: client, child: MyApp());

  runApp(app);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(productsGraphQL),
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final productList = result.data?['products']['edges'];

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Products",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Expanded(
                  child: GridView.builder(
                itemCount: productList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (_, index) {
                  var product = productList[index]['node'];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.0),
                        width: 180,
                        height: 180,
                        child: Image.network(product['thumbnail']['url']),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          product['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("\$4.50")
                    ],
                  );
                },
              ))
            ],
          );
        },
      ),
    );
  }
}
