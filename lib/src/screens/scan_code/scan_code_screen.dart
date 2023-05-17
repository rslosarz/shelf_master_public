/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/routes.dart';

class ScanCodeScreen extends StatefulWidget {
  const ScanCodeScreen({Key? key}) : super(key: key);

  @override
  State<ScanCodeScreen> createState() => _ScanCodeScreenState();
}

class _ScanCodeScreenState extends State<ScanCodeScreen> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;

    if (cameraController == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      cameraController.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!scanInProgress) {
        scanInProgress = true;
        if (scanData.code != null) {
          final url = Uri.tryParse(scanData.code!);
          final pathParts = url?.path.split('/');
          if (pathParts?.length == 3) {
            final objectType = pathParts![1];
            final objectParam = pathParts[2];
            final objectId = objectParam.replaceAll('id=', '');
            if (objectType == 'group') {
              GroupDetailRoute(groupId: objectId).push<void>(context);
              context.read<AnalyticsRepository>().groupDetailDeeplink(objectId);
            }
            if (objectType == 'item') {
              ItemDetailRoute(itemId: objectId).push<void>(context);
              context.read<AnalyticsRepository>().itemDetailDeeplink(objectId);
            }
            context.read<AnalyticsRepository>().onQrCodeScanned(url?.path ?? 'N/A');
          }
        }
        Future.delayed(
          const Duration(seconds: 1),
          () => scanInProgress = false,
        );
      }
    });
  }
}
