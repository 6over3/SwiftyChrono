// Ported from chrono.js test/zh/hant/zh_hant_date.test.ts


test("Test - Single Expression", function() {
    testSingleCase(chrono, "雞2016年9月3號全部都係雞", new Date(2012, 8 - 1, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("2016年9月3號"), 'result.text expected "2016年9月3號" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 9 - 1, 3, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "雞二零一六年，九月三號全部都係雞", new Date(2012, 8 - 1, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("二零一六年，九月三號"), 'result.text expected "二零一六年，九月三號" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 9 - 1, 3, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "雞九月三號全部都係雞", new Date(2014, 8 - 1, 10), function(result) {
        ok((result.index) == (1), 'result.index expected 1 but got ' + (result.index));
        ok((result.text) == ("九月三號"), 'result.text expected "九月三號" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2014), 'result.start.get("year") expected 2014 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2014, 9 - 1, 3, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });

    testSingleCase(chrono, "2016年09月03日", new Date(2012, 8 - 1, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("2016年09月03日"), 'result.text expected "2016年09月03日" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));

        const resultDate = result.start.date();
        const expectDate = new Date(2016, 9 - 1, 3, 12);
        ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
    });
});

test("Test - Range Expression", function() {
    testSingleCase(chrono, "2016年9月3號-2017年10月24號", new Date(2012, 8 - 1, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("2016年9月3號-2017年10月24號"), 'result.text expected "2016年9月3號-2017年10月24號" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));

        {
            const resultDate = result.start.date();
            const expectDate = new Date(2016, 9 - 1, 3, 12);
            ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
        }

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("year")) == (2017), 'result.end.get("year") expected 2017 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (10), 'result.end.get("month") expected 10 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (24), 'result.end.get("day") expected 24 but got ' + (result.end.get("day")));

        {
            const resultDate = result.end.date();
            const expectDate = new Date(2017, 10 - 1, 24, 12);
            ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
        }
    });

    testSingleCase(chrono, "二零一六年九月三號ー2017年10月24號", new Date(2012, 8 - 1, 10), function(result) {
        ok((result.index) == (0), 'result.index expected 0 but got ' + (result.index));
        ok((result.text) == ("二零一六年九月三號ー2017年10月24號"), 'result.text expected "二零一六年九月三號ー2017年10月24號" but got ' + (result.text));

        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (2016), 'result.start.get("year") expected 2016 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (9), 'result.start.get("month") expected 9 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (3), 'result.start.get("day") expected 3 but got ' + (result.start.get("day")));

        {
            const resultDate = result.start.date();
            const expectDate = new Date(2016, 9 - 1, 3, 12);
            ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
        }

        ok(!!(result.end), 'result.end is null');
        ok((result.end.get("year")) == (2017), 'result.end.get("year") expected 2017 but got ' + (result.end.get("year")));
        ok((result.end.get("month")) == (10), 'result.end.get("month") expected 10 but got ' + (result.end.get("month")));
        ok((result.end.get("day")) == (24), 'result.end.get("day") expected 24 but got ' + (result.end.get("day")));

        {
            const resultDate = result.end.date();
            const expectDate = new Date(2017, 10 - 1, 24, 12);
            ok(Math.abs((expectDate.getTime()) - (resultDate.getTime())) < 100000, 'expectDate.getTime() vs resultDate.getTime(): ' + (expectDate.getTime()) + ' / ' + (resultDate.getTime()));
        }
    });
});
