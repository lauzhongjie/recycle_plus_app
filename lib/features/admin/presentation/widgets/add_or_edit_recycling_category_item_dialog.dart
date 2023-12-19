import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_item_cubit.dart';

enum RecyclableOption { yes, no }

class AddOrEditRecyclingCategoryItemDialog extends StatefulWidget {
  final RCategoryEntity rCategory;
  final RCategoryItemEntity? item;
  final bool? isInObjectDetection;
  final List<RCategoryItemEntity> rCategoryItems;

  const AddOrEditRecyclingCategoryItemDialog(
      {super.key,
      required this.rCategory,
      this.item,
      this.isInObjectDetection,
      required this.rCategoryItems});

  @override
  State<AddOrEditRecyclingCategoryItemDialog> createState() =>
      _AddOrEditRecyclingCategoryItemDialogState();
}

class _AddOrEditRecyclingCategoryItemDialogState
    extends State<AddOrEditRecyclingCategoryItemDialog> {
  final TextEditingController _nameController = TextEditingController();
  RecyclableOption? _selectedOption = RecyclableOption.yes;
  List<TextEditingController> stepControllers = [TextEditingController()];
  bool _isConfirmPressed = false;

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      // Default values for existing item
      _nameController.text = widget.item!.name!;
      _selectedOption = widget.item!.recyclability!
          ? RecyclableOption.yes
          : RecyclableOption.no;

      // Initialize step controllers with the existing item's steps
      stepControllers = widget.item!.recyclingStepList!
          .map((step) => TextEditingController(text: step))
          .toList();
    } else {
      // Default values for new item
      _selectedOption = RecyclableOption.yes;
      stepControllers = [TextEditingController()];
    }

    _addListenersToStepControllers();
    _nameController.addListener(_validateInputs);
  }

  void _addListenersToStepControllers() {
    for (var controller in stepControllers) {
      controller.addListener(_validateInputs);
    }
  }

  void _validateInputs() {
    if (_nameController.text.isNotEmpty &&
        stepControllers.every((controller) => controller.text.isNotEmpty) &&
        _selectedOption != null) {
      setState(() {
        _isConfirmPressed = false; // Hide the error message
      });
    }
  }

  bool _isItemNameUnique() {
    return widget.rCategoryItems.every((existingItem) {
      // Allow the same name if it's the current item being edited
      if (widget.item != null && existingItem.id == widget.item!.id) {
        return true;
      }
      // Check if the name is unique
      return existingItem.name!.toLowerCase() !=
          _nameController.text.trim().toLowerCase();
    });
  }

  void _addNewStepController() {
    if (stepControllers.length < 5) {
      setState(() {
        var newController = TextEditingController();
        stepControllers.add(newController);
        _addListenersToStepControllers();
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateInputs);
    for (var controller in stepControllers) {
      controller.removeListener(_validateInputs);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    vertical: 48.0, horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item == null
                          ? 'Add New Item'
                          : 'Edit "${widget.item!.name}" Item',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Image.network(
                          widget.rCategory.imageUrl!,
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(height: 10),
                        Text('Category: ${widget.rCategory.name!}'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: widget.isInObjectDetection ?? false
                              ? darkGrey
                              : black,
                        ),
                      ),
                      style: TextStyle(
                        color: widget.isInObjectDetection ?? false
                            ? darkGrey
                            : black,
                      ),
                      cursorColor: widget.isInObjectDetection ?? false
                          ? Colors.transparent
                          : black,
                      enabled: !(widget.isInObjectDetection ?? false),
                    ),
                    if (widget.isInObjectDetection != null &&
                        widget.isInObjectDetection!)
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            'This item\'s name cannot be changed.',
                            style: TextStyle(color: darkGrey),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Is it Recyclable?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            // 'Yes' option
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<RecyclableOption>(
                                    value: RecyclableOption.yes,
                                    groupValue: _selectedOption,
                                    activeColor: colorSecondary,
                                    onChanged: (RecyclableOption? value) {
                                      setState(() {
                                        _selectedOption = value;
                                      });
                                    },
                                  ),
                                  const Text('Yes'),
                                ],
                              ),
                            ),
                            // 'No' option
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<RecyclableOption>(
                                    value: RecyclableOption.no,
                                    groupValue: _selectedOption,
                                    activeColor: Colors.red,
                                    onChanged: (RecyclableOption? value) {
                                      setState(() {
                                        _selectedOption = value;
                                      });
                                    },
                                  ),
                                  const Text('No'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          _selectedOption == RecyclableOption.yes
                              ? 'How to Recycle?'
                              : 'How to Dispose?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    for (int i = 0; i < stepControllers.length; i++)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: stepControllers[i],
                                  decoration: InputDecoration(
                                    labelText: 'Step ${i + 1}',
                                  ),
                                ),
                              ),
                              if (stepControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    setState(() {
                                      stepControllers[i].dispose();
                                      stepControllers.removeAt(i);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    if (stepControllers.length == 5)
                      const Text(
                        'Maximum steps reached.',
                        style: TextStyle(
                          color: darkGrey,
                        ),
                      ),
                    const SizedBox(height: 15),
                    if (stepControllers.length < 5)
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (stepControllers.length < 5) {
                                setState(() {
                                  _addNewStepController();
                                  _isConfirmPressed =
                                      false; // Hide the error message
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isConfirmPressed = true;
                          });

                          if (_allInputsValid()) {
                            if (widget.item == null) {
                              _addNewItemToFirebase();
                            } else {
                              _editExistingItemInFirebase();
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('CONFIRM'),
                        ),
                      ),
                    ),
                    if (_isConfirmPressed && !_allInputsValid())
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          !_isItemNameUnique()
                              ? 'This item is already registered. Please enter a different name.'
                              : 'Please fill in all fields.',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 4.0,
                top: 4.0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RCategoryItemEntity _createItemEntity() {
    bool recyclable = _selectedOption == RecyclableOption.yes;
    List<String> steps =
        stepControllers.map((controller) => controller.text).toList();

    return RCategoryItemEntity(
      id: widget.item?.id, // null if it's a new item
      name: _nameController.text,
      recyclability: recyclable,
      recyclingStepList: steps,
    );
  }

  void _addNewItemToFirebase() {
    RCategoryItemEntity item = _createItemEntity();

    BlocProvider.of<RCategoryItemCubit>(context)
        .addNewRCategoryItem(widget.rCategory.id!, item);

    _showSnackbar('Item added successfully');
  }

  void _editExistingItemInFirebase() {
    RCategoryItemEntity item = _createItemEntity();

    BlocProvider.of<RCategoryItemCubit>(context)
        .updateRCategoryItem(widget.rCategory.id!, item);

    _showSnackbar('Item edited successfully');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _allInputsValid() {
    String name = _nameController.text;
    bool allStepsFilled =
        stepControllers.every((controller) => controller.text.isNotEmpty);
    bool isNameUnique = _isItemNameUnique();

    return name.isNotEmpty &&
        allStepsFilled &&
        _selectedOption != null &&
        isNameUnique;
  }
}
