import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notemakerapp/Utils/Database_Helper.dart';
import 'package:notemakerapp/componenets/buttonComponent.dart';
import 'package:notemakerapp/model/note.dart';

// ignore: must_be_immutable
class NoteDetails extends StatefulWidget {
  final Note? note;
  final String? appDetails;
  NoteDetails({this.note, this.appDetails});

  @override
  _NoteDetailsState createState() => _NoteDetailsState();
}

GlobalKey<FormState> formKey = GlobalKey<FormState>();

class _NoteDetailsState extends State<NoteDetails> {
  TextEditingController? titleController;
  TextEditingController? descriptionController;
  DatabaseHelper? helper;
  static var _priorities = ['High', 'Low'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appDetails.toString()),
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () => moveToLastScreen(),
          ),
        ),
        body: noteDetails(),
      ),
    );
  }

  Widget? noteDetails() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButton(
              items: _priorities.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                );
              }).toList(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
              value: getPriorityAsString(widget.note!.priority!),
              onChanged: (String? selectedValue) {
                setState(() {
                  updatePriorityAsInt(selectedValue);
                  print(selectedValue);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Title Required';
                }
              },
              onChanged: (value) {
                print("Value: $value");
                updateTitle();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Description Required';
                }
              },
              onChanged: (value) {
                print("Value: $value");
                updateDescription();
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ButtonComponent(
                    onPressed: () {
                      if (validateAndSave() == true) {
                        _saveData();
                        print('Title: ' + titleController!.text);
                      }
                    },
                    name: 'Save',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ButtonComponent(
                    onPressed: () {
                      _delete();
                    },
                    name: 'Delete',
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
  //Converting string priority in integer before saving

  void updatePriorityAsInt(String? value) {
    switch (value) {
      case 'High':
        widget.note!.priority = 1;
        break;
      case 'Low':
        widget.note!.priority = 2;
        break;
    }
  }

  //Converting integer priority to String and display to user in DropDown
  String getPriorityAsString(int value) {
    String? priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //High
        break;
      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority!;
  }

  //Updating title of Note
  void updateTitle() {
    widget.note!.title = titleController!.text;
  }

  //Updating description of Note
  void updateDescription() {
    widget.note!.description = descriptionController!.text;
  }

  void _saveData() async {
    moveToLastScreen();

    widget.note!.date = DateFormat.yMMMd().format(DateTime.now());
    int? result;
    // ignore: unnecessary_null_comparison
    if (widget.note!.id != null) {
      // Case 1: Update operation
      result = await helper!.updateNote(widget.note!);
    } else {
      // Case 2: Insert Operation
      result = await helper!.insertNote(widget.note!);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    // ignore: unnecessary_null_comparison
    if (widget.note!.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int? result = await helper!.deleteNote(widget.note!.id!);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
