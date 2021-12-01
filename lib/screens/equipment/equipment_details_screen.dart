import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';

class EquipmentDetailsScreen extends StatelessWidget {
  const EquipmentDetailsScreen({Key? key}) : super(key: key);

  static const routeName = '/equipment-details';

  @override
  Widget build(BuildContext context) {
    Item item = ModalRoute.of(context)!.settings.arguments as Item;
    return Scaffold(
      appBar: AppBar(
        title: Text('${item.producer} ${item.model}'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 2,
          ),
          IconButton(
            onPressed: () {
              Provider.of<ItemProvider>(context, listen: false)
                  .deleteItem(context, item.itemId);
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 3,
          ),
        ],
      ),
    );
  }
}
