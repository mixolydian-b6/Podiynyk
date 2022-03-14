import 'package:flutter/material.dart';

import 'package:podiynyk/storage/appearance.dart';


abstract class Section extends StatelessWidget {
	const Section();

	/// The static [nameRepr].
	String get sectionName;
	/// The static [icon].
	IconData get sectionIcon;

	Widget? get actionButton => null;
}


abstract class CloudEntitiesSectionData<E> {
	abstract final Future<List<E>> entities;

	Future<Iterable<E>> get counted => entities;
	Future<int> get count => counted.then((counted) => counted.length);
}

abstract class CloudEntitiesSection<D extends CloudEntitiesSectionData<E>, E> extends Section {
	final D data;

	const CloudEntitiesSection(this.data);

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<List<E>>(
			future: data.entities,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Icon(sectionIcon));
				// if (snapshot.hasError) print(snapshot.error!);  // todo: consider handling

				return ListView(
					children: tiles(context, snapshot.data!)
				);
			}
		);
	}

	List<Widget> tiles(BuildContext context, List<E> entities);
}


class EntityTile extends StatelessWidget {
	final String title;
	final String? subtitle;
	final String? trailing;
	final Widget Function() pageBuilder;

	const EntityTile({
		required this.title,
		this.subtitle,
		this.trailing,
		required this.pageBuilder
	});

	@override
	Widget build(BuildContext context) {
		return ListTile(
			title: Text(title, style: Appearance.contentText),
			subtitle: subtitle != null ? Text(subtitle!, style: Appearance.smallText) : null,
			trailing: trailing != null ? Text(trailing!, style: Appearance.contentText) : null,
			onTap: () => Navigator.of(context).push(MaterialPageRoute(
				builder: (_) => pageBuilder()
			))
		);
	}
}


class NewEntityButton extends StatelessWidget {
	final Widget Function(BuildContext) pageBuilder;

	const NewEntityButton({required this.pageBuilder});

	@override
	Widget build(BuildContext context) {
		return FloatingActionButton(
			child: const Icon(Icons.add),
			onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: pageBuilder))
		);
	}
}
