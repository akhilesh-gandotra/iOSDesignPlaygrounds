import Foundation

// NOTES:

/*
 
 1. Should ConfigProvider conform to a protocol for testability, if yes how will the framework pass the instance to the client?
 Protocol will enable testability at the framework's end. The client can directly call the ConfigProvider instance, it can stub the config Fetcherer's instance if required for iunit Testing.
 
 */

enum ConfigType {
    case litmus
    case bcs
}

/// An object representing a config, gives functionality to get value in specific datatype.
struct Config {
    public var value: Any?
    
    public func toBool(defaultValue: Bool = false) -> Bool {
        if let some = value as? Bool {
            return some
        }
        return defaultValue
    }
    
    public func toString(defaultValue: String = "") -> String {
        return value as? String ?? defaultValue
    }
    
    public func toInt(defaultValue: Int = 0) -> Int {
        if let some = value as? Int {
            return some
        }
        return defaultValue
    }
    
}

/// An interface representing which can fetch the key from a source client
/// Its is the minimal requirement of the config provider.
protocol ConfigProvidable {
    func fetch(key: String, source: ConfigType) -> Config
}

/// Interface for an object that can provide the actual config values
/// Type is important for identifying the config, getch helps in getting the value
protocol Provider {
    var type: ConfigType {get}
    func fetch(key: String) -> Config
}

/// Basic requirement of a fetcherer
/// It manages providers, and gives the configs according to the source
protocol ConfigFetchererProtocol {
    var providers: [Provider]  { get set }
    func fetch(key: String, source: ConfigType) -> Config
}

/// The concrete class which will provide the configs.
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

/// Assembles and Manages all the providers
class ConfigFetcherer: ConfigFetchererProtocol {
    internal var providers: [Provider]
    
    init(providers: [Provider]) {
        self.providers = providers
    }
    
    public func fetch(key: String, source: ConfigType) -> Config {
        providers.filter{$0.type == source}.first?.fetch(key: key) ?? Config(value: nil)
    }
    
}


class BCSProvider: Provider {
    var type: ConfigType {
        return .bcs
    }
    
    private var dict: [String: Any]
    
    init() {
        // Usually will be an API call
        func getMyData() -> [String: Any] {
            return ["bcs":"akhilesh", "key1": 87]
        }
        self.dict = getMyData()
    }
    
    func fetch(key: String) -> Config {
       return Config(value: dict[key])
    }
    
    
}

class LitmusProvider: Provider {
    var type: ConfigType {
        return .litmus
    }
    
    private var dict: [String: Any]
    
    init() {
        // Usually will be an API call
        func getMyData() -> [String: Any] {
            return ["litmus": true, "key1": 887]
        }
        self.dict = getMyData()
    }
    
    func fetch(key: String) -> Config {
       return Config(value: dict[key])
    }
    
    
}


let configProvider = ConfigProvider.shared()
configProvider.initilize(fetcherer: ConfigFetcherer(providers: [BCSProvider(), LitmusProvider()]))



print(configProvider.fetch(key: "litmus", source: .litmus).toBool())

