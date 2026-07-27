// Ported from chrono.js test/zh/hant/zh_hant_time_exp.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "雞上午6點13分全部都係雞", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("上午6點13分"), 'result.text expected "上午6點13分" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("hour")) == (6), 'result.start.get("hour") expected 6 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (13), 'result.start.get("minute") expected 13 but got ' + (result.start.get("minute")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 6, 13);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "雞後天凌晨全部都係雞", new Date(2012, 7, 10, 0, 0), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("後天凌晨"), 'result.text expected "後天凌晨" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 12, 0, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "雞大前天凌晨全部都係雞", new Date(2012, 7, 10, 0, 0), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("大前天凌晨"), 'result.text expected "大前天凌晨" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 7, 0, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我明天上午8點要打遊戲", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("明天上午8點"), 'result.text expected "明天上午8點" but got ' + (result.text));
        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (11), 'result.start.get("day") expected 11 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 11, 8);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Range Expression", function() {
    testSingleCase(chrono, "雞由今朝八點十分至下午11點32分全部都係雞", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("由今朝八點十分至下午11點32分"), 'result.text expected "由今朝八點十分至下午11點32分" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (10), 'result.start.get("minute") expected 10 but got ' + (result.start.get("minute")));

        ok((result.start.isCertain("day")) == (true), 'result.start.isCertain("day") expected true but got ' + (result.start.isCertain("day")));
        ok((result.start.isCertain("month")) == (true), 'result.start.isCertain("month") expected true but got ' + (result.start.isCertain("month")));
        ok((result.start.isCertain("year")) == (true), 'result.start.isCertain("year") expected true but got ' + (result.start.isCertain("year")));
        ok((result.start.isCertain("hour")) == (true), 'result.start.isCertain("hour") expected true but got ' + (result.start.isCertain("hour")));
        ok((result.start.isCertain("minute")) == (true), 'result.start.isCertain("minute") expected true but got ' + (result.start.isCertain("minute")));
        ok((result.start.isCertain("second")) == (false), 'result.start.isCertain("second") expected false but got ' + (result.start.isCertain("second")));
        ok((result.start.isCertain("millisecond")) == (false), 'result.start.isCertain("millisecond") expected false but got ' + (result.start.isCertain("millisecond")));

        var resultDate = result.start.date();
        var expectDate = new Date(2012, 7, 10, 8, 10);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("hour")) == (23), 'result.end.get("hour") expected 23 but got ' + (result.end.get("hour")));
        ok((result.end.get("minute")) == (32), 'result.end.get("minute") expected 32 but got ' + (result.end.get("minute")));

        ok((result.end.isCertain("day")) == (false), 'result.end.isCertain("day") expected false but got ' + (result.end.isCertain("day")));
        ok((result.end.isCertain("month")) == (false), 'result.end.isCertain("month") expected false but got ' + (result.end.isCertain("month")));
        ok((result.end.isCertain("year")) == (false), 'result.end.isCertain("year") expected false but got ' + (result.end.isCertain("year")));
        ok((result.end.isCertain("hour")) == (true), 'result.end.isCertain("hour") expected true but got ' + (result.end.isCertain("hour")));
        ok((result.end.isCertain("minute")) == (true), 'result.end.isCertain("minute") expected true but got ' + (result.end.isCertain("minute")));
        ok((result.end.isCertain("second")) == (false), 'result.end.isCertain("second") expected false but got ' + (result.end.isCertain("second")));
        ok((result.end.isCertain("millisecond")) == (false), 'result.end.isCertain("millisecond") expected false but got ' + (result.end.isCertain("millisecond")));

        var resultDate = result.end.date();
        var expectDate = new Date(2012, 7, 10, 23, 32);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "6點30pm-11點pm", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("6點30pm-11點pm"), 'result.text expected "6點30pm-11點pm" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("hour")) == (18), 'result.start.get("hour") expected 18 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (30), 'result.start.get("minute") expected 30 but got ' + (result.start.get("minute")));
        ok((result.start.get("meridiem")) == (1), 'result.start.get("meridiem") expected 1 but got ' + (result.start.get("meridiem")));

        var resultDate = result.start.date();
        var expectDate = new Date(2012, 7, 10, 18, 30);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("hour")) == (23), 'result.end.get("hour") expected 23 but got ' + (result.end.get("hour")));
        ok((result.end.get("minute")) == (0), 'result.end.get("minute") expected 0 but got ' + (result.end.get("minute")));
        ok((result.end.get("meridiem")) == (1), 'result.end.get("meridiem") expected 1 but got ' + (result.end.get("meridiem")));

        var resultDate = result.end.date();
        var expectDate = new Date(2012, 7, 10, 23, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Date + Time Expression", function() {
    testSingleCase(
        chrono,
        "雞二零一八年十一月廿六日下午三時半五十九秒全部都係雞",
        new Date(2012, 7, 10),
        function(result) {
            ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
            ok((result.text) == ("二零一八年十一月廿六日下午三時半五十九秒"), 'result.text expected "二零一八年十一月廿六日下午三時半五十九秒" but got ' + (result.text));

            ok((result.start.get("year")) == (2018), 'result.start.get("year") expected 2018 but got ' + (result.start.get("year")));
            ok((result.start.get("month")) == (11), 'result.start.get("month") expected 11 but got ' + (result.start.get("month")));
            ok((result.start.get("day")) == (26), 'result.start.get("day") expected 26 but got ' + (result.start.get("day")));
            ok((result.start.get("hour")) == (15), 'result.start.get("hour") expected 15 but got ' + (result.start.get("hour")));
            ok((result.start.get("minute")) == (30), 'result.start.get("minute") expected 30 but got ' + (result.start.get("minute")));
            ok((result.start.get("second")) == (59), 'result.start.get("second") expected 59 but got ' + (result.start.get("second")));
            ok((result.start.get("millisecond")) == (0), 'result.start.get("millisecond") expected 0 but got ' + (result.start.get("millisecond")));
            ok((result.start.isCertain("millisecond")) == (false), 'result.start.isCertain("millisecond") expected false but got ' + (result.start.isCertain("millisecond")));

            const resultDate = result.start.date();
            const expectDate = new Date(2018, 11 - 1, 26, 15, 30, 59);
            ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
        }
    );
});

