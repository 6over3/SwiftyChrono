// Ported from chrono.js test/zh/hant/zh_hant_ago.test.ts


test("Test - Traditional Chinese Ago Expression", function() {
    testSingleCase(chrono, "1小時前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1小時前"), 'result.text expected "1小時前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 11, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "1小時之前出門了", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1小時之前"), 'result.text expected "1小時之前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 11, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "五分鐘前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("五分鐘前"), 'result.text expected "五分鐘前" but got ' + (result.text));

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

    testSingleCase(chrono, "2禮拜前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("2禮拜前"), 'result.text expected "2禮拜前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 6, 27, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "半小時前", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("半小時前"), 'result.text expected "半小時前" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 11, 44);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});
