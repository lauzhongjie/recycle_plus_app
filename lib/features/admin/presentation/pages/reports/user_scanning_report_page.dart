import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_record_cubit.dart';
import 'package:fl_chart/fl_chart.dart';

Map<String, Color> colorMap = {
  'battery': Colors.lightBlueAccent,
  'paper': Colors.amber,
  'plastic bag': Colors.lime,
  'can': Colors.pinkAccent,
  'glass bottle': Colors.green,
  'pop tab': Colors.redAccent,
  'plastic bottle': Colors.blue,
  'cardboard': Colors.orange,
  'plastic bottle cap': Colors.purpleAccent,
  'drink carton': Colors.teal,
};

class UserScanningReportPage extends StatefulWidget {
  const UserScanningReportPage({super.key});

  @override
  State<UserScanningReportPage> createState() => _UserScanningReportPageState();
}

class _UserScanningReportPageState extends State<UserScanningReportPage> {
  late List<ScanEntity> scans;
  DateTime? startDate;
  DateTime? endDate;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  String? selectedItem;

  @override
  void initState() {
    super.initState();

    // Get all users' scans
    context.read<ScanningRecordCubit>().getAllScans();

    // Filtering
    startDateController = TextEditingController();
    endDateController = TextEditingController();

    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);

    // Check if the current date is before the last day of the month
    // If true, set to today's date
    // Otherwise, set to the last day of the month
    endDate = (now.day < DateTime(now.year, now.month + 1, 0).day)
        ? now
        : DateTime(now.year, now.month + 1, 0);

