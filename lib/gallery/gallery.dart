import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'gallery_db_worker.dart';
import 'gallery_list.dart';
import 'gallery_entry.dart';
import 'gallery_model.dart';

/// ********************************************************************************************************************
/// The Gallery screen.
/// ********************************************************************************************************************
class Gallery extends StatelessWidget {


  /// Constructor.
  Gallery({Key? key}) : super(key: key) {

    print("## Gallery.constructor");

    // Initial load of data.
    galleryModel.loadData("gallery", GalleryDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## Gallery.build()");

    return ScopedModel<GalleryModel>(
        model : galleryModel,
        child : ScopedModelDescendant<GalleryModel>(
            builder : (BuildContext inContext, Widget inChild, GalleryModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    GalleryList(),
                    GalleryEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */