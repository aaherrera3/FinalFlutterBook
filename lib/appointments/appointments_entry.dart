import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart' as utils;
import 'appointments_db_worker.dart';
import 'appointments_model.dart' show AppointmentsModel, appointmentsModel;

/// ********************************************************************************************************************
/// The Appointments Entry sub-screen.
/// ********************************************************************************************************************
class AppointmentsEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  AppointmentsEntry({Key? key}) : super(key: key) {

    print("## AppointmentsEntry.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## AppointmentsEntry.build()");

    // Set value of controllers.
    if (appointmentsModel.entityBeingEdited != null) {
      _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      _descriptionEditingController.text = appointmentsModel.entityBeingEdited.description;
    }

    // Return widget.
    return ScopedModel(
        model : appointmentsModel,
        child : ScopedModelDescendant<AppointmentsModel>(
            builder : (BuildContext inContext, Widget inChild, AppointmentsModel inModel) {
              return Scaffold(
                  bottomNavigationBar : Padding(
                      padding : const EdgeInsets.symmetric(vertical : 0, horizontal : 10),
                      child : Row(
                          children : [
                            TextButton(
                                child : const Text("Cancel"),
                                onPressed : () {
                                  // Hide soft keyboard.
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  // Go back to the list view.
                                  inModel.setStackIndex(0);
                                }
                            ),
                            const Spacer(),
                            TextButton(
                                child : const Text("Save"),
                                onPressed : () { _save(inContext, appointmentsModel); }
                            )
                          ]
                      )
                  ),
                  body : Form(
                      key : _formKey,
                      child : ListView(
                          children : [
                            // Title.
                            ListTile(
                                leading : const Icon(Icons.subject),
                                title : TextFormField(
                                    decoration : const InputDecoration(hintText : "Title"),
                                    controller : _titleEditingController,
                                    validator : (inValue) {
                                      if (inValue!.isEmpty) { return "Please enter a title"; }
                                      return null;
                                    }
                                )
                            ),
                            // Description.
                            ListTile(
                                leading : const Icon(Icons.description),
                                title : TextFormField(
                                    keyboardType : TextInputType.multiline,
                                    maxLines : 4,
                                    decoration : const InputDecoration(hintText : "Description"),
                                    controller : _descriptionEditingController
                                )
                            ),
                            // Appointment Date.
                            ListTile(
                                leading : const Icon(Icons.today),
                                title : const Text("Date"),
                                subtitle : Text(appointmentsModel.chosenDate ?? ""),
                                trailing : IconButton(
                                    icon : const Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () async {
                                      // Request a date from the user.  If one is returned, store it.
                                      String chosenDate = await utils.selectDate(
                                          inContext, appointmentsModel, appointmentsModel.entityBeingEdited.apptDate
                                      );
                                      if (chosenDate != null) {
                                        appointmentsModel.entityBeingEdited.apptDate = chosenDate;
                                      }
                                    }
                                )
                            ),
                            // Appointment Time.
                            ListTile(
                                leading : const Icon(Icons.alarm),
                                title : const Text("Time"),
                                subtitle : Text(appointmentsModel.apptTime ?? ""),
                                trailing : IconButton(
                                    icon : const Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () => _selectTime(inContext)
                                )
                            )
                          ] /* End Column children. */
                      ) /* End ListView. */
                  ) /* End Form. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Function for handling taps on the edit icon for apptDate.
  ///
  /// @param inContext  The BuildContext of the parent Widget.
  /// @return           Future.
  Future _selectTime(BuildContext inContext) async {

    // Default to right now, assuming we're adding an appointment.
    TimeOfDay initialTime = TimeOfDay.now();

    // If editing an appointment, set the initialTime to the current apptTime, if any.
    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      // Create a DateTime using the hours, minutes and a/p from the apptTime.
      initialTime = TimeOfDay(hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1]));
    }

    // Now request the time.
    var picked = await showTimePicker(context : inContext, initialTime : initialTime);

    // If they didn't cancel, update it on the appointment being edited as well as the apptTime field in the model so
    // it shows on the screen.
    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(inContext));
    }

  } /* End _selectTime(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The AppointmentsModel.
  void _save(BuildContext inContext, AppointmentsModel inModel) async {

    print("## AppointmentsEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // Creating a new appointment.
    if (inModel.entityBeingEdited.id == null) {

      print("## AppointmentsEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);

      // Updating an existing appointment.
    } else {

      print("## AppointmentsEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);

    }

    // Reload data from database to update list.
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Appointment saved")
        )
    );

  } /* End _save(). */


} /* End class. */