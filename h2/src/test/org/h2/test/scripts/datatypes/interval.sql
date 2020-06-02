-- Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(ID INT PRIMARY KEY,
    I01 INTERVAL YEAR, I02 INTERVAL MONTH, I03 INTERVAL DAY, I04 INTERVAL HOUR, I05 INTERVAL MINUTE,
    I06 INTERVAL SECOND, I07 INTERVAL YEAR TO MONTH, I08 INTERVAL DAY TO HOUR, I09 INTERVAL DAY TO MINUTE,
    I10 INTERVAL DAY TO SECOND, I11 INTERVAL HOUR TO MINUTE, I12 INTERVAL HOUR TO SECOND,
    I13 INTERVAL MINUTE TO SECOND,
    J01 INTERVAL YEAR(5), J02 INTERVAL MONTH(5), J03 INTERVAL DAY(5), J04 INTERVAL HOUR(5), J05 INTERVAL MINUTE(5),
    J06 INTERVAL SECOND(5, 9), J07 INTERVAL YEAR(5) TO MONTH, J08 INTERVAL DAY(5) TO HOUR,
    J09 INTERVAL DAY(5) TO MINUTE, J10 INTERVAL DAY(5) TO SECOND(9), J11 INTERVAL HOUR(5) TO MINUTE,
    J12 INTERVAL HOUR(5) TO SECOND(9), J13 INTERVAL MINUTE(5) TO SECOND(9));
> ok

SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, DATETIME_PRECISION, INTERVAL_TYPE, INTERVAL_PRECISION
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TEST' ORDER BY ORDINAL_POSITION;
> COLUMN_NAME DATA_TYPE COLUMN_TYPE                     DATETIME_PRECISION INTERVAL_TYPE          INTERVAL_PRECISION
> ----------- --------- ------------------------------- ------------------ ---------------------- ------------------
> ID          INTEGER   INT NOT NULL                    null               null                   null
> I01         INTERVAL  INTERVAL YEAR                   0                  YEAR                   2
> I02         INTERVAL  INTERVAL MONTH                  0                  MONTH                  2
> I03         INTERVAL  INTERVAL DAY                    0                  DAY                    2
> I04         INTERVAL  INTERVAL HOUR                   0                  HOUR                   2
> I05         INTERVAL  INTERVAL MINUTE                 0                  MINUTE                 2
> I06         INTERVAL  INTERVAL SECOND                 6                  SECOND                 2
> I07         INTERVAL  INTERVAL YEAR TO MONTH          0                  YEAR TO MONTH          2
> I08         INTERVAL  INTERVAL DAY TO HOUR            0                  DAY TO HOUR            2
> I09         INTERVAL  INTERVAL DAY TO MINUTE          0                  DAY TO MINUTE          2
> I10         INTERVAL  INTERVAL DAY TO SECOND          6                  DAY TO SECOND          2
> I11         INTERVAL  INTERVAL HOUR TO MINUTE         0                  HOUR TO MINUTE         2
> I12         INTERVAL  INTERVAL HOUR TO SECOND         6                  HOUR TO SECOND         2
> I13         INTERVAL  INTERVAL MINUTE TO SECOND       6                  MINUTE TO SECOND       2
> J01         INTERVAL  INTERVAL YEAR(5)                0                  YEAR(5)                5
> J02         INTERVAL  INTERVAL MONTH(5)               0                  MONTH(5)               5
> J03         INTERVAL  INTERVAL DAY(5)                 0                  DAY(5)                 5
> J04         INTERVAL  INTERVAL HOUR(5)                0                  HOUR(5)                5
> J05         INTERVAL  INTERVAL MINUTE(5)              0                  MINUTE(5)              5
> J06         INTERVAL  INTERVAL SECOND(5, 9)           9                  SECOND(5, 9)           5
> J07         INTERVAL  INTERVAL YEAR(5) TO MONTH       0                  YEAR(5) TO MONTH       5
> J08         INTERVAL  INTERVAL DAY(5) TO HOUR         0                  DAY(5) TO HOUR         5
> J09         INTERVAL  INTERVAL DAY(5) TO MINUTE       0                  DAY(5) TO MINUTE       5
> J10         INTERVAL  INTERVAL DAY(5) TO SECOND(9)    9                  DAY(5) TO SECOND(9)    5
> J11         INTERVAL  INTERVAL HOUR(5) TO MINUTE      0                  HOUR(5) TO MINUTE      5
> J12         INTERVAL  INTERVAL HOUR(5) TO SECOND(9)   9                  HOUR(5) TO SECOND(9)   5
> J13         INTERVAL  INTERVAL MINUTE(5) TO SECOND(9) 9                  MINUTE(5) TO SECOND(9) 5
> rows (ordered): 27

