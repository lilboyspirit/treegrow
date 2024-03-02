extends Node


func list_directories(path: String) -> Array:
	var list := []
	var dir := Directory.new()

	var open_err := dir.open(path)
	if open_err:
		push_error("'%s' [%s]" % [path, open_err])
		return list

	var list_begin_err := dir.list_dir_begin(true)
	if list_begin_err:
		push_error("'%s' [%s]" % [path, list_begin_err])
		return list
	
	var dir_name := dir.get_next()
	while dir_name != "":
		if dir.current_is_dir():
			list.append(dir_name)
		dir_name = dir.get_next()
	
	dir.list_dir_end()

	return list


func list_files(path: String, extension: String = "tscn", tree: bool = false) -> Dictionary:
	path = path.replace("\\", "/")
	if !path.ends_with("/"):
		path += "/"
	if extension.begins_with("."):
		extension.erase(0, 1)

	var list := {}
	var dir := Directory.new()

	var open_err := dir.open(path)
	if open_err:
		push_error("'%s' [%s]" % [path, open_err])
		return list

	var list_begin_err := dir.list_dir_begin(true)
	if list_begin_err:
		push_error("'%s' [%s]" % [path, list_begin_err])
		return list

	var file_name := dir.get_next()
	while file_name != "":
		file_name = file_name.replace(".import", "")

		if dir.current_is_dir():
			var sub_dir := list_files(path + "/" + file_name, extension, tree)
			if sub_dir.size() > 0:
				if tree:
					list[file_name] = sub_dir
				else:
					for key in sub_dir:
						list[key] = sub_dir.get(key)
		elif file_name.get_extension() == extension:
			list[file_name.get_basename()] = path + file_name
		file_name = dir.get_next()
	dir.list_dir_end()

	return list
