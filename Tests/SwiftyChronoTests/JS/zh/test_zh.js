// Ported from chrono.js test/zh/zh.test.ts


test("Test - International compatible", function() {
    testSingleCase(chrono, "1994-11-05T08:15:30-05:30", new Date(2012, 7, 8), function(result) {
        ok(!!(result.start), 'result.start is null');
        ok((result.start.get("year")) == (1994), 'result.start.get("year") expected 1994 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (11), 'result.start.get("month") expected 11 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (5), 'result.start.get("day") expected 5 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));
        ok((result.start.get("minute")) == (15), 'result.start.get("minute") expected 15 but got ' + (result.start.get("minute")));
        ok((result.start.get("second")) == (30), 'result.start.get("second") expected 30 but got ' + (result.start.get("second")));
        ok((result.start.get("timezoneOffset")) == (-330), 'result.start.get("timezoneOffset") expected -330 but got ' + (result.start.get("timezoneOffset")));
        ok((result.text) == ("1994-11-05T08:15:30-05:30"), 'result.text expected "1994-11-05T08:15:30-05:30" but got ' + (result.text));

        var expectDate = new Date(784043130000);
        ok(Math.abs(result.start.date().getTime() - expectDate.getTime()) < 100000, 'result.start.date() expected ' + expectDate + ' but got ' + result.start.date());
    });
});

test("Test - Default Zh setting combine both hans/hant", function() {
    testSingleCase(chrono, "明天早上8点", new Date(2012, 8 - 1, 8, 12), function(result) {
        ok((result.text) == ("明天早上8点"), 'result.text expected "明天早上8点" but got ' + (result.text));
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (9), 'result.start.get("day") expected 9 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));
    });

    testSingleCase(chrono, "明天早上8點", new Date(2012, 8 - 1, 8, 12), function(result) {
        ok((result.text) == ("明天早上8點"), 'result.text expected "明天早上8點" but got ' + (result.text));
        ok((result.start.get("year")) == (2012), 'result.start.get("year") expected 2012 but got ' + (result.start.get("year")));
        ok((result.start.get("month")) == (8), 'result.start.get("month") expected 8 but got ' + (result.start.get("month")));
        ok((result.start.get("day")) == (9), 'result.start.get("day") expected 9 but got ' + (result.start.get("day")));
        ok((result.start.get("hour")) == (8), 'result.start.get("hour") expected 8 but got ' + (result.start.get("hour")));
    });
});
