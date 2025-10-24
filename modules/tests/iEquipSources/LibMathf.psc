ScriptName LibMathf Hidden


; Returns the absolute value of f
Float Function Abs(Float f) Global Native

; Returns the arc-cosine of f - the angle in radians whose cosine is f
Float Function Acos(Float f) Global Native

; Returns the arc-tangent of f - the angle in radians whose tangent is f
Float Function Atan(Float f) Global Native

; Returns the angle in radians whose tan is y/x
Float Function Atan2(Float y, Float x) Global Native

; Compares two floating point values and returns true if they are similar
Bool Function Approximately(Float a, Float b) Global Native

; Returns the arc-sine of f - the angle in radians whose sine is f
Float Function Asin(Float f) Global Native

; Returns the smallest number (as Float) greater than or equal to f
Float Function Ceil(Float f) Global Native

; Returns the smallest number (as Int) greater than or equal to f
Int Function CeilToInt(Float f) Global Native

; Returns value clamped between min and max
Float Function Clamp(Float value, Float min, Float max) Global Native

; Returns value clamped between 0 and 1
Float Function Clamp01(Float value) Global Native

; Returns the closest power of two number
Int Function ClosestPowerOfTwo(Int value) Global Native

; Returns the cosine of angle f
Float Function Cos(Float f) Global Native

; Calculates the shortest difference between two angles in degrees
Float Function DeltaAngle(Float current, Float target) Global Native

; Returns e raised to the specified power
Float Function Exp(Float p) Global Native

; Returns the largest number (as Float) smaller than or equal to f
Float Function Floor(Float f) Global Native

; Returns the largest number (as Int) smaller than or equal to f
Int Function FloorToInt(Float f) Global Native

; Returns t if value is true or f if value is false
Float Function IfThen(Bool value, Float t, Float f) Global Native

; Returns true if value is between min and max
Bool Function InRange(Float value, Float min, Float max) Global Native

; Calculates the linear parameter t that produces the interpolant value within the range [a, b]
Float Function InverseLerp(Float a, Float b, Float value) Global Native

; Returns true if the number is power of two
Bool Function IsPowerOfTwo(Int n) Global Native

; Linearly interpolates between a and b by t
Float Function Lerp(Float a, Float b, Float t) Global Native

; Same as Lerp but makes sure the values interpolate correctly when they wrap around 360 degrees
Float Function LerpAngle(Float a, Float b, Float t) Global Native

; Linearly interpolates between a and b by t with no limit to t
Float Function LerpUnclamped(Float a, Float b, Float t) Global Native

; Returns the largest of two numbers
Float Function Max(Float x, Float y) Global Native

; Returns the smallest of two numbers
Float Function Min(Float x, Float y) Global Native

; Moves current value towards target
Float Function MoveTowards(Float current, Float target, Float maxDelta) Global Native

; Same as MoveTowards but makes sure the values interpolate correctly when they wrap around 360 degrees
Float Function MoveTowardsAngle(Float current, Float target, Float maxDelta) Global Native

; Returns the next power of two greater than or equal to n
Int Function NextPowerOfTwo(Int n) Global Native

; Returns number that will increment and decrement between 0 and length
Float Function PingPong(Float t, Float len) Global Native

; Returns the logarithm of a number
Float Function Log(Float f) Global Native

; Returns the base 10 logarithm of a number
Float Function Log10(Float f) Global Native

; Returns f raised to power p
Float Function Pow(Float f, Float p) Global Native

; Loops t so t is never larger than length and never smaller than 0
Float Function Repeat(Float t, Float len) Global Native

; Returns f (as Float) rounded to the nearest integer
Float Function Round(Float f) Global Native

; Returns f (as Int) rounded to the nearest integer
Int Function RoundToInt(Float f) Global Native

; Returns the sign of f
Float Function Sign(Float f) Global Native

; Returns the sine of angle f
Float Function Sin(Float f) Global Native

; Interpolates between min and max with smoothing at the limits
Float Function SmoothStep(Float current, Float target, Float t) Global Native

; Returns square root of f
Float Function Sqrt(Float f) Global Native

; Returns the tangent of angle f in radians
Float Function Tan(Float f) Global Native
