import 'package:flutter/material.dart';

import 'package:podiynyk/storage/cloud.dart' show Cloud;
import 'package:podiynyk/storage/local.dart';
import 'package:podiynyk/storage/entities/student.dart' show Role;
import 'package:podiynyk/storage/entities/subject.dart' show Subject;

import '../agenda.dart';
import 'entity.dart';


class SubjectPage extends StatefulWidget {
	final Subject _subject;
	final bool isFollowed;
	final _nameField = TextEditingController();

	SubjectPage(this._subject, {required this.isFollowed}) {
		_nameField.text = _subject.name;
	}

	@override
	State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
	@override
	void initState() {
		widget._subject.addDetails().whenComplete(() => setState(() {}));
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		final subject = widget._subject;
		final totalEventCount = subject.totalEventCount;
		final info = subject.info;
		final events = subject.events;

		return EntityPage(
			children: [
				TextField(
					controller: widget._nameField,
					decoration: const InputDecoration(hintText: "subject"),
					onSubmitted: (label) {},  // todo: add the label
				),
				if (totalEventCount != null) Text("${subject.totalEventCountRepr} so far"),
				if (info != null) TextButton(
					child: const Text("information"),
					onPressed: () => _showPage([
						for (final entry in info) Text(entry)
					])
				),
				if (events.isNotEmpty) TextButton(
					child: Text(subject.eventCountRepr),
					onPressed: () => _showPage([
						for (final event in events) EventTile(event, showSubject: false)
					])
				)
			],
			options: [
				EntityActionButton(
					text: "add an event",
					action: () {}  // todo: implement
				),
				EntityActionButton(
					text: "add information",
					action: () {}  // todo: implement
				),
				widget.isFollowed ? EntityActionButton(
					text: "unfollow",
					action: () => Local.addStoredEntity(StoredEntities.unfollowedSubjects, subject)
				) : EntityActionButton(
					text: "follow",
					action: () => Local.deleteStoredEntity(StoredEntities.unfollowedSubjects, subject)
				),
				if (Cloud.role == Role.leader) EntityActionButton(
					text: "delete",
					action: () => Cloud.deleteSubject(subject)
				)
			]
		);
	}

	void _showPage(List<Widget> children) {
		Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scaffold(
			body: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: children
			)
		)));
	}
}
