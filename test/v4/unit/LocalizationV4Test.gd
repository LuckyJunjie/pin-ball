extends "res://addons/gut/test.gd"
## Unit tests for LocalizationV4.gd

var localization: Node = null

func before_all():
	localization = autoqfree(load("res://scripts/v4/LocalizationV4.gd").new())
	add_child(localization)

func test_localization_exists():
	assert_not_null(localization, "LocalizationV4 should exist")
	assert_eq(localization.get_script().resource_path, "res://scripts/v4/LocalizationV4.gd")

func test_default_language():
	var lang = localization.get_language()
	assert_gt(lang.length(), 0, "Should have a default language")

func test_set_language():
	watch_signals(localization)
	localization.set_language("zh")
	
	assert_eq(localization.get_language(), "zh", "Language should be set")
	assert_signal_emitted(localization, "language_changed")

func test_tr_function():
	# Test translation function (will return key if translation not found)
	var result = localization.tr("test_key")
	assert_eq(result, "test_key", "Should return key if translation not found")

func test_detect_system_language():
	var detected = localization._detect_system_language()
	assert_gt(detected.length(), 0, "Should detect a language")

func test_language_change_signal():
	watch_signals(localization)
	localization.set_language("ja")
	assert_signal_emitted(localization, "language_changed")

func after_all():
	pass
