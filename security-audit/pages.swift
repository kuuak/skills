// Render each page of a PDF to <dir>/page-N.png, for machines without pdftoppm.
// Usage: swift pages.swift <file.pdf> <dir>
import AppKit
import PDFKit

let args = CommandLine.arguments
guard let doc = PDFDocument(url: URL(fileURLWithPath: args[1])) else { exit(1) }
for i in 0..<doc.pageCount {
    guard let page = doc.page(at: i) else { continue }
    let rect = page.bounds(for: .mediaBox)
    let scale: CGFloat = 1.4
    let img = NSImage(size: NSSize(width: rect.width * scale, height: rect.height * scale))
    img.lockFocus()
    NSColor.white.set()
    NSRect(origin: .zero, size: img.size).fill()
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: ctx)
    img.unlockFocus()
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!
        .write(to: URL(fileURLWithPath: "\(args[2])/page-\(i + 1).png"))
}
