// Ported from chrono.js test/zh/hans/zh_hans_casual.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "我今天要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("今天"), 'result.text expected "今天" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我明日要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("明日"), 'result.text expected "明日" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (11), 'result.start.get("day") expected 11 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 11, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我明天要打游戏", new Date(2012, 7, 10, 1), function(result) {
        // Say.."Tomorrow" in the late night (1 AM)
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我后天凌晨要打游戏", new Date(2012, 7, 10, 0, 0), function(result) {
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 12, 0, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我大前天凌晨要打游戏", new Date(2012, 7, 10, 0, 0), function(result) {
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 7, 0, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我前天要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("前天"), 'result.text expected "前天" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (8), 'result.start.get("day") expected 8 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 8, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我昨日要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("昨日"), 'result.text expected "昨日" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (9), 'result.start.get("day") expected 9 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 9, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我昨天晚上要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("昨天晚上"), 'result.text expected "昨天晚上" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (9), 'result.start.get("day") expected 9 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 9, 22);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我今天早上要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("今天早上"), 'result.text expected "今天早上" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (6), 'result.start.get("hour") expected 6 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 6);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我下午要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("下午"), 'result.text expected "下午" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (15), 'result.start.get("hour") expected 15 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 15);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我今晚要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("今晚"), 'result.text expected "今晚" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 22);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Combined Expression", function() {
    testSingleCase(chrono, "我今天下午5点要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("今天下午5点"), 'result.text expected "今天下午5点" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (17), 'result.start.get("hour") expected 17 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 17);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Casual date range", function() {
    testSingleCase(chrono, "我今天 - 下周五要打游戏", new Date(2012, 7, 4, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("今天 - 下周五"), 'result.text expected "今天 - 下周五" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (4), 'result.start.get("day") expected 4 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (12), 'result.start.get("hour") expected 12 but got ' + (result.start.get("hour")));

        const resultStartDate = result.start.date();
        const expectStartDate = new Date(2012, 7, 4, 12);
        ok(Math.abs((resultStartDate.getTime()) - (expectStartDate.getTime())) < 100000, 'resultStartDate.getTime() vs expectStartDate.getTime(): ' + (resultStartDate.getTime()) + ' / ' + (expectStartDate.getTime()));

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (10), 'result.end.get("day") expected 10 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (12), 'result.end.get("hour") expected 12 but got ' + (result.end.get("hour")));

        const resultEndDate = result.end.date();
        const expectEndDate = new Date(2012, 7, 10, 12);
        ok(Math.abs((expectEndDate.getTime()) - (resultEndDate.getTime())) < 100000, 'expectEndDate.getTime() vs resultEndDate.getTime(): ' + (expectEndDate.getTime()) + ' / ' + (resultEndDate.getTime()));
    });

    testSingleCase(chrono, "我今日 - 下周五要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("今日 - 下周五"), 'result.text expected "今日 - 下周五" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (12), 'result.start.get("hour") expected 12 but got ' + (result.start.get("hour")));

        const resultStartDate = result.start.date();
        const expectStartDate = new Date(2012, 7, 10, 12);
        ok(Math.abs((expectStartDate.getTime()) - (resultStartDate.getTime())) < 100000, 'expectStartDate.getTime() vs resultStartDate.getTime(): ' + (expectStartDate.getTime()) + ' / ' + (resultStartDate.getTime()));

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (17), 'result.end.get("day") expected 17 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (12), 'result.end.get("hour") expected 12 but got ' + (result.end.get("hour")));

        const resultEndDate = result.end.date();
        const expectEndDate = new Date(2012, 7, 17, 12);
        ok(Math.abs((expectEndDate.getTime()) - (resultEndDate.getTime())) < 100000, 'expectEndDate.getTime() vs resultEndDate.getTime(): ' + (expectEndDate.getTime()) + ' / ' + (resultEndDate.getTime()));
    });
});

test("Test - Random text", function() {
    testSingleCase(chrono, "今日夜晚", new Date(2012, 1 - 1, 1, 12), function(result) {
        ok((result.text) == ("今日夜晚"), 'result.text expected "今日夜晚" but got ' + (result.text));
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (1), 'result.start.get("month") expected 1 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (1), 'result.start.get("day") expected 1 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));
        ok((result.start.get("meridiem")) == (1), 'result.start.get("meridiem") expected 1 but got ' + (result.start.get("meridiem")));
    });

    testSingleCase(chrono, "今晚8点正", new Date(2012, 1 - 1, 1, 12), function(result) {
        ok((result.text) == ("今晚8点正"), 'result.text expected "今晚8点正" but got ' + (result.text));
        ok((result.start.get("hour")) == (20), 'result.start.get("hour") expected 20 but got ' + (result.start.get("hour")));
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (1), 'result.start.get("month") expected 1 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (1), 'result.start.get("day") expected 1 but got ' + (result.start.get("day")));
        ok((result.start.get("meridiem")) == (1), 'result.start.get("meridiem") expected 1 but got ' + (result.start.get("meridiem")));
    });

    testSingleCase(chrono, "晚上8点", new Date(2012, 1 - 1, 1, 12), function(result) {
        ok((result.text) == ("晚上8点"), 'result.text expected "晚上8点" but got ' + (result.text));
        ok((result.start.get("hour")) == (20), 'result.start.get("hour") expected 20 but got ' + (result.start.get("hour")));
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (1), 'result.start.get("month") expected 1 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (1), 'result.start.get("day") expected 1 but got ' + (result.start.get("day")));
        ok((result.start.get("meridiem")) == (1), 'result.start.get("meridiem") expected 1 but got ' + (result.start.get("meridiem")));
    });

    testSingleCase(chrono, "星期四", new Date(), function(result) {
        ok((result.text) == ("星期四"), 'result.text expected "星期四" but got ' + (result.text));
        ok((result.start.get("weekday")) == (4), 'result.start.get("weekday") expected 4 but got ' + (result.start.get("weekday")));
    });
});
