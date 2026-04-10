// Angle Tests.swift

import Testing

@testable import Angle

@Suite
struct AngleTests {
    @Test
    func radianBasics() {
        let angle = Radian(Double.pi / 2)
        #expect(angle.value == Double.pi / 2)
    }

    @Test
    func degreeBasics() {
        let angle = Degree(90)
        #expect(angle.value == 90)
    }

    @Test
    func conversion() {
        let radians = Radian(.pi)
        let degrees = radians.degrees
        #expect(degrees.value == 180)
    }
}
