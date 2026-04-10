import Formatting
import Testing

@Suite
struct `BinaryInteger+Formatting Tests` {

    // MARK: - Binary Formatting

    @Test
    func `Binary formatting`() {
        #expect(5.formatted(.binary) == "0b101")
        #expect(0.formatted(.binary) == "0b0")
        #expect(42.formatted(.binary) == "0b101010")
        #expect(UInt8(255).formatted(.binary) == "0b11111111")
    }

    @Test
    func `Binary with sign strategy`() {
        #expect(5.formatted(.binary.sign(strategy: .always)) == "+0b101")
        #expect((-5).formatted(.binary.sign(strategy: .always)) == "-0b101")
    }

    // MARK: - Octal Formatting

    @Test
    func `Octal formatting`() {
        #expect(8.formatted(.octal) == "0o10")
        #expect(0.formatted(.octal) == "0o0")
        #expect(64.formatted(.octal) == "0o100")
        #expect(UInt8(255).formatted(.octal) == "0o377")
    }

    @Test
    func `Octal with sign strategy`() {
        #expect(8.formatted(.octal.sign(strategy: .always)) == "+0o10")
        #expect((-8).formatted(.octal.sign(strategy: .always)) == "-0o10")
    }

    // MARK: - Decimal Formatting

    @Test
    func `Decimal formatting`() {
        #expect(42.formatted(.decimal) == "42")
        #expect(0.formatted(.decimal) == "0")
        #expect((-42).formatted(.decimal) == "-42")
    }

    @Test
    func `Decimal with sign strategy`() {
        #expect(42.formatted(.decimal.sign(strategy: .always)) == "+42")
        #expect((-42).formatted(.decimal.sign(strategy: .always)) == "-42")
        #expect(0.formatted(.decimal.sign(strategy: .always)) == "+0")
    }

    @Test
    func `Decimal with zero padding`() {
        #expect(5.formatted(.decimal.zeroPadded(width: 3)) == "005")
        #expect(42.formatted(.decimal.zeroPadded(width: 4)) == "0042")
        #expect(123.formatted(.decimal.zeroPadded(width: 2)) == "123")  // No truncation
    }
}
