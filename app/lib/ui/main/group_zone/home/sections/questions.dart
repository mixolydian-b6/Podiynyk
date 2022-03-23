import 'package:flutter/material.dart';

import 'package:podiynyk/storage/cloud.dart' show Cloud;
import 'package:podiynyk/storage/entities/question.dart';

import 'section.dart';


// class QuestionsSectionData extends CloudEntitiesSectionData<Question> {
// 	@override
// 	Future<List<Question>> get entitiesFuture => Cloud.questions;
// }


class QuestionsSection extends EntitiesSection<Question> {
	static const name = "questions";
	static const icon = Icons.question_answer;

	@override
	String get sectionName => name;
	@override
	IconData get sectionIcon => icon;

	@override
	Future<Iterable<Question>> get entities => Cloud.questions;

	@override
	List<Widget> tiles(BuildContext context, Iterable<Question> questions) => [];
}
