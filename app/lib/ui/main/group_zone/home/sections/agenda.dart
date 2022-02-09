import 'package:flutter/material.dart';

import 'package:podiynyk/storage/cloud.dart' show Cloud, Subjects;
import 'package:podiynyk/storage/entities/subject.dart';
import 'package:podiynyk/storage/local.dart';
import 'package:podiynyk/storage/entities/event.dart';

import 'section.dart';
import 'entity_pages/event.dart';
import 'new_entity_pages/event.dart';


class AgendaSectionCloudData {
	// todo: completely redo storing entities
	final subjects = Cloud.subjectsWithEvents.then((subjects) {
		final unfollowedEssences = Local.storedEntities<SubjectEssence>(DataBox.unfollowedSubjects);
		return subjects.where((subject) =>
			!unfollowedEssences.contains(subject.essence)
		).toList();
	});
	
	Future<List<Event>> get events => subjects.then((subjects) => subjects.events);
}


class AgendaSection extends CloudSection {
	static const name = "agenda";
	static const icon = Icons.import_contacts;

	AgendaSection() : super(AgendaSectionCloudData());

	@override
	String get sectionName => name;
	@override
	IconData get sectionIcon => icon;

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<List<Event>>(
			future: cloudData.events,
			builder: (context, snapshot) {
				// todo: what is shown while awaiting
				if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Icon(icon));
				// if (snapshot.hasError) print(snapshot.error);  // todo: consider handling

				return ListView(
					children: [
						for (final entity in snapshot.data!) EventTile(
							entity,
							showSubject: true
						),
						const ListTile()
					],
				);
			}
		);
	}

	// Widget addEntityButton(BuildContext context) => const AddEventButton();
}


class EventTile extends StatelessWidget {
	final Event _event;
	final bool showSubject;

	const EventTile(this._event, {required this.showSubject});

	@override
	Widget build(BuildContext context) {
		return ListTile(
			title: Text(_event.name),
			subtitle: showSubject && _event.subject != null ? Text(_event.subject!.name) : null,
			trailing: Text(_event.date.dateRepr),
			onTap: () => Navigator.of(context).push(MaterialPageRoute(
				builder: (context) => EventPage(_event)
			))
		);
	}
}


// class AddEventButton extends StatefulWidget {
// 	const AddEventButton();

// 	@override
// 	_AddEventButtonState createState() => _AddEventButtonState();
// }

// class _AddEventButtonState extends State<AddEventButton> {
// 	List<Subject>? _subjects;

// 	@override
// 	void initState() {
// 		Cloud.subjects.then((subjects) => setState(() => _subjects = subjects));
// 		super.initState();
// 	}

// 	@override
// 	Widget build(BuildContext context) {
// 		final isVisible = _subjects != null;

// 		return AnimatedOpacity(
// 			opacity: isVisible ? 1 : 0,
// 			duration: const Duration(milliseconds: 200),
// 			child: isVisible ? NewEntityButton(
// 				pageBuilder: (_) => NewEventPage(subjects: _subjects!)
// 			) : null
// 		);
// 	}
// }
