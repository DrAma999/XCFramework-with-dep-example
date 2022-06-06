@_exported import PublicSDK

@_implementationOnly import ImpOnlyA
@_implementationOnly import ImpOnlyB


public struct SDK {
    #if PVT
    public private(set) var text = "Hello I'm SDK Private"
    #else
    public private(set) var text = "Hello I'm SDK"
    #endif

    public init() {
    }
    
    public func pokeImpOnlyA() {
        let text = ImpOnlyA().text
        print("Poking: \(text)")
    }
    
    public func pokeImpOnlyB() {
        let text = ImpOnlyB().text
        print("Poking: \(text)")
    }
    
    public func pokePublicSDK() {
        let text = PublicSDK().text
        print("Poking: \(text)")
    }
    
    public func pokeAllSDKs() {
        pokePublicSDK()
        pokeImpOnlyA()
        pokeImpOnlyB()
    }
}
