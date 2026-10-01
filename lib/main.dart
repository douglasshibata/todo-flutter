import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';

void main() {
  runApp(const App());
}

/// Root widget for the Todo Application.
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

/// Home screen displaying the list of tasks and allowing user actions.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Encapsulated state list of items inside the State object to avoid state mutation bugs.
  List<Item> _items = [];
  bool _isLoading = true;

  // TextEditingController properly lifecycle-managed.
  final TextEditingController _newTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Asynchronously load stored items during initState lifecycle hook.
    _loadItems();
  }

  @override
  void dispose() {
    // Dispose text controller to prevent memory leaks when widget is destroyed.
    _newTaskController.dispose();
    super.dispose();
  }

  /// Loads saved todo items from local storage using SharedPreferences.
  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('data');
      if (data != null && data.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
        final List<Item> loadedItems = decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => Item.fromJson(e))
            .where((item) => item.title.isNotEmpty)
            .toList();

        if (mounted) {
          setState(() {
            _items = loadedItems;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // In case of corrupt stored JSON data, fallback to empty list safely.
      if (mounted) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Persists current list of items to SharedPreferences.
  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString('data', jsonString);
    } catch (e) {
      // Handle potential storage errors silently or log appropriately
      debugPrint('Error saving tasks: $e');
    }
  }

  /// Adds a new task to the item list after trimming and validating user input.
  void _add() {
    final String trimmedText = _newTaskController.text.trim();
    if (trimmedText.isEmpty) return;

    // Generate unique ID using timestamp and list length to prevent key collisions in Dismissible.
    final String uniqueId = '${DateTime.now().microsecondsSinceEpoch}_${_items.length}';

    setState(() {
      _items.add(
        Item(
          id: uniqueId,
          title: trimmedText,
          done: false,
        ),
      );
      _newTaskController.clear();
    });
    _saveItems();
  }

  /// Removes an item at [index] and persists changes.
  void _remove(int index) {
    if (index < 0 || index >= _items.length) return;
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();
  }

  /// Toggles completion status of a task at [index].
  void _toggleDone(int index, bool? done) {
    if (index < 0 || index >= _items.length) return;
    setState(() {
      _items[index] = _items[index].copyWith(done: done ?? false);
    });
    _saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _newTaskController,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          onFieldSubmitted: (_) => _add(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma tarefa cadastrada.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _items[index];
                    return Dismissible(
                      // Keying by unique item.id guarantees correct element identification during dismiss.
                      key: ValueKey(item.id),
                      background: Container(
                        color: Colors.red.withValues(alpha: 0.2),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20.0),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (direction) {
                        _remove(index);
                      },
                      child: CheckboxListTile(
                        key: ValueKey('checkbox_${item.id}'),
                        title: Text(item.title),
                        value: item.done,
                        onChanged: (value) {
                          _toggleDone(index, value);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
