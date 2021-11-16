import '../base_model.dart';

/// A class representing this PIM entity type.
class Appointment {


  /// The fields this entity type contains.
  var id;
  var title;
  var description;
  var apptDate; // YYYY,MM,DD
  var apptTime; // HH,MM


  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, title=$title, description=$description, apptDate=$apptDate, apptDate=$apptTime }";
  }


} /* End class. */


/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class AppointmentsModel extends BaseModel {


  /// The appointment time.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  var apptTime;


  /// For display of the appointment time chosen by the user.
  ///
  /// @param inApptTime The appointment date in HH:MM form.
  void setApptTime(String inApptTime) {

    apptTime = inApptTime;
    notifyListeners();

  } /* End setApptTime(). */


} /* End class. */


// The one and only instance of this model.
AppointmentsModel appointmentsModel = AppointmentsModel();