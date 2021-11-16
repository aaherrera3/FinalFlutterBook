import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'task_db_worker.dart';
import 'task_list.dart';
import 'task_entry.dart';
import 'task_model.dart' show TasksModel, tasksModel;

/// ********************************************************************************************************************
/// The Tasks screen.
/// ********************************************************************************************************************
class Tasks extends StatelessWidget {


  /// Constructor.
  Tasks({Key? key}) : super(key: key) {

    print("## Tasks.constructor");

    // Initial load of data.
    tasksModel.loadData("tasks", TasksDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## Tasks.build()");

    return ScopedModel<TasksModel>(
        model : tasksModel,
        child : ScopedModelDescendant<TasksModel>(
            builder : (BuildContext inContext, Widget inChild, TasksModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    TasksList(),
                    TasksEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */