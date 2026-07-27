// Ported from chrono.js test/zh/hant/zh_hant_deadline.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "五日內我地有d野做", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("五日內"), 'result.text expected "五日內" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (15), 'result.start.get("day") expected 15 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 15, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "5日之內我地有d野做", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("5日之內"), 'result.text expected "5日之內" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (15), 'result.start.get("day") expected 15 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 15, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "十日內我地有d野做", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("十日內"), 'result.text expected "十日內" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (20), 'result.start.get("day") expected 20 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 20, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "五分鐘後", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("五分鐘後"), 'result.text expected "五分鐘後" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 19);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "一個鐘之內", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("一個鐘之內"), 'result.text expected "一個鐘之內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 13, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "5分鐘之後我就收皮", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("5分鐘之後"), 'result.text expected "5分鐘之後" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 19);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "係5秒之後你就會收皮", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("5秒之後"), 'result.text expected "5秒之後" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 14, 5);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "半小時之內", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("半小時之內"), 'result.text expected "半小時之內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 44);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "兩個禮拜內答覆我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("兩個禮拜內"), 'result.text expected "兩個禮拜內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 24, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "1個月之內答覆我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1個月之內"), 'result.text expected "1個月之內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "幾個月之內答覆我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("幾個月之內"), 'result.text expected "幾個月之內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 10, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "一年內答覆我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("一年內"), 'result.text expected "一年內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2013, 7, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "1年之內答覆我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1年之內"), 'result.text expected "1年之內" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2013, 7, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});
