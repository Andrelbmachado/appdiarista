import SwiftUI
import PassKit
import UIKit

struct ServiceCompletionView: View {
    @Binding var service: UpcomingService
    @Environment(\.dismiss) private var dismiss
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var isRequestingPayment = false
    @State private var alertMessage: String?
    @StateObject private var paymentController = PaymentController()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    proofSection
                    paymentSection
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Registrar serviço")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .sheet(isPresented: $showCamera) {
                PhotoCaptureView(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .alert(alertMessage ?? "", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            }
            .onAppear {
                if capturedImage == nil, let data = service.proofImageData, let uiImage = UIImage(data: data) {
                    capturedImage = uiImage
                }
            }
        }
    }
    
    private var proofSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comprovante do serviço")
                .font(.headline)
            Text("Anexe uma foto do local após a limpeza para compartilhar com o cliente.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Group {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8]))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                                Text("Nenhuma foto adicionada")
                                    .foregroundStyle(.secondary)
                            }
                        )
                }
            }
            Button(action: { showCamera = true }) {
                Label(capturedImage == nil ? "Capturar foto" : "Refazer foto", systemImage: "camera.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solicitar pagamento")
                .font(.headline)
            Text("Valor: \(CurrencyFormatter.string(from: service.amount))")
                .font(.title3)
                .fontWeight(.semibold)
            if paymentController.canMakePayments() {
                ApplePayButton(action: requestPayment)
                    .frame(height: 52)
                    .opacity(canRequestPayment ? 1 : 0.4)
                    .allowsHitTesting(canRequestPayment && !isRequestingPayment)
                if !canRequestPayment {
                    Text("Adicione uma foto antes de solicitar o pagamento.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Apple Pay não está configurado neste dispositivo.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var canRequestPayment: Bool {
        capturedImage != nil && !isRequestingPayment
    }
    
    private func requestPayment() {
        guard let image = capturedImage else {
            alertMessage = "Capture uma foto para comprovar o serviço antes de solicitar o pagamento."
            return
        }
        isRequestingPayment = true
        paymentController.startPayment(amount: service.amount, description: "Serviço de limpeza") { result in
            DispatchQueue.main.async {
                self.isRequestingPayment = false
                switch result {
                case .success:
                    self.service.proofImageData = image.jpegData(compressionQuality: 0.85)
                    self.service.status = .finalized
                    self.dismiss()
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                }
            }
        }
    }
}

private struct ApplePayButton: UIViewRepresentable {
    var action: () -> Void
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .inStore, paymentButtonStyle: .automatic)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        context.coordinator.action = action
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    final class Coordinator: NSObject {
        var action: () -> Void
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func didTapButton() {
            action()
        }
    }
}

private struct PhotoCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoCaptureView
        init(parent: PhotoCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
