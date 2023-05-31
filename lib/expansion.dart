import 'package:flutter/material.dart';

class MyList extends StatefulWidget {
  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  final List<ItemModel> _items = [
    ItemModel(headerValue: 'Başlık 1', expandedValue: 'Açıklama 1', isExpanded: false),
    ItemModel(headerValue: 'Başlık 2', expandedValue: 'Açıklama 2', isExpanded: false),
    ItemModel(headerValue: 'Başlık 3', expandedValue: 'Açıklama 3', isExpanded: false),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: ExpansionPanelList(
          elevation: 1,
          expandedHeaderPadding: EdgeInsets.all(0),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _items[index].isExpanded = !isExpanded;
            });
          },
          children: _items.map<ExpansionPanel>((ItemModel item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(item.headerValue),
                );
              },
              body: ListTile(
                title: Text(item.expandedValue),
              ),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ItemModel {
  String headerValue;
  String expandedValue;
  bool isExpanded;

  ItemModel({required this.headerValue, required this.expandedValue, required this.isExpanded});
}
