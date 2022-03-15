import 'package:flutter/material.dart';

import 'package:podiynyk/storage/appearance.dart';
import 'package:podiynyk/storage/cloud.dart';
import 'package:podiynyk/storage/entities/subject.dart';

import 'package:podiynyk/ui/main/common/fields.dart' show InputField;

import 'entity.dart';


class NewSubjectPage extends StatelessWidget {
	final _nameField = TextEditingController();

	@override
	Widget build(BuildContext context) => NewEntityPage(
		add: _add,
		children: [
			InputField(
				controller: _nameField,
				name: "name",
				style: Appearance.headlineText
			)
		]
	);

	bool _add() {
		final name = _nameField.text;
		if (name.isEmpty) return false;

		final subject = Subject(name: name);
		Cloud.addSubject(subject);
		return true;
	}
}


class NewSubjectInfoPage extends StatelessWidget {
	final Subject subject;
	final _nameField = TextEditingController();
	final _contentField = TextEditingController();

	NewSubjectInfoPage({required this.subject});

	@override
	Widget build(BuildContext context) => NewEntityPage(
		add: _add,
		children: [
			InputField(
				controller: _nameField,
				name: "topic",
				style: Appearance.headlineText
			),
			InputField(
				controller: _contentField,
				name: "content",
				style: Appearance.bodyText,
				grows: true
			)
		]
	);

	bool _add() {
		final name = _nameField.text, content = _contentField.text;
		if (name.isEmpty || content.isEmpty) return false;

		subject.addInfo(SubjectInfo(
			subject: subject,
			name: name,
			content: content
		));
		return true;
	}
}
