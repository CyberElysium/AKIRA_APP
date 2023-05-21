import 'package:akira_mobile/models/material_item.dart';
import 'package:flutter/material.dart';

class MaterialSearchModal extends StatefulWidget {
  final Future<List<MaterialItem>> Function(String query) onSearch;

  const MaterialSearchModal({required this.onSearch});

  @override
  _MaterialSearchModalState createState() => _MaterialSearchModalState();
}

class _MaterialSearchModalState extends State<MaterialSearchModal> {
  TextEditingController _searchController = TextEditingController();
  List<MaterialItem> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _performSearch(value);
            },
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                MaterialItem material = _searchResults[index];
                return ListTile(
                  title: Text(material.name),
                  onTap: () {
                    Navigator.pop(context, material.id.toString());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      final results = await widget.onSearch(query);
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }
}
