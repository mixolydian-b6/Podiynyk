import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:podiinyk/main.dart';

import 'package:podiinyk/states/home/domain/entities/event.dart';
import 'package:podiinyk/states/home/domain/entities/subject.dart';

import '../../data/user_repository.dart';
import '../id.dart';
import 'user.dart';


final initialUserProvider = StateProvider<User?>((ref) => null);


class UserNotifier extends StateNotifier<User> {
	UserNotifier({
		required User initial,
		required this.repository,
		required this.appStateController
	}) :
		super(initial);

	final UserRepository repository;
	final StateController<AppState> appStateController;

	Future<void> createGroup() async {
		final id = newId(user: state);
		final user = state.copyWith(
			info: state.info,
			groupId: id,
			irrelevantEventIds: <String>{},
			chosenSubjectIds: <String>{}
		);
		await repository.createGroup(user: user);
		state = user;
	}

	Future<void> joinGroup(String id) async {
		final user = state.copyWith(
			info: state.info,
			groupId: id,
			irrelevantEventIds: <String>{},
			chosenSubjectIds: <String>{}
		);
		await repository.joinGroup(user: user);
		state = user;
	}

	Future<void> toggleEventIsRelevant(Event event) async {
		final ids = state.irrelevantEventIds!;

		if (state.eventIsRelevant(event)) {
			ids.add(event.id);
		}
		else {
			ids.remove(event.id);
		}

		await _update(
			info: state.info,
			irrelevantEventIds: ids,
			chosenSubjectIds: state.chosenSubjectIds
		);
	}

	Future<void> toggleSubjectIsStudied(Subject subject) async {
		final ids = state.chosenSubjectIds!;

		if (!state.studies(subject)) {
			ids.add(subject.id);
		}
		else {
			ids.remove(subject.id);
		}

		await _update(
			info: state.info,
			irrelevantEventIds: state.irrelevantEventIds,
			chosenSubjectIds: ids
		);
	}

	Future<void> update({String? firstName, String? lastName, required String? info}) => _update(
		firstName: firstName,
		lastName: lastName,
		info: info,
		irrelevantEventIds: state.irrelevantEventIds,
		chosenSubjectIds: state.chosenSubjectIds
	);

	Future<void> _update({
		String? firstName,
		String? lastName,
		required String? info,
		required Set<String>? irrelevantEventIds,
		required Set<String>? chosenSubjectIds
	}) async {
		final user = state.copyWith(
			firstName: firstName,
			lastName: lastName,
			info: info,
			groupId: state.groupId,
			irrelevantEventIds: irrelevantEventIds,
			chosenSubjectIds: chosenSubjectIds
		);
		await repository.update(user);
		state = user;
	}

	Future<void> leaveGroup() async {
		await repository.leaveGroup(user: state);
		state = state.copyWith(
			info: state.info,
			groupId: null,
			irrelevantEventIds: null,
			chosenSubjectIds: null
		);
		appStateController.state = AppState.identification;
	}

	Future<void> signOut() async {
		await FirebaseAuth.instance.signOut();
		appStateController.state = AppState.auth;
	}

	Future<void> deleteAccount() async {
		await repository.deleteAccount(state);
		appStateController.state = AppState.auth;
	}
}

final userProvider = StateNotifierProvider<UserNotifier, User>(
	(ref) => UserNotifier(
		initial: ref.watch(initialUserProvider)!,
		repository: ref.watch(userRepositoryProvider),
		appStateController: ref.watch(appStateProvider.notifier)
	)
);
