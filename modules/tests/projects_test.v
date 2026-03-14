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
	path := os.abs_path(os.join_path("test-files", "compiled", "__project_test_" + dir_name))

	if !os.is_dir(path) {
		os.mkdir_all(path, os.MkdirParams{}) or { assert false, "[get_output_dir] failed to create output folder ${path}; error: ${err}" }
	}

	if !os.is_dir(path) {
		assert false, "[get_output_dir] invalid output directory ${path}"
	}

	return path
}

const skyrim_deps = get_source_dir("psc_deps", "Form.psc")
const skyui_sdk_51 = get_source_dir("SkyuiSDKSources_v5.1", "SKI_ConfigBase.psc")
const skyui_sdk_52 = get_source_dir("SkyuiSDKSources_v5.2", "SKI_ConfigBase.psc")
const mcm_helper = get_source_dir("MCMHelperSources", "MCM_ConfigBase.psc")
const lovense_api = get_source_dir("LovenseAPISources", "Lovense.psc")
const fnis = get_source_dir("FNISSources", "fnis.psc")
const mfgfix = get_source_dir("MfgFixSources", "MfgFix_Settings.psc")
const libfire = get_source_dir("LibFireSources", "LibFire.psc")
const libturtleclub = get_source_dir("LibTurtleClubSources", "LibTurtleClub.psc")
const papyrus_util = get_source_dir("PapyrusUtilSources", "PapyrusUtil.psc")
const console_util = get_source_dir("ConsoleUtilSources", "ConsoleUtil.psc")
const ni_override = get_source_dir("NiOverrideSources", "NiOverride.psc")
const race_menu = get_source_dir("RaceMenuSources", "racemenu.psc")
const ui_extensions = get_source_dir("UIExtensionsSources", "UIExtensions.psc")
const lib_mathf = get_source_dir("LibMathfSources", "LibMathf.psc")
const jcontainers = get_source_dir("JContainersSources", "JContainers.psc")
const iequip = get_source_dir("iEquipSources", "dubhMonitorEffectScript.psc")
const mantella_spell = get_source_dir("MantellaSpellSources", "MantellaLauncher.psc")
const master_of_disguise = get_source_dir("MasterOfDisguiseSources", "dubhDisguiseMCMQuestScript.psc")
const osa = get_source_dir("OSASources", "OSA.psc")
const ostim = get_source_dir("OStimNGSources", "OStimAddon.psc")
const sexlab = get_source_dir("SexLabSources", "SexLabFramework.psc")
const campfire = get_source_dir("CampfireSources", "CampfireAPI.psc")
const requiem = get_source_dir("RequiemSources", "Req_VampireDustScript.psc")

fn test_project_skyrim_deps_sources() {
	prefs := get_prefs(skyrim_deps, [], get_output_dir("SkyrimDeps"))

	builder.compile(&prefs)
}

fn test_project_skyui_sdk_51() {
	prefs := get_prefs(skyui_sdk_51, [
		skyrim_deps
	], get_output_dir("SkyuiSDK51"))

	builder.compile(&prefs)
}

fn test_project_skyui_sdk_52() {
	prefs := get_prefs(skyui_sdk_52, [
		skyrim_deps
	], get_output_dir("SkyuiSDK52"))

	builder.compile(&prefs)
}

fn test_project_mcm_helper() {
	prefs := get_prefs(mcm_helper, [
		skyrim_deps,
		skyui_sdk_52
	], get_output_dir("MCMHelper"))

	builder.compile(&prefs)
}

fn test_project_lovense_api() {
	prefs := get_prefs(lovense_api, [
		skyrim_deps
	], get_output_dir("LovenseAPI"))

	builder.compile(&prefs)
}

fn test_project_fnis()
{
	prefs := get_prefs(fnis, [
		skyrim_deps
	], get_output_dir("FNIS"))

	builder.compile(&prefs)
}