INSERT INTO TEST VALUES (
    1,
    INTERVAL '1' YEAR, INTERVAL '1' MONTH, INTERVAL '1' DAY, INTERVAL '1' HOUR, INTERVAL '1' MINUTE,
    INTERVAL '1.123456789' SECOND, INTERVAL '1-2' YEAR TO MONTH, INTERVAL '1 2' DAY TO HOUR,
    INTERVAL '1 2:3' DAY TO MINUTE, INTERVAL '1 2:3:4.123456789' DAY TO SECOND, INTERVAL '1:2' HOUR TO MINUTE,
    INTERVAL '1:2:3.123456789' HOUR TO SECOND, INTERVAL '1:2.123456789' MINUTE TO SECOND,
    INTERVAL '1' YEAR, INTERVAL '1' MONTH, INTERVAL '1' DAY, INTERVAL '1' HOUR, INTERVAL '1' MINUTE,
    INTERVAL '1.123456789' SECOND, INTERVAL '1-2' YEAR TO MONTH, INTERVAL '1 2' DAY TO HOUR,
    INTERVAL '1 2:3' DAY TO MINUTE, INTERVAL '1 2:3:4.123456789' DAY TO SECOND, INTERVAL '1:2' HOUR TO MINUTE,
    INTERVAL '1:2:3.123456789' HOUR TO SECOND, INTERVAL '1:2.123456789' MINUTE TO SECOND
    ), (
    2,
    INTERVAL '-1' YEAR, INTERVAL '-1' MONTH, INTERVAL '-1' DAY, INTERVAL '-1' HOUR, INTERVAL '-1' MINUTE,
    INTERVAL '-1.123456789' SECOND, INTERVAL '-1-2' YEAR TO MONTH, INTERVAL '-1 2' DAY TO HOUR,
    INTERVAL '-1 2:3' DAY TO MINUTE, INTERVAL '-1 2:3:4.123456789' DAY TO SECOND, INTERVAL '-1:2' HOUR TO MINUTE,
    INTERVAL '-1:2:3.123456789' HOUR TO SECOND, INTERVAL '-1:2.123456789' MINUTE TO SECOND,
    INTERVAL -'1' YEAR, INTERVAL -'1' MONTH, INTERVAL -'1' DAY, INTERVAL -'1' HOUR, INTERVAL -'1' MINUTE,
    INTERVAL -'1.123456789' SECOND, INTERVAL -'1-2' YEAR TO MONTH, INTERVAL -'1 2' DAY TO HOUR,
    INTERVAL -'1 2:3' DAY TO MINUTE, INTERVAL -'1 2:3:4.123456789' DAY TO SECOND, INTERVAL -'1:2' HOUR TO MINUTE,
    INTERVAL -'1:2:3.123456789' HOUR TO SECOND, INTERVAL -'1:2.123456789' MINUTE TO SECOND);
> update count: 2

@reconnect

SELECT I01, I02, I03, I04, I05, I06 FROM TEST ORDER BY ID;
> I01                I02                 I03               I04                I05                  I06
> ------------------ ------------------- ----------------- ------------------ -------------------- ---------------------------
> INTERVAL '1' YEAR  INTERVAL '1' MONTH  INTERVAL '1' DAY  INTERVAL '1' HOUR  INTERVAL '1' MINUTE  INTERVAL '1.123457' SECOND
> INTERVAL '-1' YEAR INTERVAL '-1' MONTH INTERVAL '-1' DAY INTERVAL '-1' HOUR INTERVAL '-1' MINUTE INTERVAL '-1.123457' SECOND
> rows (ordered): 2

SELECT I07, I08, I09, I10 FROM TEST ORDER BY ID;
> I07                           I08                          I09                               I10
> ----------------------------- ---------------------------- --------------------------------- -------------------------------------------
> INTERVAL '1-2' YEAR TO MONTH  INTERVAL '1 02' DAY TO HOUR  INTERVAL '1 02:03' DAY TO MINUTE  INTERVAL '1 02:03:04.123457' DAY TO SECOND
> INTERVAL '-1-2' YEAR TO MONTH INTERVAL '-1 02' DAY TO HOUR INTERVAL '-1 02:03' DAY TO MINUTE INTERVAL '-1 02:03:04.123457' DAY TO SECOND
> rows (ordered): 2

SELECT I11, I12, I12 FROM TEST ORDER BY ID;
> I11                             I12                                       I12
> ------------------------------- ----------------------------------------- -----------------------------------------
> INTERVAL '1:02' HOUR TO MINUTE  INTERVAL '1:02:03.123457' HOUR TO SECOND  INTERVAL '1:02:03.123457' HOUR TO SECOND
> INTERVAL '-1:02' HOUR TO MINUTE INTERVAL '-1:02:03.123457' HOUR TO SECOND INTERVAL '-1:02:03.123457' HOUR TO SECOND
> rows (ordered): 2

SELECT J01, J02, J03, J04, J05, J06 FROM TEST ORDER BY ID;
> J01                J02                 J03               J04                J05                  J06
> ------------------ ------------------- ----------------- ------------------ -------------------- ------------------------------
> INTERVAL '1' YEAR  INTERVAL '1' MONTH  INTERVAL '1' DAY  INTERVAL '1' HOUR  INTERVAL '1' MINUTE  INTERVAL '1.123456789' SECOND
> INTERVAL '-1' YEAR INTERVAL '-1' MONTH INTERVAL '-1' DAY INTERVAL '-1' HOUR INTERVAL '-1' MINUTE INTERVAL '-1.123456789' SECOND
> rows (ordered): 2

SELECT J07, J08, J09, J10 FROM TEST ORDER BY ID;
> J07                           J08                          J09                               J10
> ----------------------------- ---------------------------- --------------------------------- ----------------------------------------------
> INTERVAL '1-2' YEAR TO MONTH  INTERVAL '1 02' DAY TO HOUR  INTERVAL '1 02:03' DAY TO MINUTE  INTERVAL '1 02:03:04.123456789' DAY TO SECOND
> INTERVAL '-1-2' YEAR TO MONTH INTERVAL '-1 02' DAY TO HOUR INTERVAL '-1 02:03' DAY TO MINUTE INTERVAL '-1 02:03:04.123456789' DAY TO SECOND
> rows (ordered): 2

SELECT J11, J12, J12 FROM TEST ORDER BY ID;
> J11                             J12                                          J12
> ------------------------------- -------------------------------------------- --------------------------------------------
> INTERVAL '1:02' HOUR TO MINUTE  INTERVAL '1:02:03.123456789' HOUR TO SECOND  INTERVAL '1:02:03.123456789' HOUR TO SECOND
> INTERVAL '-1:02' HOUR TO MINUTE INTERVAL '-1:02:03.123456789' HOUR TO SECOND INTERVAL '-1:02:03.123456789' HOUR TO SECOND
> rows (ordered): 2

DROP TABLE TEST;
> ok

-- Year-month casts

SELECT CAST(INTERVAL '-10' YEAR AS INTERVAL MONTH(3));
>> INTERVAL '-120' MONTH

SELECT CAST(INTERVAL '-10' YEAR AS INTERVAL YEAR TO MONTH);
>> INTERVAL '-10-0' YEAR TO MONTH

SELECT CAST(INTERVAL '-20' MONTH AS INTERVAL YEAR);
>> INTERVAL '-1' YEAR

SELECT CAST(INTERVAL '-20' MONTH AS INTERVAL YEAR TO MONTH);
>> INTERVAL '-1-8' YEAR TO MONTH

SELECT CAST(INTERVAL '-20-10' YEAR TO MONTH AS INTERVAL YEAR);
>> INTERVAL '-20' YEAR

SELECT CAST(INTERVAL '-20-10' YEAR TO MONTH AS INTERVAL MONTH(3));
>> INTERVAL '-250' MONTH

-- Day-time casts: DAY

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL HOUR(3));
>> INTERVAL '-240' HOUR

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL MINUTE(5));
>> INTERVAL '-14400' MINUTE

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL SECOND(6));
>> INTERVAL '-864000' SECOND

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL DAY TO HOUR);
>> INTERVAL '-10 00' DAY TO HOUR

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-10 00:00' DAY TO MINUTE

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL DAY TO SECOND);
>> INTERVAL '-10 00:00:00' DAY TO SECOND

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL HOUR(3) TO MINUTE);
>> INTERVAL '-240:00' HOUR TO MINUTE

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL HOUR(3) TO SECOND);
>> INTERVAL '-240:00:00' HOUR TO SECOND

SELECT CAST(INTERVAL '-10' DAY AS INTERVAL MINUTE(5) TO SECOND);
>> INTERVAL '-14400:00' MINUTE TO SECOND

-- Day-time casts: HOUR

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL MINUTE(4));
>> INTERVAL '-1800' MINUTE

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL SECOND(6));
>> INTERVAL '-108000' SECOND

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 06' DAY TO HOUR

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 06:00' DAY TO MINUTE

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 06:00:00' DAY TO SECOND

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-30:00' HOUR TO MINUTE

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-30:00:00' HOUR TO SECOND

SELECT CAST(INTERVAL '-30' HOUR AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1800:00' MINUTE TO SECOND

-- Day-time casts: MINUTE

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL HOUR);
>> INTERVAL '-26' HOUR

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL SECOND(5));
>> INTERVAL '-94200' SECOND

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 02' DAY TO HOUR

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 02:10' DAY TO MINUTE

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 02:10:00' DAY TO SECOND

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-26:10' HOUR TO MINUTE

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-26:10:00' HOUR TO SECOND

SELECT CAST(INTERVAL '-1570' MINUTE AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1570:00' MINUTE TO SECOND

-- Day-time casts: SECOND

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL HOUR);
>> INTERVAL '-26' HOUR

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL MINUTE(4));
>> INTERVAL '-1563' MINUTE

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 02' DAY TO HOUR

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 02:03' DAY TO MINUTE

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 02:03:04.123457' DAY TO SECOND

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-26:03' HOUR TO MINUTE

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-26:03:04.123457' HOUR TO SECOND

SELECT CAST(INTERVAL '-93784.123456789' SECOND AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1563:04.123457' MINUTE TO SECOND

-- Day-time casts: DAY TO HOUR

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL HOUR);
>> INTERVAL '-26' HOUR

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL MINUTE(4));
>> INTERVAL '-1560' MINUTE

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL SECOND(5));
>> INTERVAL '-93600' SECOND

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 02:00' DAY TO MINUTE

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 02:00:00' DAY TO SECOND

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-26:00' HOUR TO MINUTE

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-26:00:00' HOUR TO SECOND

SELECT CAST(INTERVAL '-1 2' DAY TO HOUR AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1560:00' MINUTE TO SECOND

-- Day-time casts: DAY TO MINUTE

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL HOUR);
>> INTERVAL '-26' HOUR

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL MINUTE(4));
>> INTERVAL '-1563' MINUTE

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL SECOND(5));
>> INTERVAL '-93780' SECOND

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 02' DAY TO HOUR

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 02:03:00' DAY TO SECOND

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-26:03' HOUR TO MINUTE

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-26:03:00' HOUR TO SECOND

SELECT CAST(INTERVAL '-1 2:3' DAY TO MINUTE AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1563:00' MINUTE TO SECOND

-- Day-time casts: DAY TO SECOND

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL HOUR);
>> INTERVAL '-26' HOUR

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL MINUTE(4));
>> INTERVAL '-1563' MINUTE

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL SECOND(5));
>> INTERVAL '-93784.123457' SECOND

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 02' DAY TO HOUR

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 02:03' DAY TO MINUTE

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-26:03' HOUR TO MINUTE

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-26:03:04.123457' HOUR TO SECOND

SELECT CAST(INTERVAL '-1 2:3:4.123456789' DAY TO SECOND AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1563:04.123457' MINUTE TO SECOND

-- Day-time casts: HOUR TO MINUTE

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL HOUR);
>> INTERVAL '-30' HOUR

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL MINUTE(4));
>> INTERVAL '-1802' MINUTE

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL SECOND(6));
>> INTERVAL '-108120' SECOND

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 06' DAY TO HOUR

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 06:02' DAY TO MINUTE

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 06:02:00' DAY TO SECOND

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-30:02:00' HOUR TO SECOND

