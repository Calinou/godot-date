# Godot Date: Date manipulation and formatting with i18n support
#
# Copyright © 2019 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends MainLoop

var year: int
var month: int
var day: int
var hour: int
var minute: int
var second: int

# The Date instance's locale
# By default, the locale defined in TranslationServer is used
var locale: String setget set_locale

# The locale strings as defined in the locale JSON
var locale_strings: Dictionary

# Creates a new Date instance.
# Accepted date formats: ISO 8601 string, Godot date dictionary
func _init(date) -> void:
	if typeof(date) == TYPE_DICTIONARY:
		year = date.year
		month = date.month
		day = date.day
		hour = date.hour
		minute = date.minute
		second = date.second
	elif typeof(date) == TYPE_STRING and date.find("T") >= 0 and date.find("Z") >= 0:
		var result := _parse_iso_date(date)
		year = result.year
		month = result.month
		day = result.day
		hour = result.hour
		minute = result.minute
		second = result.second
	else:
		push_error("Unrecognized date format.")

	self.locale = TranslationServer.get_locale()

# Sets the locale for the current Date instance.
# If `locale` is null, the language from the TranslationServer will be used.
func set_locale(p_locale: String) -> void:
	var file := File.new()
	file.open(
			"res://addons/godot_date/locale/" + p_locale + ".json",
			File.READ
	)
	var json_result := JSON.parse(file.get_as_text())

	if json_result.error == OK:
		locale_strings = json_result.result
	else:
		push_error(
				"Error while parsing JSON at res://addons/godot_date/locale/{locale}.json:{line}: {message}".format({
					locale = p_locale,
					line = json_result.error_line,
					message = json_result.error_string,
				})
		)

	locale = p_locale

# Formats the date following the given type.
# `type` should be a LDML-like string or a localized format,
# see <https://momentjs.com/docs/#/displaying/>.
# If no type is given, an ISO 8601 date string (without timezone information)
# will be returned.
func format(type = null) -> String:
	if type != null:
		var date_string: String = locale_strings.formats[type]
		# Replacements for placeholders in format strings
		var replacements := {
			"YYYY": str(year),
			"MMMM": locale_strings.months.long[month - 1],
			"MMM": locale_strings.months.short[month - 1],
			"MM": str(month).pad_zeros(2),
			"M": str(month),
			"DD": str(day).pad_zeros(2),
			"D": str(day),
			"HH": str(hour).pad_zeros(2),
			"mm": str(minute).pad_zeros(2),
			"m": str(minute),
			"ss": str(second).pad_zeros(2),
			"s": str(second),
		}

		for replacement in replacements:
			date_string = date_string.replace(replacement, replacements[replacement])

		return date_string
	else:
		return "{year}-{month}-{day}T{hour}:{minute}:{second}".format({
			year = str(year),
			month = str(month).pad_zeros(2),
			day = str(day).pad_zeros(2),
			hour = str(hour).pad_zeros(2),
			minute = str(minute).pad_zeros(2),
			second = str(second).pad_zeros(2),
		})

# Returns `true` if the date is prior to the date passed as argument.
func is_before(date: Object) -> bool:
	if (
		year < date.year or
		year == date.year and month < date.month or
		year == date.year and month == date.month and day < date.day or
		year == date.year and month == date.month and day == date.day and hour < date.hour or
		year == date.year and month == date.month and day == date.day and hour == date.hour and minute < date.minute or
		year == date.year and month == date.month and day == date.day and hour == date.hour and minute == date.minute and second < date.second
	):
		return true

	return false

# Returns `true` if the date is posterior to the date passed as argument.
func is_after(date: Object) -> bool:
	return !is_before(date)

# TODO: Handle dates with timezones
func _parse_iso_date(date: String) -> Dictionary:
	var fragments := date.split("T")
	var date_dict := fragments[0].split("-")
	var time := fragments[1].trim_suffix("Z").split(":")

	return {
		year = int(date_dict[0]),
		month = int(date_dict[1]),
		day = int(date_dict[2]),
		hour = int(time[0]),
		minute = int(time[1]),
		second = int(time[2]),
	}
