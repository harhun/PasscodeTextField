//
//  PasscodeTextField.swift
//
//  Created by Harhun on 27.10.16.
//

import UIKit

protocol PasscodeTextFieldDelegate : class {
    func codeInputCompleted(_ code:String)
}

class PasscodeTextField: UITextField {

    weak var passcodeTextFieldDelegate: PasscodeTextFieldDelegate?
    var requiredCodeLength = 4 {
        didSet {
            numOfSpaces = requiredCodeLength - 1
        }
    }
    
    fileprivate var padding = UIEdgeInsets.zero
    
    fileprivate let widthSquares: CGFloat = 50
    fileprivate var numOfSpaces = 3

    override func awakeFromNib() {
        
        borderStyle = .none
        keyboardType = .numberPad
        tintColor = UIColor.black
        
        delegate = self
        adjustsFontSizeToFitWidth = false
        
        font = UIFont.appSpecific(.regularFont, ofSize: 45)
        textColor = UIColor.black
        
        addTarget(self, action: #selector(textFieldDidChangeText(_:)), for: .editingChanged)
    }
    
    fileprivate func addTextSpacing() {
        if let text = text {
            
            let attributedString = NSMutableAttributedString(string: text)
            var currentSpace: CGFloat = 0
            var lastSpace: CGFloat = 0

            // count spaces
            for value in text.characters.enumerated() {
                let text: NSString = String(value.element) as NSString
                
                let textSize = text.size(attributes: [NSFontAttributeName : font!])
                if value.offset == 0 {
                    padding = UIEdgeInsets(top: 0,
                                           left: (widthSquares - textSize.width)/2,
                                           bottom: 0,
                                           right: 0)
                    lastSpace = (widthSquares + textSize.width)/2
                }
                else {
                    var spacing = (bounds.width * CGFloat(value.offset) / CGFloat(numOfSpaces)) - widthSquares * (currentSpace / CGFloat(numOfSpaces))
                    spacing += (widthSquares - textSize.width)/2

                    attributedString.addAttribute(NSKernAttributeName,
                                                  value: spacing - lastSpace,
                                                  range: NSRange(location: value.offset - 1, length: 1))
                    lastSpace += (spacing - lastSpace) + textSize.width
                }
                currentSpace += 1
            }
           
            attributedText = attributedString
        }
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let h = rect.height
        let w = rect.width
        
        let color:UIColor = UIColor(rgbColorCodeRed: 226, green: 226, blue: 235, alpha: 1)
        
        var currentSpace: CGFloat = 0

        for i in 0..<requiredCodeLength {
  
            let drect = CGRect(x: (w / CGFloat(numOfSpaces) * CGFloat(i)) - widthSquares * (currentSpace / CGFloat(numOfSpaces)),
                               y: 0,
                               width: widthSquares,
                               height: h)
            
            let bpath:UIBezierPath = UIBezierPath(roundedRect: drect,
                                                  cornerRadius: 5)
            
            currentSpace += 1

            color.set()
            bpath.fill()
            bpath.stroke()
        }
    }
    
}

//MARK: - UITextFieldDelegate

extension PasscodeTextField: UITextFieldDelegate {
    
    @objc fileprivate func textFieldDidChangeText(_ textField: UITextField) {
        addTextSpacing()
        
        if let code = textField.text, code.characters.count >= requiredCodeLength {
            passcodeTextFieldDelegate?.codeInputCompleted(code)
        }
    }
    
}
