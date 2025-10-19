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

  String _getUniqueKey(String category, String itemTitle) {
    return "$category::$itemTitle";
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

  List<String> get _allItemsAcrossCategories {
    List<String> all = [..._goBagItems, ..._homeItems];
    _customCategories.forEach((_, items) {
      all.addAll(items);
    });
    _checklistState.keys.forEach((key) {
      if (key.contains("::")) {
        final parts = key.split("::");
        if (parts.length > 1 && parts[1].isNotEmpty) {
          all.add(parts[1]);
        }
      }
    });
    return Set<String>.from(all).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadChecklistData();
  }

  Future<void> _loadChecklistData() async {
    /* ... same as before ... */
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _userService.getChecklistData();
      if (mounted) {
        setState(() {
          _checklistState = data['checklistState'] ?? {};
          _customCategories = data['customChecklistCategories'] ?? {};
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
    /* ... same cleanup logic as before ... */
    Map<String, List<String>> cleanedCustomCategories = {};
    Map<String, bool> cleanedChecklistState = {};
    _checklistState.forEach((key, isChecked) {
      if (key.contains("::")) {
        var parts = key.split("::");
        if (parts.length < 2 || parts[1].isEmpty) return;
        String cat = parts[0];
        String item = parts[1];
        cleanedChecklistState[key] = isChecked;
        bool isPredefinedInPlace = (cat == goBagCategory &&
                _goBagItems
                    .any((pi) => pi.toLowerCase() == item.toLowerCase())) ||
            (cat == homeCategory &&
                _homeItems.any((pi) => pi.toLowerCase() == item.toLowerCase()));
        if (!isPredefinedInPlace) {
          cleanedCustomCategories.putIfAbsent(cat, () => []);
          if (!cleanedCustomCategories[cat]!
              .any((ci) => ci.toLowerCase() == item.toLowerCase())) {
            cleanedCustomCategories[cat]!.add(item);
          }
        }
      }
    });
    cleanedCustomCategories.forEach((cat, items) {
      items.removeWhere((item) =>
          !cleanedChecklistState.containsKey(_getUniqueKey(cat, item)));
    });
    cleanedCustomCategories
        .removeWhere((cat, items) => items.isEmpty && cat != otherCategory);
    _customCategories = cleanedCustomCategories;
    _checklistState = cleanedChecklistState;
    try {
      await _userService.saveChecklistData(
        checklistState: _checklistState,
        customCategories: _customCategories,
      );
      print(
          "Saved Data: State=$_checklistState, CustomCats=$_customCategories");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving checklist: $e')),
        );
      }
    }
  }

  void _handleItemChanged(String category, String itemTitle, bool isChecked) {
    /* ... same as before ... */
    setState(() {
      final uniqueKey = _getUniqueKey(category, itemTitle);
      _checklistState[uniqueKey] = isChecked;
    });
    _saveChecklistData();
  }

  void _deleteCustomItem(String itemTitle, String category) {
    /* ... same as before ... */
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Item?'),
              content: Text(
                  'Are you sure you want to delete "$itemTitle" from "$category"? This cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      final lowerCaseTitleToDelete = itemTitle.toLowerCase();
                      final uniqueKeyToDelete =
                          _getUniqueKey(category, itemTitle);
                      _customCategories[category]?.removeWhere((item) =>
                          item.toLowerCase() == lowerCaseTitleToDelete);
                      if ((_customCategories[category]?.isEmpty ?? false) &&
                          category != goBagCategory &&
                          category != homeCategory &&
                          category != otherCategory) {
                        _customCategories.remove(category);
                      }
                      _checklistState.remove(uniqueKeyToDelete);
                      print("Removing state for key: $uniqueKeyToDelete");
                    });
                    _saveChecklistData();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ));
  }

  // ⭐ CORRECTED Helper function to build sorted list tiles
  List<Widget> _buildSortedTiles(String category) {
    List<String> predefinedItems;
    // Assign the correct predefined list based on the category
    if (category == goBagCategory) {
      predefinedItems = _goBagItems;
    } else if (category == homeCategory) {
      predefinedItems = _homeItems;
    } else {
      // For "Others" or any user-created category, there are no predefined items
      predefinedItems = [];
    }

    final allItemsInCategory = _getAllItemsForCategory(category);
    if (allItemsInCategory.isEmpty) {
      return [const SizedBox.shrink()];
    }

    // --- Sorting Logic (remains the same) ---
    final uncheckedItems = allItemsInCategory
        .where((item) =>
            !(_checklistState[_getUniqueKey(category, item)] ?? false))
        .toList();
    final checkedItems = allItemsInCategory
        .where(
            (item) => (_checklistState[_getUniqueKey(category, item)] ?? false))
        .toList();
    final uncheckedPredefined = uncheckedItems
        .where((i) => predefinedItems.contains(i))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final uncheckedCustom = uncheckedItems
        .where((i) => !predefinedItems.contains(i))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final checkedPredefined = checkedItems
        .where((i) => predefinedItems.contains(i))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final checkedCustom = checkedItems
        .where((i) => !predefinedItems.contains(i))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final sortedItems = [
      ...uncheckedPredefined,
      ...uncheckedCustom,
      ...checkedPredefined,
      ...checkedCustom
    ];
    // --- End Sorting Logic ---

    return sortedItems.map((item) {
      final uniqueKey = _getUniqueKey(category, item);
      final bool isChecked = _checklistState[uniqueKey] ?? false;

      // ⭐ CORRECTED FIX FOR DELETABILITY: Deletable if NOT in this category's specific predefined list.
      final bool allowDelete = !predefinedItems
          .any((predefined) => predefined.toLowerCase() == item.toLowerCase());

      // For visual distinction: Use the same logic as deletability for consistency
      final bool isCustomForDisplay = allowDelete;

      return ChecklistTile(
        key: ValueKey(uniqueKey),
        title: item,
        initialValue: isChecked,
        isCustom: isCustomForDisplay, // Visual marker
        onChanged: (isChecked) => _handleItemChanged(category, item, isChecked),
        // Pass delete callback ONLY if it's allowed for this category instance
        onDelete: allowDelete ? () => _deleteCustomItem(item, category) : null,
      );
    }).toList();
  }

  // Dialog to add item (remains the same)
  void _showAddItemDialog() {
    /* ... same as before ... */
    final TextEditingController itemController = TextEditingController();
    final TextEditingController newCategoryController = TextEditingController();
    String? selectedCategoryValue = goBagCategory;
    bool useNewCategory = false;
    List<String> displayCategories = [
      goBagCategory,
      homeCategory,
      otherCategory,
      ..._customCategories.keys
          .where((k) =>
              k != goBagCategory && k != homeCategory && k != otherCategory)
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
                              groupValue:
                                  useNewCategory ? null : selectedCategoryValue,
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
                  onPressed: () {
                    final newItem = itemController.text.trim();
                    final String categoryToAdd;
                    if (useNewCategory) {
                      categoryToAdd = newCategoryController.text.trim();
                      if (categoryToAdd.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('New category name cannot be empty.'),
                                backgroundColor: Colors.red));
                        return;
                      }
                      if (categoryToAdd.toLowerCase() ==
                              goBagCategory.toLowerCase() ||
                          categoryToAdd.toLowerCase() ==
                              homeCategory.toLowerCase() ||
                          categoryToAdd.toLowerCase() ==
                              otherCategory.toLowerCase()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Cannot reuse standard category names ("$goBagCategory", "$homeCategory", "$otherCategory").'),
                            backgroundColor: Colors.orange));
                        return;
                      }
                    } else if (selectedCategoryValue != null) {
                      categoryToAdd = selectedCategoryValue!;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please select or create a category.'),
                          backgroundColor: Colors.red));
                      return;
                    }
                    if (newItem.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Item description cannot be empty.'),
                          backgroundColor: Colors.red));
                      return;
                    }
                    final categoryItemsLower =
                        _getAllItemsForCategory(categoryToAdd)
                            .map((i) => i.toLowerCase())
                            .toList();
                    if (categoryItemsLower.contains(newItem.toLowerCase())) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Item "$newItem" already exists in category "$categoryToAdd".'),
                          backgroundColor: Colors.orange));
                      return;
                    }
                    setState(() {
                      _customCategories.putIfAbsent(categoryToAdd, () => []);
                      _customCategories[categoryToAdd]!.add(newItem);
                      final uniqueKey = _getUniqueKey(categoryToAdd, newItem);
                      _checklistState[uniqueKey] = false;
                      print(
                          "Adding item '$newItem' to category '$categoryToAdd' with key '$uniqueKey'");
                    });
                    _saveChecklistData();
                    Navigator.of(context).pop();
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
    /* ... same as before ... */
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
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                            bottom: (index == allCategoryNames.length - 1)
                                ? 0
                                : 24.0),
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
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 4.0),
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
