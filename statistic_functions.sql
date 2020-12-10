CREATE OR REPLACE FUNCTION instruments_in_depository_by_account_number(number int)
RETURNS TABLE (
    instrument varchar(20),
    quantity bigint
)
AS $BODY$ 
DECLARE
    account_ RECORD; 
BEGIN
    SELECT * INTO account_ FROM get_account(number);
    RETURN QUERY (SELECT instrument_template.short_name as instrument, 
                (SUM(CASE WHEN depository.direction = 'input' then depository.quantity else 0 end) 
                - SUM(CASE WHEN depository.direction = 'output' then depository.quantity else 0 end))
    from account join depository on account.number = depository.account_number
                 join instrument on depository.instrument_id = instrument.id
                 join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                 where account.number = account_.number
                 GROUP BY instrument_template.short_name);
END;
$BODY$ 
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION instruments_in_depository_by_trader_id(trader_id int)
RETURNS TABLE
(
    instrument varchar(20),
    quantity bigint
)
AS $BODY$ 
DECLARE
    trader_ RECORD;
BEGIN
    SELECT * INTO trader_ FROM get_trader(trader_id);
    RETURN QUERY (SELECT instrument_template.short_name, 
                SUM(CASE WHEN depository.direction = 'input' then depository.quantity else 0 end) 
                - SUM(CASE WHEN depository.direction = 'output' then depository.quantity else 0 end) 
                        FROM account inner join depository on account.number = depository.account_number
                                    inner join instrument on depository.instrument_id = instrument.id
                                    inner join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                                    where account.trader_code is not null and account.trader_code = trader_.id
                                    GROUP BY instrument_template.short_name);
END;
$BODY$ 
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION movement_fund_hisory_by_acount_number(account_number int) 
RETURNS TABLE
(
    initiator varchar(100),
    description varchar(256),
    amount money,
    direction direction
)
AS $BODY$ 
DECLARE
    account_ RECORD; 
BEGIN
    SELECT * INTO account_ FROM get_account(account_number);
    RETURN QUERY (SELECT CASE WHEN broker_initiator_id is not null then broker.name else 
                         CASE WHEN trader_initiator_id is not null then trader.first_name else 'system' end end,
                         movement_fund.description, movement_fund.amount, movement_fund.direction
                            FROM movement_fund 
                            join account on movement_fund.account_id = account.number
                            left join broker on movement_fund.broker_initiator_id = broker.id
                            left join trader on movement_fund.trader_initiator_id = trader.id
                            where account_.number = account.number);
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION trade_history_by_date_interval(start_period timestamptz, end_period timestamptz, broker_id int) 
RETURNS TABLE 
(
    instrument varchar(20),
    bid_initiator text,
    offer_initiator text,
    price money,
    quantity int,
    broker_who_control varchar(100)
)
AS $BODY$
DECLARE
    broker_ RECORD; 
BEGIN
    SELECT * into broker_ FROM get_broker(broker_id);
    RETURN QUERY (SELECT instrument_template.short_name, 
    CASE WHEN bid_a.trader_code is null 
        THEN (SELECT broker.name || ' (broker)' from broker where broker.id = bid_a.broker_code)
        ELSE (SELECT trader.first_name || ' (trader)' from trader where trader.id = bid_a.trader_code)
    END,
    CASE WHEN offer_a.trader_code is null 
        THEN (SELECT broker.name || ' (broker)' from broker where broker.id = offer_a.broker_code)
        ELSE (SELECT trader.first_name || ' (trader)' from trader where trader.id = offer_a.trader_code) 
    END,
    trade.price, trade.quantity, broker_.name
    FROM trade join order_ bid on trade.bid_order_id  = bid.id
                join order_ offer on trade.offer_order_id = offer.id
                join account bid_a on bid.account = bid_a.number
                join account offer_a on offer.account = offer_a.number
                join instrument on bid.instrument_id = instrument.id
                join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                where trade.trade_date >= start_period and trade.trade_date <= end_period and bid_a.broker_code = broker_.id or offer_a.broker_code = broker_id
    );
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION all_active_orders_on_market(instrument_id int) 
RETURNS TABLE(
    market varchar(10),
    instrument varchar(20),
    status order_status,
    side order_side,
    price money,
    quantity int,
    traded_quantity int,
    leaves_quantity int
)
AS $BODY$ 
DECLARE
    instrument_ RECORD; 
