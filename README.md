# text-scan-summarize-ios

This iOS app allows the user to scan a document using the device camera and generate a summary of the text. The app in the current state is only a prototype; it is very barebones with no considerations put into the UI.

## Text Scanning

The text scanning uses the Apple Vision framework and is based on an Apple example project.

[Locating and Displaying Recognized Text on a Document](https://developer.apple.com/documentation/vision/locating_and_displaying_recognized_text_on_a_document)

- Note: For more information about this sample code project, see [WWDC 2019 Session 234: Text Recognition in Vision Framework](https://developer.apple.com/videos/play/wwdc19/234/).

## Text Summarization

The text summarization utlizes the [Reductio](https://github.com/fdzsergio/Reductio) library by [fdzsergio](https://github.com/fdzsergio). Reductio uses the TextRank algorithm to provide an extractive summary of the text.