SELECT CAST(INTERVAL '-30:2' HOUR TO MINUTE AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1802:00' MINUTE TO SECOND

-- Day-time casts: HOUR TO SECOND

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL HOUR);
>> INTERVAL '-30' HOUR

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL MINUTE(4));
>> INTERVAL '-1802' MINUTE

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL SECOND(6));
>> INTERVAL '-108124.123457' SECOND

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 06' DAY TO HOUR

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 06:02' DAY TO MINUTE

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 06:02:04.123457' DAY TO SECOND

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-30:02' HOUR TO MINUTE

SELECT CAST(INTERVAL '-30:2:4.123456789' HOUR TO SECOND AS INTERVAL MINUTE(4) TO SECOND);
>> INTERVAL '-1802:04.123457' MINUTE TO SECOND

-- Day-time casts: MINUTE TO SECOND

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL DAY);
>> INTERVAL '-1' DAY

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL HOUR);
>> INTERVAL '-30' HOUR

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL MINUTE(4));
>> INTERVAL '-1803' MINUTE

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL SECOND(6));
>> INTERVAL '-108184.123457' SECOND

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL DAY TO HOUR);
>> INTERVAL '-1 06' DAY TO HOUR

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL DAY TO MINUTE);
>> INTERVAL '-1 06:03' DAY TO MINUTE

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL DAY TO SECOND);
>> INTERVAL '-1 06:03:04.123457' DAY TO SECOND

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '-30:03' HOUR TO MINUTE

SELECT CAST(INTERVAL '-1803:4.123456789' MINUTE TO SECOND AS INTERVAL HOUR TO SECOND);
>> INTERVAL '-30:03:04.123457' HOUR TO SECOND

-- Cast with fractional seconds precision

SELECT CAST(INTERVAL '10:11.123456789' MINUTE TO SECOND AS INTERVAL SECOND(3, 9));
>> INTERVAL '611.123456789' SECOND

-- Casts with strings

SELECT CAST(INTERVAL '10' YEAR AS VARCHAR);
>> INTERVAL '10' YEAR

SELECT CAST('INTERVAL ''10'' YEAR' AS INTERVAL YEAR);
>> INTERVAL '10' YEAR

SELECT CAST('10' AS INTERVAL YEAR);
>> INTERVAL '10' YEAR

SELECT CAST(INTERVAL '10' MONTH AS VARCHAR);
>> INTERVAL '10' MONTH

SELECT CAST('INTERVAL ''10'' MONTH' AS INTERVAL MONTH);
>> INTERVAL '10' MONTH

SELECT CAST('10' AS INTERVAL MONTH);
>> INTERVAL '10' MONTH

SELECT CAST(INTERVAL '10' DAY AS VARCHAR);
>> INTERVAL '10' DAY

SELECT CAST('INTERVAL ''10'' DAY' AS INTERVAL DAY);
>> INTERVAL '10' DAY

SELECT CAST('10' AS INTERVAL DAY);
>> INTERVAL '10' DAY

SELECT CAST(INTERVAL '10' HOUR AS VARCHAR);
>> INTERVAL '10' HOUR

