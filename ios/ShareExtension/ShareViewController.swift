// DOOMNOTES - iOS Share Extension Controller
//
// This subclasses receive_sharing_intent's own RSIShareViewController,
// which is the plugin's documented integration point — it already handles
// reading the shared text/URL, writing it to the App Group container in the
// format the Dart side expects, and returning control to the host app.
//
// An earlier draft implemented this from scratch (manually reading
// NSExtensionItem attachments, writing a raw file into the App Group
// container, and posting a Darwin notification). That code never matched
// what ReceiveSharingIntent.instance.getMediaStream() on the Dart side
// actually reads, so shares would have silently gone nowhere. The old file
// is kept for reference in _legacy_drafts/.
//
// Remaining manual setup this file can't do on its own (needs Xcode/your
// Apple Developer account) is in docs/IOS_SHARE_EXTENSION_SETUP.md.

import receive_sharing_intent

class ShareViewController: RSIShareViewController {
}
