import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'states/authentication/authentication.dart';
import 'states/home/presentation/home.dart';
import 'states/identification/identification.dart';
import 'states/loading/loading.dart';


void main() async {
	runApp(const ProviderScope(child: App()));
}


enum AppState {
	loading,
	auth,
	// think: rename
	identification,
	home
}

final appStateProvider = StateProvider<AppState>((ref) => AppState.loading);

class App extends StatelessWidget {
	const App();

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Подійник',
			// do: remove after theming
			darkTheme: ThemeData(
				useMaterial3: true,
				colorScheme: const ColorScheme.dark(),
				canvasColor: const Color(0xff1a1a1a),
				snackBarTheme: const SnackBarThemeData(backgroundColor: Color(0xff333333))
			),
			home: Consumer(builder: (context, ref, _) {
				switch (ref.watch(appStateProvider)) {
					case AppState.loading:
						return const Loading();
					case AppState.auth:
						return const Authentication();
					case AppState.identification:
						return const Identification();
					case AppState.home:
						return const Home();
				}
			})
		);
	}
}
