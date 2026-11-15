/// Pantalla principal (shell) de MyMusic con navegación por pestañas.
library mymusic.features.ui_shell.presentation.ui_shell_page;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymusic/features/ui_shell/domain/ui_shell_state.dart';
import 'package:mymusic/features/ui_shell/presentation/tabs/home_tab_page.dart';
import 'package:mymusic/features/ui_shell/presentation/tabs/library_tab_page.dart';
import 'package:mymusic/features/ui_shell/presentation/tabs/player_tab_page.dart';
import 'package:mymusic/features/ui_shell/presentation/tabs/playlists_tab_page.dart';
import 'package:mymusic/features/ui_shell/presentation/tabs/profile_tab_page.dart';
import 'package:mymusic/features/ui_shell/presentation/tabs/search_tab_page.dart';
import 'package:mymusic/features/ui_shell/presentation/ui_shell_providers.dart';

/// Íconos de Material disponibles para cada pestaña.
final Map<String, IconData> _tabIcons = {
  'home': Icons.home,
  'library': Icons.library_music,
  'playlists': Icons.playlist_play,
  'search': Icons.search,
  'player': Icons.play_circle,
  'auth': Icons.person,
};

/// Página shell con NavigationBar y las pestañas de la aplicación.
class UiShellPage extends ConsumerStatefulWidget {
  const UiShellPage({super.key});

  @override
  ConsumerState<UiShellPage> createState() => _UiShellPageState();
}

class _UiShellPageState extends ConsumerState<UiShellPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uiShellNotifierProvider.notifier).loadTabs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uiShellNotifierProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(uiShellNotifierProvider.notifier).clearError(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final tabs = state.tabs;
    if (tabs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay pestañas disponibles.')),
      );
    }
    final currentIndex = state.currentTabIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[currentIndex].title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: tabs.map((tab) => _tabPage(tab)).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(uiShellNotifierProvider.notifier).changeTab(index);
        },
        destinations: tabs.map((tab) {
          return NavigationDestination(
            icon: Icon(_tabIcons[tab.id] ?? Icons.circle, size: 22),
            selectedIcon: Icon(
              _tabIcons[tab.id] ?? Icons.circle,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: tab.title,
          );
        }).toList(),
      ),
    );
  }

  /// Página individual de cada pestaña de la aplicación.
  Widget _tabPage(ShellTab tab) {
    switch (tab.id) {
      case 'home':
        return const HomeTabPage();
      case 'library':
        return const LibraryTabPage();
      case 'playlists':
        return const PlaylistsTabPage();
      case 'search':
        return const SearchTabPage();
      case 'player':
        return const PlayerTabPage();
      case 'auth':
        return const ProfileTabPage();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_tabIcons[tab.id] ?? Icons.circle,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                tab.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
    }
  }
}
