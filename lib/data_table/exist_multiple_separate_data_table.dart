import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../fetch_information/quantity_fetch_information.dart';
import '../utils/date_time_format.dart';
import '../utils/loading_display.dart';
import '../utils/text.dart';

class DynamicDataTable extends StatefulWidget {
  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;

  final dynamic staffAttendance;

  const DynamicDataTable({
    super.key,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    this.staffAttendance,
  });

  @override
  DynamicDataTableState createState() => DynamicDataTableState();
}

class DynamicDataTableState extends State<DynamicDataTable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuantityFetchInformation? fetchInformation;
  int? sortColumnIndex;
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();
    fetchInformation = QuantityFetchInformation(
      firestore: firestore,
      setState: setState,
    );
    fetchInformation!.fetchAvailableQuantities().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: fetchInformation!.fetchAvailableQuantities(),
      builder: (context, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: buildLoadingOverlay());
        }

        if (futureSnapshot.hasError) {
          return Center(
            child: Text(
              "Error fetching available quantities: ${futureSnapshot.error}",
              style: style(18, color: Colors.red),
            ),
          );
        }

        final availableQuantities = futureSnapshot.data ?? {};

        return StreamBuilder<QuerySnapshot>(
          stream: firestore.collection(widget.collectionName).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: buildLoadingOverlay());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No data found.",
                  style: style(18, color: Colors.red),
                ),
              );
            }

            var records = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                ...data,
              };
            }).where((record) {
              final query = widget.searchQuery.toLowerCase();
              return record.values.any((value) {
                if (value is Timestamp) {
                  String formattedDate = formatDateTimestamp(value);
                  return formattedDate.toLowerCase().contains(query);
                } else {
                  return value.toString().toLowerCase().contains(query);
                }
              });
            }).toList();

            if (sortColumnIndex != null) {
              records.sort((a, b) {
                var fieldA = widget
                    .columnFieldMapping[widget.columnNames[sortColumnIndex!]];
                var valueA = a[fieldA];
                var fieldB = widget
                    .columnFieldMapping[widget.columnNames[sortColumnIndex!]];
                var valueB = b[fieldB];

                return sortAscending
                    ? valueA.toString().compareTo(valueB.toString())
                    : valueB.toString().compareTo(valueA.toString());
              });
            }

            return buildDataTables(records, availableQuantities);
          },
        );
      },
    );
  }

  Align buildDataTables(List<Map<String, dynamic>> records,
      Map<String, double> availableQuantities) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
              horizontalMargin: 20,
              headingRowHeight: 50,
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              columns: buildDataColumns(),
              rows: records
                  .map((record) =>
                      buildDataRow(record, records, availableQuantities))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> buildDataColumns() {
    return widget.columnNames.map((name) {
      return DataColumn(
        label: Text(name,
            style: style(
              16,
              color: Colors.black,
            )),
        onSort: (columnIndex, ascending) {
          setState(() {
            sortColumnIndex = columnIndex;
            sortAscending = ascending;
          });
        },
      );
    }).toList();
  }

  DataRow buildDataRow(
      Map<String, dynamic> record,
      List<Map<String, dynamic>> records,
      Map<String, double> availableQuantities) {
    return DataRow(
        color: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.blue.shade50;
            }
            return records.indexOf(record) % 2 == 0
                ? Colors.grey.shade100
                : Colors.white;
          },
        ),
        cells: widget.columnNames.map((col) {
          var fieldName = widget.columnFieldMapping[col];
          var value = record[fieldName] ?? '';

          if (col == 'Quantity') {
            var quantity = record['quantity'] ?? '0';
            var unit = record['unit'] ?? '';
            value = '$quantity $unit';
          }

          if (col == 'Available Quantity') {
            var productName = record['productName'] ?? '';
            var availableQuantity = availableQuantities[productName] ?? 0.00;
            value = availableQuantity.toStringAsFixed(2);
          }

          if (col == 'Product Price' || col == 'Amount') {
            value = value.toStringAsFixed(2);
          }

          if (value is Timestamp) {
            value = formatTimestamp(value);
          }

          return DataCell(
              Text(value.toString(), style: style(16, color: Colors.black)));
        }).toList());
  }
}
