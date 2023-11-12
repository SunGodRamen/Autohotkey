; Assert that a condition is true
AssertTrue(flag, user_story) {
    if (flag != true) {
        Fail("Assertion failed (expected true): " . user_story)
    } else {
        Pass(user_story)
    }
    return
}

; Assert that a condition is false
AssertFalse(flag, user_story) {
    if (flag != false){
        Fail("Assertion failed (expected false): " . user_story)
    } else {
        Pass(user_story)
    }
    return
}

; Assert that two values are equal
AssertEqual(actual, expected, user_story) {
    if (actual != expected) {
        Fail("Assertion failed (expected " . expected . ", got " . actual . "): " . user_story)
    } else {
        Pass(user_story)
    }
    return
}

; Fail the test and log the message
Fail(message) {
    OutputDebug, % message
    return
}

Pass(user_story) {
    OutputDebug, Pass: %user_story%
    return
}