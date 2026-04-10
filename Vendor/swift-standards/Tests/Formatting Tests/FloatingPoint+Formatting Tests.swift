import Formatting
import Testing

@Suite
struct `FloatingPoint+Formatting Tests` {

    // MARK: - Number Formatting

    @Test
    func `Number format strips trailing zero`() {
        #expect(10.0.formatted(.number) == "10")
        #expect(3.14.formatted(.number) == "3.14")
        #expect(0.0.formatted(.number) == "0")
    }

    // MARK: - Percent Formatting

    @Test
    func `Double formatted as percent`() {
        #expect(0.75.formatted(.percent) == "75%")
        #expect(0.5.formatted(.percent) == "50%")
        #expect(1.0.formatted(.percent) == "100%")
        #expect(0.0.formatted(.percent) == "0%")
    }

    @Test
    func `Float formatted as percent`() {
        #expect(Float(0.75).formatted(.percent) == "75%")
        #expect(Float(0.5).formatted(.percent) == "50%")
        #expect(Float(1.0).formatted(.percent) == "100%")
    }

    @Test
    func `Percent with rounding`() {
        #expect(0.755.formatted(.percent.rounded()) == "76%")
        #expect(0.745.formatted(.percent.rounded()) == "75%")
        #expect(0.5.formatted(.percent.rounded()) == "50%")
    }

    @Test
    func `Percent with precision`() {
        #expect(0.755.formatted(.percent.precision(2)) == "75.5%")
        #expect(0.1234.formatted(.percent.precision(1)) == "12.3%")
        #expect(0.5.formatted(.percent.precision(2)) == "50%")
    }

    @Test
    func `Percent with rounding and precision`() {
        #expect(0.755.formatted(.percent.rounded().precision(2)) == "76%")
        #expect(0.745.formatted(.percent.rounded().precision(2)) == "75%")
    }

    // MARK: - Edge Cases

    @Test
    func `Very small values`() {
        #expect(0.0001.formatted(.percent) == "0.01%")
        #expect(0.00001.formatted(.percent) == "0.001%")
    }

    @Test
    func `Large values`() {
        #expect(10.0.formatted(.percent) == "1000%")
        #expect(100.0.formatted(.percent) == "10000%")
    }

    @Test
    func `Zero values`() {
        #expect(0.0.formatted(.percent) == "0%")
        #expect(0.0.formatted(.percent.rounded()) == "0%")
        #expect(0.0.formatted(.percent.precision(2)) == "0%")
    }

    @Test
    func `Negative values`() {
        #expect((-0.5).formatted(.percent) == "-50%")
        #expect((-0.755).formatted(.percent.precision(2)) == "-75.5%")
        #expect((-0.25).formatted(.percent.rounded()) == "-25%")
    }

    // MARK: - Float Specific

    @Test
    func `Float with precision`() {
        #expect(Float(0.755).formatted(.percent.precision(2)) == "75.5%")
    }

    @Test
    func `Float with rounding`() {
        #expect(Float(0.755).formatted(.percent.rounded()) == "76%")
    }
}
