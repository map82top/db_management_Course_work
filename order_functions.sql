CREATE OR REPLACE FUNCTION cancel_order(order_id bigint)
    RETURNS void AS
$BODY$
DECLARE
    order_ RECORD;
BEGIN
    SELECT * INTO order_ FROM order_ o WHERE o.id = order_id;

     IF order_ IS NULL THEN
        RAISE EXCEPTION 'Order not found';
     END IF;

     IF order_.cancel_time IS NOT NULL OR order_.status = 'cancelled' THEN
        RAISE EXCEPTION 'Order is cancelled';
     END IF;

     IF order_.status != 'filled' THEN
        RAISE EXCEPTION 'Order is filled';
     END IF;

     UPDATE order_ o SET o.cancel_time = CURRENT_TIMESTAMP, o.status = 'cancelled' WHERE o.id = order_id;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_order(account_id int, instrument_id int, price money, quantity int, side order_side)
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    instrument RECORD;
    market RECORD;
    broker RECORD;
    trader RECORD;
    instrument_template RECORD;
    market_broker RECORD;
    cost_over_orders money;
    broker_market_account RECORD;
BEGIN
    SELECT * INTO account FROM account ac WHERE ac.number = account_id;

     IF account IS NULL THEN
        RAISE EXCEPTION 'Account not found';
     END IF;

     IF account.deleted_time THEN
        RAISE EXCEPTION 'Account is deleted';
     END IF;

    SELECT * INTO instrument FROM instrument inst WHERE inst.id = instrument_id;

     IF instrument IS NULL THEN
        RAISE EXCEPTION 'Instrument not found';
     END IF;

     IF instrument.deleted_time THEN
        RAISE EXCEPTION 'Instrument is deleted';
     END IF;

     IF quantity % instrument.lot_size != 0 THEN
        RAISE EXCEPTION 'Order`s quantity not multiple to lot size instrument';
     END IF;

    SELECT * INTO market FROM market m WHERE m.id = instrument.market_id;

     IF market IS NULL THEN
        RAISE EXCEPTION 'Market not found';
     END IF;

     IF market.deleted_time THEN
        RAISE EXCEPTION 'Market is deleted';
     END IF;

     IF market.status = 'close' THEN
        RAISE EXCEPTION 'Market is closed';
     END IF;

     IF market.currency != account.type_currency THEN
        RAISE EXCEPTION 'Currency market not equal currency account';
     END IF;

     SELECT * INTO broker FROM broker b WHERE b.id = account.broker_code;

     IF broker IS NULL THEN
        RAISE EXCEPTION 'Broker not found';
     END IF;

     IF broker.deleted_time THEN
        RAISE EXCEPTION 'Broker is deleted';
     END IF;

     SELECT SUM(o.price * o.quantity + o.price * o.quantity * broker.comission) INTO cost_over_orders
        FROM order_ o JOIN account a ON a.number = o.account WHERE a.number = account.number;


     IF account.type_account = 'debit' THEN
        IF price * quantity  + price * quantity * broker.commission + cost_over_orders > current_funds THEN
            RAISE EXCEPTION 'Account`s funds is exceeded';
        END IF;
     END IF;

     IF account.trader_code IS NOT NULL THEN
        SELECT * INTO trader FROM trader t WHERE t.id = account.trader_code;

        IF trader IS NULL THEN
            RAISE EXCEPTION 'Trader not found';
        END IF;

        IF trader.deleted_time THEN
           RAISE EXCEPTION 'Trader is deleted';
        END IF;
     END IF;

     SELECT * INTO instrument_template FROM instrument_template it WHERE it.insrument_code = instrument.instrument_template_code;

     IF instrument_template IS NULL THEN
        RAISE EXCEPTION 'Instrument template not found';
     END IF;

     IF instrument_template.deleted_time THEN
        RAISE EXCEPTION 'Instrument template is deleted';
     END IF;

     IF instrument_template.emission_volume < quantity THEN
        RAISE EXCEPTION 'Order`s quantity can`t be more when an emission volume of instrument';
     END IF;

     SELECT * INTO market_broker FROM market_broker mb WHERE mb.broker_id = broker.id AND market.id = mb.market_id;

     IF market_broker IS NULL THEN
        RAISE EXCEPTION 'Broker not assign to order`s market';
     END IF;

    SELECT * INTO broker_market_account FROM account a WHERE a.number = market_broker.account_id;

    IF broker_market_account IS NULL THEN
        RAISE EXCEPTION 'Broker market account not found';
    END IF;

    IF broker_market_account.deleted_time THEN
       RAISE EXCEPTION 'Broker market account is deleted';
    END IF;

    INSERT INTO order_ (place_time, price, quantity, leaves_qty, side, account, instrument_id)
        VALUES(CURRENT_TIMESTAMP, price, quantity, quantity, side, account, instrument_id);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trade_order(order_id bigint, quantity int)
    RETURNS void AS
$BODY$
DECLARE
    order_ RECORD;
    new_status order_status;
BEGIN
    SELECT * INTO order_ FROM order_ o WHERE o.id = order_id;

     IF order_ IS NULL THEN
        RAISE EXCEPTION 'Order not found';
     END IF;

     IF order_.cancel_time IS NOT NULL OR order_.status = 'cancelled' THEN
        RAISE EXCEPTION 'Order is cancelled';
     END IF;

     IF order_.status != 'filled' THEN
        RAISE EXCEPTION 'Order is filled';
     END IF;

     IF traded_qty + quantity = order_.quantity THEN
        new_status = 'filled';
     ELSE
        new_status = 'partfilled';
     END IF;

     UPDATE order_ o
        SET traded_qty = traded_qty + quantity,
            leaves_qty = leaves_qty - quantity,
            status = new_status
        WHERE
            o.id = order_id;
END;
$BODY$
LANGUAGE plpgsql;