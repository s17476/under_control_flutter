import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/responsive_size.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/item_provider.dart';

class CostsBarChart extends StatelessWidget with ResponsiveSize {
  const CostsBarChart({Key? key, required this.assetsCost}) : super(key: key);

  final Map<String, double> assetsCost;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Map<String, double> sortedMap = {};

    sortedMap.addEntries(assetsCost.entries.toList()
      ..sort((a, b) => (b.value).compareTo(a.value)));

    final double chartWidthBlock = responsiveSizePct(small: 60, medium: 80) /
        sortedMap[sortedMap.keys.toList()[0]]!;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          const Text(
            'Expenses per asset',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 16,
          ),
          for (var key in sortedMap.keys)
            Builder(builder: (context) {
              Item item;
              try {
                item = Provider.of<ItemProvider>(context)
                    .items
                    .firstWhere((element) => element.itemId == key);
              } catch (e) {
                return Container();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: sortedMap[key]! * chartWidthBlock,
                        height: 15,
                        color: Colors.green,
                      ),
                      Text('  ${sortedMap[key]!.toString()}'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(
                      '${item.producer} ${item.model} ${item.internalId}',
                    ),
                  ),
                ],
              );
            })
        ],
      ),
    );
  }
}
