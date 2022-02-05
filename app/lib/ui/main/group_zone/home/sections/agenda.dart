import 'package:flutter/material.dart';

import 'package:podiynyk/storage/cloud.dart' show Cloud;
import 'package:podiynyk/storage/entities/subject.dart';
import 'package:podiynyk/storage/local.dart';
import 'package:podiynyk/storage/entities/event.dart';

import 'section.dart';
import 'entity_pages/event.dart';
import 'new_entity_pages/event.dart';


class AgendaSection extends ExtendableListSection<Event> {
	@override
	final name = "agenda";
	@override
	final icon = Icons.import_contacts;

	@override
	Future<List<Event>> get entitiesFuture => Cloud.events.then((events) {
		final unfollowedEssences = Local.storedEntities<SubjectEssence>(DataBox.unfollowedSubjects);
		return events.where((event) => !unfollowedEssences.contains(event.subject?.essence)).toList();
	});

	@override
	Widget tile(BuildContext context, Event event) => EventTile(event, showSubject: true);

	@override
	Widget addEntityButton(BuildContext context) => const AddEventButton();
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


class AddEventButton extends StatefulWidget {
	const AddEventButton();

	@override
	_AddEventButtonState createState() => _AddEventButtonState();
}

class _AddEventButtonState extends State<AddEventButton> {
	List<Subject>? _subjects;

	@override
	void initState() {
		Cloud.subjects.then((subjects) => setState(() => _subjects = subjects));
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		final isVisible = _subjects != null;

		return AnimatedOpacity(
			opacity: isVisible ? 1 : 0,
			duration: const Duration(milliseconds: 200),
			child: isVisible ? NewEntityButton(
				pageBuilder: (_) => NewEventPage(subjects: _subjects!)
			) : null
		);
	}
}