BEGIN
    SELECT * INTO instrument_ from get_instrument(instrument_id);
    RETURN QUERY (SELECT market.name, instrument_template.short_name, order_.status, order_.side, order_.price, order_.quantity, order_.traded_qty, order_.leaves_qty
                    from instrument join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                        join order_ on order_.instrument_id = instrument.id
                        join market on instrument.market_id = market.id
                        where order_.status != 'filled' and order_.status != 'cancelled' and instrument.id = instrument_.id
    
    );
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION trade_history_by_account_number(number int) 
RETURNS TABLE(
    instrument varchar(20),
    bid_initiator text,
    offer_initiator text,
    price money,
    quantity int
)
AS $BODY$ 
DECLARE
    account_ RECORD; 
BEGIN
    SELECT * INTO account_ from get_account(number);
    RETURN QUERY (SELECT instrument_template.short_name, 
    CASE WHEN bid_a.trader_code is null 
        THEN (SELECT broker.name || ' (broker)' from broker where broker.id = bid_a.broker_code)
        ELSE (SELECT trader.first_name || ' (trader)' from trader where trader.id = bid_a.trader_code)
    END,
    CASE WHEN offer_a.trader_code is null 
        THEN (SELECT broker.name || ' (broker)' from broker where broker.id = offer_a.broker_code)
        ELSE (SELECT trader.first_name || ' (trader)' from trader where trader.id = offer_a.trader_code) 
    END,
    trade.price, trade.quantity
    FROM trade join order_ bid on trade.bid_order_id  = bid.id
                join order_ offer on trade.offer_order_id = offer.id
                join account bid_a on bid.account = bid_a.number
                join account offer_a on offer.account = offer_a.number
                join instrument on bid.instrument_id = instrument.id
                join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                where bid_a.number = account_.number or offer_a.number = account_.number
    );
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION commision_income_by_broker_id(broker_id int) 
RETURNS TABLE 
(
    broker varchar(100),
    instrument varchar(20),
    commision_income money,
    currency varchar(10)
)
AS $BODY$ 
DECLARE
    broker_ RECORD; 
BEGIN
    SELECT * into broker_ from get_broker(broker_id);

    RETURN QUERY (select broker_.name, instrument_template.short_name, SUM(
            CASE WHEN bid_a.broker_code = broker_.id and offer_a.broker_code = broker_.id
                THEN broker_.commission*bid.price*2
                ELSE broker_.commission*bid.price END
            ), (SELECT currency.currency_name from currency where currency.id = bid_a.type_currency)
            from trade t join order_ bid on t.bid_order_id = bid.id
                    join order_ offer on t.offer_order_id = offer.id
                    join account bid_a on bid.account = bid_a.number
                    join account offer_a on offer.account = offer_a.number
                    join instrument on bid.instrument_id = instrument.id
                    join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                    where (bid_a.trader_code is not null and bid_a.broker_code = broker_.id) or (offer_a.trader_code is not null and offer_a.broker_code = broker_.id) 
                    GROUP BY instrument_template.short_name, bid_a.type_currency 
);
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION get_order_statuses_by_trader_id(trader_id int) 
RETURNS TABLE
(
    trader varchar(100),
    status order_status,
    traded_qty int,
    leaves_qty int,
    instrument varchar(20)
)
AS $BODY$ 
DECLARE
    trader_ RECORD; 
BEGIN
    SELECT * into trader_ from get_trader(trader_id);

    RETURN QUERY (Select trader_.first_name, order_.status, order_.traded_qty, order_.leaves_qty, instrument_template.short_name
                    from order_ join account on account.number = order_.account
                    join instrument on instrument.id = order_.instrument_id
                    join instrument_template on instrument_template.instrument_code = instrument.instrument_template_code
                    where account.trader_code = trader_.id  
    );
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION total_trading_volume_by_instrument_id(instrument_id int) 
RETURNS TABLE
(
    instrument varchar(20),
    total_lot_movement bigint
)
AS $BODY$ 
DECLARE
    instrument_ RECORD; 
