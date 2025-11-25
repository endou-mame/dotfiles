#! /usr/bin/env node
import { execFileSync } from "node:child_process";
import { readFileSync, existsSync } from "node:fs";
import path from "node:path";
import os from "node:os";

function showNotification(title, message) {
    const escapedMessage = message
        .replace(/`/g, '``')
        .replace(/"/g, '`"')
        .replace(/\$/g, '`$')
        .replace(/\r?\n/g, ' ')
        .slice(0, 200);

    const script = `
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
        $template = @"
        <toast>
            <visual>
                <binding template="ToastText02">
                    <text id="1">${title}</text>
                    <text id="2">${escapedMessage}</text>
                </binding>
            </visual>
        </toast>
"@
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)
        $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code").Show($toast)
    `;

    execFileSync('powershell.exe', ['-NoProfile', '-Command', script], {
        stdio: 'ignore'
    });
}

try {
    const input = JSON.parse(readFileSync(process.stdin.fd, 'utf8'));

    // Notification イベントの場合（直接メッセージが渡される）
    if (input.message) {
        showNotification(input.title || "Claude Code", input.message);
        process.exit(0);
    }

    // Stop イベントの場合（transcript_path から読み取る）
    if (!input.transcript_path) {
        process.exit(0);
    }

    const homeDir = os.homedir();
    let transcriptPath = input.transcript_path;
    if (transcriptPath.startsWith('~/')) {
        transcriptPath = path.join(homeDir, transcriptPath.slice(2));
    }

    const allowedBase = path.join(homeDir, '.claude', 'projects');
    const resolvedPath = path.resolve(transcriptPath);
    if (!resolvedPath.startsWith(allowedBase)) {
        process.exit(1);
    }

    if (!existsSync(resolvedPath)) {
        console.log('Hook execution failed: Transcript file does not exist');
        process.exit(0);
    }

    const lines = readFileSync(resolvedPath, "utf-8").split("\n").filter(line => line.trim());
    if (lines.length === 0) {
        console.log('Hook execution failed: Transcript file is empty');
        process.exit(0);
    }

    const lastLine = lines[lines.length - 1];
    const transcript = JSON.parse(lastLine);
    const lastMessageContent = transcript?.message?.content?.[0]?.text;

    if (lastMessageContent) {
        showNotification("Claude Code", lastMessageContent);
    }
} catch (error) {
    console.log('Hook execution failed:', error.message);
    process.exit(1);
}
