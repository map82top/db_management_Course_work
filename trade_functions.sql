CREATE OR REPLACE FUNCTION create_trade(bid_order_id bigint, offer_order_id bigint, quantity int)
    RETURNS void AS
$BODY$
DECLARE
    bid_order RECORD;
    offer_order RECORD;
    bid_account RECORD;
    offer_account RECORD;

    bid_trader RECORD;
    offer_trader RECORD;
    bid_broker RECORD;
    offer_broker RECORD;

    bid_market_broker RECORD;
    offer_market_broker RECORD;

    offer_broker_account RECORD;
    bid_broker_account RECORD;

    instrument_template RECORD;
    instrument RECORD;
    market RECORD;

BEGIN
    SELECT * INTO bid_order FROM order_ o WHERE o.id = bid_order_id;

     IF bid_order IS NULL THEN
        RAISE EXCEPTION 'Order not found';
     END IF;

     IF bid_order.cancel_time IS NOT NULL OR bid_order.status = 'cancelled' THEN
        RAISE EXCEPTION 'Order is cancelled';
     END IF;

     IF bid_order.status = 'filled' THEN
        RAISE EXCEPTION 'Order is filled';
     END IF;

     SELECT * INTO offer_order FROM order_ o WHERE o.id = offer_order_id;

     IF offer_order IS NULL THEN
        RAISE EXCEPTION 'Order not found';
     END IF;

     IF offer_order.cancel_time IS NOT NULL OR offer_order.status = 'cancelled' THEN
        RAISE EXCEPTION 'Order is cancelled';
     END IF;

     IF offer_order.status = 'filled' THEN
        RAISE EXCEPTION 'Order is filled';
     END IF;

     IF offer_order.side = 'bid' AND bid_order.side = 'bid' OR offer_order.side = 'offer' AND bid_order.side = 'offer' THEN
        RAISE EXCEPTION 'Both orders is on same side';
     END IF;

     IF offer_order.price <> bid_order.price THEN
        RAISE EXCEPTION 'Price of traded orders isn`t equal';
     END IF;

     IF offer_order.instrument_id <> bid_order.instrument_id THEN
        RAISE EXCEPTION 'Instrument of traded orders not equal';
     END IF;

     IF offer_order.account = bid_order.account THEN
        RAISE EXCEPTION 'Self trading not available';
     END IF;

     IF offer_order.leaves_qty < quantity THEN
        RAISE EXCEPTION 'Available quantity on sell order is less then trade quantity';
     END IF;

      IF bid_order.leaves_qty < quantity THEN
        RAISE EXCEPTION 'Available quantity on bid order is less then trade quantity';
     END IF;

     SELECT * INTO bid_account FROM account ac WHERE ac.number = bid_order.account;

     IF bid_account IS NULL THEN
        RAISE EXCEPTION 'Bid account not found';
     END IF;

     IF bid_account.deleted_time THEN
        RAISE EXCEPTION 'Bid account is deleted';
     END IF;

     SELECT * INTO offer_account FROM account ac WHERE ac.number = offer_order.account;

     IF offer_account IS NULL THEN
        RAISE EXCEPTION 'Bid account not found';
     END IF;

     IF offer_account.deleted_time THEN
        RAISE EXCEPTION 'Bid account is deleted';
     END IF;

     SELECT * INTO instrument FROM instrument inst WHERE inst.id = offer_order.instrument_id;

     IF instrument IS NULL THEN
        RAISE EXCEPTION 'Instrument not found';
     END IF;

     IF instrument.delete_date THEN
        RAISE EXCEPTION 'Instrument is deleted';
     END IF;

     IF quantity % instrument.lot_size != 0 THEN
        RAISE EXCEPTION 'Traded quantity not multiple to lot size instrument';
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

     IF market.currency != offer_account.type_currency THEN
        RAISE EXCEPTION 'Currency market not equal currency offer account';
     END IF;

     IF market.currency != bid_account.type_currency THEN
        RAISE EXCEPTION 'Currency market not equal currency bid account';
     END IF;

    SELECT * INTO instrument_template FROM instrument_template it WHERE it.instrument_code = instrument.instrument_template_code;

     IF instrument_template IS NULL THEN
        RAISE EXCEPTION 'Instrument template not found';
     END IF;

     IF instrument_template.delete_date THEN
        RAISE EXCEPTION 'Instrument template is deleted';
     END IF;

     IF instrument_template.emission_volume < quantity THEN
        RAISE EXCEPTION 'Order`s quantity can`t be more when an emission volume of instrument';
     END IF;

     SELECT * INTO bid_broker FROM broker b WHERE b.id = bid_account.broker_code;

     IF bid_broker IS NULL THEN
        RAISE EXCEPTION 'Bid broker not found';
     END IF;

     IF bid_account.deleted_time THEN
        RAISE EXCEPTION 'Bid broker is deleted';
     END IF;

     SELECT * INTO offer_broker FROM broker b WHERE b.id = offer_account.broker_code;

     IF bid_broker IS NULL THEN
        RAISE EXCEPTION 'Offer broker not found';
     END IF;

     IF bid_account.deleted_time THEN
        RAISE EXCEPTION 'Offer broker is deleted';
     END IF;

    SELECT * INTO bid_market_broker FROM market_broker mb WHERE mb.broker_id = bid_broker.id AND market.id = mb.market_id;

     IF bid_market_broker IS NULL THEN
        RAISE EXCEPTION 'Bid broker not assign to order`s market';
     END IF;

    SELECT * INTO offer_market_broker FROM market_broker mb WHERE mb.broker_id = offer_broker.id AND market.id = mb.market_id;

     IF offer_market_broker IS NULL THEN
        RAISE EXCEPTION 'Offer broker not assign to order`s market';
     END IF;

     SELECT * INTO bid_broker_account FROM account ac WHERE ac.number = bid_market_broker.account_id;

     IF bid_broker_account IS NULL THEN
        RAISE EXCEPTION 'Bid broker account not found';
     END IF;

     IF bid_broker_account.deleted_time THEN
        RAISE EXCEPTION 'Bid broker account is deleted';
     END IF;

     SELECT * INTO offer_broker_account FROM account ac WHERE ac.number = offer_market_broker.account_id;

     IF offer_broker_account IS NULL THEN
        RAISE EXCEPTION 'Offer broker account not found';
     END IF;

     IF offer_broker_account.deleted_time THEN
        RAISE EXCEPTION 'Offer broker account is deleted';
     END IF;

     PERFORM trade_order(bid_order.id, quantity);
     PERFORM trade_order(offer_order.id, quantity);

    IF bid_account.trader_code IS NOT NULL THEN
     SELECT * INTO bid_trader FROM trader t WHERE t.id = bid_account.trader_code;
        IF bid_trader IS NULL THEN
            RAISE EXCEPTION 'Bid trader not found';
        END IF;

        IF bid_trader.deleted_time THEN
           RAISE EXCEPTION 'Bid trader is deleted';
        END IF;
      raise notice 'Values % - % - %', bid_order.price, quantity, bid_broker.commission;
     PERFORM make_movement_fund(bid_order.price * quantity, 'output', NULL, 'system', bid_account.number, 'buying ' || instrument_template.short_name);
     PERFORM make_movement_fund(bid_order.price * quantity * bid_broker.commission, 'output', NULL, 'system', bid_account.number, 'broker commission per buying ' || instrument_template.short_name);
     PERFORM make_movement_fund(bid_order.price * quantity * bid_broker.commission, 'input', NULL, 'system', bid_broker_account.number,
        'commission per buying ' || instrument_template.short_name || ' trader: ' || bid_trader.first_name || ' ' || bid_trader.last_name);
    ELSE
     PERFORM make_movement_fund(bid_order.price * quantity, 'output', NULL, 'system', bid_broker_account.number, 'selling ' || instrument_template.short_name);
    END IF;

    IF offer_account.trader_code IS NOT NULL THEN
     SELECT * INTO offer_trader FROM trader t WHERE t.id = offer_account.trader_code;
        IF offer_trader IS NULL THEN
           RAISE EXCEPTION 'Offer trader not found';
        END IF;

        IF offer_trader.deleted_time THEN
            RAISE EXCEPTION 'Offer trader is deleted';
        END IF;

     PERFORM make_movement_fund(offer_order.price * quantity, 'input', NULL, 'system', offer_account.number, 'selling ' || instrument_template.short_name);
     PERFORM make_movement_fund(offer_order.price * quantity * offer_broker.commission, 'output', NULL, 'system', offer_account.number, 'broker commission per selling ' || instrument_template.short_name);
     PERFORM make_movement_fund(offer_order.price * quantity * offer_broker.commission, 'input', NULL, 'system', offer_broker_account.number,
        'commission per selling ' || instrument_template.short_name || ' trader: ' || offer_trader.first_name || ' ' || offer_trader.last_name);
    ELSE
     PERFORM make_movement_fund(offer_order.price * quantity, 'input', NULL, 'system', offer_broker_account.number, 'selling ' || instrument_template.short_name);
    END IF;


     INSERT INTO depository (price, quantity, direction, instrument_id, account_number) VALUES(bid_order.price, quantity, 'input', bid_order.instrument_id, bid_account.number);
     INSERT INTO depository (price, quantity, direction, instrument_id, account_number) VALUES(offer_order.price, quantity, 'output', offer_order.instrument_id, offer_account.number);


     INSERT INTO trade (price, quantity, bid_order_id, offer_order_id, trade_date)
        VALUES(bid_order.price, quantity, bid_order_id, offer_order_id, CURRENT_TIMESTAMP);
END;
$BODY$
    LANGUAGE plpgsql;