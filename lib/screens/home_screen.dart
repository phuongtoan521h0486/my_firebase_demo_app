import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:my_firebase_demo_app/models/task.dart';
import 'package:my_firebase_demo_app/screens/user_profile.dart';
import 'package:provider/provider.dart';
import '../providers/sign_in_provider.dart';
import '../utils/bottom_sheet_widget.dart';
import '../utils/my_snack_bar.dart';
import '../utils/next_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController taskController = TextEditingController();
  late final controller = SlidableController(this);

  Future<List<Map<String, dynamic>>> fetchUserTasks(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("tasks")
          .get();

      List<Map<String, dynamic>> tasks = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return tasks;
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String _getStatusString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return "In Progress";
      case TaskStatus.done:
        return "Done";
    }
  }

  Widget _getPriorityDot(String priority) {
    var color = Colors.green;
    switch (priority) {
      case "low":
        color = Colors.green;
        break;
      case "normal":
        color = Colors.yellow;
        break;
      case "high":
        color = Colors.red;
        break;
    }
    return CircleAvatar(
      backgroundColor: color,
      radius: 4,
    );
  }

  Widget _tasksBuilder(
      BuildContext context, Map<String, dynamic> task, String userId) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  bool noDate = task['dueDate'] == "No Deadline";
                  DateTime? selectedDate = !noDate
                      ? DateFormat('dd/MM/yyyy').parse(task['dueDate'])
                      : null;
                  TaskPriority selectedPriority = TaskPriority.values
                      .firstWhere(
                          (priority) => priority.name == task['priority']);
                  var controller = TextEditingController(text: task['name']);

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Edit Task'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Task Name',
                              ),
                            ),
                            CheckboxListTile(
                              value: noDate,
                              onChanged: (checked) {
                                setState(() {
                                  noDate = checked!;
                                  if (noDate) selectedDate = null;
                                });
                              },
                              title: const Text("No Deadline"),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text("Priority: "),
                                DropdownButton<TaskPriority>(
                                  value: selectedPriority,
                                  items: TaskPriority.values
                                      .map((TaskPriority priority) {
                                    return DropdownMenuItem<TaskPriority>(
                                      value: priority,
                                      child: Text(priority.name),
                                    );
                                  }).toList(),
                                  onChanged: (TaskPriority? newValue) {
                                    setState(() {
                                      selectedPriority = newValue!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (!noDate)
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.utc(2000, 1, 1),
                                    lastDate: DateTime.utc(2100, 1, 1),
                                  );

                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: Text(selectedDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(selectedDate!)
                                    : "Edit Deadline"),
                              ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (controller.text.isEmpty) {
                                Navigator.pop(context);
                                openSnackBar(context, "Task Name can not empty",
                                    Colors.red);
                              } else {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(userId)
                                    .collection("tasks")
                                    .doc(task['id'])
                                    .update({
                                  'name': controller.text,
                                  'dueDate': noDate
                                      ? "No Deadline"
                                      : DateFormat('dd/MM/yyyy')
                                          .format(selectedDate!),
                                  'priority': selectedPriority.name,
                                });

                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("tasks")
                  .doc(task['id'])
                  .delete();
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          shape: const CircleBorder(),
          value: task['status'] == TaskStatus.done.name,
          onChanged: (isDone) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .collection("tasks")
                .doc(task['id'])
                .update({
              'status':
                  isDone! ? TaskStatus.done.name : TaskStatus.inProgress.name
            });
          },
        ),
        onTap: () {},
        title: Text(task['name']),
        subtitle: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 4),
            Text(task['dueDate']),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(task['status'] == "done" ? "Done" : "In Progress"),
            _getPriorityDot(task['priority']),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = context.watch<SignInProvider>();
    signInProvider.getDataFromSharedPreferences();
    final user = signInProvider.myUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Task Tracking"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: user!.imageUrl != null
                  ? Image(
                      fit: BoxFit.fill,
                      image:
                          CachedNetworkImageProvider(user.imageUrl.toString()),
                    )
                  : Image.asset(
                      'assets/images/user_avatar_default.png',
                      fit: BoxFit.fill,
                    ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => {
                  nextScreen(context, const ProfileScreen())
                },
                child: Text('Profile'),
              ),
              PopupMenuItem(
                onTap: () {
                  signInProvider.signOut(user.provider!);
                  nextScreenReplace(context, const LoginScreen());
                },
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserTasks(user.uid!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading tasks"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Looks like you have no tasks, please add a new one.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _tasksBuilder(context, snapshot.data![index], user.uid!);
            },
            separatorBuilder: (context, index) => const Divider(thickness: 1),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0C23FE),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return BottomSheetWidget();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
