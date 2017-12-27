//
//  ViewController.swift
//  iPhoneScreenshotCreator
//
//  Created by Russell Brown on 27/12/2017.
//  Copyright © 2017 Russell Brown. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {

    // Outlets
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet var caption: NSTextView!
    @IBOutlet weak var fontName: NSPopUpButton!
    @IBOutlet weak var fontSize: NSPopUpButton!
    @IBOutlet weak var fontColor: NSColorWell!
    @IBOutlet weak var backgroundImage: NSPopUpButton!
    @IBOutlet weak var backgroundColorStart: NSColorWell!
    @IBOutlet weak var backgroundColorEnd: NSColorWell!
    @IBOutlet weak var dropShadowStrength: NSSegmentedControl!
    @IBOutlet weak var dropShadowTarget: NSSegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFonts()
        loadBackgroundImages()
        
    }
    
    override func viewWillAppear() {
        generatePreview()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadFonts() {
        
        //find the list of fonts
        guard let fontFile = Bundle.main.url(forResource: "fonts", withExtension: nil) else { return }
        guard let fonts = try? String(contentsOf: fontFile) else { return }
        
        //split it up into an array by breaking on new lines
        let fontNames = fonts.components(separatedBy: "\n")
        
        //loop over every font
        for font in fontNames {
            if font.hasPrefix(" ") {
                //this is a font variation
                let item = NSMenuItem(title: font, action: #selector(changeFontName), keyEquivalent: "")
                item.target = self
                fontName.menu?.addItem(item)
            } else {
                //this is a font family
                let item = NSMenuItem(title: font, action: nil, keyEquivalent: "")
                item.target = self
                item.isEnabled = false
                fontName.menu?.addItem(item)
            }
        }
    }
    
    func loadBackgroundImages() {
        let allImages = ["Antique Wood", "Autumn Leaves", "Autumn Sunset", "Autumn by the Lake", "Beach and Palm Tree", "Blue Skies", "Bokeh (Blue)", "Bokeh (Golden)", "Bokeh (Green)", "Bokeh (Orange)", "Bokeh (Rainbow)", "Bokeh (White)", "Burning Fire", "Cherry Blossom", "Coffee Beans", "Cracked Earth", "Geometric Pattern 1", "Geometric Pattern 2", "Geometric Pattern 3", "Geometric Pattern 4", "Grass", "Halloween", "In the Forest", "Jute Pattern", "Polka Dots (Purple)", "Polka Dots (Teal)", "Red Bricks", "Red Hearts", "Red Rose", "Sandy Beach", "Sheet Music", "Snowy Mountain", "Spruce Tree Needles", "Summer Fruits", "Swimming Pool", "Tree Silhouette", "Tulip Field", "Vintage Floral", "Zebra Stripes"]
        for image in allImages {
            let item = NSMenuItem(title: image, action: #selector(changeBackgroundImage), keyEquivalent: "")
            item.target = self
            backgroundImage.menu?.addItem(item)
        }
    }
    
    @objc func changeFontName(_ sender: NSMenuItem) {
        generatePreview()
    }
    
    func generatePreview() {
        let image = NSImage(size: CGSize(width: 1242, height: 2208), flipped: false) { [unowned self] rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            //our drawing code here
            self.clearBackground(context: ctx, rect: rect)
            self.drawBackgroundImage(rect: rect)
            self.drawColorOverlay(rect: rect)
            let captionOffset = self.drawCaption(context: ctx, rect: rect)
            return true
        }
        imageView.image = image
    }
    
    func clearBackground(context: CGContext, rect: CGRect) {
        context.setFillColor(NSColor.white.cgColor)
        context.fill(rect)
    }
    
    func drawBackgroundImage(rect: CGRect) {
        //if they chose no background image, bail out
        if backgroundImage.selectedTag() == 999 { return }
        
        //if we can't get the current title, bail out
        guard let title = backgroundImage.titleOfSelectedItem else { return }
        
        //if we can't convert that title to an image, bail out
        guard let image = NSImage(named: NSImage.Name(rawValue: title)) else { return }
        
        //still here? draw the image
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    }
    
    func drawColorOverlay(rect: CGRect) {
        let gradient = NSGradient(starting: backgroundColorStart.color, ending: backgroundColorEnd.color)
        gradient?.draw(in: rect, angle: -90)
    }
    
    func createCaptionAttributes() -> [NSAttributedStringKey: Any]? {
        let ps = NSMutableParagraphStyle()
        ps.alignment = .center
        
        let fontSizes: [Int: CGFloat] = [0: 48, 1: 56, 2: 64, 3: 72, 4: 80, 5: 96, 6: 128]
        guard let baseFontSize = fontSizes[fontSize.selectedTag()] else { return nil }
        
        let selectedFontName = fontName.selectedItem?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? "HelveticaNeue-Medium"
        guard let font = NSFont(name: selectedFontName, size: baseFontSize) else { return nil }
        
        let color = fontColor.color
        
        return [NSAttributedStringKey.paragraphStyle: ps, NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: color]
    }
    
    func setShadow() {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize.zero
        shadow.shadowColor = NSColor.black
        shadow.shadowBlurRadius = 50
        //the shadow is now configured - activate it
        shadow.set()
    }
    
    func drawCaption(context: CGContext, rect: CGRect) -> CGFloat {
        if dropShadowStrength.selectedSegment != 0 {
            //if the drop shadow is enabled
            if dropShadowTarget.selectedSegment == 0 || dropShadowTarget.selectedSegment == 2 {
                //and is set to "Text" or "Both"
                setShadow()
            }
        }
        
        //pull out the string to render
        let string = caption.textStorage?.string ?? ""
        
        //inset the rendering rectto keep the text off the edges
        let insetRect = rect.insetBy(dx: 40, dy: 20)
        
        //combine the user's text with their attributes to create an attributed string
        let captionAttributes = createCaptionAttributes()
        let attributedString = NSAttributedString(string: string, attributes: captionAttributes)
        
        //draw the string in the inset rect
        attributedString.draw(in: insetRect)
        
        //if the shadow is set to strong then we'll draw the string again to make the shadow deeper
        if dropShadowStrength.selectedSegment == 2 {
            if dropShadowTarget.selectedSegment == 0 || dropShadowTarget.selectedSegment == 2 {
                attributedString.draw(in: insetRect)
            }
        }
        
        //clear the shadow so it doesn't affect other stuff
        let noShadow = NSShadow()
        noShadow.set()
        
        //calculate how much space this attributed string needs
        let availableSpace = CGSize(width: insetRect.width, height: CGFloat.greatestFiniteMagnitude)
        let textFrame = attributedString.boundingRect(with: availableSpace, options: [.usesLineFragmentOrigin, .usesFontLeading])
        
        return textFrame.height
    }
    
    func textDidChange(_ notification: Notification) {
        generatePreview()
    }

    // Actions
    @IBAction func changeFontSize(_ sender: NSMenuItem) {
        generatePreview()
    }
    
    @IBAction func changeFontColor(_ sender: NSColorWell) {
        generatePreview()
    }
    
    @IBAction func changeBackgroundImage(_ sender: NSPopUpButton) {
        generatePreview()
    }

    @IBAction func changeBackgroundColorStart(_ sender: NSColorWell) {
        generatePreview()
    }
    
    @IBAction func changeBackgroundColorEnd(_ sender: NSColorWell) {
        generatePreview()
    }
    
    @IBAction func changeDropShadowStrength(_ sender: NSSegmentedControl) {
        generatePreview()
    }
    
    @IBAction func changeDropShadowTarget(_ sender: NSSegmentedControl) {
        generatePreview()
    }
    
}

