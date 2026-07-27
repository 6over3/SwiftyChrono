// Ported from chrono.js test/zh/hans/zh_hans_ago.test.ts


test("Test - Simplified Chinese Ago Expression", function() {
    testSingleCase(chrono, "1小时前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1小时前"), 'result.text expected "1小时前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 11, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "1小时之前出门了", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1小时之前"), 'result.text expected "1小时之前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 11, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "五分钟前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("五分钟前"), 'result.text expected "五分钟前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 9);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "3天前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("3天前"), 'result.text expected "3天前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 7, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "2星期前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("2星期前"), 'result.text expected "2星期前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 6, 27, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "半小时前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("半小时前"), 'result.text expected "半小时前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 11, 44);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});
