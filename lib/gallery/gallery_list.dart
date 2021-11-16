import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart';
import '../utils.dart' as utils;
import 'gallery_db_worker.dart';
import 'gallery_model.dart' show Gallery, GalleryModel, galleryModel;
import 'package:getwidget/getwidget.dart';

/// ********************************************************************************************************************
/// The Gallery List sub-screen.
/// ********************************************************************************************************************
class GalleryList extends StatelessWidget {
  const GalleryList({Key? key}) : super(key: key);

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    print("## GalleryList.build()");

    // Return widget.
    return ScopedModel<GalleryModel>(
      model: galleryModel,
      child: ScopedModelDescendant<GalleryModel>(
        builder:(BuildContext inContext, Widget inChild, GalleryModel inModel){
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color : Colors.white),
              onPressed: ()async{
                // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                galleryModel.entityBeingEdited = Gallery();
                galleryModel.setStackIndex(1);
              }
            ),
            body: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: galleryModel.entityList.length,
                itemBuilder: (BuildContext inBuildContext, int inIndex) {
                  Gallery gallery = galleryModel.entityList[inIndex];
                  File avatarFile = File(join(utils.docsDir.path, gallery.id.toString()));
                  bool avatarFileExists = avatarFile.existsSync();
                  print("## GalleryList.build(): avatarFile: $avatarFile -- avatarFileExists=$avatarFileExists");
                  return InkWell(
                    child: GridTile(
                      child: GFAvatar(
                        backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                        shape: GFAvatarShape.square,
                      ),
                    ),
                    onTap: () async {
                      // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                      File avatarFile = File(join(utils.docsDir.path, "avatar"));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      // Get the data from the database and send to the edit view.
                      galleryModel.entityBeingEdited = await GalleryDBWorker.db.get(gallery.id);
                      galleryModel.setStackIndex(1);
                    },
                    onDoubleTap:() => _deleteGallery(inContext, gallery),
                  );
                }
            ),
          );
        },
      ),
    );
  }/* End build(). */

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The parent build context.
  /// @param  inGallery The gallery (potentially) being deleted.
  /// @return           Future.
  Future _deleteGallery(BuildContext inContext, Gallery inGallery) async {
    print("## GalleryList._deleteGallery(): inGallery = $inGallery");

    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
              title: const Text("Delete Gallery"),
              content:
                  Text("Are you sure you want to delete ${inGallery.name}?"),
              actions: [
                TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }),
                TextButton(
                    child: const Text("Delete"),
                    onPressed: () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      // Also, don't forget to delete the avatar file or else new gallery created might wind up with an
                      // ID of a file that's present from a previously deleted gallery!
                      File avatarFile = File(
                          join(utils.docsDir.path, inGallery.id.toString()));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      await GalleryDBWorker.db.delete(inGallery.id);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                              content: Text("Gallery deleted")));
                      // Reload data from database to update list.
                      galleryModel.loadData("gallery", GalleryDBWorker.db);
                    })
              ]);
        });
  } /* End _deleteGallery(). */

} /* End class. */
