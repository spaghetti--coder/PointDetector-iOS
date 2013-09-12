
#import "GHUnitIOS/GHUnit.h"

@interface pointdetectorTests : GHTestCase

@end

@implementation pointdetectorTests

// デフォルトはNOですが、UIのテストやメインスレッドに依存するテストを行う場合はYESにします。
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// 本クラスが実行される前に呼び出されます。
- (void)setUpClass {
}

// 本クラスが終了された後に呼び出されます。
- (void)tearDownClass {
}

// 本クラスの各メソッドが実行される前に呼び出されます。
- (void)setUp {
}

// 本クラスの各メソッドが終了された後に呼び出されます。
- (void)tearDown {
}

// 「test～」というメソッド名にすることでテスト対象一覧に出力されます。
- (void)testDivideRoundUp
{
    NSInteger num = 100;
    GHAssertEquals(num, 34, @"test");
}

@end