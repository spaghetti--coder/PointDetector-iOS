#import "/Users/sasaki/Kiwi/Classes/Core/Kiwi.h"

SPEC_BEGIN(MathSpec)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 21;
        NSUInteger b = 21;
        [[theValue(a + b) should] equal:theValue(42)];
    });
});

SPEC_END
