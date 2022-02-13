import 'package:cloud_firestore/cloud_firestore.dart';

import 'labelable.dart';
import '../cloud.dart';
import '../fields.dart';
import '../local.dart';


class Event extends LabelableEntity {
	final String id;
	final String? subjectName;
	final DateTime date;
	late bool isShown;

	String? note;

	Event.fromCloudFormat(MapEntry<String, dynamic> entry) :
		id = entry.key,
		subjectName = entry.value[Field.subject.name],
		date = (entry.value[Field.date.name] as Timestamp).toDate(),
		super(initialName: entry.value[Field.name.name] as String)
	{
		isShown = Local.entityIsUnstored(Field.hiddenEvents, essence);
	}

	Future<void> addDetails() => Cloud.addEventDetails(this);

	@override
	Field get labelCollection => Field.events;

	void hide() {
		Local.storeEntity(Field.hiddenEvents, essence);
		isShown = false;
	}

	void show() {
		Local.deleteEntity(Field.hiddenEvents, essence);
		isShown = true;
	}

	@override
	String get essence => '$subjectName.$initialName';
}