    startDateController.text = _formatDate(startDate!);
    endDateController.text = _formatDate(endDate!);
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorSecondary,
        elevation: 0,
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterModalSheet(context);
        },
        child: const Icon(Icons.filter_alt),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: colorSecondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Text(
              'User Scanning Report',
              style: TextStyle(
                color: white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          BlocBuilder<ScanningRecordCubit, ScanningRecordState>(
            builder: (context, state) {
              if (state is ScanningRecordLoading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is ScanningRecordLoaded) {
                scans = state.scans;
                return _buildReport(context);
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Text('An error occured. Please try again later.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReport(BuildContext context) {
    // Filter and aggregate data by DetectedObjectEntity's item
    final filteredScans = scans.where((scan) {
      final scanDate = scan.scanDate;
      return scanDate != null &&
          scanDate.isAfter(startDate!) &&
          scanDate.isBefore(endDate!.add(const Duration(days: 1)));
    }).toList();

    final Map<String, int> itemCounts = {};
    int totalCount = 0;

    // Aggregate counts by item
    for (var scan in filteredScans) {
      for (var detectedObject in scan.detectedObjectList ?? []) {
        final int count = detectedObject.count.toInt();
        itemCounts.update(detectedObject.item.name, (value) => value + count,
            ifAbsent: () => count);
        totalCount += count;
      }
    }

    // Convert data to pie chart format
    List<PieChartSectionData> sections = itemCounts.entries.map((entry) {
      final isSelected = entry.key.toLowerCase() == selectedItem?.toLowerCase();
      final double sectionRadius =
          isSelected ? 30.0 : 25.0; // Increase radius if selected

      return PieChartSectionData(
        color: _getColorForCategory(entry.key.toLowerCase()),
        value: entry.value.toDouble(),
        radius: sectionRadius,
        showTitle: false,
        title: '',
      );
    }).toList();

    // Ensure the sum of section values equals totalCount
    double totalValue = sections.fold(0, (sum, item) => sum + item.value);
    sections = sections.map((item) {
      // Adjust the value to match the totalCount proportionally
      final adjustedValue = (item.value / totalValue) * totalCount;
      return item.copyWith(value: adjustedValue);
    }).toList();

    return Transform.translate(
      offset: const Offset(0, -50),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Date Range
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Text(
                  '${_formatDate(startDate!)} - ${_formatDate(endDate!)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              totalCount != 0
                  ? SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event,
                                    PieTouchResponse? pieTouchResponse) {
                                  if (event is FlTapDownEvent) {
                                    if (pieTouchResponse != null &&
                                        pieTouchResponse.touchedSection !=
                                            null &&
                                        pieTouchResponse.touchedSection!
                                                .touchedSectionIndex >=
                                            0 &&
                                        pieTouchResponse.touchedSection!
                                                .touchedSectionIndex <
                                            itemCounts.keys.length) {
                                      setState(() {
                                        selectedItem = itemCounts.keys
                                            .elementAt(pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex);
                                      });
                                    } else {
                                      setState(() {
                                        selectedItem =
                                            null; // Reset selection when tapping outside any section
                                      });
                                    }
                                  }
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 70,
                              sections: sections,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Total Scanned',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '$totalCount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const Text(
                      'No records found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
              const SizedBox(height: 10),
              totalCount != 0
                  ? _buildReportDataTable(context, itemCounts, totalCount)
                  : Container(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 48.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedStartDate = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2023, 12),
                          lastDate: endDate ??
                              DateTime.now(), // End date or today's date
                        );
                        if (pickedStartDate != null) {
                          setModalState(() {
                            startDate = pickedStartDate;
                            startDateController.text =
                                _formatDate(pickedStartDate);
                          });
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedEndDate = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: startDate ??
                              DateTime(2023, 12), // Start date or December 2023
                          lastDate: DateTime.now(), // Today's date
                        );
                        if (pickedEndDate != null) {
                          setModalState(() {
                            endDate = pickedEndDate;
                            endDateController.text = _formatDate(pickedEndDate);
                          });
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getColorForCategory(String category) {
    return colorMap[category] ?? Colors.grey;
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    // Split string into multiple words
    final words = text.split(' ');
    // Capitalize each word
    final capitalizedWords = words.map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    return capitalizedWords;
  }

  Widget _buildReportDataTable(
    BuildContext context,
    Map<String, int> itemCounts,
    int totalCount,
  ) {
    // Normalize the keys in itemCounts to match the casing of colorMap
    final normalizedItemCounts = <String, int>{};
    itemCounts.forEach((key, value) {
      // Find the colorMap key that matches the detection key, ignoring case
      final colorMapKey = colorMap.keys.firstWhere(
        (k) => k.toLowerCase() == key.toLowerCase(),
        orElse: () => key,
      );
      // Sum the counts for keys that match ignoring case
      normalizedItemCounts.update(
        colorMapKey, // Preserve the case from colorMap
        (existing) => existing + value,
        ifAbsent: () => value,
      );
    });

    // Add missing items from colorMap with a count of 0
    for (var key in colorMap.keys) {
      normalizedItemCounts.putIfAbsent(key, () => 0);
    }

    // Sort the items first by count in descending order, then by name in ascending order
    final sortedItems = normalizedItemCounts.entries.toList()
      ..sort((a, b) {
        int compareCount = b.value.compareTo(a.value);
        if (compareCount == 0) {
          // If counts are equal, sort by name
          return a.key.compareTo(b.key);
        }
        return compareCount;
      });

    // Create DataRow list for the sorted items
    List<DataRow> dataRows = sortedItems.map((entry) {
      final isRowSelected =
          entry.key.toLowerCase() == selectedItem?.toLowerCase();
      final rowColor =
          isRowSelected ? Colors.grey[200] : null; // Highlight if selected

      double percent = totalCount > 0 ? entry.value / totalCount * 100 : 0.0;
      // Capitalize the first letter of each word for display
      String displayName = capitalize(entry.key);

      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>((states) => rowColor),
        cells: [
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorForCategory(entry.key.toLowerCase()),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(displayName), // Use the capitalized name
              ],
            ),
          ),
          DataCell(Text('${entry.value}')),
          DataCell(Text('${percent.toStringAsFixed(1)}%')),
        ],
      );
    }).toList();

    var boldText = const TextStyle(fontWeight: FontWeight.bold);
    return DataTable(
      columnSpacing: 18.0,
      columns: [
        DataColumn(label: Text('Item', style: boldText)),
        DataColumn(label: Text('Total', style: boldText), numeric: true),
        DataColumn(label: Text('%', style: boldText), numeric: true),
      ],
      rows: dataRows,
    );
  }
}
