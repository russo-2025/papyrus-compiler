import  vscode, { window, ExtensionContext, workspace } from 'vscode';
import { LanguageClient, LanguageClientOptions, ServerOptions, TransportKind } from "vscode-languageclient/node";

export let client: LanguageClient;

export function connectPls(path: string, context: ExtensionContext) {
	// Path to VLS executable.
	// Server Options for STDIO
	const serverOptions: ServerOptions = {
		command: path,
		args: [],
		transport: TransportKind.stdio
	};

	// LSP Client options
	const clientOptions: LanguageClientOptions = {
		documentSelector: [{ scheme: 'file', language: "papyrusex" }],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher('**/*.psc')
		}
	}
	
	client = new LanguageClient(
		"Papyrus Language Server",
		serverOptions,
		clientOptions,
		true
	);
	
	client.onReady()
		.then(() => {
			window.setStatusBarMessage('The Papyrus language server is ready.', 3000);
		})
		.catch(() => {
			window.setStatusBarMessage('The Papyrus language server failed to initialize.', 3000);
		});

	context.subscriptions.push(client.start());
}

export async function activatePls(context: ExtensionContext) {
	const path = vscode.workspace.getConfiguration().get<string>('papyrusex.pls.customPath');

	if(path) {
		connectPls(path, context);
	}
}

export async function deactivatePls() {
	if (!client) {
		return;
	}
	await client.stop();
}