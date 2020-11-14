import 'dart:convert';
import 'package:cat_it/models/Item.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ItemSharePage extends StatefulWidget {
  final Item item;

  ItemSharePage({@required this.item});

  @override
  _ItemSharePageState createState() => _ItemSharePageState();
}

class _ItemSharePageState extends State<ItemSharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share ${widget.item.name}')),
      body: Stack(
        children: [
          Container(width: double.infinity, height: MediaQuery.of(context).size.height * 0.35, color: Colors.blue),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        generateQrCode(),
                        SizedBox(height: 16.0),
                        Text(widget.item.name, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8.0),
                        Text(widget.item.category, style: TextStyle(fontSize: 16.0, color: Colors.grey))
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  QrImage generateQrCode() {
    return QrImage(
      data: jsonEncode(widget.item),
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
