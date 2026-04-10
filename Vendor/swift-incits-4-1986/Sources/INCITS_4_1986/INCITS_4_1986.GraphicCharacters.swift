// INCITS_4_1986.GraphicCharacters.swift
// swift-incits-4-1986
//
// Section 4.3: Graphic Characters (INCITS 4-1986)

extension INCITS_4_1986 {
    /// Section 4.3: Graphic Characters (0x21-0x7E)
    ///
    /// Namespace for the 94 printable graphic characters defined in US-ASCII.
    ///
    /// ## Overview
    ///
    /// Graphic characters are the printable characters in the ASCII standard. Per INCITS 4-1986 Section 4.3,
    /// "Each graphic character has a visual representation normally handwritten, printed, or displayed."
    /// These are the characters that have visual glyphs, as opposed to control characters which affect
    /// formatting and device behavior.
    ///
    /// US-ASCII defines exactly 94 graphic characters in the range 0x21-0x7E (decimal 33-126).
    /// Note that SPACE (0x20) is handled separately due to its dual nature as both a graphic and
    /// control character.
    ///
    /// ## Character Ranges
    ///
    /// The graphic characters are organized into the following ranges:
    ///
    /// **Punctuation and Symbols** (0x21-0x2F, 0x3A-0x40, 0x5B-0x60, 0x7B-0x7E):
    /// - Common punctuation: `! " # $ % & ' ( ) * + , - . /`
    /// - Mathematical operators: `: ; < = > ?`
    /// - Brackets and delimiters: `[ \ ] ^ _ \` { | } ~`
    /// - Special symbols: `@ ~`
    ///
    /// **Digits** (0x30-0x39):
    /// - Decimal digits: `0 1 2 3 4 5 6 7 8 9`
    ///
    /// **Uppercase Letters** (0x41-0x5A):
    /// - Latin capital letters: `A B C D E F G H I J K L M N O P Q R S T U V W X Y Z`
    ///
    /// **Lowercase Letters** (0x61-0x7A):
    /// - Latin small letters: `a b c d e f g h i j k l m n o p q r s t u v w x y z`
    ///
    /// ## ASCII Table Reference
    ///
    /// ```
    /// 20-2F:   !"#$%&'()*+,-./
    /// 30-3F:  0123456789:;<=>?
    /// 40-4F:  @ABCDEFGHIJKLMNO
    /// 50-5F:  PQRSTUVWXYZ[\]^_
    /// 60-6F:  `abcdefghijklmno
    /// 70-7E:  pqrstuvwxyz{|}~
    /// ```
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Access individual characters
    /// let letterA = INCITS_4_1986.GraphicCharacters.A      // 0x41
    /// let digit0 = INCITS_4_1986.GraphicCharacters.`0`     // 0x30
    /// let exclaim = INCITS_4_1986.GraphicCharacters.exclamationPoint  // 0x21
    ///
    /// // Check if byte is a graphic character
    /// let byte: UInt8 = 0x41
    /// let isGraphic = (byte >= 0x21) && (byte <= 0x7E)  // true
    ///
    /// // Use in string operations
    /// let bytes: [UInt8] = [
    ///     INCITS_4_1986.GraphicCharacters.H,
    ///     INCITS_4_1986.GraphicCharacters.i
    /// ]
    /// let text = String.ascii(bytes)  // "Hi"
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CaseConversion.offset``
    /// - ``SPACE``
    public enum GraphicCharacters {}
}

extension INCITS_4_1986.GraphicCharacters {
    /// EXCLAMATION POINT (0x21) - !
    public static let exclamationPoint: UInt8 = 0x21

    /// QUOTATION MARK (0x22) - "
    public static let quotationMark: UInt8 = 0x22

    /// NUMBER SIGN (0x23) - #
    public static let numberSign: UInt8 = 0x23

    /// DOLLAR SIGN (0x24) - $
    public static let dollarSign: UInt8 = 0x24

    /// PERCENT SIGN (0x25) - %
    public static let percentSign: UInt8 = 0x25

    /// AMPERSAND (0x26) - &
    public static let ampersand: UInt8 = 0x26

    /// APOSTROPHE (0x27) - '
    public static let apostrophe: UInt8 = 0x27

    /// LEFT PARENTHESIS (0x28) - (
    public static let leftParenthesis: UInt8 = 0x28

    /// RIGHT PARENTHESIS (0x29) - )
    public static let rightParenthesis: UInt8 = 0x29

