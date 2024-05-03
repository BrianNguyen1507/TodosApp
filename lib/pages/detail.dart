import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/constant/colors.dart';
import 'package:todo/models/congviec.dart';
import 'package:todo/pages/UpdateAdd.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:todo/services/handle/handleDateTime.dart';

import 'package:todo/Provider/provider.dart';

class DetailPage extends StatefulWidget {
  final CongViec task;

  const DetailPage({super.key, required this.task});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  HandleDateTime handleDateTime = HandleDateTime();
  bool isDelayed() {
    return handleDateTime.calculateDelayInMinutes(
            widget.task.date, widget.task.time) >
        0;
  }

  @override
  Widget build(BuildContext context) {
    String getPriorityText() {
      switch (widget.task.priority.toString()) {
        case 'High':
          return AppLocalizations.of(context)?.high ?? 'High';
        case 'Medium':
          return AppLocalizations.of(context)?.medium ?? 'Medium';
        case 'Low':
          return AppLocalizations.of(context)?.low ?? 'Low';
        default:
          return '';
      }
    }

    Color getColorByPriority() {
      switch (widget.task.priority.toString()) {
        case 'High':
          return AppColors.high;
        case 'Medium':
          return AppColors.medium;
        case 'Low':
          return AppColors.low;
        default:
          return Colors.transparent;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Provider.of<ThemeProvider>(context)
            .themeData
            .appBarTheme
            .backgroundColor,
        title: Text(
          widget.task.name,
          style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.title),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UpdateAddTask(
                  taskToUpdate: widget.task,
                ),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              width: 500,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDelayed()
                              ? AppColors.delayed
                              : AppColors.pending,
                        ),
                        child: Center(
                          child: isDelayed()
                              ? Text(
                                  AppLocalizations.of(context)!.delayed,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.pending,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        height: 50,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: getColorByPriority(),
                        ),
                        child: Center(
                          child: Text(
                            getPriorityText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.date} :',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' ${DateFormat('yyyy-MM-dd').format(widget.task.date)} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.time} :',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' ${(widget.task.time)} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          AppLocalizations.of(context)!.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      subtitle: Center(
                        child: Text(
                          widget.task.description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
