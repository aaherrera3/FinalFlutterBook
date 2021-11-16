import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_db_worker.dart';
import 'contacts_list.dart';
import 'contacts_entry.dart';
import 'contacts_model.dart';

/// ********************************************************************************************************************
/// The Contacts screen.
/// ********************************************************************************************************************
class Contacts extends StatelessWidget {


  /// Constructor.
  Contacts({Key? key}) : super(key: key) {

    print("## Contacts.constructor");

    // Initial load of data.
    contactsModel.loadData("contacts", ContactsDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## Contacts.build()");

    return ScopedModel<ContactsModel>(
        model : contactsModel,
        child : ScopedModelDescendant<ContactsModel>(
            builder : (BuildContext inContext, Widget inChild, ContactsModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    ContactsList(),
                    ContactsEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */