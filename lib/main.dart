import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book3/appointments/appointments_model.dart';
import 'package:flutter_book3/gallery/gallery_entry.dart';
import 'package:flutter_book3/tasks/tasks.dart';
import 'package:path_provider/path_provider.dart';
import 'appointments/appointments.dart';
import 'contacts/contacts.dart';
import 'gallery/gallery.dart';
import 'notes/notes.dart';
import "utils.dart" as utils;
void main() {

  WidgetsFlutterBinding.ensureInitialized();

  print("## main(): FlutterBook Starting");

  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(const FlutterBook());
  }

  startMeUp();

} /* End main(). */

class _Dummy extends StatelessWidget {
  final String _title;

  const _Dummy(this._title);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_title));
  }
}

/// ********************************************************************************************************************
/// Main app widget.
/// ********************************************************************************************************************
class FlutterBook extends StatelessWidget {
  const FlutterBook({Key? key}) : super(key: key);



  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## FlutterBook.build()");

    return MaterialApp(
        home : DefaultTabController(
            length : 5,
            child : Scaffold(
                appBar : AppBar(
                    title : const Text("FlutterBook"),
                    bottom : const TabBar(
                        tabs : [
                          Tab(icon : Icon(Icons.date_range), text : "Appointments"),
                          Tab(icon : Icon(Icons.contacts), text : "Contacts"),
                          Tab(icon : Icon(Icons.note), text : "Notes"),
                          Tab(icon : Icon(Icons.assignment_turned_in), text : "Tasks"),
                          Tab(icon: Icon(Icons.image), text: "Gallery",)
                        ] /* End TabBar.tabs. */
                    ) /* End TabBar. */
                ), /* End AppBar. */
                body : TabBarView(
                    children : [
                      Appointments(),
                      Contacts(),
                      Notes(),
                      Tasks(),
                      Gallery()
                    ] /* End TabBarView.children. */
                ) /* End TabBarView. */
            ) /* End Scaffold. */
        ) /* End DefaultTabController. */
    ); /* End MaterialApp. */

  } /* End build(). */


} /* End class. */