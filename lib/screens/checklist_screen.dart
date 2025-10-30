import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/checklist_tile.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final UserService _userService = UserService();
  Map<String, bool> _checklistState = {};
  bool _isLoading = true;
  Map<String, List<String>> _customCategories = {};

  static const String goBagCategory = 'Emergency Go Bag';
  static const String homeCategory = 'Home Preparation';
  static const String otherCategory = 'Others';

  final List<String> _goBagItems = const [
    'Bottled water (1 gallon per person per day)',
    'Non-perishable food (good for 3 days)',
    'Flashlight with extra batteries',
    'First-aid kit',
    'Whistle to signal for help',
    'Copies of important documents (passports, IDs)',
    'Cash in small denominations',
    'Medications and prescription info',
    'Phone with power bank',
    'Face masks',
  ];
  
  final List<String> _homeItems = const [
    'Secure heavy furniture to walls',
    'Know location of gas, water, and electricity shutoffs',
    'Check fire extinguisher expiration date',
    'Prepare a family emergency plan',
    'Designate a safe meeting place',
  ];

  final Map<String, Map<String, String>> _itemDetails = {
    'Bottled water (1 gallon per person per day)': {
      'detail': 'assets/audio/images/water_detail.jpg',
      'tips': 'Store in cool, dry place. Rotate every 6 months. Plan for 3 days minimum.',
    },
    'Non-perishable food (good for 3 days)': {
      'detail': 'assets/audio/images/food_detail.jpg',
      'tips': 'Include canned goods, energy bars, dried fruits. Check expiration dates.',
    },
    'Flashlight with extra batteries': {
      'detail': 'assets/audio/images/flashlight_detail.jpg',
      'tips': 'LED flashlights last longer. Store batteries separately to prevent drain.',
    },
    'First-aid kit': {
      'detail': 'assets/audio/images/firstaid_detail.jpg',
      'tips': 'Include bandages, antiseptic, pain relievers, and personal medications.',
    },
    'Whistle to signal for help': {
      'detail': 'assets/audio/images/whistle_detail.jpg',
      'tips': 'Louder than voice. Use 3 short blasts to signal distress.',
    },
    'Copies of important documents (passports, IDs)': {
      'detail': 'assets/audio/images/passport_detail.jpg',
      'tips': 'Store in waterproof bag. Include insurance papers and contact info.',
    },
    'Cash in small denominations': {
      'detail': 'assets/audio/images/cash_detail.jpg',
      'tips': 'ATMs may not work. Keep bills under ₱100 for easier transactions.',
    },
    'Medications and prescription info': {
      'detail': 'assets/audio/images/meds_detail.jpg',
      'tips': 'Include prescription copies. Update regularly. Store in cool place.',
    },
    'Phone with power bank': {
      'detail': 'assets/audio/images/phone_detail.jpg',
      'tips': 'Keep power bank charged. Include charging cables. Save emergency contacts.',
    },
    'Face masks': {
      'detail': 'assets/audio/images/facemask_detail.jpg',
      'tips': 'N95 masks protect from dust and smoke. Include several per person.',
    },
    'Secure heavy furniture to walls': {
      'detail': 'assets/audio/images/furniture_detail.jpg',
      'tips': 'Use L-brackets for bookcases. Prevents tipping during earthquakes.',
    },
    'Know location of gas, water, and electricity shutoffs': {
      'detail': 'assets/audio/images/shutoff_detail.jpg',
      'tips': 'Label valves. Keep wrench nearby. Teach all family members.',
    },
    'Check fire extinguisher expiration date': {
      'detail': 'assets/audio/images/extinguisher_detail.jpg',
      'tips': 'Check pressure gauge monthly. Replace if expired. Learn PASS technique.',
    },
    'Prepare a family emergency plan': {
      'detail': 'assets/audio/images/plan_detail.jpg',
      'tips': 'Include evacuation routes. Assign roles. Practice twice yearly.',
    },
    'Designate a safe meeting place': {
      'detail': 'assets/audio/images/meeting_detail.jpg',
      'tips': 'Choose a nearby and distant location. Share with all family members.',
    },
  };
  
  String _getUniqueKey(String category, String itemTitle) {
    return "$category::$itemTitle";
  }

  IconData _getIconForItem(String itemTitle) {
    final titleLower = itemTitle.toLowerCase();
    
    if (titleLower.contains('water')) return Icons.water_drop_outlined;
    if (titleLower.contains('food')) return Icons.fastfood_outlined;
    if (titleLower.contains('flashlight')) return Icons.flashlight_on;
    if (titleLower.contains('first-aid')) return Icons.medical_services_outlined;
    if (titleLower.contains('whistle')) return Icons.campaign_outlined;
    if (titleLower.contains('documents') || titleLower.contains('passport')) return Icons.description_outlined;
    if (titleLower.contains('cash')) return Icons.attach_money_outlined;
    if (titleLower.contains('medications')) return Icons.medication_outlined;
    if (titleLower.contains('phone') || titleLower.contains('power bank')) return Icons.battery_charging_full_outlined;
    if (titleLower.contains('mask')) return Icons.masks_outlined;
    if (titleLower.contains('secure heavy furniture')) return Icons.security_outlined;
    if (titleLower.contains('shutoffs')) return Icons.electrical_services_outlined;
    if (titleLower.contains('fire extinguisher')) return Icons.fire_extinguisher_outlined;
    if (titleLower.contains('plan')) return Icons.groups_outlined;
    if (titleLower.contains('meeting place')) return Icons.place_outlined;
    
    return Icons.format_list_bulleted;
  }

  List<String> _getAllItemsForCategory(String category) {
    List<String> combinedItems;
    List<String> customItemsForCategory = _customCategories[category] ?? [];

    if (category == goBagCategory) {
      combinedItems = [..._goBagItems, ...customItemsForCategory];
    } else if (category == homeCategory) {
      combinedItems = [..._homeItems, ...customItemsForCategory];
    } else {
      List<String> itemsFromState = _checklistState.keys
          .where((key) => key.startsWith("$category::"))
          .map((key) {
            final parts = key.split("::");
            return parts.length > 1 ? parts[1] : '';
          })
          .where((item) => item.isNotEmpty)
          .toList();
      combinedItems = [...customItemsForCategory, ...itemsFromState];
    }
    return Set<String>.from(combinedItems).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadChecklistData();
  }

  Future<void> _loadChecklistData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _userService.getChecklistData();
      if (mounted) {
        setState(() {
          _checklistState = data['checklistState'] ?? {};
          _customCategories = data['customChecklistCategories'] ?? {};
          print("Loaded Data: State=$_checklistState, CustomCats=$_customCategories");
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading checklist: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveChecklistData() async {
    final Map<String, bool> stateToSave = Map.from(_checklistState);
    final Map<String, List<String>> categoriesToSave = {};
    _customCategories.forEach((key, value) {
      categoriesToSave[key] = List.from(value);
    });

    print("Attempting to save: State=$stateToSave, CustomCats=$categoriesToSave");

    try {
      await _userService.saveChecklistData(
        checklistState: stateToSave,
        customCategories: categoriesToSave,
      );
      print("Save successful.");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving checklist: $e')),
        );
      } else {
        print("Error saving checklist after widget disposed: $e");
      }
    }
  }

  Future<void> _handleItemChanged(
      String category, String itemTitle, bool isChecked) async {
    if (!mounted) return;
    setState(() {
      final uniqueKey = _getUniqueKey(category, itemTitle);
      _checklistState[uniqueKey] = isChecked;
      print("Check state changed for $uniqueKey to $isChecked (Local State: $_checklistState)");
    });
    await _saveChecklistData();
    print("Data saved after check change.");
  }

  Future<void> _deleteCustomItem(String itemTitle, String category) async {
    if (!mounted) return;

    print("--- Initiating delete for '$itemTitle' in '$category' ---");
    final uniqueKeyToDelete = _getUniqueKey(category, itemTitle);
    print("State BEFORE delete attempt: $_checklistState");
    print("Custom Cats BEFORE delete attempt: $_customCategories");

    bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Item?'),
              content: Text(
                  'Are you sure you want to delete "$itemTitle" from "$category"? This cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ));

    if (confirmed == true && mounted) {
      print("Delete confirmed by user.");
      bool removedFromStateInSetState = false;

      setState(() {
        print("Inside setState for delete...");
        final lowerCaseTitleToDelete = itemTitle.toLowerCase();

        bool removedFromList = false;
        if (_customCategories.containsKey(category)) {
          int initialLength = _customCategories[category]?.length ?? 0;
          _customCategories[category]?.removeWhere(
              (item) => item.toLowerCase() == lowerCaseTitleToDelete);
          removedFromList = (_customCategories[category]?.length ?? 0) < initialLength;
          print("  Removed '$itemTitle' from _customCategories['$category'] list: $removedFromList");

          if ((_customCategories[category]?.isEmpty ?? false) &&
              category != goBagCategory &&
              category != homeCategory &&
              category != otherCategory) {
            _customCategories.remove(category);
            print("  Removed empty custom category key: $category");
          }
        } else {
          print("  Category '$category' not found in _customCategories map.");
        }

        print("  Attempting to remove state key: $uniqueKeyToDelete");
        print("  State map BEFORE removal: $_checklistState");
        var removedValue = _checklistState.remove(uniqueKeyToDelete);
        removedFromStateInSetState = removedValue != null;
        print("  State map AFTER removal: $_checklistState");
        print("  State key removed inside setState: $removedFromStateInSetState. (Removed value: $removedValue)");
      });

      print("Calling _saveChecklistData AFTER setState (state key removed successfully: $removedFromStateInSetState)...");
      if (removedFromStateInSetState) {
        await _saveChecklistData();
        print("--- Deletion process complete for '$itemTitle' ---");
      } else {
        print("--- ERROR: State key removal failed locally. Save aborted. ---");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: Could not remove item state locally. Deletion may not persist.'),
                backgroundColor: Colors.orange),
          );
        }
      }
    } else {
      print("Deletion cancelled by user or widget disposed.");
    }
  }

  List<Widget> _buildSortedTiles(String category) {
    List<String> predefinedItems = [];
    if (category == goBagCategory) {
      predefinedItems = _goBagItems;
    } else if (category == homeCategory) {
      predefinedItems = _homeItems;
    } else {
      predefinedItems = [];
    }

    final allItemsInCategory = _getAllItemsForCategory(category);
    if (allItemsInCategory.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final uncheckedItems = allItemsInCategory
        .where((item) => !(_checklistState[_getUniqueKey(category, item)] ?? false))
        .toList();
    final checkedItems = allItemsInCategory
        .where((item) => (_checklistState[_getUniqueKey(category, item)] ?? false))
        .toList();
    final uncheckedPredefined = uncheckedItems
        .where((i) => predefinedItems.any((pi) => pi.toLowerCase() == i.toLowerCase()))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final uncheckedCustom = uncheckedItems
        .where((i) => !predefinedItems.any((pi) => pi.toLowerCase() == i.toLowerCase()))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final checkedPredefined = checkedItems
        .where((i) => predefinedItems.any((pi) => pi.toLowerCase() == i.toLowerCase()))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final checkedCustom = checkedItems
        .where((i) => !predefinedItems.any((pi) => pi.toLowerCase() == i.toLowerCase()))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final sortedItems = [
      ...uncheckedPredefined,
      ...uncheckedCustom,
      ...checkedPredefined,
      ...checkedCustom
    ];

    return sortedItems.map<Widget>((item) {
      final uniqueKey = _getUniqueKey(category, item);
      final bool isChecked = _checklistState[uniqueKey] ?? false;
      final bool allowDelete = !predefinedItems
          .any((predefined) => predefined.toLowerCase() == item.toLowerCase());
      final bool isCustomForDisplay = allowDelete;
      final IconData itemIcon = _getIconForItem(item);

      final itemDetail = _itemDetails[item];
      final String? detailImagePath = itemDetail?['detail'];
      final String? tips = itemDetail?['tips'];

      return ChecklistTile(
        key: ValueKey(uniqueKey),
        title: item,
        initialValue: isChecked,
        isCustom: isCustomForDisplay,
        leadingIcon: itemIcon,
        detailImagePath: detailImagePath,
        tips: tips,
        onChanged: (isChecked) async {
          await _handleItemChanged(category, item, isChecked);
        },
        onDelete: allowDelete
            ? () async {
                await _deleteCustomItem(item, category);
              }
            : null,
      );
    }).toList();
  }

  void _showAddItemDialog() {
    if (!mounted) return;
    final TextEditingController itemController = TextEditingController();
    final TextEditingController newCategoryController = TextEditingController();
    String? selectedCategoryValue = goBagCategory;
    bool useNewCategory = false;
    List<String> displayCategories = [
      goBagCategory,
      homeCategory,
      otherCategory,
      ..._customCategories.keys
          .where((k) => k != goBagCategory && k != homeCategory && k != otherCategory)
          .toList()
        ..sort()
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Checklist Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Select Category:'),
                    ...displayCategories
                        .map((category) => RadioListTile<String>(
                              title: Text(category),
                              value: category,
                              groupValue: useNewCategory ? null : selectedCategoryValue,
                              onChanged: (String? value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedCategoryValue = value;
                                    useNewCategory = false;
                                    newCategoryController.clear();
                                  });
                                }
                              },
                            )),
                    Row(
                      children: [
                        Checkbox(
                          value: useNewCategory,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              useNewCategory = value ?? false;
                              if (useNewCategory) {
                                selectedCategoryValue = null;
                              } else if (selectedCategoryValue == null &&
                                  displayCategories.isNotEmpty) {
                                selectedCategoryValue = displayCategories.first;
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: newCategoryController,
                            enabled: useNewCategory,
                            decoration: InputDecoration(
                              hintText: useNewCategory
                                  ? "Enter new category name"
                                  : "Create New Category...",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: itemController,
                      decoration: const InputDecoration(
                        hintText: "Enter item description",
                        labelText: 'New Item Description',
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    final newItem = itemController.text.trim();
                    final String categoryToAdd;
                    if (useNewCategory) {
                      categoryToAdd = newCategoryController.text.trim();
                      if (categoryToAdd.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('New category name cannot be empty.'),
                                  backgroundColor: Colors.red));
                        }
                        return;
                      }
                      if (categoryToAdd.toLowerCase() == goBagCategory.toLowerCase() ||
                          categoryToAdd.toLowerCase() == homeCategory.toLowerCase() ||
                          categoryToAdd.toLowerCase() == otherCategory.toLowerCase()) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Cannot reuse standard category names ("$goBagCategory", "$homeCategory", "$otherCategory").'),
                              backgroundColor: Colors.orange));
                        }
                        return;
                      }
                    } else if (selectedCategoryValue != null) {
                      categoryToAdd = selectedCategoryValue!;
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select or create a category.'),
                                backgroundColor: Colors.red));
                      }
                      return;
                    }
                    if (newItem.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Item description cannot be empty.'),
                                backgroundColor: Colors.red));
                      }
                      return;
                    }
                    final categoryItemsLower = _getAllItemsForCategory(categoryToAdd)
                        .map((i) => i.toLowerCase())
                        .toList();
                    if (categoryItemsLower.contains(newItem.toLowerCase())) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Item "$newItem" already exists in category "$categoryToAdd".'),
                            backgroundColor: Colors.orange));
                      }
                      return;
                    }

                    if (mounted) {
                      setState(() {
                        _customCategories.putIfAbsent(categoryToAdd, () => []);
                        _customCategories[categoryToAdd]!.add(newItem);
                        final uniqueKey = _getUniqueKey(categoryToAdd, newItem);
                        _checklistState[uniqueKey] = false;
                        print("Adding item '$newItem' to category '$categoryToAdd' with key '$uniqueKey'");
                      });
                    } else {
                      return;
                    }

                    await _saveChecklistData();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customKeys = _customCategories.keys.toList();
    final Set<String> categorySet = {
      goBagCategory,
      homeCategory,
      otherCategory,
      ...customKeys
    };
    final List<String> allCategoryNames = categorySet.toList()
      ..sort((a, b) {
        if (a == goBagCategory) return -1;
        if (b == goBagCategory) return 1;
        if (a == homeCategory) return -1;
        if (b == homeCategory) return 1;
        if (a == otherCategory) return -1;
        if (b == otherCategory) return 1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const ScreenHeader(
            title: 'Safety Checklist',
            subtitle: 'Prepare your Go Bag and Home',
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: allCategoryNames.length,
                    itemBuilder: (context, index) {
                      final categoryName = allCategoryNames[index];
                      final categoryTiles = _buildSortedTiles(categoryName);
                      bool showSection = true;
                      if (categoryTiles.length == 1 &&
                          categoryTiles.first is SizedBox &&
                          (categoryTiles.first as SizedBox).height == 0) {
                        if (categoryName != goBagCategory &&
                            categoryName != homeCategory &&
                            categoryName != otherCategory) {
                          showSection = false;
                        }
                      }
                      if (!showSection) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: (index == allCategoryNames.length - 1) ? 0 : 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(categoryName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (categoryTiles.length == 1 &&
                                categoryTiles.first is SizedBox &&
                                (categoryTiles.first as SizedBox).height == 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('No items added yet.',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic)),
                              )
                            else
                              Column(children: categoryTiles),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}