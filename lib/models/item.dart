/// Data model representing a single To-Do task item.
class Item {
  /// Unique identifier for keying widgets reliably (prevents Dismissible key collision bugs).
  final String id;

  /// Title/description of the todo task.
  final String title;

  /// Completion status of the todo task.
  final bool done;

  const Item({
    required this.id,
    required this.title,
    this.done = false,
  });

  /// Factory constructor to safely create an [Item] from JSON decoding.
  /// Includes type checks and fallback defaults for data integrity and error prevention.
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      // Ensure fallback key generation if ID is missing or not a string
      id: json['id'] is String && (json['id'] as String).isNotEmpty
          ? json['id'] as String
          : DateTime.now().microsecondsSinceEpoch.toString(),
      // Defensive parsing to guard against null or non-string values
      title: json['title'] is String ? (json['title'] as String).trim() : '',
      // Ensure boolean type safety with false as fallback
      done: json['done'] is bool ? json['done'] as bool : false,
    );
  }

  /// Converts the [Item] instance into a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
    };
  }

  /// Creates a copy of this [Item] with updated fields.
  Item copyWith({
    String? id,
    String? title,
    bool? done,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          done == other.done;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ done.hashCode;
}
