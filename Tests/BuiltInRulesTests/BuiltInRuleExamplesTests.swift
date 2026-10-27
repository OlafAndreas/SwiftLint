import Foundation
import SwiftLintCore
import TestHelpers
import Testing

@testable import SwiftLintBuiltInRules

/// Every built-in rule, as discovery finds it.
private let builtInRules = Discoverable.types(for: RuleTypes.self)
    .compactMap { $0 as? any Rule.Type }
    .filter { String(reflecting: $0).hasPrefix("SwiftLintBuiltInRules.") }

@Suite(.rulesRegistered)
struct BuiltInRuleExamplesTests {
    @Test(arguments: builtInRules)
    func withDefaultConfiguration(_ rule: any Rule.Type) {
        verifyRule(rule.description)
    }

    @Test
    func everyRuleFileDeclaresADiscoveredRule() throws {
        let rulesDirectory = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Source/SwiftLintBuiltInRules/Rules", directoryHint: .isDirectory)
        let enumerator = try #require(
            FileManager.default.enumerator(at: rulesDirectory, includingPropertiesForKeys: nil)
        )
        let ruleFiles = enumerator
            .compactMap { ($0 as? URL)?.lastPathComponent }
            .filter { $0.hasSuffix("Rule.swift") }
            .map { String($0.dropLast(".swift".count)) }
        let discovered = builtInRules.map { String(describing: $0) }
        #expect(Set(ruleFiles) == Set(discovered))
    }
}
