import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/screens/equipment/equipment_details_screen.dart';
import 'package:under_control_flutter/widgets/start/status_icon.dart';

// this screen shows a list of all registred in DB assets
class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> with ResponsiveSize {
  var _isLoading = false;
  var _currentCategory = '';
  // colors used to mark categories in lise view
  final colors = [
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.green,
  ];
  var colorPointer = -1;

  // fetch data from DB and refresh list
  Future<void> _refreshItems() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ItemProvider>(context, listen: false)
        .fetchAndSetItems()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    _refreshItems();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ItemProvider itemProvider = Provider.of<ItemProvider>(context);
    final items = itemProvider.items;
    _currentCategory = '';

    return RefreshIndicator(
      onRefresh: _refreshItems,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      color: Theme.of(context).primaryColor,
      child: _isLoading
          // data is loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          // no data found
          : items.isEmpty
              ? Center(
                  child: Text(
                    'No assets registered. \n\n Add some!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.headline6!.color,
                    ),
                  ),
                )
              // show list of items when loaded and has data
              : ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSizePx(small: 5, medium: 10),
                  ),
                  children: [
                    ...items.map(
                      (item) {
                        var categoryChanges = false;
                        if (_currentCategory != item.category) {
                          _currentCategory = item.category;
                          categoryChanges = true;
                          if (colorPointer < colors.length - 1) {
                            colorPointer++;
                          } else {
                            colorPointer = 0;
                          }
                        }
                        return Column(
                          key: ValueKey<String>(item.itemId!),
                          children: [
                            // if order by category (default mode) is selected
                            // if category changes print category name as items divider
                            if (categoryChanges && itemProvider.showCategories)
                              ListTile(
                                title: Text(
                                  item.category,
                                  style: TextStyle(
                                    color: colors[colorPointer],
                                    fontSize:
                                        responsiveSizePx(small: 24, medium: 30),
                                  ),
                                ),
                              ),
                            // assets list item
                            GestureDetector(
                              // go to details screen on tap
                              onTap: () => Navigator.of(context)
                                  .pushNamed(EquipmentDetailsScreen.routeName,
                                      arguments: item)
                                  .then((value) {
                                if (value != null) {
                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: const Text('Item deleted'),
                                        backgroundColor:
                                            Theme.of(context).errorColor,
                                      ),
                                    );
                                }
                              }),
                              child: ListTile(
                                // category avatar
                                leading: CircleAvatar(
                                  radius:
                                      responsiveSizePx(small: 20, medium: 30),
                                  child: FittedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        item.category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  backgroundColor: colors[colorPointer],
                                ),
                                // list item title
                                title: Text(
                                  '${item.producer}  ${item.model}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          fontSize: responsiveSizePx(
                                              small: 18, medium: 22)),
                                ),
                                // list item subtitle
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Internal ID: ${item.internalId}',
                                      style: TextStyle(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    Text(
                                      'Next inspection: ${DateFormat('dd/MMM/yyyy').format(item.nextInspection)}',
                                      style: TextStyle(
                                        color: item.inspectionStatus ==
                                                InspectionStatus.expired.index
                                            ? Theme.of(context).errorColor
                                            : Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  ],
                                ),
                                // last inspection status icon
                                trailing: StatusIcon(
                                  heroTag: item.itemId!,
                                  inspectionStatus: item.inspectionStatus,
                                  size: 50,
                                  textSize: 0,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
