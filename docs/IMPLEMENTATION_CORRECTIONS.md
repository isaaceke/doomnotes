# DOOMNOTES: Required Corrections Before Coding Further

This document overrides inaccurate or incomplete prior generated files.

## 1. Do Not Keep Duplicate Production Files

Files such as:
- `home_screen.dart`
- `home_screen_optimized.dart`
- `share_handler_service.dart`
- `share_handler_service_updated.dart`

must not coexist as competing implementations. The coding agent must consolidate each pair into one final production file and delete or archive the obsolete version.

## 2. Manual Topic Selection Behavior

The manual picker must be optional.

Default behavior:
1. Receive content from the Share Sheet.
2. Extract URL/text/file payload.
3. Transcribe only when a supported video source can legally and technically be processed.
4. Classify transcript/text with keywords.
5. Save locally.
6. Notify the user: `Saved to [Topic]`.
7. Include source in the notification if the user enabled that preference.

Optional behavior:
1. Same capture and classification steps.
2. Present user with the predicted topic.
3. User can accept prediction, change it, or create a topic.
4. Save only after their choice.

## 3. X/Twitter Requirements

A shared X post may contain:
- A post URL
- Text included by X's share sheet
- An image file, if the operating system and source application actually provide it

The app must not scrape, invent, or falsely claim to have retrieved post text/images from the URL. Store the actual shared payload and original source URL.

## 4. Backend Constraint

A phone cannot call `localhost:8000` and reach a backend running on a Windows laptop unless the device, LAN address, firewall rules, and server binding are configured correctly. Production needs:
- A real HTTPS backend endpoint, OR
- On-device transcription, OR
- A clearly documented LAN development configuration.

## 5. Before Store Submission

Remove:
- Every `TODO`
- Every fake statistic
- Every invented testimonial
- Every inaccurate privacy claim
- Every external URL using `YOUR_WEBSITE`
- Every claim that a feature exists when it is not implemented

The app description, screenshots, privacy form, and data safety form must match final behavior exactly.