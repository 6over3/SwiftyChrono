// Ported from chrono.js test/zh/hant/zh_hant_weekday.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "星期四", new Date(2016, 9 - 1, 2), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("星期四"), 'result.text expected "星期四" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (1), 'result.start.get("day") expected 1 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (4), 'result.start.get("weekday") expected 4 but got ' + (result.start.get("weekday")));

        ok((result.start.isCertain("day")) == (false), 'result.start.isCertain("day") expected false but got ' + (result.start.isCertain("day")));
        ok((result.start.isCertain("month")) == (false), 'result.start.isCertain("month") expected false but got ' + (result.start.isCertain("month")));
        ok((result.start.isCertain("year")) == (false), 'result.start.isCertain("year") expected false but got ' + (result.start.isCertain("year")));
        ok((result.start.isCertain("weekday")) == (true), 'result.start.isCertain("weekday") expected true but got ' + (result.start.isCertain("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 9 - 1, 1, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我週一要打遊戲", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("週一"), 'result.text expected "週一" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (13), 'result.start.get("day") expected 13 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (1), 'result.start.get("weekday") expected 1 but got ' + (result.start.get("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 13, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(
        chrono,
        "禮拜四 (forward dates only)",
        new Date(2016, 9 - 1, 2),
        { forwardDate: true },
        function(result) {
            ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
            ok((result.text) == ("禮拜四"), 'result.text expected "禮拜四" but got ' + (result.text));

            ok(!!(result.start), 'result.start is null');
            ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
            ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
            ok((result.start.get("day")) == (8), 'result.start.get("day") expected 8 but got ' + (result.start.get("day")));
            ok((result.start.get("weekday")) == (4), 'result.start.get("weekday") expected 4 but got ' + (result.start.get("weekday")));

            ok((result.start.isCertain("day")) == (false), 'result.start.isCertain("day") expected false but got ' + (result.start.isCertain("day")));
            ok((result.start.isCertain("month")) == (false), 'result.start.isCertain("month") expected false but got ' + (result.start.isCertain("month")));
            ok((result.start.isCertain("year")) == (false), 'result.start.isCertain("year") expected false but got ' + (result.start.isCertain("year")));
            ok((result.start.isCertain("weekday")) == (true), 'result.start.isCertain("weekday") expected true but got ' + (result.start.isCertain("weekday")));

            const resultDate = result.start.date();
            const expectDate = new Date(2016, 9 - 1, 8, 12);
            ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
        }
    );

    testSingleCase(chrono, "禮拜日", new Date(2016, 9 - 1, 2), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("禮拜日"), 'result.text expected "禮拜日" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (4), 'result.start.get("day") expected 4 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (0), 'result.start.get("weekday") expected 0 but got ' + (result.start.get("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 9 - 1, 4, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "雞上個禮拜三全部都係雞", new Date(2016, 9 - 1, 2), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("上個禮拜三"), 'result.text expected "上個禮拜三" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (24), 'result.start.get("day") expected 24 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (3), 'result.start.get("weekday") expected 3 but got ' + (result.start.get("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 8 - 1, 24, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "雞下星期天全部都係雞", new Date(2016, 9 - 1, 2), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("下星期天"), 'result.text expected "下星期天" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (4), 'result.start.get("day") expected 4 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (0), 'result.start.get("weekday") expected 0 but got ' + (result.start.get("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 9 - 1, 4, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - 'this' week", function() {
    testSingleCase(chrono, "我這個星期一要打遊戲", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("這個星期一"), 'result.text expected "這個星期一" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (6), 'result.start.get("day") expected 6 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (1), 'result.start.get("weekday") expected 1 but got ' + (result.start.get("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 6, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "星期一", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (13), 'result.start.get("day") expected 13 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (1), 'result.start.get("weekday") expected 1 but got ' + (result.start.get("weekday")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 13, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - forward dates only option", function() {
    testSingleCase(chrono, "星期六-星期一", new Date(2016, 9 - 1, 2), { forwardDate: true }, function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("星期六-星期一"), 'result.text expected "星期六-星期一" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));
        ok((result.start.get("weekday")) == (6), 'result.start.get("weekday") expected 6 but got ' + (result.start.get("weekday")));

        ok((result.start.isCertain("day")) == (false), 'result.start.isCertain("day") expected false but got ' + (result.start.isCertain("day")));
        ok((result.start.isCertain("month")) == (false), 'result.start.isCertain("month") expected false but got ' + (result.start.isCertain("month")));
        ok((result.start.isCertain("year")) == (false), 'result.start.isCertain("year") expected false but got ' + (result.start.isCertain("year")));
        ok((result.start.isCertain("weekday")) == (true), 'result.start.isCertain("weekday") expected true but got ' + (result.start.isCertain("weekday")));

        var resultDate = result.start.date();
        var expectDate = new Date(2016, 9 - 1, 3, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("year")) == (2016), 'result.end.get("year") expected 2016 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (9), 'result.end.get("month") expected 9 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (5), 'result.end.get("day") expected 5 but got ' + (result.end.get("day")));
        ok((result.end.get("weekday")) == (1), 'result.end.get("weekday") expected 1 but got ' + (result.end.get("weekday")));

        ok((result.end.isCertain("day")) == (false), 'result.end.isCertain("day") expected false but got ' + (result.end.isCertain("day")));
        ok((result.end.isCertain("month")) == (false), 'result.end.isCertain("month") expected false but got ' + (result.end.isCertain("month")));
        ok((result.end.isCertain("year")) == (false), 'result.end.isCertain("year") expected false but got ' + (result.end.isCertain("year")));
        ok((result.end.isCertain("weekday")) == (true), 'result.end.isCertain("weekday") expected true but got ' + (result.end.isCertain("weekday")));

        var resultDate = result.end.date();
        var expectDate = new Date(2016, 9 - 1, 5, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});
