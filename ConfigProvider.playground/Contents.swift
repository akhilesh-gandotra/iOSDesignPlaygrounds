import UIKit

var str = "Hello, playground"



// QUERIES:

/*
 
 1. Should ConfigProvider conform to a protocol for testability, if yes how will the framework pass the instance to the client?
 
 
 
 
 
 */

enum ConfigType {
    case litmus
    case bcs
}

struct Config {
    public var value: Any?
    
    public func toBool(defaultValue: Bool = true) -> Bool {
        
        guard let rawValueNSString = value as? NSString else {
            return defaultValue
        }
        return rawValueNSString.boolValue
    }
    
    
    
    public func toString(defaultValue: String = "") -> String {
        return value as? String ?? defaultValue
    }
    public func toInt(defaultValue: Int = 0) -> Int {
        guard let rawValueNSString = value as? NSString else {
            return defaultValue
        }
        
        return rawValueNSString.integerValue
    }
    
}


protocol ConfigProvidable {
    func fetch(key: String, source: ConfigType) -> Config
}

protocol Provider {
    var type: ConfigType {get}
    func fetch(key: String) -> Config
}

protocol ConfigFetchererProtocol {
    var providers: [Provider]  { get set }
    func fetch(key: String, source: ConfigType) -> Config
}

class ConfigProvider: ConfigProvidable {
    
    static var sharedInstance: ConfigProvider?
    
    private var configFetcherer: ConfigFetchererProtocol?
    
    public func initilize(fetcherer: ConfigFetchererProtocol) {
        self.configFetcherer = fetcherer
    }
    
    public static func shared() -> ConfigProvider {
        guard let instance = sharedInstance else {
            self.sharedInstance = ConfigProvider()
            return sharedInstance!
        }
        
        return instance
    }
    
    
    public func fetch(key: String, source: ConfigType) -> Config {
        if let fetcherer = configFetcherer {
            return fetcherer.fetch(key: key, source: source)
        }
        return Config(value: nil)
    }
}

class ConfigFetcherer: ConfigFetchererProtocol {
    var providers: [Provider]
    
    init(providers: [Provider]) {
        self.providers = providers
    }
    
    func fetch(key: String, source: ConfigType) -> Config {
        providers.filter{$0.type == source}.first?.fetch(key: key) ?? Config(value: nil)
    }
    
}


class BCSProvider: Provider {
    var type: ConfigType {
        return .bcs
    }
    
    private var dict: [String: Any]
    
    init() {
        func getMyData() -> [String: Any] {
            return ["bcs":"akhiles", "key1": 87]
        }
        self.dict = getMyData()
    }
    
    func fetch(key: String) -> Config {
        Config(value: dict[key])
    }
    
    
}

class LitmusProvider: Provider {
    var type: ConfigType {
        return .litmus
    }
    
    private var dict: [String: Any]
    
    init() {
        func getMyData() -> [String: Any] {
            return ["litmus": false, "key1": 887]
        }
        self.dict = getMyData()
    }
    
    func fetch(key: String) -> Config {
        Config(value: dict[key])
    }
    
    
}


let configProvider = ConfigProvider.shared()
configProvider.initilize(fetcherer: ConfigFetcherer(providers: [BCSProvider(), LitmusProvider()]))



print(configProvider.fetch(key: "litmus", source: .litmus).toBool())

