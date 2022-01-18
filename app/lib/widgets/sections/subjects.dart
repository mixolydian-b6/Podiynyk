import 'package:flutter/material.dart';

import 'package:podiynyk/storage/local.dart';
import 'package:podiynyk/storage/cloud.dart' show Cloud;
import 'package:podiynyk/storage/entities/event.dart';
import 'package:podiynyk/storage/entities/subject.dart';

import 'entity_pages/subject.dart';
import 'new_entity_pages/subject.dart';
import 'section.dart';


class SubjectsSection extends ExtendableListSection<Subject> {
	@override
	final name = "subjects";
	@override
	final icon = Icons.school;

	@override
	Future<List<Subject>> get entitiesFuture => Cloud.subjects();

	@override
	Widget tile(BuildContext context, Subject subject) {
		final isFollowed = !Local.entityIsStored(StoredEntities.unfollowedSubjects, subject);
		final nextEvent = _nextEvent(subject);

		final tile = ListTile(
			title: Text(subject.name),
			subtitle: Text(subject.eventCountRepr),
			trailing: nextEvent != null ? Text(nextEvent.date.dateRepr) : null,
			onTap: () => Navigator.of(context).push(MaterialPageRoute(
				builder: (context) => SubjectPage(subject, isFollowed: isFollowed)
			))
		);

		return isFollowed ? tile : Opacity(opacity: 0.6, child: tile);
	}

	Event? _nextEvent(Subject subject) {
		if (subject.events.isEmpty) return null;
		return subject.events.reduce((nextEvent, event) =>  event.isBefore(nextEvent) ? event : nextEvent);
	}

	@override
	Widget addEntityButton(BuildContext context) => AddEntityButton(pageBuilder: (_) => NewSubjectPage());
}
