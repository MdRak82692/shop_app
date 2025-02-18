import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../function/delete_functions.dart';
import '../utils/chart_other_part.dart';
import '../utils/date_time_format.dart';
import '../utils/loading_display.dart';
import '../utils/text.dart';
import '../utils/pdf_generator.dart';

class DynamicDataTable1 extends StatefulWidget {
  final Widget Function(String userId, Map<String, dynamic> userData)
      targetWidget;
  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;
  final String fieldName;
  final List<String> itemNames;
  final Map<String, dynamic> itemFieldMapping;
  final bool? editDelete;

  const DynamicDataTable1({
    super.key,
    required this.targetWidget,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    required this.fieldName,
    required this.itemNames,
    required this.itemFieldMapping,
    this.editDelete,
  });

  @override
  DynamicDataTableState createState() => DynamicDataTableState();
}

class DynamicDataTableState extends State<DynamicDataTable1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? sortColumnIndex;
  bool sortAscending = false;

  @override
  Widget build(BuildContext context) {
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
            'items': data['items'] ?? [],
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
              String? fieldA, fieldB;
              dynamic valueA, valueB;

              if (sortColumnIndex! == 0) {
                valueA = a['id'];
                valueB = b['id'];
              } else if (sortColumnIndex! <= widget.itemNames.length) {
                fieldA = widget
                    .itemFieldMapping[widget.itemNames[sortColumnIndex! - 1]];
                valueA = a[fieldA];
                fieldB = widget
                    .itemFieldMapping[widget.itemNames[sortColumnIndex! - 1]];
                valueB = b[fieldB];
              } else {
                fieldA = widget.columnFieldMapping[widget.columnNames[
                    sortColumnIndex! - widget.itemNames.length - 1]];
                valueA = a[fieldA];
                fieldB = widget.columnFieldMapping[widget.columnNames[
                    sortColumnIndex! - widget.itemNames.length - 1]];
                valueB = b[fieldB];
              }

              return sortAscending
                  ? valueA.toString().compareTo(valueB.toString())
                  : valueB.toString().compareTo(valueA.toString());
            });
          });
        }

        if (sortColumnIndex != null) {
          groupedRecords.forEach((date, records) {
            records.sort((a, b) {
              String? fieldA, fieldB;
              dynamic valueA, valueB;

              if (sortColumnIndex! == 0) {
                valueA = a['id'];
                valueB = b['id'];
              } else if (sortColumnIndex! <= widget.itemNames.length) {
                fieldA = widget
                    .itemFieldMapping[widget.itemNames[sortColumnIndex! - 1]];
                valueA = a[fieldA];
                fieldB = widget
                    .itemFieldMapping[widget.itemNames[sortColumnIndex! - 1]];
                valueB = b[fieldB];
              } else {
                fieldA = widget.columnFieldMapping[widget.columnNames[
                    sortColumnIndex! - widget.itemNames.length - 1]];
                valueA = a[fieldA];
                fieldB = widget.columnFieldMapping[widget.columnNames[
                    sortColumnIndex! - widget.itemNames.length - 1]];
                valueB = b[fieldB];
              }

              return sortAscending
                  ? valueA.toString().compareTo(valueB.toString())
                  : valueB.toString().compareTo(valueA.toString());
            });
          });
        }

        return Column(
          children: groupedRecords.keys.map((date) {
            var recordsForDate = groupedRecords[date]!;

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
                      child: Text('Date: $date',
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
                        rows: recordsForDate
                            .map((doc) => buildDataRows(doc, recordsForDate))
                            .expand((rows) => rows)
                            .toList(),
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
    List<String> newColumnNames = [
      widget.collectionName == 'products' ? 'Purchase ID' : 'Sales ID',
      ...widget.itemNames,
      ...widget.columnNames
    ];

    List<DataColumn> columns = newColumnNames.map((name) {
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

    columns.add(
      DataColumn(
        label: Text('Actions', style: style(16, color: Colors.black)),
      ),
    );

    return columns;
  }

  List<DataRow> buildDataRows(
      Map<String, dynamic> record, List<Map<String, dynamic>> records) {
    List<DataRow> rows = [];

    List<dynamic> items = record['items'] is List ? record['items'] : [];

    if (items.isEmpty) {
      rows.add(createDataRow(record, null, records, isFirstRow: true));
    } else {
      for (var i = 0; i < items.length; i++) {
        rows.add(
            createDataRow(record, items[i], records, isFirstRow: (i == 0)));
      }
    }

    return rows;
  }

  DataRow createDataRow(
    Map<String, dynamic> record,
    dynamic item,
    List<Map<String, dynamic>> records, {
    required bool isFirstRow,
  }) {
    List<DataCell> cells = [];

    if (isFirstRow) {
      cells.add(DataCell(Text(record['id']?.toString() ?? '',
          style: style(16, color: Colors.black))));
    } else {
      cells.add(const DataCell(Text('')));
    }

    for (var itemName in widget.itemNames) {
      var itemValue =
          item != null ? (item[widget.itemFieldMapping[itemName]] ?? '') : '';
      cells.add(DataCell(
          Text(itemValue.toString(), style: style(16, color: Colors.black))));
    }

    if (isFirstRow) {
      for (var col in widget.columnNames) {
        var fieldName = widget.columnFieldMapping[col];
        var value = record[fieldName] ?? '';

        if (value is Timestamp) {
          value = formatTimestamp(value);
        } else if (value is int || value is double) {
          value = value.toString();
        }

        if (col == 'Discount') {
          double? numericValue = double.tryParse(value.toString());

          if (numericValue != null) {
            value = numericValue.toStringAsFixed(2);
          } else {
            value = '0.00';
          }
        }

        if (col == "Print") {
          cells.add(
            DataCell(
              IconButton(
                icon: const Icon(Icons.print, color: Colors.green),
                onPressed: () {
                  printSalesPDF(record);
                },
              ),
            ),
          );
        } else {
          cells.add(DataCell(
              Text(value.toString(), style: style(16, color: Colors.black))));
        }
      }
    } else {
      for (var i = 0; i < widget.columnNames.length; i++) {
        cells.add(const DataCell(Text('')));
      }
    }

    if (isFirstRow) {
      if (widget.editDelete == true) {
        if (widget.fieldName == 'time') {
          DateTime now = DateTime.now();
          String currentDate =
              '${now.day} ${getMonthName(now.month)} ${now.year}';
          var recordDate = record[widget.fieldName];
          if (recordDate == null) {
            cells.add(const DataCell(Text('')));
            return DataRow(cells: cells);
          }
          String formattedRecordDate;
          if (recordDate is Timestamp) {
            DateTime dateTime = recordDate.toDate();
            formattedRecordDate =
                '${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}';
          } else if (recordDate is String) {
            DateTime dateTime = DateTime.parse(recordDate);
            formattedRecordDate =
                '${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}';
          } else {
            cells.add(const DataCell(Text('')));
            return DataRow(cells: cells);
          }
          if (formattedRecordDate == currentDate) {
            cells.add(
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        String userId = record['id'];
                        Map<String, dynamic> userData = record;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                widget.targetWidget(userId, userData),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        var userId = record['id'];
                        if (userId != null) {
                          deleteFunction(
                              context, userId, widget.collectionName);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            cells.add(const DataCell(Text('')));
          }
        } else {
          cells.add(const DataCell(Text('')));
        }
      } else {
        cells.add(const DataCell(Text('')));
      }
    } else {
      cells.add(const DataCell(Text('')));
    }

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
      cells: cells,
    );
  }
}
