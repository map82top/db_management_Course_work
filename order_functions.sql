CREATE OR REPLACE FUNCTION cancel_order(order_id bigint)
    RETURNS void AS
$BODY$
DECLARE
    order_ RECORD;
BEGIN
    SELECT * INTO order_ FROM get_order(order_id);

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
    all_offer_quantity bigint;
BEGIN
     SELECT * INTO account FROM get_account(account_id);

     SELECT * INTO instrument FROM get_instrument(instrument_id);

     IF quantity % instrument.lot_size != 0 THEN
        RAISE EXCEPTION 'Order`s quantity not multiple to lot size instrument';
     END IF;

     SELECT * INTO market FROM get_market(instrument.market_id);

     IF market.status = 'close' THEN
        RAISE EXCEPTION 'Market is closed';
     END IF;

     IF market.currency != account.type_currency THEN
        RAISE EXCEPTION 'Currency market not equal currency account';
     END IF;

     SELECT * INTO broker FROM get_broker(account.broker_code);

     IF EXISTS(SELECT * FROM order_ o JOIN account a ON a.number = o.account WHERE a.number = account.number AND o.side != create_order.side and o.status != 'filled') THEN
        RAISE EXCEPTION 'Not available active bid and offer orders from one account in the same time';
     END IF;

     SELECT SUM(o.price * o.quantity + o.price * o.quantity * broker.commission), SUM(o.quantity) INTO cost_over_orders, all_offer_quantity
        FROM order_ o JOIN account a ON a.number = o.account WHERE a.number = account.number and o.side = 'offer' and o.status != 'filled';

      raise notice 'Value %', account.number;
     IF all_offer_quantity + quantity > (SELECT count_instrument_on_account(instrument.id, account.number)) THEN
           RAISE EXCEPTION 'Not available selling more orders then has in account depositary';
     END IF;

     IF account.type_account = 'debit' THEN
        IF price * quantity  + price * quantity * broker.commission + cost_over_orders > account.current_funds THEN
            RAISE EXCEPTION 'Account`s funds is exceeded';
        END IF;
     END IF;

     IF account.trader_code IS NOT NULL THEN
        SELECT * INTO trader FROM get_trader(account.trader_code);
     END IF;

     SELECT * INTO instrument_template FROM get_instrument_template(instrument.instrument_template_code);

     IF instrument_template.emission_volume < quantity THEN
        RAISE EXCEPTION 'Order`s quantity can`t be more when an emission volume of instrument';
     END IF;

     SELECT * INTO market_broker FROM get_market_broker(market.id, broker.id);
     SELECT * INTO broker_market_account FROM get_account(market_broker.account_id);

     INSERT INTO order_ (place_time, price, quantity, leaves_qty, side, account, instrument_id)
         VALUES(CURRENT_TIMESTAMP, price, quantity, quantity, side, account.number, instrument_id);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trade_order(order_id bigint, quantity_ int)
    RETURNS void AS
$BODY$
DECLARE
    order_ RECORD;
    new_status order_status;
BEGIN
     SELECT * INTO order_ FROM get_order(order_id);

     IF order_.traded_qty + quantity_ = order_.quantity THEN
        new_status = 'filled';
     ELSE
        new_status = 'partfilled';
     END IF;

     UPDATE order_ o
        SET traded_qty = traded_qty + quantity_,
            leaves_qty = leaves_qty - quantity_,
            status = new_status
        WHERE
            o.id = order_id;
END;
$BODY$
LANGUAGE plpgsql;