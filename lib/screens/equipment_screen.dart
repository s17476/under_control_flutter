import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({
    Key? key,
  }) : super(key: key);

  // final AppUser appUser;

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  var _isLoading = false;
  var _currentCategory = '';
  final colors = [
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.amber.shade700,
    Colors.green,
  ];
  var colorPointer = -1;

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
    ItemProvider itemProvider =
        Provider.of<ItemProvider>(context, listen: false);
    // if (itemProvider.items.isEmpty) {
    setState(() {
      _isLoading = true;
    });
    itemProvider.fetchAndSetItems().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    // }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ItemProvider itemProvider = Provider.of<ItemProvider>(context);
    final items = itemProvider.items;
    bool isExpired = false;
    _currentCategory = '';
    return RefreshIndicator(
      onRefresh: _refreshItems,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      color: Theme.of(context).primaryColor,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : ListView(
              padding: EdgeInsets.symmetric(
                // vertical: SizeConfig.blockSizeVertical * 1,
                horizontal: SizeConfig.blockSizeHorizontal * 2,
              ),
              // itemCount: items.length,
              children: [
                ...items.map(
                  (item) {
                    // check if inspection has expired
                    List<String> days = item.interval.split(' ');
                    int duration;
                    if (days[1] == 'week' || days[1] == 'weeks') {
                      duration = int.parse(days[0]) * 7;
                    } else if (days[1] == 'month' || days[1] == 'months') {
                      duration = int.parse(days[0]) * 30;
                    } else {
                      duration = int.parse(days[0]) * 365;
                    }
///////////////////////////////////////////////////////////////////////////////////
                    isExpired = DateTime.now()
                        .subtract(Duration(
                            days: duration)) //////////////////////////////
                        .isAfter(item.lastInspection);
                    var categoryChanges = false;
                    if (_currentCategory != item.category) {
                      _currentCategory = item.category;
                      categoryChanges = true;
                      if (colorPointer < colors.length - 1) {
                        colorPointer++;
                      } else {
                        colorPointer = 0;
                      }
                      // print(' $currentCategory   ${item.category}');
                    }
                    return Column(
                      key: ValueKey<String>(item.itemId!),
                      children: [
                        if (categoryChanges && itemProvider.showCategories)
                          ListTile(
                            // key: ValueKey('${items[i].itemId}separator'),
                            title: Text(
                              item.category,
                              style: TextStyle(
                                color: colors[colorPointer],
                                fontSize: SizeConfig.blockSizeHorizontal * 6,
                              ),
                            ),
                          ),
                        ListTile(
                          leading: CircleAvatar(
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
                            // radius: SizeConfig.blockSizeHorizontal * 3,
                          ),
                          title: Text(
                            '${item.producer}  ${item.model}',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          subtitle: Text(
                            'Last inspection: ${item.lastInspection.day}/${item.lastInspection.month}/${item.lastInspection.year}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: isExpired
                              ? Icon(
                                  Icons.alarm_outlined,
                                  color: Colors.red,
                                  size: SizeConfig.blockSizeVertical * 5,
                                )
                              : item.inspectionStatus ==
                                      InspectionStatus.ok.index
                                  ? Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.green,
                                      size: SizeConfig.blockSizeVertical * 5,
                                    )
                                  : item.inspectionStatus ==
                                          InspectionStatus.failed.index
                                      ? Icon(
                                          Icons.clear_rounded,
                                          color: Colors.red,
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                        )
                                      : item.inspectionStatus ==
                                              InspectionStatus
                                                  .needsAttention.index
                                          ? Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.amber,
                                              size:
                                                  SizeConfig.blockSizeVertical *
                                                      5,
                                            )
                                          : Icon(
                                              Icons.alarm_outlined,
                                              color: Colors.red,
                                              size:
                                                  SizeConfig.blockSizeVertical *
                                                      5,
                                            ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
    // Text('data');
  }
}
