import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image_picker/image_picker.dart';
import '../utils.dart' as utils;
import 'gallery_db_worker.dart';
import 'gallery_model.dart' show GalleryModel, galleryModel;

/// ********************************************************************************************************************
/// The Gallery Entry sub-screen.
/// ********************************************************************************************************************
class GalleryEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _nameEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  GalleryEntry({Key? key}) : super(key: key) {

    print("## GalleryEntry.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _nameEditingController.addListener(() {
      galleryModel.entityBeingEdited.name = _nameEditingController.text;
    });

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## GalleryEntry.build()");

    // Set value of controllers.
    if (galleryModel.entityBeingEdited != null) {
      _nameEditingController.text = galleryModel.entityBeingEdited.name;
    }

    // Return widget.
    return ScopedModel(
        model : galleryModel,
        child : ScopedModelDescendant<GalleryModel>(
            builder : (BuildContext inContext, Widget inChild, GalleryModel inModel) {
              // Get reference to avatar file, if any.  If it doesn't exist and the entityBeingEdited has an id then
              // look for an avatar file for the existing gallery.
              File avatarFile = File(join(utils.docsDir.path, "avatar"));
              if (avatarFile.existsSync() == false) {
                if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id != null) {
                  avatarFile = File(join(utils.docsDir.path, inModel.entityBeingEdited.id.toString()));
                }
              }
              return Scaffold(
                  bottomNavigationBar : Padding(
                      padding : const EdgeInsets.symmetric(vertical : 0, horizontal : 10),
                      child : Row(
                          children : [
                            TextButton(
                                child : const Text("Cancel"),
                                onPressed : () {
                                  // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                                  File avatarFile = File(join(utils.docsDir.path, "avatar"));
                                  if (avatarFile.existsSync()) {
                                    avatarFile.deleteSync();
                                  }
                                  // Hide soft keyboard.
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  // Go back to the list view.
                                  inModel.setStackIndex(0);
                                }
                            ),
                            const Spacer(),
                            TextButton(
                                child : const Text("Save"),
                                onPressed : () { _save(inContext, inModel); }
                            )
                          ]
                      )),
                  body : Form(
                      key : _formKey,
                      child : ListView(
                          children : [
                            ListTile(
                                title : avatarFile.existsSync() ? Image.file(avatarFile) : const Text("No avatar image for this gallery"),
                                trailing : IconButton(
                                    icon : const Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () => _selectAvatar(inContext)
                                )
                            ),
                            // Name.
                            ListTile(
                                leading : const Icon(Icons.image),
                                title : TextFormField(
                                    decoration : const InputDecoration(hintText : "Name"),
                                    controller : _nameEditingController,
                                    validator : (inValue) {
                                      if (inValue!.isEmpty) { return "Please enter a name"; }
                                      return null;
                                    }
                                )
                            ),
                          ] /* End Column children. */
                      ) /* End ListView. */
                  ) /* End Form. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Function for handling taps on the edit icon for avatar.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @return           Future.
  Future _selectAvatar(BuildContext inContext) {

    print("GalleryEntry._selectAvatar()");

    return showDialog(context : inContext,
        builder : (BuildContext inDialogContext) {
          return AlertDialog(
              content : SingleChildScrollView(
                  child : ListBody(
                      children : [
                        GestureDetector(
                            child : const Text("Take a picture"),
                            onTap : () async {
                              var cameraImage = await ImagePicker().pickImage(source : ImageSource.camera);
                              if (cameraImage != null) {
                                // Copy the file into the app's docs directory.
                                cameraImage.saveTo(join(utils.docsDir.path, "avatar"));     //copySync(join(utils.docsDir.path, "avatar"));
                                // Tell the entry screen to rebuild itself to show the avatar.
                                galleryModel.triggerRebuild();
                              }
                              // Hide this dialog.
                              Navigator.of(inDialogContext).pop();
                            }
                        ),
                        const Padding(padding : EdgeInsets.all(10)),
                        GestureDetector(
                            child : const Text("Select From Gallery"),
                            onTap : () async {
                              var galleryImage = await ImagePicker().pickImage(source : ImageSource.gallery);
                              if (galleryImage != null) {
                                // Copy the file into the app's docs directory.
                                galleryImage.saveTo(join(utils.docsDir.path, "avatar"));//copySync(join(utils.docsDir.path, "avatar"));
                                // Tell the entry screen to rebuild itself to show the avatar.
                                galleryModel.triggerRebuild();
                              }
                              // Hide this dialog.
                              Navigator.of(inDialogContext).pop();
                            }
                        )
                      ]
                  )
              )
          );
        }
    );

  } /* End _selectAvatar(). */


  /// Save this gallery to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The GalleryModel.
  void _save(BuildContext inContext, GalleryModel inModel) async {

    print("## GalleryEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // We'll need the ID whether creating or updating way.
    var id;

    // Creating a new gallery.
    if (inModel.entityBeingEdited.id == null) {

      print("## GalleryEntry._save(): Creating: ${inModel.entityBeingEdited}");
      id = await GalleryDBWorker.db.create(galleryModel.entityBeingEdited);

      // Updating an existing gallery.
    } else {

      print("## GalleryEntry._save(): Updating: ${inModel.entityBeingEdited}");
      id = galleryModel.entityBeingEdited.id;
      await GalleryDBWorker.db.update(galleryModel.entityBeingEdited);

    }

    // If there is an avatar file, rename it using the ID.
    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      print("## GalleryEntry._save(): Renaming avatar file to id = $id");
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }

    // Reload data from database to update list.
    galleryModel.loadData("contacts", GalleryDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Gallery saved")
        )
    );

  } /* End _save(). */


} /* End class. */