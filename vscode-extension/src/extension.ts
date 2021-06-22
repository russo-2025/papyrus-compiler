import vscode, { workspace, ExtensionContext, ConfigurationChangeEvent, WorkspaceConfiguration, WorkspaceFolder } from "vscode";
import { activatePls, deactivatePls } from "./langserver";

export function activate(context: ExtensionContext) {
	const disposable = vscode.commands.registerCommand('extension.testPapyrus', () => {
		vscode.window.showInformationMessage('Hello PapyrusEx');
	});
	context.subscriptions.push(disposable);

	const isPlsEnabled = vscode.workspace.getConfiguration().get<boolean>('papyrusex.pls.enable');
	workspace.onDidChangeConfiguration((e: ConfigurationChangeEvent) => {
		if (e.affectsConfiguration('papyrusex.pls.enable')) {
			
			const isPlsEnabled = vscode.workspace.getConfiguration().get<boolean>('papyrusex.pls.enable');
			
			if (isPlsEnabled) {
				activatePls(context);
			} else {
				deactivatePls();
			}
		}
	})
	if (isPlsEnabled) {
    	activatePls(context)
	}
}

export function deactivate() {}