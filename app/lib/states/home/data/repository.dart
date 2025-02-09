import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:podiinyk/core/data/types/document.dart';
import 'package:podiinyk/core/data/types/field.dart';
import 'package:podiinyk/core/data/types/object_map.dart';
import 'package:podiinyk/core/data/user_doc_ref.dart';
import 'package:podiinyk/core/domain/types/date.dart';
import 'package:podiinyk/core/domain/user/state.dart';

import '../domain/entities/event.dart';
import '../domain/entities/info.dart';
import '../domain/entities/message.dart';
import '../domain/entities/student.dart';
import '../domain/entities/subject.dart';


// do: remove duplication
// do: prevent unnecessary reads
// do: failures
class HomeRepository {
	const HomeRepository({required this.groupId});

	final String groupId;

	Future<void> addEvent(Event event) async {
		await _ref(Document.events).update({
			event.id: {
				Field.name.name: event.name,
				if (event.subject != null) Field.subject.name: event.subject?.id,
				Field.date.name: event.date.value,
				Field.hasTime.name: event.date.hasTime,
				if (event.note != null) Field.note.name: event.note
			}
		});
	}

	Future<void> addSubject(Subject subject) async {
		await Future.wait([
			_ref(Document.subjects).update({
				subject.id: {
					Field.name.name: subject.name,
					Field.isCommon.name: subject.isCommon
				}
			}),
			_subjectDetailsRef(subject).set({
				Field.info.name: const <String, ObjectMap>{}
			})
		]);
	}

	Future<void> addSubjectInfo(Subject subject, Info item) async {
		await _subjectDetailsRef(subject).update({
			'${Field.info.name}.${item.id}': {
				Field.name.name: item.name,
				Field.content.name: item.content
			}
		});
	}

	Future<void> addInfo(Info item) async {
		await _ref(Document.info).update({
			item.id: {
				Field.name.name: item.name,
				Field.content.name: item.content
			}
		});
	}

	Future<void> addMessage(Message message) async {
		await _ref(Document.messages).update({
			message.id: {
				Field.name.name: message.name,
				Field.content.name: message.content,
				Field.author.name: message.author.id,
				Field.date.name: message.date.value
			}
		});
	}

	Future<Iterable<Event>> events() async {
		late final DocumentSnapshot<ObjectMap> snapshot;
		late final Iterable<Subject> subjects;
		await Future.wait([
			_ref(Document.events).get().then((s) => snapshot = s),
			this.subjects().then((s) => subjects = s)
		]);

		return snapshot.data()!.entries.map((entry) => Event(
			id: entry.key,
			name: entry.value[Field.name.name],
			subject: entry.value.containsKey(Field.subject.name) ?
				subjects.firstWhere((s) => s.id == entry.value[Field.subject.name]) :
				null,
			date: Date(
				(entry.value[Field.date.name] as Timestamp).toDate(),
				hasTime: entry.value[Field.hasTime.name]
			),
			note: entry.value[Field.note.name]
		));
	}

	Future<Iterable<Subject>> subjects() async {
		final snapshot = await _ref(Document.subjects).get();
		return snapshot.data()!.entries.map((entry) => Subject(
			id: entry.key,
			name: entry.value[Field.name.name],
			isCommon: entry.value[Field.isCommon.name]
		));
	}

	Future<SubjectDetails> subjectDetails(Subject subject) async {
		late final DocumentSnapshot<ObjectMap> snapshot;
		Iterable<Student>? students;
		await Future.wait([
			_subjectDetailsRef(subject).get().then((s) => snapshot = s),
			if (!subject.isCommon) this.students().then((s) => students = s)
		]);

		final infoMap = Map<String, ObjectMap>.from(snapshot.data()![Field.info.name]);
		final info = infoMap.entries.map((entry) => Info(
			id: entry.key,
			name: entry.value[Field.name.name],
			subject: subject,
			content: entry.value[Field.content.name]
		));

		return SubjectDetails(
			info: info,
			students: students?.where((s) => s.chose(subject))
		);
	}

