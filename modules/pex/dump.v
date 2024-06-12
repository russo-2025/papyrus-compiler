module pex

import os

pub struct DumpObject {
pub mut:
	name		string
	parent_name	string
	methods		[]DumpFn
	global_fns	[]DumpFn
}

pub struct DumpFn {
pub mut:
	name		string
	arguments	[]DumpArg
	return_type	string
	is_native	bool
	is_global	bool
}

pub struct DumpArg {
pub mut:
	name	string
	typ		string
}

fn create_dump_from_pex(file string) &DumpObject {
	pex_file := read_from_file(file)

	assert pex_file.objects.len == 1
	
	obj := pex_file.objects[0]
	state := pex_file.get_default_state(obj) or { panic(err) }
	mut dump_obj := &DumpObject{
		name: pex_file.get_string(obj.name)
		parent_name: pex_file.get_string(obj.parent_class_name) 
		methods: []DumpFn{}
		global_fns: []DumpFn{}
	}
	
	for func in state.functions {
		
		func_name := pex_file.get_string(func.name)

		if ["GetState", "GotoState", "onEndState", "onBeginState"].contains(func_name) {
			continue
		}

		if func_name.starts_with("On") {
			continue
		}

		mut dump_func := DumpFn{
			name: func_name
			return_type: pex_file.get_string(func.info.return_type)
			arguments: []DumpArg{}
			is_native: func.info.is_native()
			is_global: func.info.is_global()
		}
		for arg in func.info.params {
			dump_func.arguments << DumpArg{
				name: pex_file.get_string(arg.name)
				typ: pex_file.get_string(arg.typ)
			}
		}

		if func.info.is_global() {
			dump_obj.global_fns << dump_func
		}
		else {
			dump_obj.methods << dump_func
		}
	}

	return dump_obj
}
pub fn create_dump_from_pex_files(files []string) []DumpObject {
	mut dump_objects := []DumpObject{}

	for file in files {
		if !os.is_file(file) {
			println("file not found: ${file}")
			continue
		}

		dump_objects << create_dump_from_pex(file)
	}

	return dump_objects
}

pub fn create_dump_from_pex_dir(dir string) []DumpObject {
	if !os.is_dir(dir) {
		println("invalid dir: `${dir}`")
		exit(1)
	}

	pex_files := os.walk_ext(dir, ".pex")
	
	/*
	mut files := []string{}
	for obj_name in base_object_names {
		file := os.join_path(dir, obj_name + ".pex")
		files << file
	}*/

	return create_dump_from_pex_files(pex_files)
}
/*
const (
	skse_object_names = [
		"ActorValueInfo", "ArmorAddon", "Art", "ColorForm", "CombatStyle", "DefaultObjectManager", "EquipSlot", "HeadPart", "Input", "ModEvent", "NetImmerse", "SKSE", 
		"SoundDescriptor", "SpawnerTask", "StringUtil", "TreeObject", "UI", "UICallback", "WornObject"
	]

	base_object_names = [
	"Action", "Activator", "ActiveMagicEffect", "Actor", "ActorBase", "Alias", "Ammo",
	"Apparatus", "Armor", "AssociationType", "Book", "Cell", "Class",
	"ConstructibleObject", "Container", "Debug", "Door", 
	"EffectShader", "Enchantment", "EncounterZone", "Explosion", "Faction", "Flora", 
	"Form", "FormList", "Furniture", "Game", "GlobalVariable", "Hazard", "Idle", 
	"ImageSpaceModifier", "ImpactDataSet", "Ingredient", "Key", "Keyword", "LeveledActor", 
	"LeveledItem", "LeveledSpell", "Light", "Location", "LocationAlias", "LocationRefType", 
	"MagicEffect", "Math", "Message", "MiscObject", "MusicType", 
	"ObjectReference", "Outfit", "Package", "Perk", "Potion", "Projectile", "Quest", "Race",
	"ReferenceAlias", "Scene", "Scroll", "Shout", "SoulGem", "Sound", "SoundCategory",
	"Spell", "Static", "TalkingActivator", "TextureSet",
	"Topic", "TopicInfo", "Utility", "VisualEffect", "VoiceType",
	"Weapon", "Weather","WordOfPower", "WorldSpace"]
)*/