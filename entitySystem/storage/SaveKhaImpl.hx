package entitySystem.storage;

import kha.StorageFile;

/**
 * ...
 * @author Joaquin
 */
// kha implementation to persist data
class SaveKhaImpl implements ISave {
	var storageFile:StorageFile;

	public function new() {
		storageFile = kha.Storage.defaultFile();
	}

	public function save(aData:SaveData):Void {
		storageFile.writeObject(aData);
	}

	public function load():SaveData {
		return cast storageFile.readObject();
	}

	public function canLoad():Bool {
		return Std.is(storageFile.readObject(), SaveData);
	}
}