BEGIN
    SELECT * into instrument_ from get_instrument(instrument_id);

    RETURN QUERY (SELECT instrument_template.short_name, SUM(trade.quantity/instrument.lot_size) 
                    from instrument join instrument_template on instrument_template.instrument_code = instrument.instrument_template_code
                                    join order_ on instrument.id = order_.instrument_id
                                    join trade on order_.id = trade.bid_order_id
                                    where instrument.id = instrument_.id
                                    GROUP BY instrument_template.short_name
    );
END;
$BODY$ 
LANGUAGE plpgsql;  


CREATE OR REPLACE FUNCTION total_trading_volume_by_broker_id(broker_id int, start_date timestamptz, end_date timestamptz)
RETURNS TABLE
(
    trader varchar(100),
    instrument varchar(20),
    total_lot_movement bigint
)
AS $BODY$ 
DECLARE
    broker_ RECORD; 
BEGIN
    SELECT * into broker_ from get_broker(broker_id);

    RETURN QUERY (
        SELECT trader.first_name, instrument_template.short_name, SUM(trade.quantity/instrument.lot_size)
        from instrument join instrument_template on instrument_template.instrument_code = instrument.instrument_template_code
                                    join order_ on instrument.id = order_.instrument_id
                                    join trade on order_.id = trade.bid_order_id
                                    join account on order_.account = account.number
                                    join trader on account.trader_code = trader.id
                                    where account.broker_code = broker_.id and trade.trade_date >= start_date and trade.trade_date <= end_date
                                    group by trader.first_name, instrument_template.short_name, instrument.lot_size
    );
END;
$BODY$ 
LANGUAGE plpgsql;


CREATE OR REPLACE VIEW current_prices AS
    SELECT DISTINCT ON (1) o.instrument_id AS instrument, o.price FROM trade t JOIN order_ o ON bid_order_id = o.id
    ORDER BY 1, t.trade_date DESC;

CREATE OR REPLACE VIEW instrument_volume AS 
    SELECT it.short_name sn, 
    (CASE 
        WHEN SUM(t.quantity) > 0 THEN SUM(t.quantity)
        ELSE 0
    END) as volume 
    FROM instrument i 
            JOIN instrument_template it on i.instrument_template_code = it.instrument_code
            left JOIN order_ o on i.id = o.instrument_id
            left JOIN trade t on t.bid_order_id = o.id
            GROUP BY it.short_name;    
                              

CREATE OR REPLACE VIEW float_cash_in_trader_acounts AS
    SELECT mf.account_id AS account_number,
    SUM(CASE WHEN mf.direction = 'input' then mf.amount else 0::money end)
                - SUM(CASE WHEN mf.direction = 'output' then mf.amount else 0::money end) AS float_cash
    FROM movement_fund mf JOIN account a ON a.number = mf.account_id
    WHERE trader_initiator_id IS NULL AND initiator_type != 'trader' AND a.trader_code IS NOT NULL
    GROUP BY mf.account_id;

CREATE OR REPLACE VIEW clean_cash_in_trader_acounts AS
    SELECT mf.account_id AS account_number,
    SUM(CASE WHEN mf.direction = 'input' then mf.amount else 0::money end)
                - SUM(CASE WHEN mf.direction = 'output' then mf.amount else 0::money end) + fcta.float_cash AS clean_cash
    FROM movement_fund mf JOIN float_cash_in_trader_acounts fcta ON mf.account_id = fcta.account_number
    WHERE trader_initiator_id IS NOT NULL AND initiator_type = 'trader'
    GROUP BY mf.account_id, fcta.float_cash;

CREATE OR REPLACE VIEW quantity_instrument_on_accounts AS
    SELECT account.number as account_number,
            instrument.id as instrument,
                SUM(CASE WHEN depository.direction = 'input' then depository.quantity else 0 end)
                - SUM(CASE WHEN depository.direction = 'output' then depository.quantity else 0 end) AS quantity
    FROM account join depository on account.number = depository.account_number
                 join instrument on depository.instrument_id = instrument.id
                 GROUP BY account.number, instrument.id;

