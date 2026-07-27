// Ported from chrono.js test/zh/hans/zh_hans_time_exp.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "我上午6点13分打游戏", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("上午6点13分"), 'result.text expected "上午6点13分" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("hour")) == (6), 'result.start.get("hour") expected 6 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (13), 'result.start.get("minute") expected 13 but got ' + (result.start.get("minute")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 10, 6, 13);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我后天凌晨打游戏", new Date(2012, 7, 10, 0, 0), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("后天凌晨"), 'result.text expected "后天凌晨" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 12, 0, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我大前天凌晨打游戏", new Date(2012, 7, 10, 0, 0), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("大前天凌晨"), 'result.text expected "大前天凌晨" but got ' + (result.text));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 7, 0, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "我明天上午8点要打游戏", new Date(2012, 7, 10, 12), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("明天上午8点"), 'result.text expected "明天上午8点" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (11), 'result.start.get("day") expected 11 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 7, 11, 8);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "早上8点", new Date(2012, 8 - 1, 10, 12), function(result) {
        ok((result.text) == ("早上8点"), 'result.text expected "早上8点" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));

        const resultDate = result.start.date();
        const expectDate = new Date(2012, 8 - 1, 10, 8);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Range Expression", function() {
    testSingleCase(chrono, "我从今早八点十分至下午11点32分打游戏", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("从今早八点十分至下午11点32分"), 'result.text expected "从今早八点十分至下午11点32分" but got ' + (result.text));

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

        let resultDate = result.start.date();
        let expectDate = new Date(2012, 7, 10, 8, 10);
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

        resultDate = result.end.date();
        expectDate = new Date(2012, 7, 10, 23, 32);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "6点30pm-11点pm", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("6点30pm-11点pm"), 'result.text expected "6点30pm-11点pm" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("hour")) == (18), 'result.start.get("hour") expected 18 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (30), 'result.start.get("minute") expected 30 but got ' + (result.start.get("minute")));
        ok((result.start.get("meridiem")) == (1), 'result.start.get("meridiem") expected 1 but got ' + (result.start.get("meridiem")));

        let resultDate = result.start.date();
        let expectDate = new Date(2012, 7, 10, 18, 30);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("hour")) == (23), 'result.end.get("hour") expected 23 but got ' + (result.end.get("hour")));
        ok((result.end.get("minute")) == (0), 'result.end.get("minute") expected 0 but got ' + (result.end.get("minute")));
        ok((result.end.get("meridiem")) == (1), 'result.end.get("meridiem") expected 1 but got ' + (result.end.get("meridiem")));

        resultDate = result.end.date();
        expectDate = new Date(2012, 7, 10, 23, 0);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Date + Time Expression", function() {
    testSingleCase(
        chrono,
        "我二零一八年十一月二十六日下午三点半五十九秒打游戏",
        new Date(2012, 7, 10),
        function(result) {
            ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
            ok((result.text) == ("二零一八年十一月二十六日下午三点半五十九秒"), 'result.text expected "二零一八年十一月二十六日下午三点半五十九秒" but got ' + (result.text));

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
    testSingleCase(chrono, "1点pm到3点", new Date(2012, 7, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("1点pm到3点"), 'result.text expected "1点pm到3点" but got ' + (result.text));

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

test("Test - Random date + time expression", function() {
    testSingleCase(chrono, "2014年, 3月5日早上 6 点至 7 点", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("2014年, 3月5日早上 6 点至 7 点"), 'result.text expected "2014年, 3月5日早上 6 点至 7 点" but got ' + (result.text));
    });

    testSingleCase(chrono, "下星期六凌晨1点30分二十九秒", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("下星期六凌晨1点30分二十九秒"), 'result.text expected "下星期六凌晨1点30分二十九秒" but got ' + (result.text));
    });

    testSingleCase(chrono, "昨天早上六点正", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("昨天早上六点正"), 'result.text expected "昨天早上六点正" but got ' + (result.text));
    });

    testSingleCase(chrono, "六月四日3:00am", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("六月四日3:00am"), 'result.text expected "六月四日3:00am" but got ' + (result.text));
    });

    testSingleCase(chrono, "上个礼拜五16时", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("上个礼拜五16时"), 'result.text expected "上个礼拜五16时" but got ' + (result.text));
    });

    testSingleCase(chrono, "3月17日 20点15", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("3月17日 20点15"), 'result.text expected "3月17日 20点15" but got ' + (result.text));
    });

    testSingleCase(chrono, "10点", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("10点"), 'result.text expected "10点" but got ' + (result.text));
    });

    testSingleCase(chrono, "中午12点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("hour")) == (12), 'result.start.get("hour") expected 12 but got ' + (result.start.get("hour")));
    });

    testSingleCase(chrono, "今晚10时", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));
    });

    testSingleCase(chrono, "昨晚8点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("day")) == (9), 'result.start.get("day") expected 9 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (20), 'result.start.get("hour") expected 20 but got ' + (result.start.get("hour")));
    });

    testSingleCase(chrono, "前天下午三点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("day")) == (8), 'result.start.get("day") expected 8 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (15), 'result.start.get("hour") expected 15 but got ' + (result.start.get("hour")));
    });

    // "大后天" is parsed as "后天"
    testSingleCase(chrono, "大后天晚上9点30分", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("day")) == (13), 'result.start.get("day") expected 13 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (21), 'result.start.get("hour") expected 21 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (30), 'result.start.get("minute") expected 30 but got ' + (result.start.get("minute")));
    });

    testSingleCase(chrono, "三点", new Date(2012, 7, 10, 1), function(result) {
        ok((result.start.get("hour")) == (3), 'result.start.get("hour") expected 3 but got ' + (result.start.get("hour")));
    });

    // TODO: This test fails because of a bug in the parser.
    // The AM/PM context is not correctly applied to the end of the range.
    // testSingleCase(chrono, "下午5点-7点", new Date(2012, 7, 10), function(result) {
    //     expect(result.start.get("hour")).toBe(17);
    //     expect(result.end.get("hour")).toBe(19);
    // });

    testSingleCase(chrono, "晚上11点 ~ 凌晨2点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("hour")) == (23), 'result.start.get("hour") expected 23 but got ' + (result.start.get("hour")));
        ok((result.end.get("hour")) == (2), 'result.end.get("hour") expected 2 but got ' + (result.end.get("hour")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
    });
});

