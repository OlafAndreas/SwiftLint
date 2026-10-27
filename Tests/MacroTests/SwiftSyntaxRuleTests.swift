import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import SwiftLintCoreMacros

private let macros = [
    "SwiftSyntaxRule": MacroSpec(type: SwiftSyntaxRule.self)
]

// swiftlint:disable line_length
/// The discovery record the macro emits next to `struct Hello {}`.
private let helloRecord = """
    #if canImport(Darwin)
    @section("__DATA_CONST,__swift5_discov") @used
    private let __swiftlint_rule_Hello: (version: UInt32, flags: UInt32, type: @convention(c) () -> UnsafeRawPointer, key: @convention(c) () -> UnsafeRawPointer) = (
        version: 1,
        flags: 0,
        type: {
            unsafe unsafeBitCast(Hello.self as Any.Type, to: UnsafeRawPointer.self)
        },
        key: {
            unsafe unsafeBitCast(SwiftLintCore.RuleTypes.self as Any.Type, to: UnsafeRawPointer.self)
        }
    )
    #elseif os(Linux) || os(Android) || os(FreeBSD)
    @section("swift5_discov") @used
    private let __swiftlint_rule_Hello: (version: UInt32, flags: UInt32, type: @convention(c) () -> UnsafeRawPointer, key: @convention(c) () -> UnsafeRawPointer) = (
        version: 1,
        flags: 0,
        type: {
            unsafe unsafeBitCast(Hello.self as Any.Type, to: UnsafeRawPointer.self)
        },
        key: {
            unsafe unsafeBitCast(SwiftLintCore.RuleTypes.self as Any.Type, to: UnsafeRawPointer.self)
        }
    )
    #endif
    """
// swiftlint:enable line_length

@Suite
struct SwiftSyntaxRuleTests {
    @Test
    func noArguments() {
        assertMacroExpansion(
            """
            @SwiftSyntaxRule
            struct Hello {}
            """,
            expandedSource: """
            struct Hello {}

            \(helloRecord)

            extension Hello: SwiftSyntaxRule {
                func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor<ConfigurationType> {
                    Visitor(configuration: configuration, file: file)
                }
            }
            """,
            macroSpecs: macros,
            failureHandler: FailureHandler.instance
        )
    }

    @Test
    func falseArguments() {
        assertMacroExpansion(
            """
            @SwiftSyntaxRule(foldExpressions: false, explicitRewriter: false, correctable: false, optIn: false)
            struct Hello {}
            """,
            expandedSource: """
            struct Hello {}

            \(helloRecord)

            extension Hello: SwiftSyntaxRule {
                func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor<ConfigurationType> {
                    Visitor(configuration: configuration, file: file)
                }
            }
            """,
            macroSpecs: macros,
            failureHandler: FailureHandler.instance
        )
    }

    @Test
    func trueArguments() {
        assertMacroExpansion(
            """
            @SwiftSyntaxRule(foldExpressions: true, explicitRewriter: true, correctable: true, optIn: true)
            struct Hello {}
            """,
            expandedSource: """
            struct Hello {}

            \(helloRecord)

            extension Hello: SwiftSyntaxRule {
                func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor<ConfigurationType> {
                    Visitor(configuration: configuration, file: file)
                }
            }

            extension Hello {
                func preprocess(file: SwiftLintFile) -> SourceFileSyntax? {
                    file.foldedSyntaxTree
                }
            }

            extension Hello: SwiftSyntaxCorrectableRule {
                func makeRewriter(file: SwiftLintFile) -> ViolationsSyntaxRewriter<ConfigurationType>? {
                    Rewriter(configuration: configuration, file: file)
                }
            }

            extension Hello: OptInRule {
            }
            """,
            macroSpecs: macros,
            failureHandler: FailureHandler.instance
        )
    }

    @Test
    func correctableWithoutExplcitRewriter() {
        assertMacroExpansion(
            """
            @SwiftSyntaxRule(correctable: true)
            struct Hello {}
            """,
            expandedSource: """
            struct Hello {}

            \(helloRecord)

            extension Hello: SwiftSyntaxRule {
                func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor<ConfigurationType> {
                    Visitor(configuration: configuration, file: file)
                }
            }

            extension Hello: SwiftSyntaxCorrectableRule {
            }
            """,
            macroSpecs: macros,
            failureHandler: FailureHandler.instance
        )
    }

    @Test
    func arbitraryArguments() {
        // Fail with a diagnostic because the macro definition explicitly requires bool arguments.
        assertMacroExpansion(
            """
            @SwiftSyntaxRule(foldExpressions: arg, explicitRewriter: arg, correctable: arg, optIn: arg)
            struct Hello {}
            """,
            expandedSource: """
            struct Hello {}

            \(helloRecord)

            extension Hello: SwiftSyntaxRule {
                func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor<ConfigurationType> {
                    Visitor(configuration: configuration, file: file)
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: SwiftLintCoreMacroError.noBooleanLiteral.message, line: 1, column: 35),
                DiagnosticSpec(message: SwiftLintCoreMacroError.noBooleanLiteral.message, line: 1, column: 58),
                DiagnosticSpec(message: SwiftLintCoreMacroError.noBooleanLiteral.message, line: 1, column: 76),
                DiagnosticSpec(message: SwiftLintCoreMacroError.noBooleanLiteral.message, line: 1, column: 88),
            ],
            macroSpecs: macros,
            failureHandler: FailureHandler.instance
        )
    }
}
