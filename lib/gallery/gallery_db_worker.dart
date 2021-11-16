import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'gallery_model.dart';

/// ********************************************************************************************************************
/// Database provider class for gallery
/// ********************************************************************************************************************
class GalleryDBWorker {
  /// Static instance and private constructor, since this is a singleton.
  GalleryDBWorker._();
  static final GalleryDBWorker db = GalleryDBWorker._();
  /// The one and only database instance.
  Database? _db;

  /// Get singleton instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {

    _db ??= await init();

    print("## Gallery GalleryDBWorker.get-database(): _db = $_db");

    return _db;
  }

  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {

    print("Gallery GalleryDBWorker.init()");

    String path = join(utils.docsDir.path, "gallery.db");
    print("## Gallery GalleryDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
        onCreate : (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS gallery ("
                  "id INTEGER PRIMARY KEY,"
                  "name TEXT"
                  ")"
          );
        }
    );
    return db;

  } /* End init(). */

  /// Create a Gallery from a Map.
  Gallery galleryFromMap(Map inMap) {

    print("## Gallery GalleryDBWorker.galleryFromMap(): inMap = $inMap");

    Gallery gallery = Gallery();
    gallery.id = inMap["id"];
    gallery.name = inMap["name"];

    print("## Gallery GalleryDBWorker.galleryFromMap(): gallery = $gallery");

    return gallery;

  } /* End galleryFromMap(); */

  /// Create a Map from a gallery.
  Map<String, dynamic> galleryToMap(Gallery inGallery) {

    print("## Gallery GalleryDBWorker.galleryToMap(): inGallery = $inGallery");

    Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = inGallery.id;
    map["name"] = inGallery.name;

    print("## Gallery GalleryDBWorker.galleryToMap(): map = $map");

    return map;

  } /* End galleryToMap(). */

  /// Create a gallery.
  ///
  /// @param  inGallery the Gallery object to create.
  /// @return           The ID of the created gallery.
  Future create(Gallery inGallery) async {

    print("## Gallery GalleryDBWorker.create(): inGallery = $inGallery");

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM gallery");
    var id = val.first["id"];
    id ??= 1;

    // Insert into table.
    await db.rawInsert(
        "INSERT INTO gallery (id, name) VALUES (?, ?)",
        [
          id,
          inGallery.name,
        ]
    );

    return id;

  } /* End create(). */

  /// Get a specific gallery.
  ///
  /// @param  inID The ID of the gallery to get.
  /// @return      The corresponding Gallery object.
  Future<Gallery> get(int inID) async {

    print("## Gallery GalleryDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("gallery", where : "id = ?", whereArgs : [ inID ]);

    print("## Gallery GalleryDBWorker.get(): rec.first = $rec.first");

    return galleryFromMap(rec.first);

  } /* End get(). */

  /// Get all gallery.
  ///
  /// @return A List of Gallery objects.
  Future<List> getAll() async {

    print("## Gallery GalleryDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("gallery");
    var list = recs.isNotEmpty ? recs.map((m) => galleryFromMap(m)).toList() : [ ];

    print("## Gallery GalleryDBWorker.getAll(): list = $list");

    return list;

  } /* End getAll(). */

  /// Update a Gallery.
  ///
  /// @param  inGallery The gallery to update.
  /// @return           Future.
  Future update(Gallery inGallery) async {

    print("## Gallery GalleryDBWorker.update(): inGallery = $inGallery");

    Database db = await database;
    return await db.update("gallery", galleryToMap(inGallery), where : "id = ?", whereArgs : [ inGallery.id ]);

  } /* End update(). */

  /// Delete a gallery.
  ///
  /// @param  inID The ID of the gallery to delete.
  /// @return      Future.
  Future delete(int inID) async {

    print("## Gallery GalleryDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("gallery", where : "id = ?", whereArgs : [ inID ]);

  } /* End delete(). */

}