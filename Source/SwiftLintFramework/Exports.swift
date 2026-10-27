@_exported import SwiftLintBuiltInRules
@_exported import SwiftLintCore
import SwiftLintExtraRules

private let _registerAllRulesOnceImpl: Void = {
    let rules = Discoverable.types(for: RuleTypes.self).compactMap { $0 as? any Rule.Type }
    RuleRegistry.shared.register(rules: rules + extraRules())
}()

package extension RuleRegistry {
    /// Register all rules. Should only be called once before any SwiftLint code is executed.
    static func registerAllRulesOnce() {
        _ = _registerAllRulesOnceImpl
    }
}
