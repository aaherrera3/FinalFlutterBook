import '../base_model.dart';

/// A class representing this PIM entity type.
class Gallery {
  var id;
  var name;

  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, name=$name}";
  }

}/* End class. */

/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class GalleryModel extends BaseModel {
  void triggerRebuild() {

    print("## GalleryModel.triggerRebuild()");

    notifyListeners();

  }
}/* End class. */

// The one and only instance of this model.
GalleryModel galleryModel = GalleryModel();