fn test_project_mfgfix()
{
	prefs := get_prefs(mfgfix, [
		skyrim_deps
	], get_output_dir("MfgFix"))

	builder.compile(&prefs)
}

fn test_project_libfire() {
	prefs := get_prefs(libfire, [
		skyrim_deps
	], get_output_dir("LibFire"))

	builder.compile(&prefs)
}

fn test_project_libturtleclub() {
	prefs := get_prefs(libturtleclub, [
		skyrim_deps
	], get_output_dir("LibTurtleClub"))

	builder.compile(&prefs)
}

fn test_project_papyrus_util() {
	prefs := get_prefs(papyrus_util, [
		skyrim_deps
	], get_output_dir("PapyrusUtil"))

	builder.compile(&prefs)
}

fn test_project_console_util() {
	prefs := get_prefs(console_util, [
		skyrim_deps
	], get_output_dir("ConsoleUtil"))

	builder.compile(&prefs)
}

fn test_project_ni_override() {
	prefs := get_prefs(ni_override, [
		skyrim_deps
	], get_output_dir("NiOverride"))

	builder.compile(&prefs)
}

fn test_project_race_menu() {
	prefs := get_prefs(race_menu, [
		skyrim_deps,
		ni_override
	], get_output_dir("RaceMenu"))

	builder.compile(&prefs)
}

fn test_project_ui_extensions() {
	prefs := get_prefs(ui_extensions, [
		skyrim_deps,
		ni_override,
		race_menu
	], get_output_dir("UIExtensions"))

	builder.compile(&prefs)
}

fn test_project_lib_mathf() {
	prefs := get_prefs(lib_mathf, [
		skyrim_deps
	], get_output_dir("LibMathf"))

	builder.compile(&prefs)
}

fn test_project_jcontainers() {
	prefs := get_prefs(jcontainers, [
		skyrim_deps
	], get_output_dir("JContainers"))

	builder.compile(&prefs)
}

fn test_project_iequip() {
	prefs := get_prefs(iequip, [
		skyrim_deps,
		skyui_sdk_52,
		libturtleclub,
		lib_mathf,
		libfire
	], get_output_dir("iEquip"))

	builder.compile(&prefs)
}

fn test_project_mantella_spell() {
	prefs := get_prefs(mantella_spell, [
		skyrim_deps,
		ui_extensions,
		skyui_sdk_51
	], get_output_dir("MantellaSpell"))

	builder.compile(&prefs)
}

fn test_project_master_of_disguise() {
	prefs := get_prefs(master_of_disguise, [
		skyrim_deps,
		libfire,
		libturtleclub,
		skyui_sdk_51,
		lib_mathf
	], get_output_dir("MasterOfDisguise"))

	builder.compile(&prefs)
}

fn test_project_osa() {
	prefs := get_prefs(osa, [
		skyrim_deps,
		skyui_sdk_52,
		papyrus_util
	], get_output_dir("OSA"))

	builder.compile(&prefs)
}

fn test_project_ostim() {
	prefs := get_prefs(ostim, [
		skyrim_deps,
		ui_extensions,
		papyrus_util,
		ni_override,
		jcontainers,
		skyui_sdk_51,
		console_util
	], get_output_dir("OStim"))

	builder.compile(&prefs)
}

fn test_project_sexlab(){
	prefs := get_prefs(sexlab, [
		skyrim_deps,
		ni_override,
		mfgfix,
		skyui_sdk_51,
		lovense_api,
		fnis,
		papyrus_util
	], get_output_dir("SexLab"))

	builder.compile(&prefs)
}

/*
fn test_project_campfire(){
	prefs := get_prefs(campfire, [
		skyrim_deps
	], get_output_dir("CampfireSources"))

	builder.compile(&prefs)
}
*/

fn test_project_requiem(){
	prefs := get_prefs(requiem, [
		skyrim_deps
	], get_output_dir("RequiemSources"))

	builder.compile(&prefs)
}

