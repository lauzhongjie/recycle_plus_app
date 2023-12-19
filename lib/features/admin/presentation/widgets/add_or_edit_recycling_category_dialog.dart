import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';

class AddOrEditRecyclingCategoryDialog extends StatefulWidget {
  final List<RCategoryEntity> allCategories;
  final RCategoryEntity? rCategory;

  const AddOrEditRecyclingCategoryDialog(
      {super.key, this.rCategory, required this.allCategories});

  @override
  State<AddOrEditRecyclingCategoryDialog> createState() =>
      _AddOrEditRecyclingCategoryDialogState();
}

class _AddOrEditRecyclingCategoryDialogState
    extends State<AddOrEditRecyclingCategoryDialog> {
  XFile? _image;
  String? _imageUrl;
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitPressed = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
        _imageUrl = null;
      });
      _validateInputs();
    }
  }

  void _validateInputs() {
    setState(() {
      _isSubmitPressed = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInputs);
    _validateInputs();

    if (widget.rCategory != null) {
      _nameController.text = widget.rCategory!.name!;
      if (widget.rCategory!.imageUrl != null &&
          widget.rCategory!.imageUrl!.startsWith('http')) {
        _imageUrl = widget.rCategory!.imageUrl;
      } else {
        _image = XFile(widget.rCategory!.imageUrl!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateInputs);
    _nameController.dispose();
    super.dispose();
  }

  bool _isNameAlreadyExists() {
    return widget.allCategories.any((category) {
      // If editing, allow the same name as the current category
      if (widget.rCategory != null && category.name == widget.rCategory!.name) {
        return false;
      }

      return category.name!.toLowerCase() ==
          _nameController.text.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? errorMessage;

    if (_isSubmitPressed) {
      bool isImageMissing = _image == null && _imageUrl == null;
      bool isNameNotEmpty = _nameController.text.isNotEmpty;
      bool isNameAlreadyExists = _isNameAlreadyExists();

      if (isImageMissing && !isNameNotEmpty) {
        errorMessage = 'Please select an image and enter a name.';
      } else if (isImageMissing) {
        errorMessage = 'Please select an image.';
      } else if (!isNameNotEmpty) {
        errorMessage = 'Please enter a name.';
      } else if (isNameAlreadyExists) {
        errorMessage =
            'This category is already registered. Please enter a different name.';
      }
    }

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
                      widget.rCategory == null
                          ? 'Add New Category'
                          : 'Edit "${widget.rCategory!.name}" Category',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          _image != null
                              ? Image.file(File(_image!.path),
                                  width: 70, height: 70)
                              : (_imageUrl != null
                                  ? Image.network(_imageUrl!,
                                      width: 70, height: 70)
                                  : const Icon(Icons.image, size: 70)),
                          const SizedBox(height: 10),
                          Text(
                            widget.rCategory == null
                                ? 'Select image'
                                : 'Change image',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isSubmitPressed = true;
                          });

                          bool isImageSelectedOrExists =
                              _image != null || _imageUrl != null;
                          bool isNameNotEmpty = _nameController.text.isNotEmpty;
                          bool isNameAlreadyExists = _isNameAlreadyExists();

                          if (widget.rCategory == null && isNameAlreadyExists) {
                            return;
                          }

                          if (isNameNotEmpty &&
                              isImageSelectedOrExists &&
                              !isNameAlreadyExists) {
                            File? imageFile;
                            if (_image != null) {
                              imageFile = File(_image!.path);
                            }

                            // Add new category
                            if (widget.rCategory == null) {
                              BlocProvider.of<RCategoryCubit>(context)
                                  .addNewRCategory(
                                RCategoryEntity(
                                    name: _nameController.text.trim()),
                                imageFile!,
                              );
                              _showSnackbar('Category added successfully');
                            }
                            // Update existing category
                            else {
                              BlocProvider.of<RCategoryCubit>(context)
                                  .updateRCategory(
                                RCategoryEntity(
                                  id: widget.rCategory!.id,
                                  name: _nameController.text,
                                  imageUrl: widget.rCategory!.imageUrl,
                                ),
                                imageFile,
                              );
                              _showSnackbar('Category edited successfully');
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
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