CREATE OR REPLACE FUNCTION total_income_for_account(account_number int)
RETURNS TABLE
(
    income money
)
AS $BODY$
DECLARE
    account RECORD;
BEGIN
     SELECT * INTO account FROM get_account($1);

     IF account.trader_code IS NULL THEN
          RAISE EXCEPTION 'Account % not belong to trader', account_number;
     END IF;

     RETURN QUERY (
        SELECT SUM(qia.quantity * cp.price) + fcta.float_cash AS income
        FROM quantity_instrument_on_accounts qia JOIN current_prices cp ON qia.instrument = cp.instrument
        JOIN float_cash_in_trader_acounts fcta ON fcta.account_number = qia.account_number
        WHERE qia.account_number = $1
        GROUP BY qia.account_number, fcta.float_cash
    );
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_income_for_trader(trader_id int)
RETURNS TABLE
(
    income money
)
AS $BODY$
BEGIN
     RETURN QUERY (
        SELECT SUM(qia.quantity * cp.price) + fcta.float_cash AS income
        FROM quantity_instrument_on_accounts qia JOIN current_prices cp ON qia.instrument = cp.instrument
        JOIN float_cash_in_trader_acounts fcta ON fcta.account_number = qia.account_number
        JOIN account a ON a.trader_code = trader_id AND qia.account_number = a.number
        GROUP BY a.trader_code, fcta.float_cash
    );
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_instruments_on_account_clients(broker_id int)
RETURNS TABLE
(
    instrument int,
    quantity bigint
)
AS $BODY$
BEGIN
     RETURN QUERY (
        SELECT qia.instrument,
        SUM(qia.quantity::bigint)::bigint as quantity
        FROM account a JOIN quantity_instrument_on_accounts qia ON qia.account_number = a.number
        WHERE a.broker_code = broker_id AND a.trader_code IS NOT NULL
        GROUP BY qia.instrument
    );
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION risk_of_clients(broker_id int)
RETURNS TABLE
(
    trader varchar(46),
    risk varchar(10)
)
AS $BODY$
BEGIN
     RETURN QUERY (
         SELECT
            coef.trader,
            (CASE
                    WHEN coef > 2 OR coef < 0 THEN 'ZERO'
                    WHEN coef < 2 AND coef > 1 THEN 'STABLE'
                    WHEN coef < 1 AND coef > 0.75 THEN 'MODERATE'
                    WHEN coef < 0.75 THEN 'DANGER'
             END)::varchar(10) AS risk
         FROM (
            SELECT CONCAT(t.first_name, ' ', t.last_name)::varchar(46) AS trader,
            (-1) * ((SUM(qia.quantity * cp.price) + ccta.clean_cash) / fcta.float_cash) AS coef
            FROM account a JOIN quantity_instrument_on_accounts qia ON qia.account_number = a.number
            JOIN current_prices cp ON qia.instrument = cp.instrument
            JOIN float_cash_in_trader_acounts fcta ON fcta.account_number = qia.account_number
            JOIN clean_cash_in_trader_acounts ccta ON ccta.account_number = qia.account_number
            JOIN trader t ON t.id = a.trader_code
            WHERE a.broker_code = broker_id AND a.trader_code IS NOT NULL
            GROUP BY a.trader_code, t.first_name, t.last_name, fcta.float_cash, ccta.clean_cash
        ) AS coef
    );
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calc_instrument_growth_coef(start_period timestamptz, end_period timestamptz, start_price money, end_price money)
RETURNS FLOAT
AS $BODY$
DECLARE
    change_in_persent int;
    duration_in_days int;
    a float := 70 /1200;
    b float := 660 / 605;
