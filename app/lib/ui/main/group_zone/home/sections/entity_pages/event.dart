import 'package:flutter/material.dart';

import 'package:podiynyk/storage/cloud.dart';
import 'package:podiynyk/storage/entities/event.dart';
import 'package:podiynyk/storage/entities/student.dart' show Role;

import 'package:podiynyk/ui/main/common/fields.dart';

import 'entity.dart';


class EventPage extends StatefulWidget {
	final Event event;

	const EventPage(this.event);

	@override
	State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
	late final Event _event;
	bool _showNoteField = false;
	final _nameField = TextEditingController();
	final _noteField = TextEditingController();

	@override
	void initState() {
		super.initState();
		_event = widget.event;
		_nameField.text = _event.nameRepr;

		_event.addDetails().whenComplete(() => setState(() {
			final note = _event.note;
			_showNoteField = note != null;
			if (_showNoteField) _noteField.text = note!;
		}));
	}

	@override
	Widget build(BuildContext context) {
		final hasSubject = _event.subject != null;

		return EntityPage(
			children: [
				InputField(
					controller: _nameField,
					name: "name"
				),
				if (hasSubject) Text(_event.subjectNameRepr!),
				DateField(
					initialDate: _event.date,
					onDatePicked: (date) => _event.date = date,
					enabled: Cloud.role != Role.ordinary
				),
				if (_showNoteField) InputField(
					controller: _noteField,
					name: "note"
				)
			],
			actions: [
				if (_event.note == null) EntityActionButton(
					text: "add a note",
					action: () => setState(() => _showNoteField = true)
				),
				!_event.isHidden ? EntityActionButton(
					text: "hide",
					action: () => _event.isHidden = true
				) : EntityActionButton(
					text: "show",
					action: () => _event.isHidden = false
				),
				if (Cloud.role != Role.ordinary) EntityActionButton(
					text: "delete",
					action: () => Cloud.deleteEvent(_event)
				)
			]
		);
	}

	@override
	void dispose() {
		_event.label = _nameField.text;
		
		final note = _noteField.text;
		_event.note = note.isNotEmpty ? note : null;

		super.dispose();
	}
}