    /// ASTERISK (0x2A) - *
    public static let asterisk: UInt8 = 0x2A

    /// PLUS SIGN (0x2B) - +
    public static let plusSign: UInt8 = 0x2B

    /// COMMA (0x2C) - ,
    public static let comma: UInt8 = 0x2C

    /// HYPHEN, MINUS SIGN (0x2D) - -
    public static let hyphen: UInt8 = 0x2D

    /// PERIOD, DECIMAL POINT (0x2E) - .
    public static let period: UInt8 = 0x2E

    /// SLANT (SOLIDUS) (0x2F) - /
    public static let slant: UInt8 = 0x2F
    public static let solidus: UInt8 = slant
}

extension INCITS_4_1986.GraphicCharacters {
    /// DIGIT ZERO (0x30) - 0
    public static let `0`: UInt8 = 0x30

    /// DIGIT ONE (0x31) - 1
    public static let `1`: UInt8 = 0x31

    /// DIGIT TWO (0x32) - 2
    public static let `2`: UInt8 = 0x32

    /// DIGIT THREE (0x33) - 3
    public static let `3`: UInt8 = 0x33

    /// DIGIT FOUR (0x34) - 4
    public static let `4`: UInt8 = 0x34

    /// DIGIT FIVE (0x35) - 5
    public static let `5`: UInt8 = 0x35

    /// DIGIT SIX (0x36) - 6
    public static let `6`: UInt8 = 0x36

    /// DIGIT SEVEN (0x37) - 7
    public static let `7`: UInt8 = 0x37

    /// DIGIT EIGHT (0x38) - 8
    public static let `8`: UInt8 = 0x38

    /// DIGIT NINE (0x39) - 9
    public static let `9`: UInt8 = 0x39
}

extension INCITS_4_1986.GraphicCharacters {
    /// COLON (0x3A) - :
    public static let colon: UInt8 = 0x3A

    /// SEMICOLON (0x3B) - ;
    public static let semicolon: UInt8 = 0x3B

    /// LESS-THAN SIGN (0x3C) - <
    public static let lessThanSign: UInt8 = 0x3C

    /// EQUALS SIGN (0x3D) - =
    public static let equalsSign: UInt8 = 0x3D

    /// GREATER-THAN SIGN (0x3E) - >
    public static let greaterThanSign: UInt8 = 0x3E

    /// QUESTION MARK (0x3F) - ?
    public static let questionMark: UInt8 = 0x3F

    /// COMMERCIAL AT (0x40) - @
    public static let commercialAt: UInt8 = 0x40
}

extension INCITS_4_1986.GraphicCharacters {
    /// CAPITAL LETTER A (0x41)
    public static let A: UInt8 = 0x41

    /// CAPITAL LETTER B (0x42)
    public static let B: UInt8 = 0x42

    /// CAPITAL LETTER C (0x43)
    public static let C: UInt8 = 0x43

    /// CAPITAL LETTER D (0x44)
    public static let D: UInt8 = 0x44

    /// CAPITAL LETTER E (0x45)
    public static let E: UInt8 = 0x45

    /// CAPITAL LETTER F (0x46)
    public static let F: UInt8 = 0x46

    /// CAPITAL LETTER G (0x47)
    public static let G: UInt8 = 0x47

    /// CAPITAL LETTER H (0x48)
    public static let H: UInt8 = 0x48

    /// CAPITAL LETTER I (0x49)
    public static let I: UInt8 = 0x49

    /// CAPITAL LETTER J (0x4A)
    public static let J: UInt8 = 0x4A

    /// CAPITAL LETTER K (0x4B)
    public static let K: UInt8 = 0x4B

    /// CAPITAL LETTER L (0x4C)
    public static let L: UInt8 = 0x4C

    /// CAPITAL LETTER M (0x4D)
    public static let M: UInt8 = 0x4D

    /// CAPITAL LETTER N (0x4E)
    public static let N: UInt8 = 0x4E

    /// CAPITAL LETTER O (0x4F)
    public static let O: UInt8 = 0x4F

    /// CAPITAL LETTER P (0x50)
    public static let P: UInt8 = 0x50

    /// CAPITAL LETTER Q (0x51)
    public static let Q: UInt8 = 0x51

    /// CAPITAL LETTER R (0x52)
    public static let R: UInt8 = 0x52

    /// CAPITAL LETTER S (0x53)
    public static let S: UInt8 = 0x53

