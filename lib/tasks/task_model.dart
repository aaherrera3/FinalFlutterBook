import '../base_model.dart';


/// A class representing this PIM entity type.
class Task {


  /// The fields this entity type contains.
  var id;
  var description;
  var dueDate; // YYYY,MM,DD
  var completed = "false";


  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }


} /* End class. */


/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class TasksModel extends BaseModel {
} /* End class. */


// The one and only instance of this model.
TasksModel tasksModel = TasksModel();