import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

import 'notes_db_worker.dart';
import 'notes_entry.dart';
import 'notes_list.dart';
import 'notes_model.dart';

/// ********************************************************************************************************************
/// The Notes screen.
/// ********************************************************************************************************************
class Notes extends StatelessWidget {


  /// Constructor.
  Notes({Key? key}) : super(key: key) {

    print("## Notes.constructor");

    // Initial load of data.
    notesModel.loadData("notes", NotesDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## Notes.build()");

    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (BuildContext inContext, Widget inChild, NotesModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    const NotesList(),
                    NotesEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */