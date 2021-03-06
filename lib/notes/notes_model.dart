import '../base_model.dart';

/// A class representing this PIM entity type.
class Note {


  /// The fields this entity type contains.
  var id;
  var title;
  var content;
  var color;


  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, title=$title, content=$content, color=$color }";
  }


} /* End class. */


/// ****************************************************************************
/// The model backing this entity type's views.
/// ****************************************************************************
class NotesModel extends BaseModel {


  /// The color.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  var color;


  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.
  void setColor(String inColor) {

    print("## NotesModel.setColor(): inColor = $inColor");

    color = inColor;
    notifyListeners();

  } /* End setColor(). */


} /* End class. */


// The one and only instance of this model.
NotesModel notesModel = NotesModel();