test("Test - Time Expression's Meridiem imply", function() {
    testSingleCase(chrono, "1點pm到3點", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1點pm到3點"), 'result.text expected "1點pm到3點" but got ' + (result.text));

        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (13), 'result.start.get("hour") expected 13 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (0), 'result.start.get("minute") expected 0 but got ' + (result.start.get("minute")));
        ok((result.start.get("second")) == (0), 'result.start.get("second") expected 0 but got ' + (result.start.get("second")));
        ok((result.start.get("millisecond")) == (0), 'result.start.get("millisecond") expected 0 but got ' + (result.start.get("millisecond")));
        ok((result.start.get("meridiem")) == (1), 'result.start.get("meridiem") expected 1 but got ' + (result.start.get("meridiem")));
        ok((result.start.isCertain("meridiem")) == (true), 'result.start.isCertain("meridiem") expected true but got ' + (result.start.isCertain("meridiem")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (3), 'result.end.get("hour") expected 3 but got ' + (result.end.get("hour")));
        ok((result.end.get("minute")) == (0), 'result.end.get("minute") expected 0 but got ' + (result.end.get("minute")));
        ok((result.end.get("second")) == (0), 'result.end.get("second") expected 0 but got ' + (result.end.get("second")));
        ok((result.end.get("millisecond")) == (0), 'result.end.get("millisecond") expected 0 but got ' + (result.end.get("millisecond")));
        ok((result.end.isCertain("meridiem")) == (false), 'result.end.isCertain("meridiem") expected false but got ' + (result.end.isCertain("meridiem")));
    });
});

test("Test - Cantonese Combined Expressions", function() {
    testSingleCase(chrono, "大後日下晝5點", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("大後日下晝5點"), 'result.text expected "大後日下晝5點" but got ' + (result.text));

        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (13), 'result.start.get("day") expected 13 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (17), 'result.start.get("hour") expected 17 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (0), 'result.start.get("minute") expected 0 but got ' + (result.start.get("minute")));
    });

    testSingleCase(chrono, "聽晚10點到聽晚11點", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("聽晚10點到聽晚11點"), 'result.text expected "聽晚10點到聽晚11點" but got ' + (result.text));

        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (11), 'result.start.get("day") expected 11 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (0), 'result.start.get("minute") expected 0 but got ' + (result.start.get("minute")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (23), 'result.end.get("hour") expected 23 but got ' + (result.end.get("hour")));
        ok((result.end.get("minute")) == (0), 'result.end.get("minute") expected 0 but got ' + (result.end.get("minute")));
    });
});

test("Test - Random date + time expression", function() {
    testSingleCase(chrono, "2014年, 3月5日晏晝 6 點至 7 點", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("2014年, 3月5日晏晝 6 點至 7 點"), 'result.text expected "2014年, 3月5日晏晝 6 點至 7 點" but got ' + (result.text));
    });

    testSingleCase(chrono, "下星期六凌晨1點30分廿九秒", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("下星期六凌晨1點30分廿九秒"), 'result.text expected "下星期六凌晨1點30分廿九秒" but got ' + (result.text));
    });

    testSingleCase(chrono, "尋日朝早六點正", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("尋日朝早六點正"), 'result.text expected "尋日朝早六點正" but got ' + (result.text));
    });

    testSingleCase(chrono, "六月四日3:00am", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("六月四日3:00am"), 'result.text expected "六月四日3:00am" but got ' + (result.text));
    });

    testSingleCase(chrono, "上個禮拜五16時", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("上個禮拜五16時"), 'result.text expected "上個禮拜五16時" but got ' + (result.text));
    });

    testSingleCase(chrono, "3月17日 20點15", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("3月17日 20點15"), 'result.text expected "3月17日 20點15" but got ' + (result.text));
    });

    testSingleCase(chrono, "10點", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("10點"), 'result.text expected "10點" but got ' + (result.text));
    });

    testSingleCase(chrono, "中午12點", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("hour")) == (12), 'result.start.get("hour") expected 12 but got ' + (result.start.get("hour")));
    });
});
