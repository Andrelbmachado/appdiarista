import Foundation
import PassKit
import Combine

final class PaymentController: NSObject, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    enum PaymentError: LocalizedError {
        case unavailable
        case unableToPresent
        case cancelled
        case failed
        
        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "Apple Pay não está disponível neste dispositivo."
            case .unableToPresent:
                return "Não foi possível apresentar o Apple Pay."
            case .cancelled:
                return "O pagamento foi cancelado."
            case .failed:
                return "Não foi possível concluir o pagamento."
            }
        }
    }
    
    private let merchantIdentifier = "merchant.com.example.diaristafacil"
    private let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .maestro, .elo]
    private var completion: ((Result<Void, Error>) -> Void)?
    private var controller: PKPaymentAuthorizationController?
    private var didAuthorizePayment = false
    
    func canMakePayments() -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }
    
    func startPayment(amount: Decimal, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard canMakePayments() else {
            completion(.failure(PaymentError.unavailable))
            return
        }
        didAuthorizePayment = false
        self.completion = completion
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        if #available(iOS 17, *) {
            request.merchantCapabilities = .threeDSecure
        } else {
            request.merchantCapabilities = .capability3DS
        }
        request.supportedNetworks = supportedNetworks
        request.countryCode = "BR"
        request.currencyCode = "BRL"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: description, amount: NSDecimalNumber(decimal: amount))
        ]
        controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller?.delegate = self
        controller?.present(completion: { [weak self] presented in
            guard let self else { return }
            if !presented {
                self.completion?(.failure(PaymentError.unableToPresent))
            }
        })
    }
}

extension PaymentController: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        didAuthorizePayment = true
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        self.completion?(.success(()))
        self.completion = nil
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            if !self.didAuthorizePayment {
                self.completion?(.failure(PaymentError.cancelled))
                self.completion = nil
            }
            self.didAuthorizePayment = false
            self.controller = nil
        }
    }
}
