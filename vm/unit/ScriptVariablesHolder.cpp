#include "ScriptVariablesHolder.h"

#include "Utils.h"

ScriptVariablesHolder::ScriptVariablesHolder(const std::string& myScriptName_)
  : myScriptName(myScriptName_)
{
}

VarValue* ScriptVariablesHolder::GetVariableByName(const char* name,
                                                   const PexScript& pex)
{
  if (!Utils::stricmp(name, "::State")) {
    if (state == VarValue::None())
      FillState(pex);
    return &state;
  }

  if (!vars) {
    vars.reset(new VarsMap);
    FillNormalVariables(pex);
  }

  auto it = vars->find(name);
  if (it != vars->end()) {
    return &it->second;
  }
  return nullptr;
}

void ScriptVariablesHolder::FillNormalVariables(const PexScript& pex)
{
  for (auto& object : pex.objectTable.m_data) {
    for (auto& var : object.variables) {
      ObjectTable::Object::VarInfo varInfo;
      varInfo = var;
      if ((const char*)varInfo.value == nullptr) {
        varInfo.value =
          VarValue(ActivePexInstance::GetTypeByName(var.typeName));
      }
      (*vars)[CIString{ var.name.begin(), var.name.end() }] = varInfo.value;
    }
  }
}

void ScriptVariablesHolder::FillState(const PexScript& pex)
{
  // Creating temp variable for save State ActivePexInstance and
  // transition between them
  state = VarValue(pex.objectTable.m_data[0].autoStateName.data());
}