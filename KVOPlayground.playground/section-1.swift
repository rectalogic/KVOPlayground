// Playground - noun: a place where people can play

import UIKit

typealias KVObserver = (kvo: KeyValueObserver, change: [NSObject : AnyObject]) -> Void

class KeyValueObserver {
    let source: NSObject
    let keyPath: String
    private let observer: KVObserver

    init(source: NSObject, keyPath: String, options: NSKeyValueObservingOptions, observer: KVObserver) {
        self.source = source
        self.keyPath = keyPath
        self.observer = observer
        source.addObserver(defaultKVODispatcher, forKeyPath: keyPath, options: options, context: self.pointer)
    }

    func __conversion() -> UnsafeMutablePointer<KeyValueObserver> {
        return pointer
    }

    private lazy var pointer: UnsafeMutablePointer<KeyValueObserver> = {
        return UnsafeMutablePointer<KeyValueObserver>(Unmanaged<KeyValueObserver>.passUnretained(self).toOpaque())
    }()

    private class func fromPointer(pointer: UnsafeMutablePointer<KeyValueObserver>) -> KeyValueObserver {
        return Unmanaged<KeyValueObserver>.fromOpaque(COpaquePointer(pointer)).takeUnretainedValue()
    }

    class func observe(pointer: UnsafeMutablePointer<KeyValueObserver>, change: [NSObject : AnyObject]) {
        let kvo = fromPointer(pointer)
        kvo.observer(kvo: kvo, change: change)
    }

    deinit {
        source.removeObserver(defaultKVODispatcher, forKeyPath: keyPath, context: self.pointer)
    }
}


class KVODispatcher : NSObject {
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        KeyValueObserver.observe(UnsafeMutablePointer<KeyValueObserver>(context), change: change)
    }
}

private let defaultKVODispatcher = KVODispatcher()



let button = UIButton()
KeyValueObserver(source: button, keyPath: "selected", options: .New) {
    (kvo, change) in
    NSLog("OBSERVE 1 %@ %@", kvo.keyPath, change)
}

button.selected = true
button.selected = false

var kvo: KeyValueObserver? = KeyValueObserver(source: button, keyPath: "selected", options: .New) {
    (kvo, change) in
    NSLog("OBSERVE 2 %@ %@", kvo.keyPath, change)
}

button.selected = true
button.selected = false
kvo = nil
button.selected = true