BEGIN
    change_in_persent := end_price / (start_price / 100) - 100;
    duration_in_days := EXTRACT(epoch FROM end_period - start_period) / (60 * 60 * 24);

    IF duration_in_days <= 0 THEN
        duration_in_days := 1;
    END IF;

    RETURN change_in_persent / duration_in_days * (a * duration_in_days + b);
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION instruments_analitic(start_period timestamptz, end_period timestamptz,
abnormal_share int, perfect_share int, normal_share int, low_share int, staging_share int,
bond_abnormal_upper int, bond_abnormal_lower int, bond_overvalued int, bond_normal int)
RETURNS TABLE
(
    instrument varchar(20),
    market varchar(60),
    instrument_type instrument_type,
    start_price money,
    end_price money,
    change_in_persent float,
    status varchar(20)
)
AS $BODY$
BEGIN
     RETURN QUERY (
     SELECT
            base.instrument,
            base.market,
            base.instrument_type,
            base.start_price,
            base.end_price,
            base.change_in_persent,
            (CASE
                WHEN base.instrument_type = 'share' THEN
                    (CASE
                        WHEN base.growth_coef > abnormal_share  THEN 'ABNORMAL'
                        WHEN base.growth_coef <= abnormal_share AND  base.growth_coef >= perfect_share THEN 'PERFECT'
                        WHEN base.growth_coef < perfect_share AND base.growth_coef >= normal_share THEN 'NORMAL'
                        WHEN base.growth_coef < normal_share AND base.growth_coef >= low_share THEN 'LOW'
                        WHEN base.growth_coef < low_share AND base.growth_coef >= staging_share THEN 'STAGING'
                        WHEN base.growth_coef < staging_share THEN 'HIGH_STAGING'
                    END)
                WHEN  base.instrument_type = 'bond' THEN
                     (CASE
                        WHEN base.change_in_persent > bond_abnormal_upper or base.change_in_persent < bond_abnormal_lower THEN 'ABNORMAL'
                        WHEN base.change_in_persent > bond_overvalued AND base.change_in_persent <= bond_abnormal_upper THEN 'OVERVALUED'
                        WHEN base.change_in_persent <= bond_overvalued AND base.change_in_persent >= bond_normal THEN 'NORMAL'
                        WHEN base.change_in_persent < bond_normal AND base.change_in_persent >= bond_abnormal_lower THEN 'STAGING'
                     END)
             END)::varchar(20) AS status
     FROM (
     SELECT
            se.instrument,
            se.market,
            se.instrument_type,
            se.start_price,
            se.end_price,
            se.end_price / (se.start_price / 100) - 100 as change_in_persent,
            calc_instrument_growth_coef(start_period, end_period, se.start_price, se.end_price) AS growth_coef
         FROM (
             SELECT
             it.short_name as instrument,
             m.name as market,
             it.instrument_type,
             (SELECT t.price FROM order_ o JOIN trade t ON o.id = t.bid_order_id OR O.id = offer_order_id
             WHERE t.trade_date >= start_period and t.trade_date <= end_period and inst.id = o.instrument_id
             ORDER BY t.trade_date ASC, t.price ASC
             LIMIT 1) as start_price,
             (SELECT t.price FROM order_ o JOIN trade t ON o.id = t.bid_order_id OR O.id = offer_order_id
             WHERE t.trade_date >= start_period and t.trade_date <= end_period and inst.id = o.instrument_id
             ORDER BY t.trade_date DESC, t.price DESC
             LIMIT 1) as end_price
             FROM instrument inst JOIN instrument_template it ON inst.instrument_template_code = it.instrument_code
             JOIN market m ON m.id = inst.market_id
             GROUP BY inst.id, inst.market_id, it.short_name, m.name, it.instrument_type
         ) as se
        ) as base);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rating_of_instruments(super_popular numeric, popular numeric, pre_popular numeric, moderate numeric)
RETURNS TABLE
(
    instrument varchar(100),
    precent_ numeric,
    rating VARCHAR(10)
)
AS $BODY$
BEGIN
    RETURN QUERY (
        SELECT sn as instrument, precent,
        (CASE
            WHEN precent > super_popular THEN 'SUPER POPULAR'
            WHEN precent < super_popular AND precent > popular THEN 'POPULAR'
            WHEN precent < popular AND precent > pre_popular THEN 'PRE-POPULAR'
            WHEN precent < pre_popular AND precent > moderate THEN 'MODERATE'
            WHEN precent < moderate THEN 'DARK HORSE'
        END)::varchar(10) as rating
        FROM
        (
            SELECT sn, (volume/(SELECT SUM(volume) from instrument_volume))*100 as precent
            FROM instrument_volume
        ) as volume_prеcent
        ORDER BY precent
    );
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION traders_rating(broker_id int, large_profiter numeric, moderate numeric) 
RETURNS TABLE 
(
    trader varchar(100),
    rating varchar(30)
)
AS $BODY$ 
DECLARE
    broker_ RECORD; 
