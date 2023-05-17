/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart' as model;
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/screens/print_label/bloc/print_label_cubit.dart';
import 'package:shelf_master/src/screens/print_label/bloc/print_label_state.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';

class PrintLabelScreen extends StatefulWidget {
  final String routeName;

  const PrintLabelScreen({Key? key, required this.routeName}) : super(key: key);

  @override
  State<PrintLabelScreen> createState() => _PrintLabelScreenState();
}

class _PrintLabelScreenState extends State<PrintLabelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: DashboardNavigationBar.asHero(
        selectedRouteName: widget.routeName,
      ),
      body: BlocBuilder<PrintLabelCubit, PrintLabelState>(
        builder: (context, state) {
          return state.when(
            init: _init,
            loaded: _loaded,
            error: _error,
          );
        },
      ),
    );
  }

  Widget _init() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _error() {
    return Center(
      child: Text(context.l10n.errorInfo),
    );
  }

  Widget _loaded(List<Group>? groups, List<Item>? items) {
    final theme = Theme.of(context);
    return Theme(
      data: ThemeData(
        primaryColor: theme.scaffoldBackgroundColor,
      ),
      child: PdfPreview(
        build: (format) => _generatePdf(format, groups, items),
        canDebug: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, List<Group>? groups, List<Item>? items) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_5,
      compress: true,
      title: context.l10n.groupLabelDocName,
    );
    final font = await PdfGoogleFonts.ubuntuLight();

    final pagedGroups = groups?.slices(20);
    final pagedItems = items?.slices(20);

    if (pagedGroups != null) {
      for (final page in pagedGroups) {
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
            build: (context) {
              return pw.Wrap(children: page.map((group) => _buildGroupLabel(group, font)).toList());
            },
          ),
        );
      }
    }
    if (pagedItems != null) {
      for (final page in pagedItems) {
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
            build: (context) {
              return pw.Wrap(children: page.map((item) => _buildItemLabel(item, font)).toList());
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  pw.Widget _buildGroupLabel(Group group, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2.0),
      child: pw.Container(
        width: 220,
        height: 68,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('#000000'), width: 1),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(width: 8),
            pw.BarcodeWidget(
              color: PdfColor.fromHex('#000000'),
              barcode: pw.Barcode.qrCode(),
              data: group.groupUrl(),
              width: 50,
              height: 50,
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 4),
                  pw.Text(
                    group.name,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                    ),
                    tightBounds: true,
                  ),
                  pw.Spacer(),
                  if (group.locationDsc != null) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      group.locationDsc!,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                      ),
                      tightBounds: true,
                    ),
                    pw.SizedBox(height: 2),
                  ],
                  pw.Wrap(
                    children: group.categories
                        .map(
                          (category) => _buildCategoryLabel(category, font),
                        )
                        .toList(),
                  ),
                  pw.SizedBox(height: 4),
                ],
              ),
            ),
            pw.SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildItemLabel(Item item, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2.0),
      child: pw.Container(
        width: 220,
        height: 68,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('#000000'), width: 1),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(width: 8),
            pw.BarcodeWidget(
              color: PdfColor.fromHex('#000000'),
              barcode: pw.Barcode.qrCode(),
              data: item.itemUrl(),
              width: 50,
              height: 50,
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 4),
                  pw.Text(
                    item.name ?? '',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                    ),
                    tightBounds: true,
                  ),
                  pw.Spacer(),
                  pw.Wrap(
                    children: item.categories
                        .map(
                          (category) => _buildCategoryLabel(category, font),
                        )
                        .toList(),
                  ),
                  pw.SizedBox(height: 4),
                ],
              ),
            ),
            pw.SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildCategoryLabel(model.Category category, pw.Font font) {
    final color = category.colorHex.substring(2);
    return pw.Padding(
      padding: const pw.EdgeInsets.all(1.0),
      child: pw.Container(
        height: 8,
        width: 40,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: PdfColor.fromHex('#$color'), width: 1),
        ),
        child: pw.Center(
          child: pw.Text(
            category.name,
            maxLines: 1,
            softWrap: false,
            style: pw.TextStyle(
              font: font,
              fontSize: 6,
            ),
            tightBounds: false,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ),
    );
  }
}