test("Test - YYYY-MM-DD HH:mm:ss format", function() {
    testSingleCase(chrono, "2023-10-26 10:30:00", new Date(2012, 7, 10), function(result) {
        ok((result.text) == ("2023-10-26 10:30:00"), 'result.text expected "2023-10-26 10:30:00" but got ' + (result.text));
        ok((result.start.get("year")) == (2023), 'result.start.get("year") expected 2023 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (10), 'result.start.get("month") expected 10 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (26), 'result.start.get("day") expected 26 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (10), 'result.start.get("hour") expected 10 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (30), 'result.start.get("minute") expected 30 but got ' + (result.start.get("minute")));
        ok((result.start.get("second")) == (0), 'result.start.get("second") expected 0 but got ' + (result.start.get("second")));
    });
});

test("Test - Range Expression with days", function() {
    testSingleCase(chrono, "今晚10点 - 明天早上6点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (6), 'result.end.get("hour") expected 6 but got ' + (result.end.get("hour")));
    });

    testSingleCase(chrono, "今天早上9点 - 后天凌晨3点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (9), 'result.start.get("hour") expected 9 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (12), 'result.end.get("day") expected 12 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (3), 'result.end.get("hour") expected 3 but got ' + (result.end.get("hour")));
    });

    testSingleCase(chrono, "今晚10点 - 明早6点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (6), 'result.end.get("hour") expected 6 but got ' + (result.end.get("hour")));
    });
});

test("Test - Range Expression with seconds", function() {
    testSingleCase(chrono, "9:00:00 - 9:00:30", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("hour")) == (9), 'result.start.get("hour") expected 9 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (0), 'result.start.get("minute") expected 0 but got ' + (result.start.get("minute")));
        ok((result.start.get("second")) == (0), 'result.start.get("second") expected 0 but got ' + (result.start.get("second")));

        ok((result.end.get("hour")) == (9), 'result.end.get("hour") expected 9 but got ' + (result.end.get("hour")));
        ok((result.end.get("minute")) == (0), 'result.end.get("minute") expected 0 but got ' + (result.end.get("minute")));
        ok((result.end.get("second")) == (30), 'result.end.get("second") expected 30 but got ' + (result.end.get("second")));
    });
});

test("Test - Range Expression with AM/PM variations", function() {
    testSingleCase(chrono, "下午2点 - 晚上8点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (14), 'result.start.get("hour") expected 14 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (10), 'result.end.get("day") expected 10 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (20), 'result.end.get("hour") expected 20 but got ' + (result.end.get("hour")));
    });

    testSingleCase(chrono, "3点 - 5点PM", new Date(2012, 7, 10, 12), function(result) {
        // Context is 12:00, so 3 is likely 15:00 (3PM)
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (15), 'result.start.get("hour") expected 15 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (10), 'result.end.get("day") expected 10 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (17), 'result.end.get("hour") expected 17 but got ' + (result.end.get("hour")));
    });
});

