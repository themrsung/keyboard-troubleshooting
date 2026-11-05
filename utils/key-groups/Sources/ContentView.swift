import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            if let m = model.message {
                Text(m).foregroundColor(.red).fixedSize(horizontal: false, vertical: true)
            }
            ScrollView {
                VStack(spacing: 10) {
                    ForEach($model.groups) { $config in
                        GroupRow(model: model, config: $config)
                    }
                }
                .padding(.trailing, 4)
            }
            .frame(minHeight: 220)
            HStack {
                Button("Add Group") { model.groups.append(GroupConfig()) }
                Spacer()
                Text("Give each key in a group its own key code (F13–F20) in the keyboard's keymap tool to use it system-wide.")
                    .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.trailing)
            }
            testPanel
        }
        .padding(16)
        .frame(minWidth: 620, minHeight: 600)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: model.trusted ? "checkmark.shield" : "exclamationmark.shield")
                .foregroundColor(model.trusted ? .green : .orange)
            Text(model.trusted ? "Accessibility allowed" : "Accessibility not allowed: only needed system-wide")
            if !model.trusted { Button("Allow…") { model.requestTrust() } }
            Spacer()
            Toggle("System-wide", isOn: Binding(get: { model.systemWide }, set: { model.setSystemWide($0) }))
                .toggleStyle(.switch)
                .disabled(!model.trusted)
                .help("Apply the groups in every app. Needs Accessibility.")
        }
    }

    private var testPanel: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.systemWide
                     ? "Turn System-wide off to test here."
                     : "With this window in front, press a group's keys. Each press, and the output it causes, is logged. No permission needed.")
                    .font(.callout).foregroundColor(.secondary)
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(model.log.enumerated()), id: \.offset) { i, line in
                                Text(line).font(.system(.body, design: .monospaced))
                                    .foregroundColor(line.contains("→") ? .primary : .secondary)
                                    .id(i)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 140)
                    .onChange(of: model.log.count) { n in if n > 0 { proxy.scrollTo(n - 1, anchor: .bottom) } }
                }
                HStack {
                    Button("Clear Log") { model.clearLog() }
                    Spacer()
                }
            }
        } label: {
            Text("Try it here").font(.headline)
        }
    }
}

struct GroupRow: View {
    @ObservedObject var model: Model
    @Binding var config: GroupConfig

    private var recordingMembers: Bool { model.recording == .members(config.id) }
    private var recordingOutput: Bool { model.recording == .output(config.id) }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Keys").frame(width: 50, alignment: .leading)
                    if config.members.isEmpty {
                        Text(recordingMembers ? "Press the keys…" : "None yet").foregroundColor(.secondary)
                    }
                    ForEach(config.members, id: \.self) { chip(keyName($0)) }
                    Spacer()
                    Button(recordingMembers ? "Done" : "Record Keys") { model.toggleRecording(.members(config.id)) }
                }
                HStack(spacing: 6) {
                    Text("Sends").frame(width: 50, alignment: .leading)
                    if let out = config.output { chip(keyName(out)) } else {
                        Text(recordingOutput ? "Press a key…" : "None yet").foregroundColor(.secondary)
                    }
                    if model.heldOutputs.contains(config.id) {
                        Text("● held").foregroundColor(.green).font(.callout)
                    }
                    Spacer()
                    Button(recordingOutput ? "Cancel" : "Record Key") { model.toggleRecording(.output(config.id)) }
                }
                HStack(spacing: 6) {
                    Text("Rule").frame(width: 50, alignment: .leading)
                    Picker("", selection: $config.rule) {
                        ForEach(RuleKind.allCases) { Text($0.title).tag($0) }
                    }
                    .labelsHidden()
                    .frame(width: 220)
                    if config.rule == .nOfM {
                        Stepper("N = \(config.n) of \(config.members.count)", value: $config.n,
                                in: 1...max(1, config.members.count))
                    }
                    Spacer()
                    Button(role: .destructive) {
                        model.groups.removeAll { $0.id == config.id }
                    } label: { Text("Remove") }
                }
                if let p = model.problem(for: config.id) {
                    Text(p).font(.callout).foregroundColor(.orange)
                }
            }
            .padding(4)
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.secondary.opacity(0.18)))
    }
}
