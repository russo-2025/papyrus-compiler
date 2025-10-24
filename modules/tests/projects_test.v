module tests

import os
import pref
import builder

fn test_project_skyrim_deps_sources() {
	input_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "LibFire"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "Form.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ ]
	}

	builder.compile(&prefs)
}

fn test_project_libfire() {
	input_dir := os.real_path(os.join_path("modules", "tests", "LibFireSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "LibFire"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "LibFire.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_libturtleclub() {
	input_dir := os.real_path(os.join_path("modules", "tests", "LibTurtleClubSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "LibTurtleClub"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "LibTurtleClub.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_papyrus_util() {
	input_dir := os.real_path(os.join_path("modules", "tests", "PapyrusUtilSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "PapyrusUtil"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "PapyrusUtil.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_console_util() {
	input_dir := os.real_path(os.join_path("modules", "tests", "ConsoleUtilSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "ConsoleUtil"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "ConsoleUtil.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_ni_override() {
	input_dir := os.real_path(os.join_path("modules", "tests", "NiOverrideSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "NiOverride"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "NiOverride.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_race_menu() {
	input_dir := os.real_path(os.join_path("modules", "tests", "RaceMenuSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "RaceMenu"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	ni_override_dir := os.real_path(os.join_path("modules", "tests", "NiOverrideSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "racemenu.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(ni_override_dir) || !os.is_file(os.join_path(ni_override_dir, "NiOverride.psc")) {
		assert false, "invalid ni override dir ${ni_override_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, ni_override_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_ui_extensions() {
	input_dir := os.real_path(os.join_path("modules", "tests", "UIExtensionsSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "UIExtensions"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	ni_override_dir := os.real_path(os.join_path("modules", "tests", "NiOverrideSources"))
	race_menu_dir := os.real_path(os.join_path("modules", "tests", "RaceMenuSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "UIExtensions.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(ni_override_dir) || !os.is_file(os.join_path(ni_override_dir, "NiOverride.psc")) {
		assert false, "invalid ni override dir ${ni_override_dir}"
	}

	if !os.is_dir(race_menu_dir) || !os.is_file(os.join_path(race_menu_dir, "racemenu.psc")) {
		assert false, "invalid race menu dir ${race_menu_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, ni_override_dir, race_menu_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_lib_mathf() {
	input_dir := os.real_path(os.join_path("modules", "tests", "LibMathfSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "LibMathf"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "LibMathf.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_jcontainers() {
	input_dir := os.real_path(os.join_path("modules", "tests", "JContainersSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "JContainers"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "JContainers.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_iequip() {
	input_dir := os.real_path(os.join_path("modules", "tests", "iEquipSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "iEquip"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	skyui_dir := os.real_path(os.join_path("modules", "tests", "MCMHelperSources"))
	libturtle_dir := os.real_path(os.join_path("modules", "tests", "LibTurtleClubSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "dubhMonitorEffectScript.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	if !os.is_dir(skyui_dir) || !os.is_file(os.join_path(skyui_dir, "SKI_ConfigBase.psc")) {
		assert false, "invalid skyui dir ${skyui_dir}"
	}

	if !os.is_dir(libturtle_dir) || !os.is_file(os.join_path(libturtle_dir, "LibTurtleClub.psc")) {
		assert false, "invalid libturtle dir ${libturtle_dir}"
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, skyui_dir, libturtle_dir ]
	}

	builder.compile(&prefs)
}

// bug
fn test_project_mantella_spell() {
	input_dir := os.real_path(os.join_path("modules", "tests", "MantellaSpellSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "MantellaSpell"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	ui_extensions_dir := os.real_path(os.join_path("modules", "tests", "UIExtensionsSources"))
	skyui_dir := os.real_path(os.join_path("modules", "tests", "MCMHelperSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "MantellaLauncher.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(ui_extensions_dir) || !os.is_file(os.join_path(ui_extensions_dir, "UIExtensions.psc")) {
		assert false, "invalid ui extensions dir ${ui_extensions_dir}"
	}

	if !os.is_dir(skyui_dir) || !os.is_file(os.join_path(skyui_dir, "SKI_ConfigBase.psc")) {
		assert false, "invalid skyui dir ${skyui_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, ui_extensions_dir, skyui_dir ]
	}

	builder.compile(&prefs)
}

fn test_project_master_of_disguise() {
	input_dir := os.real_path(os.join_path("modules", "tests", "MasterOfDisguiseSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "MasterOfDisguise"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	libfire_dir := os.real_path(os.join_path("modules", "tests", "LibFireSources"))
	libturtle_dir := os.real_path(os.join_path("modules", "tests", "LibTurtleClubSources"))
	skyui_dir := os.real_path(os.join_path("modules", "tests", "MCMHelperSources"))
	libmathf_dir := os.real_path(os.join_path("modules", "tests", "LibMathfSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "dubhDisguiseMCMQuestScript.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(libfire_dir) || !os.is_file(os.join_path(libfire_dir, "LibFire.psc")) {
		assert false, "invalid libfire dir ${libfire_dir}"
	}

	if !os.is_dir(libturtle_dir) || !os.is_file(os.join_path(libturtle_dir, "LibTurtleClub.psc")) {
		assert false, "invalid libturtle dir ${libturtle_dir}"
	}

	if !os.is_dir(skyui_dir) || !os.is_file(os.join_path(skyui_dir, "SKI_ConfigBase.psc")) {
		assert false, "invalid skyui dir ${skyui_dir}"
	}

	if !os.is_dir(libmathf_dir) || !os.is_file(os.join_path(libmathf_dir, "LibMathf.psc")) {
		assert false, "invalid libmathf dir ${libmathf_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, libfire_dir, libturtle_dir, skyui_dir, libmathf_dir ]
	}

	builder.compile(&prefs)
}

// bug
fn test_project_ostim() {
	input_dir := os.real_path(os.join_path("modules", "tests", "OStimSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "OStim"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	papyrus_util_dir := os.real_path(os.join_path("modules", "tests", "PapyrusUtilSources"))
	jcontainers_dir := os.real_path(os.join_path("modules", "tests", "JContainersSources"))
	skyui_dir := os.real_path(os.join_path("modules", "tests", "MCMHelperSources"))
	console_util_dir := os.real_path(os.join_path("modules", "tests", "ConsoleUtilSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "OStimAddon.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(papyrus_util_dir) || !os.is_file(os.join_path(papyrus_util_dir, "PapyrusUtil.psc")) {
		assert false, "invalid papyrus util dir ${papyrus_util_dir}"
	}

	if !os.is_dir(jcontainers_dir) || !os.is_file(os.join_path(jcontainers_dir, "JContainers.psc")) {
		assert false, "invalid jcontainers dir ${jcontainers_dir}"
	}

	if !os.is_dir(skyui_dir) || !os.is_file(os.join_path(skyui_dir, "SKI_ConfigBase.psc")) {
		assert false, "invalid skyui dir ${skyui_dir}"
	}

	if !os.is_dir(console_util_dir) || !os.is_file(os.join_path(console_util_dir, "ConsoleUtil.psc")) {
		assert false, "invalid console util dir ${console_util_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, papyrus_util_dir, jcontainers_dir, skyui_dir, console_util_dir ]
	}

	builder.compile(&prefs)
}

// bug
fn test_project_sexlab() {
	input_dir := os.real_path(os.join_path("modules", "tests", "SexLabSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "SexLab"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	ni_override_dir := os.real_path(os.join_path("modules", "tests", "NiOverrideSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "SexLabFramework.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(ni_override_dir) || !os.is_file(os.join_path(ni_override_dir, "NiOverride.psc")) {
		assert false, "invalid ni override dir ${ni_override_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir, ni_override_dir ]
	}

	builder.compile(&prefs)
}