// Ported from chrono.js test/zh/hans/zh_hans_deadline.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "五日内我要通关游戏", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("五日内"), 'result.text expected "五日内" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (15), 'result.start.get("day") expected 15 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 15, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "5日之内我要通关游戏", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("5日之内"), 'result.text expected "5日之内" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (15), 'result.start.get("day") expected 15 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 15, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "十日内我要通关游戏", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("十日内"), 'result.text expected "十日内" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (20), 'result.start.get("day") expected 20 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 20, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "五分钟后", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("五分钟后"), 'result.text expected "五分钟后" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 19);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "一个钟之内", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("一个钟之内"), 'result.text expected "一个钟之内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 13, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "5分钟之后出门", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("5分钟之后"), 'result.text expected "5分钟之后" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 19);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我要5秒之后出门", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (2), 'result.index expected 2 but got ' + (result.index));
        ok((result.text) == ("5秒之后"), 'result.text expected "5秒之后" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 14, 5);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "半小时之内", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("半小时之内"), 'result.text expected "半小时之内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 44);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "两个礼拜内答复我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("两个礼拜内"), 'result.text expected "两个礼拜内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 24, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "1个月之内答复我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1个月之内"), 'result.text expected "1个月之内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "几个月之内答复我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("几个月之内"), 'result.text expected "几个月之内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 10, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "一年内答复我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("一年内"), 'result.text expected "一年内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2013, 7, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "1年之内答复我", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1年之内"), 'result.text expected "1年之内" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2013, 7, 10, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Untested units", function() {
    testSingleCase(chrono, "5秒钟后", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.text) == ("5秒钟后"), 'result.text expected "5秒钟后" but got ' + (result.text));
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 14, 5);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "2小时后", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.text) == ("2小时后"), 'result.text expected "2小时后" but got ' + (result.text));
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 14, 14);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "3天后", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.text) == ("3天后"), 'result.text expected "3天后" but got ' + (result.text));
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 13, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "2星期后", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.text) == ("2星期后"), 'result.text expected "2星期后" but got ' + (result.text));
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 24, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Untested suffix", function() {
    testSingleCase(chrono, "5分钟过后", new Date(2012, 7, 10, 12, 14), function(result) {
        ok((result.text) == ("5分钟过后"), 'result.text expected "5分钟过后" but got ' + (result.text));
        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 12, 19);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});
