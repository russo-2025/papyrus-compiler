module tests

import os
import pref
import builder

fn get_source_dir(dir_name string, required_file_name string) string {
	path := os.abs_path(os.join_path("modules", "tests", dir_name))
	required_file := os.join_path(path, required_file_name)

	if !os.is_dir(path) || !os.is_file(required_file) {
		assert false, "[get_source_dir] invalid directory ${path} or missing required file ${required_file}"
	}

	return path
}

fn get_output_dir(dir_name string) string {
	path := os.abs_path(os.join_path("test-files", "compiled", dir_name))

	if !os.is_dir(path) {
		os.mkdir_all(path, os.MkdirParams{}) or { assert false, "[get_output_dir] failed to create output folder ${path}; error: ${err}" }
	}

	if !os.is_dir(path) {
		assert false, "[get_output_dir] invalid output directory ${path}"
	}

	return path
}

fn test_project_skyrim_deps_sources() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("psc_deps", "Form.psc") ]
		output_dir: get_output_dir("LibFire")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ ]
	}

	builder.compile(&prefs)
}

fn test_project_skyui_sdk_51() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc") ]
		output_dir: get_output_dir("SkyuiSDK")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_skyui_sdk_52() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc") ]
		output_dir: get_output_dir("SkyuiSDK")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_mcm_helper() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("MCMHelperSources", "MCM_ConfigBase.psc") ]
		output_dir: get_output_dir("MCMHelper")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_lovense_api() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("LovenseAPISources", "Lovense.psc") ]
		output_dir: get_output_dir("LovenseAPI")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_fnis()
{
	prefs := pref.Preferences {
		paths: [ get_source_dir("FNISSources", "fnis.psc") ]
		output_dir: get_output_dir("FNIS")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_mfgfix()
{
	prefs := pref.Preferences {
		paths: [ get_source_dir("MfgFixSources", "MfgFix_Settings.psc") ]
		output_dir: get_output_dir("MfgFix")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_libfire() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("LibFireSources", "LibFire.psc") ]
		output_dir: get_output_dir("LibFire")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_libturtleclub() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc") ]
		output_dir: get_output_dir("LibTurtleClub")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_papyrus_util() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc") ]
		output_dir: get_output_dir("PapyrusUtil")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_console_util() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("ConsoleUtilSources", "ConsoleUtil.psc") ]
		output_dir: get_output_dir("ConsoleUtil")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_ni_override() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("NiOverrideSources", "NiOverride.psc") ]
		output_dir: get_output_dir("NiOverride")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_race_menu() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("RaceMenuSources", "racemenu.psc") ]
		output_dir: get_output_dir("RaceMenu")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("NiOverrideSources", "NiOverride.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_ui_extensions() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("UIExtensionsSources", "UIExtensions.psc") ]
		output_dir: get_output_dir("UIExtensions")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("NiOverrideSources", "NiOverride.psc"),
			get_source_dir("RaceMenuSources", "racemenu.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_lib_mathf() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("LibMathfSources", "LibMathf.psc") ]
		output_dir: get_output_dir("LibMathf")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_jcontainers() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("JContainersSources", "JContainers.psc") ]
		output_dir: get_output_dir("JContainers")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [ get_source_dir("psc_deps", "Form.psc") ]
	}

	builder.compile(&prefs)
}

fn test_project_iequip() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("iEquipSources", "dubhMonitorEffectScript.psc") ]
		output_dir: get_output_dir("iEquip")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc"),
			get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc"),
			get_source_dir("LibMathfSources", "LibMathf.psc"),
			get_source_dir("LibFireSources", "LibFire.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_mantella_spell() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("MantellaSpellSources", "MantellaLauncher.psc") ]
		output_dir: get_output_dir("MantellaSpell")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("UIExtensionsSources", "UIExtensions.psc"),
			get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_master_of_disguise() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("MasterOfDisguiseSources", "dubhDisguiseMCMQuestScript.psc") ]
		output_dir: get_output_dir("MasterOfDisguise")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("LibFireSources", "LibFire.psc"),
			get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc"),
			get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"),
			get_source_dir("LibMathfSources", "LibMathf.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_osa() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("OSASources", "OSA.psc") ]
		output_dir: get_output_dir("OSA")
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc"),
			get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_ostim() {
	prefs := pref.Preferences {
		paths: [ get_source_dir("OStimNGSources", "OStimAddon.psc") ]
		output_dir: get_output_dir("OStim")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("UIExtensionsSources", "UIExtensions.psc"),
			get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc"),
			get_source_dir("NiOverrideSources", "NiOverride.psc"),
			get_source_dir("JContainersSources", "JContainers.psc"),
			get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"),
			get_source_dir("ConsoleUtilSources", "ConsoleUtil.psc")
		]
	}

	builder.compile(&prefs)
}

fn test_project_sexlab(){
	prefs := pref.Preferences {
		paths: [ get_source_dir("SexLabSources", "SexLabFramework.psc") ]
		output_dir: get_output_dir("SexLab")
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: [
			get_source_dir("psc_deps", "Form.psc"),
			get_source_dir("NiOverrideSources", "NiOverride.psc"),
			get_source_dir("MfgFixSources", "MfgFix_Settings.psc"),
			get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"),
			get_source_dir("LovenseAPISources", "Lovense.psc"),
			get_source_dir("FNISSources", "fnis.psc"),
			get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc")
		]
	}

	builder.compile(&prefs)
}