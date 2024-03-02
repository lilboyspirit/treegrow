extends Node


const max_file_size = 8388608  # in bytes


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


func load_json(path: String, object: Object = null):
	var file := File.new()

	if !file.file_exists(path):
		return push_error("'%s' [file_not_found]" % [path])

	var open_err := file.open(path, File.READ)
	if open_err:
		file.close()
		return push_error("'%s' [%s]" % [path, open_err])

	var size := file.get_len()
	if size > max_file_size:
		file.close()
		return push_error("'%s' [size_exceeded(%s)]" % [path, size - max_file_size])

	var data = parse_json(file.get_as_text())

	file.close()

	if object:
		if data is Dictionary:
			for i in data:
				object.set(i, data.get(i))
		else:
			object.set(path.get_basename(), data)

	return data


func save_json(path: String, object, empty_object: Object = null, exclude: Array = [], include: Array = []):
	if !object:
		return push_error("'%s' [not_valid_object]" % [path])

	var directory : = Directory.new()
	if !directory.dir_exists(path.get_base_dir()):
		print("making: '%s'" % [path.get_base_dir()])
		var make_dir_status = directory.make_dir_recursive(path.get_base_dir())
		if make_dir_status:
			push_error("'%s' [%s]" % [path.get_base_dir(), make_dir_status])

	var file := File.new()
	var open_status := file.open(path, File.WRITE)
	if open_status:
		file.close()
		return push_error("'%s' [%s]" % [path, open_status])

	if object is Object:
		var dictionary: Dictionary = {}
		var empty_properties = ["Reference", "Script Variables"]

		for i in exclude:
			if !empty_properties.has(i):
				empty_properties.append(i)

		for i in empty_object.get_property_list():
			if !empty_properties.has(i.name):
				empty_properties.append(i.name)

		for i in empty_properties:
			if include.has(i):
				empty_properties.erase(i)

		for i in object.get_property_list():
			if !empty_properties.has(i.name):
				dictionary[i.name] = object[i.name]

		file.store_line(to_json(dictionary))
	else:
		file.store_line(to_json(object))

	file.close()
