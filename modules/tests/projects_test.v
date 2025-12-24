module tests

import os
import pref
import builder

fn get_prefs(input_dir string, header_dirs []string, output_dir string) pref.Preferences {
	return pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		output_mode: .silent
		header_dirs: header_dirs
	}
}

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
	prefs := get_prefs(get_source_dir("psc_deps", "Form.psc"), [], get_output_dir("LibFire"))

	builder.compile(&prefs)
}

fn test_project_skyui_sdk_51() {
	prefs := get_prefs(get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("SkyuiSDK"))

	builder.compile(&prefs)
}

fn test_project_skyui_sdk_52() {
	prefs := get_prefs(get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("SkyuiSDK"))

	builder.compile(&prefs)
}

fn test_project_mcm_helper() {
	prefs := get_prefs(get_source_dir("MCMHelperSources", "MCM_ConfigBase.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc")
	], get_output_dir("MCMHelper"))

	builder.compile(&prefs)
}

fn test_project_lovense_api() {
	prefs := get_prefs(get_source_dir("LovenseAPISources", "Lovense.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("LovenseAPI"))

	builder.compile(&prefs)
}

fn test_project_fnis()
{
	prefs := get_prefs(get_source_dir("FNISSources", "fnis.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("FNIS"))

	builder.compile(&prefs)
}

fn test_project_mfgfix()
{
	prefs := get_prefs(get_source_dir("MfgFixSources", "MfgFix_Settings.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("MfgFix"))

	builder.compile(&prefs)
}

fn test_project_libfire() {
	prefs := get_prefs(get_source_dir("LibFireSources", "LibFire.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("LibFire"))

	builder.compile(&prefs)
}

fn test_project_libturtleclub() {
	prefs := get_prefs(get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("LibTurtleClub"))

	builder.compile(&prefs)
}

fn test_project_papyrus_util() {
	prefs := get_prefs(get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("PapyrusUtil"))

	builder.compile(&prefs)
}

fn test_project_console_util() {
	prefs := get_prefs(get_source_dir("ConsoleUtilSources", "ConsoleUtil.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("ConsoleUtil"))

	builder.compile(&prefs)
}

fn test_project_ni_override() {
	prefs := get_prefs(get_source_dir("NiOverrideSources", "NiOverride.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("NiOverride"))

	builder.compile(&prefs)
}

fn test_project_race_menu() {
	prefs := get_prefs(get_source_dir("RaceMenuSources", "racemenu.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("NiOverrideSources", "NiOverride.psc")
	], get_output_dir("RaceMenu"))

	builder.compile(&prefs)
}

fn test_project_ui_extensions() {
	prefs := get_prefs(get_source_dir("UIExtensionsSources", "UIExtensions.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("NiOverrideSources", "NiOverride.psc"),
		get_source_dir("RaceMenuSources", "racemenu.psc")
	], get_output_dir("UIExtensions"))

	builder.compile(&prefs)
}

fn test_project_lib_mathf() {
	prefs := get_prefs(get_source_dir("LibMathfSources", "LibMathf.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("LibMathf"))

	builder.compile(&prefs)
}

fn test_project_jcontainers() {
	prefs := get_prefs(get_source_dir("JContainersSources", "JContainers.psc"), [
		get_source_dir("psc_deps", "Form.psc")
	], get_output_dir("JContainers"))

	builder.compile(&prefs)
}

fn test_project_iequip() {
	prefs := get_prefs(get_source_dir("iEquipSources", "dubhMonitorEffectScript.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc"),
		get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc"),
		get_source_dir("LibMathfSources", "LibMathf.psc"),
		get_source_dir("LibFireSources", "LibFire.psc")
	], get_output_dir("iEquip"))

	builder.compile(&prefs)
}

fn test_project_mantella_spell() {
	prefs := get_prefs(get_source_dir("MantellaSpellSources", "MantellaLauncher.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("UIExtensionsSources", "UIExtensions.psc"),
		get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc")
	], get_output_dir("MantellaSpell"))

	builder.compile(&prefs)
}

fn test_project_master_of_disguise() {
	prefs := get_prefs(get_source_dir("MasterOfDisguiseSources", "dubhDisguiseMCMQuestScript.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("LibFireSources", "LibFire.psc"),
		get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc"),
		get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"),
		get_source_dir("LibMathfSources", "LibMathf.psc")
	], get_output_dir("MasterOfDisguise"))

	builder.compile(&prefs)
}

fn test_project_osa() {
	prefs := get_prefs(get_source_dir("OSASources", "OSA.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc"),
		get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc")
	], get_output_dir("OSA"))

	builder.compile(&prefs)
}

fn test_project_ostim() {
	prefs := get_prefs(get_source_dir("OStimNGSources", "OStimAddon.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("UIExtensionsSources", "UIExtensions.psc"),
		get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc"),
		get_source_dir("NiOverrideSources", "NiOverride.psc"),
		get_source_dir("JContainersSources", "JContainers.psc"),
		get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"),
		get_source_dir("ConsoleUtilSources", "ConsoleUtil.psc")
	], get_output_dir("OStim"))

	builder.compile(&prefs)
}

fn test_project_sexlab(){
	prefs := get_prefs(get_source_dir("SexLabSources", "SexLabFramework.psc"), [
		get_source_dir("psc_deps", "Form.psc"),
		get_source_dir("NiOverrideSources", "NiOverride.psc"),
		get_source_dir("MfgFixSources", "MfgFix_Settings.psc"),
		get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc"),
		get_source_dir("LovenseAPISources", "Lovense.psc"),
		get_source_dir("FNISSources", "fnis.psc"),
		get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc")
	], get_output_dir("SexLab"))

	builder.compile(&prefs)
}