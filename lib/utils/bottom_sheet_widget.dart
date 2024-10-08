import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_firebase_demo_app/utils/my_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/sign_in_provider.dart';

class BottomSheetWidget extends StatefulWidget {
  BottomSheetWidget({super.key});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final taskController = TextEditingController();
  DateTime? selectedDate;
  bool noDate = false;
  TaskPriority selectedPriority = TaskPriority.normal;

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = context.watch<SignInProvider>();
    signInProvider.getDataFromSharedPreferences();
    final user = signInProvider.myUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: taskController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
              ),
              ListTile(
                title: const Text("No Date"),
                trailing: Checkbox(
                  value: noDate,
                  onChanged: (value) {
                    setState(() {
                      noDate = value ?? false;
                    });
                  },
                ),
              ),
              if (!noDate)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      selectedDate != null
                          ? 'Due Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'
                          : 'Select Due Date',
                      style: const TextStyle(fontSize: 16),
                    ),
                    TableCalendar(
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 1, 1),
                      focusedDay: selectedDate ?? DateTime.now(),
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDate, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          selectedDate = selectedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          selectedDate = focusedDay;
                        });
                      },
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Priority: "),
                  DropdownButton<TaskPriority>(
                    value: selectedPriority,
                    onChanged: (TaskPriority? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                    items: TaskPriority.values.map((TaskPriority priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (taskController.text.isEmpty) {
                        openSnackBar(context, "Please type Task Name", Colors.red);
                      } else {
                        var newTask = Task(
                          name: taskController.text,
                          priority: selectedPriority,
                          status: TaskStatus.inProgress,
                          dueDate: noDate ? null : selectedDate,
                        );

                        try {
                          DocumentReference docRef = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(user!.uid)
                              .collection("tasks")
                              .add(newTask.toJson());
                          newTask.id = docRef.id;
                          await docRef.update(newTask.toJson());
                          openSnackBar(context, "Task added successfully", Colors.green);
                        } catch (e) {
                          openSnackBar(context, "Failed to add task: $e", Colors.red);
                        } finally {
                          // Clear input fields after adding the task
                          taskController.clear();
                          setState(() {
                            selectedDate = null;
                            noDate = false;
                            selectedPriority = TaskPriority.normal;
                          });
                        }

                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
