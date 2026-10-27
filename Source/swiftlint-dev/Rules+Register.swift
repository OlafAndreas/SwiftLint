import ArgumentParser
import Foundation
import SwiftLintFramework

extension SwiftLintDev.Rules {
    struct Register: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "register",
            abstract: "Register rules as provided by SwiftLint.",
            discussion: """
                This command records the default configuration of every rule in the integration tests'
                reference file. Rules themselves are found at runtime through their discovery records.
                """
        )

        private var testsDirectory: URL {
            URL(filePath: FileManager.default.currentDirectoryPath)
                .appending(path: "Tests", directoryHint: .isDirectory)
        }

        func run() throws {
            try runFor(newRule: nil)
        }

        func runFor(newRule: NewRuleDetails?) throws {
            guard FileManager.default.fileExists(atPath: testsDirectory.path) else {
                throw ValidationError("Command must be run from the root of the SwiftLint repository.")
            }
            let count = try registerInTestReference(adding: newRule)
            print("(Re-)Registered \(count) rules.")
        }
    }
}

struct NewRuleDetails: Equatable {
    let identifier: String
    let yamlConfig: String
    let optIn: Bool
    let correctable: Bool

    var yaml: String {
        """
        \(identifier):
        \(yamlConfig.indent(by: 2))
          meta:
            opt-in: \(optIn)
            correctable: \(correctable)
        """
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

private extension SwiftLintDev.Rules.Register {
    func registerInTestReference(adding newRule: NewRuleDetails?) throws -> Int {
        RuleRegistry.registerAllRulesOnce()
        var ruleDetails = Configuration(rulesMode: .allCommandLine).rules
            .map { type(of: $0) }
            .filter { $0.identifier != "custom_rules" }
            .map { ruleType in
                let rule = ruleType.init()
                return NewRuleDetails(
                    identifier: ruleType.identifier,
                    yamlConfig: rule.createConfigurationDescription().yaml(),
                    optIn: rule is any OptInRule,
                    correctable: rule is any CorrectableRule
                )
            }
        if let newRule {
            ruleDetails.append(newRule)
        }
        let rules = ruleDetails
            .sorted { $0.identifier < $1.identifier }
            .unique
        try rules
            .map(\.yaml)
            .joined(separator: "\n")
            .appending("\n")
            .write(
                to: testsDirectory
                    .appending(path: "IntegrationTests", directoryHint: .isDirectory)
                    .appending(path: "Resources", directoryHint: .isDirectory)
                    .appending(path: "default_rule_configurations.yml", directoryHint: .notDirectory),
                atomically: true,
                encoding: .utf8
            )
        return rules.count
    }
}