SELECT CAST('INTERVAL ''10'' HOUR' AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST('10' AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST(INTERVAL '10' MINUTE AS VARCHAR);
>> INTERVAL '10' MINUTE

SELECT CAST('INTERVAL ''10'' MINUTE' AS INTERVAL MINUTE);
>> INTERVAL '10' MINUTE

SELECT CAST('10' AS INTERVAL MINUTE);
>> INTERVAL '10' MINUTE

SELECT CAST(INTERVAL '10.123456789' SECOND AS VARCHAR);
>> INTERVAL '10.123456789' SECOND

SELECT CAST('INTERVAL ''10.123456789'' SECOND' AS INTERVAL SECOND(2, 9));
>> INTERVAL '10.123456789' SECOND

SELECT CAST('10.123456789' AS INTERVAL SECOND(2, 9));
>> INTERVAL '10.123456789' SECOND

SELECT CAST(INTERVAL '10-11' YEAR TO MONTH AS VARCHAR);
>> INTERVAL '10-11' YEAR TO MONTH

SELECT CAST('INTERVAL ''10-11'' YEAR TO MONTH' AS INTERVAL YEAR TO MONTH);
>> INTERVAL '10-11' YEAR TO MONTH

SELECT CAST('10-11' AS INTERVAL YEAR TO MONTH);
>> INTERVAL '10-11' YEAR TO MONTH

SELECT CAST(INTERVAL '10 11' DAY TO HOUR AS VARCHAR);
>> INTERVAL '10 11' DAY TO HOUR

SELECT CAST('INTERVAL ''10 11'' DAY TO HOUR' AS INTERVAL DAY TO HOUR);
>> INTERVAL '10 11' DAY TO HOUR

SELECT CAST('10 11' AS INTERVAL DAY TO HOUR);
>> INTERVAL '10 11' DAY TO HOUR

SELECT CAST(INTERVAL '10 11:12' DAY TO MINUTE AS VARCHAR);
>> INTERVAL '10 11:12' DAY TO MINUTE

SELECT CAST('INTERVAL ''10 11:12'' DAY TO MINUTE' AS INTERVAL DAY TO MINUTE);
>> INTERVAL '10 11:12' DAY TO MINUTE

SELECT CAST('10 11:12' AS INTERVAL DAY TO MINUTE);
>> INTERVAL '10 11:12' DAY TO MINUTE

SELECT CAST(INTERVAL '10 11:12:13.123456789' DAY TO SECOND AS VARCHAR);
>> INTERVAL '10 11:12:13.123456789' DAY TO SECOND

SELECT CAST('INTERVAL ''10 11:12:13.123456789'' DAY TO SECOND' AS INTERVAL DAY TO SECOND(9));
>> INTERVAL '10 11:12:13.123456789' DAY TO SECOND

SELECT CAST('10 11:12:13.123456789' AS INTERVAL DAY TO SECOND(9));
>> INTERVAL '10 11:12:13.123456789' DAY TO SECOND

SELECT CAST(INTERVAL '11:12' HOUR TO MINUTE AS VARCHAR);
>> INTERVAL '11:12' HOUR TO MINUTE

SELECT CAST('INTERVAL ''11:12'' HOUR TO MINUTE' AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '11:12' HOUR TO MINUTE

SELECT CAST('11:12' AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '11:12' HOUR TO MINUTE

SELECT CAST(INTERVAL '11:12:13.123456789' HOUR TO SECOND AS VARCHAR);
>> INTERVAL '11:12:13.123456789' HOUR TO SECOND

SELECT CAST('INTERVAL ''11:12:13.123456789'' HOUR TO SECOND' AS INTERVAL HOUR TO SECOND(9));
>> INTERVAL '11:12:13.123456789' HOUR TO SECOND

SELECT CAST('11:12:13.123456789' AS INTERVAL HOUR TO SECOND(9));
>> INTERVAL '11:12:13.123456789' HOUR TO SECOND

SELECT CAST(INTERVAL '12:13.123456789' MINUTE TO SECOND AS VARCHAR);
>> INTERVAL '12:13.123456789' MINUTE TO SECOND

SELECT CAST('INTERVAL ''12:13.123456789'' MINUTE TO SECOND' AS INTERVAL MINUTE TO SECOND(9));
>> INTERVAL '12:13.123456789' MINUTE TO SECOND

SELECT CAST('12:13.123456789' AS INTERVAL MINUTE TO SECOND(9));
>> INTERVAL '12:13.123456789' MINUTE TO SECOND

-- More formats

SELECT INTERVAL +'+10' SECOND;
>> INTERVAL '10' SECOND

SELECT CAST('INTERVAL +''+10'' SECOND' AS INTERVAL SECOND);
>> INTERVAL '10' SECOND

SELECT INTERVAL -'-10' HOUR;
>> INTERVAL '10' HOUR

SELECT CAST('INTERVAL -''-10'' HOUR' AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST('INTERVAL ''1'' MINUTE' AS INTERVAL SECOND);
>> INTERVAL '60' SECOND

SELECT CAST('  interval  +   ''12-2''  Year  To  Month  ' AS INTERVAL YEAR TO MONTH);
>> INTERVAL '12-2' YEAR TO MONTH

SELECT CAST('INTERVAL''11:12''HOUR TO MINUTE' AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '11:12' HOUR TO MINUTE

SELECT INTERVAL '-0-1' YEAR TO MONTH;
>> INTERVAL '-0-1' YEAR TO MONTH

SELECT INTERVAL '-0.1' SECOND;
>> INTERVAL '-0.1' SECOND

SELECT INTERVAL -'0.1' SECOND;
>> INTERVAL '-0.1' SECOND

-- Arithmetic

SELECT INTERVAL '1000' SECOND + INTERVAL '10' MINUTE;
>> INTERVAL '26:40' MINUTE TO SECOND

SELECT INTERVAL '1000' SECOND - INTERVAL '10' MINUTE;
>> INTERVAL '6:40' MINUTE TO SECOND

SELECT INTERVAL '10' YEAR + INTERVAL '1' MONTH;
>> INTERVAL '10-1' YEAR TO MONTH

SELECT INTERVAL '10' YEAR - INTERVAL '1' MONTH;
>> INTERVAL '9-11' YEAR TO MONTH

SELECT INTERVAL '1000' SECOND * 2;
>> INTERVAL '2000' SECOND

SELECT 2 * INTERVAL '1000' SECOND;
>> INTERVAL '2000' SECOND

SELECT INTERVAL '1000' SECOND / 2;
>> INTERVAL '500' SECOND

SELECT INTERVAL '10' YEAR * 2;
>> INTERVAL '20' YEAR

SELECT 2 * INTERVAL '10' YEAR;
>> INTERVAL '20' YEAR

SELECT INTERVAL '10' YEAR / 2;
>> INTERVAL '5' YEAR

SELECT TIME '10:00:00' + INTERVAL '30' MINUTE;
>> 10:30:00

SELECT INTERVAL '30' MINUTE + TIME '10:00:00';
>> 10:30:00

SELECT TIME '10:00:00' - INTERVAL '30' MINUTE;
>> 09:30:00

SELECT DATE '2000-01-10' + INTERVAL '30' HOUR;
>> 2000-01-11

SELECT INTERVAL '30' HOUR + DATE '2000-01-10';
>> 2000-01-11

SELECT DATE '2000-01-10' - INTERVAL '30' HOUR;
>> 2000-01-09

SELECT DATE '2000-01-10' + INTERVAL '1-2' YEAR TO MONTH;
>> 2001-03-10

SELECT INTERVAL '1-2' YEAR TO MONTH + DATE '2000-01-10';
>> 2001-03-10

SELECT DATE '2000-01-10' - INTERVAL '1-2' YEAR TO MONTH;
>> 1998-11-10

SELECT TIMESTAMP '2000-01-01 12:00:00' + INTERVAL '25 13' DAY TO HOUR;
>> 2000-01-27 01:00:00

SELECT INTERVAL '25 13' DAY TO HOUR + TIMESTAMP '2000-01-01 12:00:00';
>> 2000-01-27 01:00:00

SELECT TIMESTAMP '2000-01-01 12:00:00' - INTERVAL '25 13' DAY TO HOUR;
>> 1999-12-06 23:00:00

SELECT TIMESTAMP '2000-01-01 12:00:00' + INTERVAL '1-2' YEAR TO MONTH;
>> 2001-03-01 12:00:00

SELECT INTERVAL '1-2' YEAR TO MONTH + TIMESTAMP '2000-01-01 12:00:00';
>> 2001-03-01 12:00:00

SELECT TIMESTAMP '2000-01-01 12:00:00' - INTERVAL '1-2' YEAR TO MONTH;
>> 1998-11-01 12:00:00

SELECT TIMESTAMP WITH TIME ZONE '2000-01-01 12:00:00+01' + INTERVAL '25 13' DAY TO HOUR;
>> 2000-01-27 01:00:00+01

SELECT INTERVAL '25 13' DAY TO HOUR + TIMESTAMP WITH TIME ZONE '2000-01-01 12:00:00+01';
>> 2000-01-27 01:00:00+01

SELECT TIMESTAMP WITH TIME ZONE '2000-01-01 12:00:00+01' - INTERVAL '25 13' DAY TO HOUR;
>> 1999-12-06 23:00:00+01

SELECT TIMESTAMP WITH TIME ZONE '2000-01-01 12:00:00+01' + INTERVAL '1-2' YEAR TO MONTH;
>> 2001-03-01 12:00:00+01

SELECT INTERVAL '1-2' YEAR TO MONTH + TIMESTAMP WITH TIME ZONE '2000-01-01 12:00:00+01';
>> 2001-03-01 12:00:00+01

SELECT TIMESTAMP WITH TIME ZONE '2000-01-01 12:00:00+01' - INTERVAL '1-2' YEAR TO MONTH;
>> 1998-11-01 12:00:00+01

SELECT -INTERVAL '1' DAY;
>> INTERVAL '-1' DAY

-- Date-time subtraction

SELECT TIME '10:30:15.123456789' - TIME '11:00:00';
>> INTERVAL '-0:29:44.876543211' HOUR TO SECOND

SELECT DATE '2010-01-15' - DATE '2009-12-31';
>> INTERVAL '15' DAY

SELECT TIMESTAMP '2010-01-15 12:00:00.5' - TIMESTAMP '2010-01-13 01:30:00';
>> INTERVAL '2 10:30:00.5' DAY TO SECOND

SELECT TIMESTAMP WITH TIME ZONE '2010-01-15 12:00:00.5+01' - TIMESTAMP WITH TIME ZONE '2010-01-13 01:30:00+01';
>> INTERVAL '2 10:30:00.5' DAY TO SECOND

SELECT TIMESTAMP WITH TIME ZONE '2010-01-15 12:00:00.5+01' - TIMESTAMP WITH TIME ZONE '2010-01-13 01:30:00+02';
>> INTERVAL '2 11:30:00.5' DAY TO SECOND

SELECT TIMESTAMP '2010-01-15 12:00:00.5+01' - TIMESTAMP WITH TIME ZONE '2010-01-13 01:30:00+02';
>> INTERVAL '2 11:30:00.5' DAY TO SECOND

SELECT TIMESTAMP WITH TIME ZONE '2010-01-15 12:00:00.5+01' - TIMESTAMP '2010-01-13 01:30:00+02';
>> INTERVAL '2 11:30:00.5' DAY TO SECOND

CREATE TABLE TEST(I INTERVAL YEAR TO MONTH);
> ok

INSERT INTO TEST VALUES ('-0-0'), ('-0-1'), ('-1-1'), ('1-0'), ('0-1'), ('1-1'), ('-1-0');
> update count: 7

SELECT * FROM TEST ORDER BY I;
> I
> -----------------------------
> INTERVAL '-1-1' YEAR TO MONTH
> INTERVAL '-1-0' YEAR TO MONTH
> INTERVAL '-0-1' YEAR TO MONTH
> INTERVAL '0-0' YEAR TO MONTH
> INTERVAL '0-1' YEAR TO MONTH
> INTERVAL '1-0' YEAR TO MONTH
> INTERVAL '1-1' YEAR TO MONTH
> rows (ordered): 7

DROP TABLE TEST;
> ok

-- Some precision tests

CREATE TABLE TEST(I INTERVAL DAY, IL INTERVAL DAY(5));
> ok

INSERT INTO TEST VALUES ('99', '99999'), ('-99', '-99999');
> update count: 2

INSERT INTO TEST(I) VALUES ('100');
> exception VALUE_TOO_LONG_2

INSERT INTO TEST(I) VALUES ('-100');
> exception VALUE_TOO_LONG_2

INSERT INTO TEST(IL) VALUES ('100000');
> exception VALUE_TOO_LONG_2

INSERT INTO TEST(IL) VALUES ('-100000');
> exception VALUE_TOO_LONG_2

DROP TABLE TEST;
> ok

CREATE TABLE TEST(I INTERVAL DAY(0));
> exception INVALID_VALUE_PRECISION

CREATE TABLE TEST(I INTERVAL DAY(18));
> ok

DROP TABLE TEST;
> ok

CREATE TABLE TEST(I INTERVAL DAY(19));
> exception INVALID_VALUE_PRECISION

CREATE TABLE TEST(I INTERVAL HOUR TO SECOND(0));
> ok

DROP TABLE TEST;
> ok

CREATE TABLE TEST(I INTERVAL HOUR TO SECOND(9));
> ok

DROP TABLE TEST;
> ok

CREATE TABLE TEST(I INTERVAL HOUR TO SECOND(10));
> exception INVALID_VALUE_SCALE

SELECT TIMESTAMP '2018-09-10 23:30:00' - TIMESTAMP '2014-09-11 23:30:00';
>> INTERVAL '1460 00:00:00' DAY TO SECOND

SELECT TIMESTAMP WITH TIME ZONE '2014-09-11 23:30:00Z' - TIMESTAMP WITH TIME ZONE '2018-09-10 23:30:00Z';
>> INTERVAL '-1460 00:00:00' DAY TO SECOND

SELECT DATE '2018-09-10' - DATE '2014-09-11';
>> INTERVAL '1460' DAY

SELECT INTERVAL -'1-2' YEAR TO MONTH / INTERVAL '1' MONTH;
>> -14.0000000000000000000000000000000000000000

SELECT INTERVAL '1 12:03:40.123456789' DAY TO SECOND / INTERVAL '1' SECOND;
>> 129820.1234567890000000000000000000000000000000000000000000000000000000

SELECT INTERVAL -'0.000000001' SECOND / INTERVAL '1' SECOND;
>> -1.0000000000000000000000000000000000000000000000000000000E-9

SELECT INTERVAL -'1-2' YEAR TO MONTH / INTERVAL '1' DAY;
> exception FEATURE_NOT_SUPPORTED_1

SELECT INTERVAL '1' DAY / INTERVAL '0' DAY;
> exception DIVISION_BY_ZERO_1

CALL CAST(INTERVAL '999999999999999998.999999999' SECOND AS INTERVAL SECOND(18));
>> INTERVAL '999999999999999999' SECOND

CALL CAST(INTERVAL '999999999999999999.999999999' SECOND AS INTERVAL SECOND(18));
>> INTERVAL '999999999999999999.999999' SECOND

CALL CAST(INTERVAL '999999999999999998 23:59:59.999999999' DAY TO SECOND AS INTERVAL DAY(18) TO SECOND);
>> INTERVAL '999999999999999999 00:00:00' DAY TO SECOND

CALL CAST(INTERVAL '999999999999999999 23:59:59.999999999' DAY TO SECOND AS INTERVAL DAY(18) TO SECOND);
>> INTERVAL '999999999999999999 23:59:59.999999' DAY TO SECOND

CALL CAST(INTERVAL '999999999999999998:59:59.999999999' HOUR TO SECOND AS INTERVAL HOUR(18) TO SECOND);
>> INTERVAL '999999999999999999:00:00' HOUR TO SECOND

CALL CAST(INTERVAL '999999999999999999:59:59.999999999' HOUR TO SECOND AS INTERVAL HOUR(18) TO SECOND);
>> INTERVAL '999999999999999999:59:59.999999' HOUR TO SECOND

CALL CAST(INTERVAL '999999999999999998:59.999999999' MINUTE TO SECOND AS INTERVAL MINUTE(18) TO SECOND);
>> INTERVAL '999999999999999999:00' MINUTE TO SECOND

CALL CAST(INTERVAL '999999999999999999:59.999999999' MINUTE TO SECOND AS INTERVAL MINUTE(18) TO SECOND);
>> INTERVAL '999999999999999999:59.999999' MINUTE TO SECOND

CALL CAST(INTERVAL '99' DAY AS INTERVAL DAY);
>> INTERVAL '99' DAY

CALL CAST(INTERVAL '-99' DAY AS INTERVAL DAY);
>> INTERVAL '-99' DAY

CALL CAST(INTERVAL '100' DAY AS INTERVAL DAY);
> exception VALUE_TOO_LONG_2

CALL CAST(INTERVAL '-100' DAY AS INTERVAL DAY);
> exception VALUE_TOO_LONG_2

SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00');
>> INTERVAL '7180 09:30:00' DAY TO SECOND

SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR;
> exception VALUE_TOO_LONG_2

SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR(6);
>> INTERVAL '172329' HOUR

SELECT (TIMESTAMP '2010-01-01 10:00:00' - INTERVAL '1' YEAR) YEAR;
> exception SYNTAX_ERROR_2

SELECT (INTERVAL '10' HOUR - INTERVAL '1' HOUR) HOUR;
> exception SYNTAX_ERROR_2

SELECT (10 - 2) SECOND;
> exception SYNTAX_ERROR_2

SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR TO SECOND;
> exception VALUE_TOO_LONG_2

SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR(6) TO SECOND;
>> INTERVAL '172329:30:00' HOUR TO SECOND

EXPLAIN SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR TO SECOND;
>> SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR TO SECOND

EXPLAIN SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR TO SECOND(9);
>> SELECT (TIMESTAMP '2010-01-01 10:00:00' - TIMESTAMP '1990-05-06 00:30:00') HOUR TO SECOND(9)

CREATE TABLE TEST(S VARCHAR) AS VALUES '1';
> ok

SELECT S DAY FROM TEST;
>> INTERVAL '1' DAY

EXPLAIN SELECT S DAY FROM TEST;
>> SELECT CAST("S" AS INTERVAL DAY) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

DROP TABLE TEST;
> ok

SELECT CAST(10 AS INTERVAL YEAR);
>> INTERVAL '10' YEAR

SELECT CAST(INTERVAL '10' YEAR AS INTEGER);
>> 10

SELECT CAST(-10 AS INTERVAL YEAR);
>> INTERVAL '-10' YEAR

SELECT CAST(INTERVAL '-10' YEAR AS INTEGER);
>> -10

SELECT CAST(10::BIGINT AS INTERVAL YEAR);
>> INTERVAL '10' YEAR

SELECT CAST(INTERVAL '10' YEAR AS BIGINT);
>> 10

SELECT CAST(INTERVAL '10' YEAR AS SMALLINT);
>> 10

SELECT CAST(INTERVAL '10' YEAR AS TINYINT);
>> 10

SELECT CAST(10::DOUBLE AS INTERVAL YEAR);
>> INTERVAL '10' YEAR

SELECT CAST(INTERVAL '10' YEAR AS REAL);
>> 10.0

SELECT CAST(INTERVAL '10' YEAR AS DOUBLE);
>> 10.0

SELECT CAST(INTERVAL '10' YEAR AS NUMERIC);
>> 10

SELECT CAST(INTERVAL '-10' YEAR AS NUMERIC);
>> -10

SELECT CAST(10.123456789123456789 AS INTERVAL YEAR);
>> INTERVAL '10' YEAR

SELECT CAST(10 AS INTERVAL MONTH);
>> INTERVAL '10' MONTH

SELECT CAST(INTERVAL '10' MONTH AS NUMERIC);
>> 10

SELECT CAST(10.123456789123456789 AS INTERVAL MONTH);
>> INTERVAL '10' MONTH

SELECT CAST(10 AS INTERVAL DAY);
>> INTERVAL '10' DAY

SELECT CAST(INTERVAL '10' DAY AS NUMERIC);
>> 10

SELECT CAST(-10 AS INTERVAL DAY);
>> INTERVAL '-10' DAY

SELECT CAST(10.123456789123456789 AS INTERVAL DAY);
>> INTERVAL '10' DAY

SELECT CAST(10 AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST(INTERVAL '10' HOUR AS NUMERIC);
>> 10

SELECT CAST(10::BIGINT AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST(10::DOUBLE AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST(10.123456789123456789 AS INTERVAL HOUR);
>> INTERVAL '10' HOUR

SELECT CAST(10 AS INTERVAL MINUTE);
>> INTERVAL '10' MINUTE

SELECT CAST(INTERVAL '10' MINUTE AS NUMERIC);
>> 10

SELECT CAST(10.123456789123456789 AS INTERVAL MINUTE);
>> INTERVAL '10' MINUTE

SELECT CAST(10 AS INTERVAL SECOND);
>> INTERVAL '10' SECOND

SELECT CAST(INTERVAL '10' SECOND AS NUMERIC);
>> 10

SELECT CAST(10.123456789123456789 AS INTERVAL SECOND);
>> INTERVAL '10.123457' SECOND

SELECT CAST(INTERVAL '10.123457' SECOND AS INT);
>> 10

SELECT CAST(INTERVAL '10.123457' SECOND AS NUMERIC(8, 6));
>> 10.123457

SELECT CAST(10 AS INTERVAL YEAR TO MONTH);
>> INTERVAL '10-0' YEAR TO MONTH

SELECT CAST(10::DOUBLE AS INTERVAL YEAR TO MONTH);
>> INTERVAL '10-0' YEAR TO MONTH

SELECT CAST(10.123456789123456789 AS INTERVAL YEAR TO MONTH);
>> INTERVAL '10-1' YEAR TO MONTH

SELECT CAST(INTERVAL '10-1' YEAR TO MONTH AS NUMERIC(4, 2));
>> 10.08

SELECT CAST(10 AS INTERVAL DAY TO HOUR);
>> INTERVAL '10 00' DAY TO HOUR

SELECT CAST(10::DOUBLE AS INTERVAL DAY TO HOUR);
>> INTERVAL '10 00' DAY TO HOUR

SELECT CAST(10.123456789123456789 AS INTERVAL DAY TO HOUR);
>> INTERVAL '10 02' DAY TO HOUR

SELECT CAST(INTERVAL '10 02' DAY TO HOUR AS NUMERIC(4, 2));
>> 10.08

SELECT CAST(INTERVAL '-10 02' DAY TO HOUR AS NUMERIC(4, 2));
>> -10.08

SELECT CAST(10 AS INTERVAL DAY TO MINUTE);
>> INTERVAL '10 00:00' DAY TO MINUTE

SELECT CAST(10.123456789123456789 AS INTERVAL DAY TO MINUTE);
>> INTERVAL '10 02:57' DAY TO MINUTE

SELECT CAST(INTERVAL '10 02:57' DAY TO MINUTE AS NUMERIC(6, 4));
>> 10.1229

SELECT CAST(10 AS INTERVAL DAY TO SECOND);
>> INTERVAL '10 00:00:00' DAY TO SECOND

SELECT CAST(10.123456789123456789 AS INTERVAL DAY TO SECOND);
>> INTERVAL '10 02:57:46.66658' DAY TO SECOND

SELECT CAST(INTERVAL '10 02:57:46.66658' DAY TO SECOND AS NUMERIC(16, 14));
>> 10.12345678912037

SELECT CAST(10 AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '10:00' HOUR TO MINUTE

SELECT CAST(10.123456789123456789 AS INTERVAL HOUR TO MINUTE);
>> INTERVAL '10:07' HOUR TO MINUTE

SELECT CAST(INTERVAL '10:07' HOUR TO MINUTE AS NUMERIC(4, 2));
>> 10.12

SELECT CAST(10 AS INTERVAL HOUR TO SECOND);
>> INTERVAL '10:00:00' HOUR TO SECOND

SELECT CAST(10.123456789123456789 AS INTERVAL HOUR TO SECOND);
>> INTERVAL '10:07:24.444441' HOUR TO SECOND

SELECT CAST(INTERVAL '10:07:24.444441' HOUR TO SECOND AS NUMERIC(15, 13));
>> 10.1234567891667

SELECT CAST(10 AS INTERVAL MINUTE TO SECOND);
>> INTERVAL '10:00' MINUTE TO SECOND

SELECT CAST(10.123456789123456789 AS INTERVAL MINUTE TO SECOND);
>> INTERVAL '10:07.407407' MINUTE TO SECOND

SELECT CAST(INTERVAL '10:07.407407' MINUTE TO SECOND AS NUMERIC(13, 11));
>> 10.12345678333

-- H2 uses 1970-01-01 as start datetime

SELECT TIMESTAMP '2001-01-05 10:30:00' - TIME '11:45:30.5';
>> INTERVAL '11326 22:44:29.5' DAY TO SECOND

SELECT TIME '11:45:30.5' - TIMESTAMP '2001-01-05 10:30:00';
>> INTERVAL '-11326 22:44:29.5' DAY TO SECOND

EXPLAIN VALUES INTERVAL '1' DAY;
>> VALUES (INTERVAL '1' DAY)