BEGIN
    SELECT * into broker_ from get_broker(broker_id);

    RETURN QUERY (
        SELECT trader_name, 
        (CASE
            WHEN procent > large_profiter THEN 'Large profiter'
            WHEN procent <= large_profiter and procent > moderate THEN 'Moderate profiter'
            WHEN procent <= moderate THEN 'Dead weight'
        END)::varchar(30) as rating
        FROM
        (SELECT trader_name, commission/(SELECT SUM(commission) from commissions where broker_.name = broker_name)*100 as procent
        FROM commissions 
        where broker_.name = broker_name) as commission_procent
    );
END;
$BODY$ 
LANGUAGE plpgsql; 

CREATE OR REPLACE VIEW commissions AS
(
    SELECT tr.first_name as trader_name, b.name as broker_name, 
    SUM(
        (bid.price*bid.quantity)*b.commission
    ) as commission
    FROM
    trade t join order_ bid on t.bid_order_id = bid.id
                    join order_ offer on t.offer_order_id = offer.id
                    join account bid_a on bid.account = bid_a.number
                    join account offer_a on offer.account = offer_a.number
                    join instrument on bid.instrument_id = instrument.id
                    join instrument_template on instrument.instrument_template_code = instrument_template.instrument_code
                    inner join broker b on bid_a.broker_code = b.id or offer_a.broker_code = b.id
                    inner join trader tr on bid_a.trader_code = tr.id or offer_a.trader_code = tr.id
                    GROUP BY tr.first_name, b.name, b.commission::numeric(7,5)
);

-- Market volume (MV) - sum of trades
-- Instruments on market (IM)
-- Stock players (SP)
-- Trades per instrument (TPI) = MV/IM
-- Trades per player (TPP) = TPI / SP
-- TPP > 100 Must to play stock
-- TPP < 100 and TPP > 50 Default Stock
-- TPP < 50 andd TPP > 25 You should play there if and only if there is
-- an instrument(s) that traded only on this stock
-- TPP < 25 This stock exchange is dying, you should not trade here.
CREATE OR REPLACE function market_analitic(index1 numeric, index2 numeric, index3 numeric)
RETURNS TABLE
(
    market varchar(100),
    index float,
    rating VARCHAR(180)
)
AS $BODY$
BEGIN
    RETURN QUERY (
        SELECT index_calc.name, index_calc.index::float,
        (CASE 
            WHEN (index_calc.index > index1) THEN 'Must to play on the stock'
            WHEN (index_calc.index < index1 and index_calc.index >= index2) THEN 'Default stock'
            WHEN (index_calc.index < index2 and index_calc.index > index3) THEN 'You should play there if and only if you need to buy specific instrument'
            WHEN (index_calc.index < index3) THEN 'This stock exchange is dying.'
        END)::varchar(180) as rating
        FROM 
        (
            SELECT mv.name, volume/(instrument_count*players_volume) as index 
            FROM market_volumes mv inner join instruments_per_market ipm on mv.name = ipm.name
            inner join players_on_market pon on ipm.name = pon.name
        ) as index_calc
    );
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE VIEW market_volumes AS
(
    SELECT m.name, COUNT(t.match_id) as volume 
    FROM
    market m inner join instrument i on m.id = i.market_id
    inner join order_ o on i.id = o.instrument_id
    inner join trade t on t.bid_order_id = o.id
    GROUP BY m.name
);

CREATE OR REPLACE VIEW instruments_per_market AS
(
    SELECT m.name, COUNT(i.id) as instrument_count 
    FROM
    market m inner join instrument i on m.id = i.market_id
    GROUP by m.name
);

CREATE OR REPLACE VIEW players_on_market AS 
(
    SELECT m.name, SUM(1+
    (SELECT COUNT(t.id) from trader t inner join account a1 on a1.trader_code = t.id
    where a1.broker_code = a.broker_code)) as players_volume 
    FROM
    market m inner join market_broker mb on mb.market_id = m.id
    inner join account a on mb.account_id = a.number
    GROUP BY m.name
);