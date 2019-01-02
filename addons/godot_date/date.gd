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

func _init(date_string: String) -> void:
	if date_string.find("T") >= 0 and date_string.find("Z") >= 0:
		_parse_iso_date(date_string)
	else:
		push_error("Unrecognized date format.")

func format() -> String:
	return "{year}-{month}-{day} {hour}:{minute}:{second}" \
			.format({
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
func _parse_iso_date(date_string: String) -> void:
	var fragments := date_string.split("T")
	var date := fragments[0].split("-")
	var time := fragments[1].trim_suffix("Z").split(":")

	year = int(date[0])
	month = int(date[1])
	day = int(date[2])
	hour = int(time[0])
	minute = int(time[1])
	second = int(time[2])
