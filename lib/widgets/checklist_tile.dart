import 'package:flutter/material.dart';

class ChecklistTile extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final bool isCustom;
  final VoidCallback? onDelete;
  final IconData? leadingIcon;
  final String? detailImagePath;
  final String? tips;

  const ChecklistTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
    this.isCustom = false,
    this.onDelete,
    this.leadingIcon,
    this.detailImagePath,
    this.tips,
  });

  @override
  State<ChecklistTile> createState() => _ChecklistTileState();
}

class _ChecklistTileState extends State<ChecklistTile> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    final bool isExpandable = widget.detailImagePath != null || widget.tips != null;
    
    if (isExpandable) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isChecked = widget.initialValue;
    final bool isExpandable = widget.detailImagePath != null || widget.tips != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.cardColor,
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  if (widget.leadingIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        widget.leadingIcon, 
                        color: isExpandable ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7), 
                        size: 24
                      ),
                    ),
                  
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        widget.onChanged(newValue);
                      }
                    },
                    activeColor: theme.colorScheme.primary,
                    checkColor: Colors.white,
                  ),
                  
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isChecked
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : theme.colorScheme.onSurface,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),

                  if (widget.isCustom && widget.onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error.withOpacity(0.7)),
                      tooltip: 'Delete Custom Item',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      visualDensity: VisualDensity.compact,
                      onPressed: widget.onDelete,
                    )
                  else if (isExpandable)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(Icons.keyboard_arrow_down, 
                          color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    )
                  else
                    const SizedBox(width: 40), 
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded && isExpandable
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      height: 108,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 60,
                            child: widget.detailImagePath != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    child: Image.asset(
                                      widget.detailImagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.image,
                                          size: 40, color: Colors.grey),
                                    ),
                                  ),
                          ),
                          Expanded(
                            flex: 40,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.tips ?? 'No additional info',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}