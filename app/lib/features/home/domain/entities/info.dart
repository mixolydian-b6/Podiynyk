import 'entity.dart';


// think: add subject to avoid passing it along
class Info extends Entity {
	const Info({
		required String id,
		required this.name,
		required this.content
	}) :
		super(id: id);

	final String name;
	final String content;

	@override
	int compareTo(covariant Info other) => name.compareTo(other.name);
}
