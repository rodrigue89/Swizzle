//
//  ViewController.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/13/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Cocoa
import SwizzleSrc

class ViewController: NSViewController, NSTextViewDelegate, LoggerDelegate {

    @IBOutlet var codeTextView: NSTextView!
    @IBOutlet var consoleTextView: NSTextView!
    
    let regexes: [RegularExpression] = [
        RegularExpression(word: .identifier, info: ["( |\\()", "( |\\(|\\)|;)"]),
        RegularExpression(word: .symbol, info: Reserved.symbols),
        RegularExpression(word: .keyword, info: Reserved.keywords),
        RegularExpression(word: .number),
        RegularExpression(word: .string),
        RegularExpression(word: .comment),
        ]
    var highlighter: Highlighter!
    
    var completions =  CodeCompletion()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        AppDelegate.logDelegate = self
        
        codeTextView.delegate = self
        codeTextView.setupLineNumbers()
        
        do {
            try Log.new()
        }
        catch {
            print(error.localizedDescription)
        }
        
        Highlighter.configure {
            $0.fontName = "Helvetica"
            $0.fontSize = 12
        }
        self.highlighter = Highlighter(regularExpressions: regexes)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    let notAllowed: Set<Unicode.Scalar> = ["\u{201d}", "\u{201c}"]
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        return !(replacementString?.unicodeScalars.contains(where: notAllowed.contains) ?? false)
    }
    
    func textDidChange(_ notification: Notification) {
        highlighter.highlightSyntax(in: codeTextView)
        try? run()
    }
    
    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
        let code = codeTextView.string
        guard let range = Range(charRange, in: code) else { return [] }
        return completions.completions(in: code, range: range)
    }
    
    func run() throws {
        let code = codeTextView.string
        let statements = parse(codeText: code, consoleText: &consoleTextView.string)
        var ir = [Any]()
        
        try generate(from: statements, into: &ir)
        print(ir)
    }

    @IBAction func runCode(_ sender: NSButton) {
        do {
            try run()
        }
        catch {
            print(error)
        }
    }
    
    func log() {
        do {
            try Log.current?.write()
        }
        catch {
            NSAlert(error: error).runModal()
        }
    }
    
}

