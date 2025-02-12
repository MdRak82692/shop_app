import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore/quantity_fetch_information.dart';
import '../utils/date_time_format.dart';
import '../utils/loading_display.dart';
import '../utils/text.dart';

class DynamicDataTable extends StatefulWidget {
  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;
  final List<String> groupByFields;
  final dynamic staffAttendance;

  const DynamicDataTable({
    super.key,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    required this.groupByFields,
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

            var groupedRecords =
                groupRecordsByFields(records, widget.groupByFields);

            return Column(
              children:
                  buildNestedDataTables(groupedRecords, availableQuantities),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> groupRecordsByFields(
      List<Map<String, dynamic>> records, List<String> fields) {
    if (fields.isEmpty) {
      return {'': records};
    }

    String currentField = fields.first;
    Map<String, dynamic> groupedRecords = {};

    for (var record in records) {
      var fieldValue = record[currentField]?.toString() ?? '';

      if (!groupedRecords.containsKey(fieldValue)) {
        groupedRecords[fieldValue] = <Map<String, dynamic>>[];
      }
      (groupedRecords[fieldValue] as List<Map<String, dynamic>>).add(record);
    }

    if (fields.length > 1) {
      var remainingFields = fields.sublist(1);
      groupedRecords.forEach((key, value) {
        groupedRecords[key] = groupRecordsByFields(
            value as List<Map<String, dynamic>>, remainingFields);
      });
    }

    return groupedRecords;
  }

  List<Widget> buildNestedDataTables(Map<String, dynamic> groupedRecords,
      Map<String, double> availableQuantities,
      {String parentKey = ''}) {
    List<Widget> widgets = [];

    groupedRecords.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 50.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        key == 'subCategory'
                            ? 'Sub-Category: $key'
                            : 'Category: $key',
                        style: style(
                          20,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    )),
              ),
              ...buildNestedDataTables(value, availableQuantities,
                  parentKey: key),
            ],
          ),
        );
      } else if (value is List<Map<String, dynamic>>) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 50.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        key == 'category'
                            ? 'Category: $key'
                            : 'Sub-Category: $key',
                        style: style(
                          20,
                          color: Colors.green.shade800,
                        ),
                      ),
                    )),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(Colors.blue.shade100),
                    horizontalMargin: 20,
                    headingRowHeight: 50,
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    columns: buildDataColumns(),
                    rows: value
                        .map((record) => buildDataRow(
                            record, value, availableQuantities, parentKey))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });

    return widgets;
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
      Map<String, double> availableQuantities,
      String parentKey) {
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