    /// CAPITAL LETTER T (0x54)
    public static let T: UInt8 = 0x54

    /// CAPITAL LETTER U (0x55)
    public static let U: UInt8 = 0x55

    /// CAPITAL LETTER V (0x56)
    public static let V: UInt8 = 0x56

    /// CAPITAL LETTER W (0x57)
    public static let W: UInt8 = 0x57

    /// CAPITAL LETTER X (0x58)
    public static let X: UInt8 = 0x58

    /// CAPITAL LETTER Y (0x59)
    public static let Y: UInt8 = 0x59

    /// CAPITAL LETTER Z (0x5A)
    public static let Z: UInt8 = 0x5A
}

extension INCITS_4_1986.GraphicCharacters {
    /// LEFT BRACKET (0x5B) - [
    public static let leftBracket: UInt8 = 0x5B

    /// REVERSE SLANT (0x5C) - \
    public static let reverseSlant: UInt8 = 0x5C
    public static let reverseSolidus: UInt8 = reverseSlant

    /// RIGHT BRACKET (0x5D) - ]
    public static let rightBracket: UInt8 = 0x5D

    /// CIRCUMFLEX ACCENT (0x5E) - ^
    public static let circumflexAccent: UInt8 = 0x5E

    /// UNDERLINE (LOW LINE) (0x5F) - _
    public static let underline: UInt8 = 0x5F

    /// LEFT SINGLE QUOTATION MARK, GRAVE ACCENT (0x60) - `
    public static let leftSingleQuotationMark: UInt8 = 0x60
}

extension INCITS_4_1986.GraphicCharacters {
    /// SMALL LETTER A (0x61)
    public static let a: UInt8 = 0x61

    /// SMALL LETTER B (0x62)
    public static let b: UInt8 = 0x62

    /// SMALL LETTER C (0x63)
    public static let c: UInt8 = 0x63

    /// SMALL LETTER D (0x64)
    public static let d: UInt8 = 0x64

    /// SMALL LETTER E (0x65)
    public static let e: UInt8 = 0x65

    /// SMALL LETTER F (0x66)
    public static let f: UInt8 = 0x66

    /// SMALL LETTER G (0x67)
    public static let g: UInt8 = 0x67

    /// SMALL LETTER H (0x68)
    public static let h: UInt8 = 0x68

    /// SMALL LETTER I (0x69)
    public static let i: UInt8 = 0x69

    /// SMALL LETTER J (0x6A)
    public static let j: UInt8 = 0x6A

    /// SMALL LETTER K (0x6B)
    public static let k: UInt8 = 0x6B

    /// SMALL LETTER L (0x6C)
    public static let l: UInt8 = 0x6C

    /// SMALL LETTER M (0x6D)
    public static let m: UInt8 = 0x6D

    /// SMALL LETTER N (0x6E)
    public static let n: UInt8 = 0x6E

    /// SMALL LETTER O (0x6F)
    public static let o: UInt8 = 0x6F

    /// SMALL LETTER P (0x70)
    public static let p: UInt8 = 0x70

    /// SMALL LETTER Q (0x71)
    public static let q: UInt8 = 0x71

    /// SMALL LETTER R (0x72)
    public static let r: UInt8 = 0x72

    /// SMALL LETTER S (0x73)
    public static let s: UInt8 = 0x73

    /// SMALL LETTER T (0x74)
    public static let t: UInt8 = 0x74

    /// SMALL LETTER U (0x75)
    public static let u: UInt8 = 0x75

    /// SMALL LETTER V (0x76)
    public static let v: UInt8 = 0x76

    /// SMALL LETTER W (0x77)
    public static let w: UInt8 = 0x77

    /// SMALL LETTER X (0x78)
    public static let x: UInt8 = 0x78

    /// SMALL LETTER Y (0x79)
    public static let y: UInt8 = 0x79

    /// SMALL LETTER Z (0x7A)
    public static let z: UInt8 = 0x7A
}

extension INCITS_4_1986.GraphicCharacters {
    /// LEFT BRACE (0x7B) - {
    public static let leftBrace: UInt8 = 0x7B

    /// VERTICAL LINE (0x7C) - |
    public static let verticalLine: UInt8 = 0x7C

    /// RIGHT BRACE (0x7D) - }
    public static let rightBrace: UInt8 = 0x7D

    /// TILDE (OVERLINE) (0x7E) - ~
    public static let tilde: UInt8 = 0x7E
}
