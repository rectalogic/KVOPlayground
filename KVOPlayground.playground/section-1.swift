// Playground - noun: a place where people can play

import UIKit

typealias KVObserver = (source: NSObject, keyPath: String, change: [NSObject : AnyObject]) -> Void

class KVOContext {
    private let source: NSObject
    private let keyPath: String
    private let observer: KVObserver

    func __conversion() -> UnsafeMutablePointer<KVOContext> {
        return UnsafeMutablePointer<KVOContext>(Unmanaged<KVOContext>.passUnretained(self).toOpaque())
    }

    class func fromPointer(pointer: UnsafeMutablePointer<KVOContext>) -> KVOContext {
        return Unmanaged<KVOContext>.fromOpaque(COpaquePointer(pointer)).takeUnretainedValue()
    }

    init(source: NSObject, keyPath: String, observer: KVObserver) {
        self.source = source
        self.keyPath = keyPath
        self.observer = observer
    }

    func invokeCallback(change: [NSObject : AnyObject]) {
        observer(source: source, keyPath: keyPath, change: change)
    }

    deinit {
        source.removeObserver(defaultKVODispatcher, forKeyPath: keyPath, context: self as UnsafeMutablePointer<KVOContext>)
    }
}

class KVODispatcher : NSObject {
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        KVOContext.fromPointer(UnsafeMutablePointer<KVOContext>(context)).invokeCallback(change)
    }
}

private let defaultKVODispatcher = KVODispatcher()

extension NSObject {
    func addKeyValueObserver(keyPath: String, options: NSKeyValueObservingOptions, observeChange: KVObserver) -> KVOContext? {
        let context = KVOContext(source: self, keyPath: keyPath, observer: observeChange)
        self.addObserver(defaultKVODispatcher, forKeyPath: keyPath, options: options, context: context as UnsafeMutablePointer<KVOContext>)
        return context
    }
}


let button = UIButton()
var context = button.addKeyValueObserver("selected", options: .New) {
    (source, keyPath, change) in
    NSLog("OBSERVE %@ %@", keyPath, change)
}
button.selected = true
button.selected = false
context = nil
