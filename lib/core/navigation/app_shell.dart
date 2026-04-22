import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/hive_learning_item_repository.dart';
import '../../features/add_data/presentation/bloc/add_data_bloc.dart';
import '../../features/add_data/presentation/pages/add_data_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/learn/presentation/bloc/learn_bloc.dart';
import '../../features/learn/presentation/bloc/learn_event.dart';
import '../../features/learn/presentation/pages/learn_page.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';
import '../../features/library/presentation/bloc/library_event.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/revision/presentation/bloc/review_queue_bloc.dart';
import '../../features/revision/presentation/bloc/revision_bloc.dart';
import '../../features/revision/presentation/bloc/revision_event.dart';
import '../../features/revision/presentation/pages/revision_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import 'app_routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int _homeIndex = 0;
  static const int _libraryIndex = 1;
  static const int _learnIndex = 2;
  static const int _revisionIndex = 3;
  static const int _searchIndex = 4;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      <GlobalKey<NavigatorState>>[
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
      ];

  int _selectedIndex = _homeIndex;

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_selectedIndex].currentState;

    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    if (_selectedIndex != _homeIndex) {
      setState(() => _selectedIndex = _homeIndex);
      return false;
    }

    return false;
  }

  Future<void> _openAddDataPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.add),
        builder: (BuildContext context) {
          return BlocProvider<AddDataBloc>(
            create: (_) => AddDataBloc(
              repository: context.read<HiveLearningItemRepository>(),
            ),
            child: const AddDataPage(),
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    context.read<LibraryBloc>().add(const LoadLibrary());
    context.read<LearnBloc>().add(const LoadLearningItems());
    context.read<RevisionBloc>().add(const LoadRevisionItems());
    context.read<ReviewQueueBloc>().add(const LoadDueItems());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == _homeIndex,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            _TabNavigator(
              navigatorKey: _navigatorKeys[_homeIndex],
              routeName: AppRoutes.home,
              child: const HomePage(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[_libraryIndex],
              routeName: AppRoutes.library,
              child: const LibraryPage(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[_learnIndex],
              routeName: AppRoutes.learn,
              child: const LearnPage(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[_revisionIndex],
              routeName: AppRoutes.revision,
              child: const RevisionPage(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[_searchIndex],
              routeName: AppRoutes.search,
              child: const SearchPage(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddDataPage,
          tooltip: 'Add data',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            if (index == _selectedIndex) {
              _navigatorKeys[index].currentState?.popUntil(
                (Route<dynamic> route) => route.isFirst,
              );
              return;
            }

            setState(() => _selectedIndex = index);
            if (index == _homeIndex) {
              context.read<ReviewQueueBloc>().add(const LoadDueItems());
            }
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.refresh_outlined),
              selectedIcon: Icon(Icons.refresh),
              label: 'Revision',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.routeName,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final String routeName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: routeName, // ✅ IMPORTANT
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => child,
        );
      },
    );
  }
}