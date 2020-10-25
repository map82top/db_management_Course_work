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
                SUM(CASE WHEN depository.direction = 'input' then depository.quantity else 0 end) 
                - SUM(CASE WHEN depository.direction = 'output' then depository.quantity else 0 end)
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