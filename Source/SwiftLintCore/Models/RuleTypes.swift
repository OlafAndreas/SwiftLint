/// The discovery key for rules. `Discoverable.types(for: RuleTypes.self)` finds every rule type marked with
/// ``SwiftSyntaxRule(foldExpressions:explicitRewriter:correctable:optIn:)`` or `@Discoverable(RuleTypes.self)`.
public enum RuleTypes: DiscoveryKey {}
