import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  // 構建小部件的方法
  // 這個方法返回一個 ChangeNotifierProvider，小部件樹的根
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAppState>(
      // 創建 MyAppState 的實例
      create: (context) => MyAppState(),
      child: MaterialApp(
        // 標題
        title: 'Flutter Demo-App',
        // 主題設置，使用顏色方案生成
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        // 首頁
        home: MyHomePage(),
      ),
    );
  }
}

/// MyAppState 是一個 ChangeNotifier，管理 APP 的狀態
///  * [current] 是一個隨機的英文單字
///  * [favorites] 是一個英文單字的收藏列表
///  * [getNext] 改變 [current] 的值
///  * [toggleFavorite] 在 [favorites] 中 toggle [current] 的值
class MyAppState extends ChangeNotifier {
  /// 產生一個隨機的英文單字
  var current = WordPair.random();

  /// 改變 [current] 的值
  void getNext() {
    current = WordPair.random();
    /// 監聽器通知其他元件更新
    notifyListeners();
  }

  /// 單字收藏列表
  var favorites = <WordPair>[];

  /// 在 [favorites] 中 toggle [current] 的值
  /// 如果 [favorites] 中已經包含 [current]，則將其 remove
  /// 否則，將 [current] add 到 [favorites] 中
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page = switch (selectedIndex) {
      0 => GeneratorPage(),
      1 => FavoritesPage(),
      _ => Placeholder(),
      // _ => throw UnimplementedError('no widget for $selectedIndex'),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 650,
                  destinations: [
                      NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon = appState.favorites.contains(pair)
      ? Icons.favorite
      : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(
          //   'A random A idea:',
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Colors.pink,
          //     backgroundColor: Colors.yellow,
          //   ),
          // ),
          BigCard(pair: pair),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // print('button pressed!');
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          '尚未收藏任何單字 !',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text('你已經收藏 '
              '${appState.favorites.length} 筆單字~'),
        ),
        for(var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    print(pair);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}