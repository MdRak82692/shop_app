import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/date_time_format.dart';

import '../utils/loading_display.dart';
import '../utils/text.dart';

class DynamicDataTable extends StatefulWidget {
  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;
  final String fieldName;

  const DynamicDataTable({
    super.key,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    required this.fieldName,
  });

  @override
  DynamicDataTableState createState() => DynamicDataTableState();
}

class DynamicDataTableState extends State<DynamicDataTable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? sortColumnIndex;
  bool sortAscending = false;

  Stream<QuerySnapshot> getStream() {
    if (widget.collectionName == 'orders') {
      return firestore
          .collection(widget.collectionName)
          .where('status', isEqualTo: 'Completed')
          .snapshots();
    }
    return firestore.collection(widget.collectionName).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getStream(),
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

        var groupedRecords = groupRecordsByDate(records);

        if (sortColumnIndex != null) {
          groupedRecords.forEach((date, records) {
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
          });
        }

        return Column(
          children: groupedRecords.keys.map((date) {
            var recordsForDate = groupedRecords[date]!;

            double totalAmount = recordsForDate.fold(0, (total, record) {
              var fieldName = widget.columnFieldMapping[widget.columnNames[2]];
              var value = record[fieldName];
              return total + (value is num ? value.toDouble() : 0);
            });

            return Column(
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
                      child: Text(date,
                          style: style(20, color: Colors.blue.shade800)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
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
                        rows: records
                            .map((record) => buildDataRow(record, records))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 50.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Total for $date: ',
                              style: style(18, color: Colors.green.shade700),
                            ),
                            TextSpan(
                              text: totalAmount.toStringAsFixed(0),
                              style: style(18, color: Colors.red.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> groupRecordsByDate(
      List<Map<String, dynamic>> records) {
    Map<String, List<Map<String, dynamic>>> groupedRecords = {};

    for (var record in records) {
      var fieldValue = record[widget.fieldName];

      if (fieldValue is Timestamp) {
        var formattedDate = formatDatestamp(fieldValue);
        if (!groupedRecords.containsKey(formattedDate)) {
          groupedRecords[formattedDate] = [];
        }
        groupedRecords[formattedDate]!.add(record);
      } else if (fieldValue != null) {
        String fieldValueString = fieldValue.toString();
        if (!groupedRecords.containsKey(fieldValueString)) {
          groupedRecords[fieldValueString] = [];
        }
        groupedRecords[fieldValueString]!.add(record);
      }
    }

    var sortedGroupedRecords = Map.fromEntries(
      groupedRecords.entries.toList()
        ..sort((a, b) {
          if (a.key.contains(RegExp(r'\d{2} \w+ \d{4}'))) {
            var dateA = formatDateToDateTime(a.key);
            var dateB = formatDateToDateTime(b.key);
            return dateB.compareTo(dateA);
          } else {
            return a.key.compareTo(b.key);
          }
        }),
    );

    return sortedGroupedRecords;
  }

  List<DataColumn> buildDataColumns() {
    return widget.columnNames.map((name) {
      return DataColumn(
        label: Text(name, style: style(16, color: Colors.black)),
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
      Map<String, dynamic> record, List<Map<String, dynamic>> records) {
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

          if (value is Timestamp) {
            value = formatTimestamp(value);
          }
          if (col == 'Amount') {
            value = value.toStringAsFixed(2);
          }

          if (col == 'Salary Amount') {
            value = value.toStringAsFixed(2);
          }

          if (col == 'Total Price') {
            value = value.toStringAsFixed(2);
          }

          if (col == 'Product Name') {
            value =
                record['items'].map((item) => item['productName']).join(', ');
          }

          return DataCell(
              Text(value.toString(), style: style(16, color: Colors.black)));
        }).toList());
  }
}
