// LoopFollow
// NightscoutContentView.swift

import SafariServices
import SwiftUI

struct NightscoutContentView: View {
    @ObservedObject private var url = Storage.shared.url
    @ObservedObject private var token = Storage.shared.token
    @ObservedObject private var useSafariView = Storage.shared.nightscoutUseSafariView

    var body: some View {
        if url.value.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "network")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Please enter your Nightscout URL in Settings.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else if useSafariView.value {
            NightscoutSafariLauncherView()
        } else {
            NightscoutWebView()
                // NightscoutViewController loads the page once in viewDidLoad,
                // so recreate it when the URL or token changes.
                .id(url.value + "|" + token.value)
        }
    }
}

private struct NightscoutWebView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> NightscoutViewController {
        NightscoutViewController()
    }

    func updateUIViewController(_ uiViewController: NightscoutViewController, context _: Context) {
        uiViewController.overrideUserInterfaceStyle = Storage.shared.appearanceMode.value.userInterfaceStyle
    }
}

/// Opens the site in SFSafariViewController, which (unlike WKWebView) supports
/// passkeys and other Safari sign-in features. Apple requires it to be presented
/// modally rather than embedded, so the tab shows a button and presents it on appear.
private struct NightscoutSafariLauncherView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "safari")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Button("Open Nightscout") {
                present()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            present()
        }
    }

    private func present() {
        guard let url = NightscoutUtils.constructURL(
            baseURL: Storage.shared.url.value,
            token: Storage.shared.token.value,
            endpoint: "",
            parameters: [:]
        ),
            let presenter = UIApplication.shared.topMost,
            !(presenter is SFSafariViewController)
        else { return }

        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .done
        safari.overrideUserInterfaceStyle = Storage.shared.appearanceMode.value.userInterfaceStyle
        presenter.present(safari, animated: true)
    }
}
