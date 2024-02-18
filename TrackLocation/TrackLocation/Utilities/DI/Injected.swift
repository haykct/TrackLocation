//
//  Injected.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

@propertyWrapper struct Injected<Value> {
    var wrappedValue: Value

    init() {
        wrappedValue = Injection.shared.container.resolve(Value.self)!
    }
}
