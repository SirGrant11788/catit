import 'dart:convert';
import 'package:cat_it/models/Item.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ItemScanPage extends StatelessWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController qrController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
            title: Text('Import an item'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner)),
              Tab(icon: Transform.rotate(
                  child: Icon(Icons.line_weight),
                  angle: 90 * pi / 180,
              ))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildQrScanner(context),
            buildBarcodeScanner()
          ],
        )
      ),
    );
  }

  Widget buildQrScanner(BuildContext context) {
    return Stack(
      children: [
        Container(width: double.infinity, height: MediaQuery.of(context).size.height * 0.35, color: Colors.blue),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              SizedBox(
                height: 300.0,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text('Scan an item\'s QR code', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Expanded(
                          child: QRView(
                            key: qrKey,
                            onQRViewCreated: (controller) {
                              _onQRViewCreated(controller, context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    qrController = controller;
    qrController.scannedDataStream.listen((scanData) {
      var jsonData = json.decode(scanData);
      Item item = Item.fromJson(jsonData);

      Navigator.pop(context, item);
      qrController.dispose();
    });
  }

  Widget buildBarcodeScanner() {
    // TODO: Create barcode scanner widget
    return Container();
  }
}
