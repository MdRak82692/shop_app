import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/date_time_format.dart';
import '../function/delete_functions.dart';
import '../utils/loading_display.dart';
import '../utils/text.dart';

class DynamicDataTable extends StatefulWidget {
  final Widget Function(String userId, Map<String, dynamic> userData)
      targetWidget;
  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;
  final List<String> groupByFields;
  final dynamic staffAttendance;

  const DynamicDataTable({
    super.key,
    required this.targetWidget,
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
          children: buildNestedDataTables(groupedRecords),
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
                  ),
                ),
              ),
              ...buildNestedDataTables(value, parentKey: key),
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
                        .map((record) => buildDataRow(record, value))
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
    }).toList()
      ..add(
        DataColumn(
          label: Text('Actions',
              style: style(
                16,
                color: Colors.black,
              )),
        ),
      );
  }

  DataRow buildDataRow(
      Map<String, dynamic> record, List<Map<String, dynamic>> records) {
    var checkInTime = record['time'];
    var checkOutTime = record['outtime'];
    String totalWorkHours = '';

    if (checkInTime is Timestamp && checkOutTime is Timestamp) {
      Duration difference =
          checkOutTime.toDate().difference(checkInTime.toDate());
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);
      totalWorkHours = "${hours}h ${minutes}m";
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
      cells: widget.columnNames.map((col) {
        var fieldName = widget.columnFieldMapping[col];
        var value = record[fieldName] ?? '';

        if (col == 'Quantity') {
          var quantity = record['quantity'] ?? '0';
          var unit = record['unit'] ?? '';
          value = '$quantity $unit';
        }

        if (col == 'Available Quantity') {
          var quantity = record['quantity'] ?? '0';
          var unit = record['unit'] ?? '';
          value = '$quantity $unit';
        }

        if (col == 'Amount') {
          value = value.toStringAsFixed(2);
        }

        if (col == 'Product Price') {
          value = value.toStringAsFixed(2);
        }

        if (col == 'Total Work Hours') {
          value = totalWorkHours;
        }

        if (value is Timestamp) {
          value = formatTimestamp(value);
        }

        return DataCell(
            Text(value.toString(), style: style(16, color: Colors.black)));
      }).toList()
        ..add(
          widget.staffAttendance == true
              ? DataCell(
                  checkOutTime == null
                      ? IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () async {
                            final now = DateTime.now();
                            await firestore
                                .collection('staffattendance')
                                .doc(record['id'])
                                .update({'outtime': now});
                          },
                        )
                      : const Icon(Icons.check, color: Colors.green),
                )
              : DataCell(
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
        ),
    );
  }
}
