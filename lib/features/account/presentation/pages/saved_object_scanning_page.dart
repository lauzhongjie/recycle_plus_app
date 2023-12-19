import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_record_cubit.dart';

class SavedObjectScanningPage extends StatefulWidget {
  const SavedObjectScanningPage({super.key});

  @override
  State<SavedObjectScanningPage> createState() =>
      _SavedObjectScanningPageState();
}

class _SavedObjectScanningPageState extends State<SavedObjectScanningPage> {
  String selectedMonth = 'All';
  String selectedYear = 'All';
  Map<String, bool> itemCheckboxStates = {};
  late String currentUid;

  @override
  void initState() {
    super.initState();
    // Initialize the checkbox states to false
    itemCheckboxStates = {
      for (var item in colorMap.keys)
        item
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' '): false
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is Authenticated) {
      currentUid = authState.uid;
      context.read<ScanningRecordCubit>().getAllUserScans(currentUid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning History'),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterModalSheet(context);
            },
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: BlocBuilder<ScanningRecordCubit, ScanningRecordState>(
        builder: (context, state) {
          if (state is ScanningRecordLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScanningRecordLoaded) {
            // Apply the filters to the list of scans
            var filteredScans = applyFilters(state.scans);
            return _buildSavedObjectScanningItems(context, filteredScans);
          } else if (state is ScanningRecordError) {
            return const Center(child: Text('Oops! An error occurred.'));
          }
          return _noFavAddedMsg();
        },
      ),
    );
  }

  Widget _buildSavedObjectScanningItems(
      BuildContext context, List<ScanEntity> scans) {
    if (scans.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No records found. Start scanning to track your recycling progress!",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // Grouping scans by month and year
    Map<String, List<ScanEntity>> groupedScans = {};
    for (var scan in scans) {
      String monthYear = DateFormat('MMMM yyyy').format(scan.scanDate!);
      if (groupedScans.containsKey(monthYear)) {
        groupedScans[monthYear]!.add(scan);
      } else {
        groupedScans[monthYear] = [scan];
      }
    }

    // Sorting month and year in ascending order
    var sortedKeys = groupedScans.keys.toList()
      ..sort((a, b) => DateFormat('MMMM yyyy')
          .parse(a)
          .compareTo(DateFormat('MMMM yyyy').parse(b)));

    // Sorting records within each month in ascending order
    for (var key in sortedKeys) {
      groupedScans[key]!.sort((a, b) => a.scanDate!.compareTo(b.scanDate!));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ListView(
        children: sortedKeys.expand((key) {
          var items = groupedScans[key]!
              .map((scan) => Column(
                    children: [
                      _buildScanItem(context, scan),
                    ],
                  ))
              .toList();
          return [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                key, // Month and year
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ...items,
          ];
        }).toList(),
      ),
    );
  }

  Widget _buildScanItem(BuildContext context, ScanEntity scan) {
    final itemNames = scan.detectedObjectList!
        .map((e) => e.item.name)
        .where((name) => name != null)
        .join(", ");

    final formattedDate = DateFormat('dd/MM/yyyy').format(scan.scanDate!);

    return Slidable(
      key: ValueKey(scan.id),
      closeOnScroll: true,
      startActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              context.read<ScanningRecordCubit>().removeScan(scan);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Remove',
          ),
        ],
      ),
      child: ListTile(
        leading: Image.asset(
          ImageConst.scanningIcon,
          color: colorPrimary,
          height: 24,
          width: 24,
        ),
        title: Text(
          itemNames.isNotEmpty ? itemNames : 'Unknown',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text('Scanned on $formattedDate'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(
            context,
            PageConst.savedObjectScanningResultPage,
            arguments: scan,
          );
        },
      ),
    );
  }

  Widget _noFavAddedMsg() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "You haven't scanned any items yet. Start scanning to track your recycling progress!",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<ScanEntity> applyFilters(List<ScanEntity> scans) {
    return scans.where((scan) {
      // Check for date filter
      bool isDateMatch = selectedMonth == 'All' && selectedYear == 'All';
      if (!isDateMatch) {
        String monthYear = DateFormat('MMMM yyyy').format(scan.scanDate!);
        isDateMatch = (selectedMonth == 'All' ||
                monthYear
                    .toLowerCase()
                    .contains(selectedMonth.toLowerCase())) &&
            (selectedYear == 'All' || monthYear.contains(selectedYear));
      }

      // Check for item filter
      bool isItemMatch = !itemCheckboxStates.containsValue(true);
      if (!isItemMatch) {
        var detectedItemsNames = scan.detectedObjectList!
            .map((e) =>
                e.item.name?.toLowerCase() ?? '') // Convert names to lowercase
            .toSet();
        isItemMatch = detectedItemsNames.any((itemName) =>
            itemCheckboxStates.keys.any((key) =>
                key.toLowerCase() == itemName && itemCheckboxStates[key]!));
      }

      return isDateMatch && isItemMatch;
    }).toList();
  }

  void _showFilterModalSheet(BuildContext context) {
    List<String> months = [
      'All',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    List<String> years = ['All'];
    years.addAll(List<String>.generate(
      DateTime.now().year - 2023 + 1,
      (index) => (2023 + index).toString(),
    ));

    // Extract unique item names for filtering
    var itemNames = colorMap.keys
        .map((itemName) => itemName
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' '))
        .toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.only(
                left: 32.0,
                right: 32.0,
                bottom: 32.0,
              ),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter By',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true, // Make dropdown wider
                          value: selectedMonth,
                          onChanged: (newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                              context
                                  .read<ScanningRecordCubit>()
                                  .getAllUserScans(currentUid);
                            });
                          },
                          items: months
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontSize: 16), // Larger text
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true, // Make dropdown wider
                          value: selectedYear,
                          onChanged: (newValue) {
                            setState(() {
                              selectedYear = newValue!;
                              context
                                  .read<ScanningRecordCubit>()
                                  .getAllUserScans(currentUid);
                            });
                          },
                          items: years
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontSize: 16), // Larger text
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: itemNames.length,
                      itemBuilder: (context, index) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              itemNames[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                            value: itemCheckboxStates[itemNames[index]],
                            onChanged: (bool? newValue) {
                              setState(() {
                                itemCheckboxStates[itemNames[index]] =
                                    newValue!;
                                context
                                    .read<ScanningRecordCubit>()
                                    .getAllUserScans(currentUid);
                              });
                            },
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
