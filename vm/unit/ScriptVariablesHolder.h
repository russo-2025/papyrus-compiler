#pragma once
#include "CIString.h"
#include "VirtualMachine.h"

class ScriptVariablesHolder : public IVariablesHolder
{
public:
  ScriptVariablesHolder(const std::string& myScriptName);

  VarValue* GetVariableByName(const char* name, const PexScript& pex) override;

private:
  void FillNormalVariables(const PexScript& pex);
  void FillState(const PexScript& pex);

  using VarsMap = CIMap<VarValue>;
  using PropStringValues = std::map<std::string, std::shared_ptr<std::string>>;

  const std::string myScriptName;
  std::unique_ptr<VarsMap> vars;
  VarValue state;
};