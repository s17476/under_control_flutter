import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:under_control_flutter/helpers/size_config.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/providers/chart_data_provider.dart';
import 'package:under_control_flutter/providers/item_provider.dart';
import 'package:under_control_flutter/widgets/overview/costs_bar_chart.dart';
import 'package:under_control_flutter/widgets/overview/time_bar_chart.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  final DateTime _toDate = DateTime.now();
  DateTime? _fromDate;
  List<String> labels = [];

  DateTime? sliderFromDate;
  DateTime? sliderToDate;

  Map<String, double> chartData = {};

  List<Item> allAssets = [];
  String? selectedAsset;

  double maxBarWidth = (SizeConfig.blockSizeHorizontal * 100) - 16;

  RangeValues _currentRangeValues = const RangeValues(0, 0);

  double _totalCost = 0;
  int _totalTime = 0;
  Map<String, double> assetsCosts = {};
  Map<String, int> assetsTime = {};

  @override
  void initState() {
    Provider.of<ChartDataProvider>(context, listen: false)
      ..getAssetExpenses()
      ..getBottomTimeBorder().then((value) {
        setState(() {
          _fromDate = value;
        });
        final chartDataProvider =
            Provider.of<ChartDataProvider>(context, listen: false);
        chartDataProvider.getCosts(_fromDate!, _toDate, selectedAsset);
        DateTime tmpDate =
            DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        assetsCosts = chartDataProvider.assetsCosts;
        assetsTime = chartDataProvider.assetsTime;

        // make range slider labels
        while (tmpDate.isBefore(_toDate)) {
          labels.add(DateFormat('MMM yyyy').format(tmpDate));
          tmpDate = DateTime(tmpDate.year, tmpDate.month + 1, 1);
        }
        _currentRangeValues = RangeValues(0, labels.length.toDouble() - 1);
      });

    allAssets = Provider.of<ItemProvider>(context, listen: false).items;
    allAssets.insert(
      0,
      Item(
        itemId: 'All assets',
        internalId: '',
        producer: 'All assets',
        model: '',
        category: '',
        location: '',
        lastInspection: DateTime.now(),
        nextInspection: DateTime.now(),
        interval: '',
        inspectionStatus: 0,
      ),
    );

    super.initState();
  }

  // get the biggest value in selected range
  int _getHighestValue() => chartData.values
      .reduce((curr, next) => curr > next ? curr : next)
      .toInt();

  //get spots coordinates in map
  List<FlSpot> _getSpots() {
    List<FlSpot> spotList = [];
    int position = 0;
    for (var key in chartData.keys) {
      spotList.add(FlSpot(position.toDouble(), chartData[key]!));
      position++;
    }
    return spotList;
  }

  // chart builder
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          rotateAngle: chartData.keys.length < 7
              ? 0
              : chartData.keys.length < 13
                  ? -45
                  : -90,
          getTitles: (value) {
            return DateFormat('MMM').format(
              DateTime(_fromDate!.year, _fromDate!.month + value.toInt()),
            );
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          reservedSize: 32,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: chartData.keys.length.toDouble() - 1,
      minY: 0,
      maxY: _getHighestValue().toDouble() * 1.5,
      lineBarsData: [
        LineChartBarData(
          spots: _getSpots(),
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          preventCurveOverShooting: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.25)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var chartDataProvider = Provider.of<ChartDataProvider>(context);
    chartData = chartDataProvider.chartValues;
    final taskProvider = Provider.of<ChartDataProvider>(context);
    _totalCost = taskProvider.totalCost;
    _totalTime = taskProvider.totalTime;
    assetsCosts = taskProvider.assetsCosts;
    assetsTime = taskProvider.assetsTime;

    if (chartData.length == 1) {
      chartData[chartData.keys.toList()[0].split(' ')[0]] =
          chartData[chartData.keys.toList()[0]]!;
    }

    return _fromDate == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Cost chart',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 6,
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1.30,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18.0,
                      left: 4.0,
                      top: 16,
                      bottom: 12,
                    ),
                    child: chartDataProvider.isLoading
                        // show spinner if data is loading
                        ? const Center(
                            child: SizedBox(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            ),
                          )
                        // show chart if loaded and has data
                        : chartData.values.any((element) => element > 0)
                            ? LineChart(
                                mainData(),
                              )
                            // show info if  loded but no data to show
                            : Builder(builder: (context) {
                                for (var key in chartData.keys) {
                                  chartData[key] = -2;
                                }
                                return Stack(children: [
                                  LineChart(
                                    mainData(),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.query_stats,
                                          color: Colors.black.withOpacity(0.5),
                                          size: SizeConfig.blockSizeHorizontal *
                                              15,
                                        ),
                                        Text(
                                          'No data found',
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    8,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }),
                  ),
                ),
                if (labels.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 28,
                    ),
                    width: double.infinity,
                    child: const Text(
                      'Range:',
                      textAlign: TextAlign.start,
                    ),
                  ),
                // chart range slider
                if (labels.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: RangeSlider(
                        values: _currentRangeValues,
                        max: labels.length.toDouble() - 1,
                        divisions: 200,
                        labels: RangeLabels(
                          labels[_currentRangeValues.start.round()],
                          labels[_currentRangeValues.end.round()],
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                            sliderFromDate = DateFormat('MMM yyyy').parse(
                                labels[_currentRangeValues.start.round()]);

                            sliderToDate = DateFormat('MMM yyyy')
                                .parse(labels[_currentRangeValues.end.round()]);
                          });
                        },
                        activeColor: Colors.green,
                        inactiveColor: Colors.green.shade900,
                      ),
                    ),
                  ),
                // Asset dropdown
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          top: 16,
                          bottom: 8.0,
                        ),
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).primaryIconTheme.color,
                            size: SizeConfig.blockSizeHorizontal * 8,
                          ),
                          alignment: AlignmentDirectional.centerStart,
                          decoration: InputDecoration(
                            labelText: 'Asset',
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).appBarTheme.foregroundColor,
                              fontSize: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).splashColor,
                                width: 0,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).splashColor,
                                width: 0,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).splashColor,
                          ),
                          dropdownColor: Colors.grey.shade800,
                          value: 'All assets',
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAsset =
                                  newValue == 'All assets' ? null : newValue;
                            });
                          },
                          items: allAssets.map((Item item) {
                            return DropdownMenuItem<String>(
                              value: '${item.itemId}',
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal * 2,
                                ),
                                child: Text(
                                  '${item.producer} ${item.model} ${item.internalId}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // chart refresh button
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 4, right: 8),
                      child: IconButton(
                        iconSize: SizeConfig.blockSizeHorizontal * 14,
                        onPressed: () {
                          chartDataProvider.getAssetExpenses(
                            itemId: selectedAsset,
                            fromDate: sliderFromDate,
                            toDate: sliderToDate,
                          );
                          if (sliderFromDate != null) {
                            _fromDate = sliderFromDate;
                          }
                          Provider.of<ChartDataProvider>(context, listen: false)
                              .getCosts(
                            _fromDate!,
                            sliderToDate,
                            selectedAsset,
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(top: 12, bottom: 20),
                        child: Text(
                          'Data from the selected period',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      const Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total cost:'),
                            Text(_totalCost.toString()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total time:'),
                            Text(
                              '${_totalTime ~/ 60} hrs, ${_totalTime % 60} min',
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      if (assetsCosts.isNotEmpty)
                        CostsBarChart(
                          assetsCost: assetsCosts,
                        ),
                      if (assetsCosts.isNotEmpty) const Divider(),
                      if (assetsTime.isNotEmpty)
                        TimeBarChart(
                          assetsTime: assetsTime,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