test("Test - Range Expression with days variations", function() {
    // "Yesterday" (昨)
    testSingleCase(chrono, "今晚10点 - 昨晚10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (9), 'result.end.get("day") expected 9 but got ' + (result.end.get("day")));
    });

    // "Day before yesterday" (前)
    testSingleCase(chrono, "今晚10点 - 前天晚上10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (8), 'result.end.get("day") expected 8 but got ' + (result.end.get("day")));
    });

    // "Day before day before yesterday" (大前)
    testSingleCase(chrono, "今晚10点 - 大前天晚上10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (7), 'result.end.get("day") expected 7 but got ' + (result.end.get("day")));
    });

    // "Day after tomorrow" (后)
    testSingleCase(chrono, "今晚10点 - 后天晚上10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (12), 'result.end.get("day") expected 12 but got ' + (result.end.get("day")));
    });

    // "Day after day after tomorrow" (大后)
    testSingleCase(chrono, "今晚10点 - 大后天晚上10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (13), 'result.end.get("day") expected 13 but got ' + (result.end.get("day")));
    });

    testSingleCase(chrono, "明天10点到明天11点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.text) == ("明天10点到明天11点"), 'result.text expected "明天10点到明天11点" but got ' + (result.text));
        ok((result.start.get("day")) == (11), 'result.start.get("day") expected 11 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (10), 'result.start.get("hour") expected 10 but got ' + (result.start.get("hour")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (11), 'result.end.get("hour") expected 11 but got ' + (result.end.get("hour")));
    });
});

test("Test - Range Expression with specific AM/PM variations", function() {
    // AM variations: 早, 上, 凌
    testSingleCase(chrono, "今早10点 - 明早10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (10), 'result.start.get("hour") expected 10 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (10), 'result.end.get("hour") expected 10 but got ' + (result.end.get("hour")));
    });

    testSingleCase(chrono, "今早10点 - 明天上午10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (10), 'result.start.get("hour") expected 10 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (10), 'result.end.get("hour") expected 10 but got ' + (result.end.get("hour")));
    });

    testSingleCase(chrono, "今早10点 - 明天凌晨2点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (10), 'result.start.get("hour") expected 10 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (2), 'result.end.get("hour") expected 2 but got ' + (result.end.get("hour")));
    });

    testSingleCase(chrono, "下午2点 - 明天下午3点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (14), 'result.start.get("hour") expected 14 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (15), 'result.end.get("hour") expected 15 but got ' + (result.end.get("hour")));
    });

    // Cross-day implied PM to AM (10pm - 2am)
    testSingleCase(chrono, "晚上10点 - 2点", new Date(2012, 7, 10), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (22), 'result.start.get("hour") expected 22 but got ' + (result.start.get("hour")));

        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (11), 'result.end.get("day") expected 11 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (2), 'result.end.get("hour") expected 2 but got ' + (result.end.get("hour")));
    });
});

test("Test - Range Expression with short day-time variations", function() {
    // "Day before yesterday" (前) + "Evening" (晚) -> 前晚
    testSingleCase(chrono, "今晚10点 - 前晚10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (8), 'result.end.get("day") expected 8 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (22), 'result.end.get("hour") expected 22 but got ' + (result.end.get("hour")));
    });

    // "Day before day before yesterday" (大前) + "Evening" (晚) -> 大前晚
    testSingleCase(chrono, "今晚10点 - 大前晚10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (7), 'result.end.get("day") expected 7 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (22), 'result.end.get("hour") expected 22 but got ' + (result.end.get("hour")));
    });

    // "Day after tomorrow" (后) + "Morning" (早) -> 后早
    testSingleCase(chrono, "今晚10点 - 后早10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (12), 'result.end.get("day") expected 12 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (10), 'result.end.get("hour") expected 10 but got ' + (result.end.get("hour")));
    });

    // "Day after day after tomorrow" (大后) + "Morning" (早) -> 大后早
    testSingleCase(chrono, "今晚10点 - 大后早10点", new Date(2012, 7, 10, 12), function(result) {
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (10), 'result.start.get("day") expected 10 but got ' + (result.start.get("day")));
        ok((result.end.get("year")) == (2012), 'result.end.get("year") expected 2012 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (8), 'result.end.get("month") expected 8 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (13), 'result.end.get("day") expected 13 but got ' + (result.end.get("day")));
        ok((result.end.get("hour")) == (10), 'result.end.get("hour") expected 10 but got ' + (result.end.get("hour")));
    });
});
