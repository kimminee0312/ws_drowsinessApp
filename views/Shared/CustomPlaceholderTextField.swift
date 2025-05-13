import SwiftUI

struct CustomPlaceholderTextField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    var placeholderColor: UIColor = .gray
    var textColor: UIColor = .black

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: UIFont.systemFont(ofSize: 13)
            ])
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject {
        var text: Binding<String>
        init(text: Binding<String>) {
            self.text = text
        }

        @objc func textDidChange(_ sender: UITextField) {
            text.wrappedValue = sender.text ?? ""
        }
    }
}