	Future<Iterable<Info>> info() async {
		final snapshot = await _ref(Document.info).get();
		return snapshot.data()!.entries.map((entry) => Info(
			id: entry.key,
			name: entry.value[Field.name.name],
			content: entry.value[Field.content.name]
		));
	}

	Future<Iterable<Message>> messages() async {
		late final DocumentSnapshot<ObjectMap> snapshot;
		late final Iterable<Student> students;
		await Future.wait([
			_ref(Document.messages).get().then((s) => snapshot = s),
			this.students().then((s) => students = s)
		]);

		return snapshot.data()!.entries.map((entry) => Message(
			id: entry.key,
			name: entry.value[Field.name.name],
			content: entry.value[Field.content.name],
			author: students.firstWhere((s) => s.id == entry.value[Field.author.name]),
			date: Date((entry.value[Field.date.name] as Timestamp).toDate())
		));
	}

	Future<Iterable<Student>> students() async {
		final snapshot = await _ref(Document.students).get();
		return snapshot.data()!.entries.map((entry) {
			final name = entry.value[Field.name.name] as List<dynamic>;
			return Student(
				id: entry.key,
				firstName: name.first,
				lastName: name.last,
				chosenSubjectIds: Set<String>.from(entry.value[Field.chosenSubjects.name])
			);
		});
	}

	Future<StudentDetails> studentDetails(Student student) async {
		late final DocumentSnapshot<ObjectMap> snapshot;
		late final Iterable<Subject> subjects;
		await Future.wait([
			userDocRef(student.id).get().then((s) => snapshot = s),
			this.subjects().then((s) => subjects = s)
		]);

		final map = snapshot.data()!;
		final subjectIds = map[Field.chosenSubjects.name] as List<dynamic>;

		return StudentDetails(
			info: map[Field.info.name],
			subjects: subjects.where((s) => subjectIds.contains(s.id))
		);
	}

	Future<void> deleteEvent(Event event) async {
		await _ref(Document.events).update({
			event.id: FieldValue.delete()
		});
	}

	// think: also delete from chosenSubjects
	Future<void> deleteSubject(Subject subject) async {
		final eventsRef = _ref(Document.events);
		final eventsSnapshot = await eventsRef.get();
		final eventEntries = eventsSnapshot.data()!.entries.where(
			(e) => e.value[Field.subject.name] == subject.id
		);

		await Future.wait([
			_ref(Document.subjects).update({
				subject.id: FieldValue.delete()
			}),
			_subjectDetailsRef(subject).delete(),
			eventsRef.update({
				for (final entry in eventEntries) entry.key: FieldValue.delete()
			})
		]);
	}

	Future<void> clearSubjects() async {
		final eventsRef = _ref(Document.events);
		final eventsSnapshot = await eventsRef.get();
		final eventEntries = eventsSnapshot.data()!.entries.where(
			(e) => e.value[Field.subject.name] != null
		);

		await Future.wait([
			_ref(Document.subjects).set({}),
			eventsRef.update({
				for (final entry in eventEntries) entry.key: FieldValue.delete()
			})
		]);
	}

	Future<void> deleteSubjectInfo(Subject subject, Info item) async {
		await _subjectDetailsRef(subject).update({
			'${Field.info.name}.${item.id}': FieldValue.delete()
		});
	}

	Future<void> deleteInfo(Info item) async {
		await _ref(Document.info).update({
			item.id: FieldValue.delete()
		});
	}

	Future<void> deleteMessage(Message message) async {
		await _ref(Document.messages).update({
			message.id: FieldValue.delete()
		});
	}

	DocumentReference<ObjectMap> _ref(Document document) => document.ref(groupId);

	DocumentReference<ObjectMap> _subjectDetailsRef(Subject subject) {
		return _ref(Document.subjects).collection('details').doc(subject.id);
	}
}

final homeRepositoryProvider = Provider<HomeRepository?>((ref) {
	final groupId = ref.watch(userProvider).groupId;
	return groupId != null ? HomeRepository(groupId: groupId) : null;
});
