CREATE OR REPLACE FUNCTION create_trader(bid_order_id bigint, offer_order_id bigint, quantity int)
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
    SELECT * INTO bid_order FROM get_order(bid_order_id);
    SELECT * INTO offer_order FROM get_order(offer_order_id);

     IF offer_order.side = 'bid' AND bid_oder = 'bid' OR offer_order.side = 'offer' AND bid_oder = 'offer' THEN
        RAISE EXCEPTION 'Both orders is on same side';
     END IF;

     IF offer_order.price <> bid_price.price THEN
        RAISE EXCEPTION 'Price of traded orders isn`t equal';
     END IF;

     IF offer_order.instrument_id <> bid_price.instrument_id THEN
        RAISE EXCEPTION 'Instrument of traded orders not equal';
     END IF;

     IF offer_order.account <> bid_price.account THEN
        RAISE EXCEPTION 'Self trading not available';
     END IF;

     IF offer_order.leaves_qty < quantity THEN
        RAISE EXCEPTION 'Available quantity on sell order is less then trade quantity';
     END IF;

      IF bid_order.leaves_qty < quantity THEN
        RAISE EXCEPTION 'Available quantity on bid order is less then trade quantity';
     END IF;

     SELECT * INTO bid_account FROM account(bid_order.account);
     SELECT * INTO offer_account FROM get_account(offer_order.account);

     SELECT * INTO instrument FROM get_instrument(offer_order.instrument_);

     IF quantity % instrument.lot_size != 0 THEN
        RAISE EXCEPTION 'Traded quantity not multiple to lot size instrument';
     END IF;

     SELECT * INTO market FROM get_market(instrument.market_id);

     IF market.status = 'close' THEN
        RAISE EXCEPTION 'Market is closed';
     END IF;

     IF market.currency != offer_account.type_currency THEN
        RAISE EXCEPTION 'Currency market not equal currency offer account';
     END IF;

     IF market.currency != bid_account.type_currency THEN
        RAISE EXCEPTION 'Currency market not equal currency bid account';
     END IF;

     SELECT * INTO instrument_template FROM get_instrument_template(instrument.instrument_template_code);

     IF instrument_template.emission_volume < quantity THEN
        RAISE EXCEPTION 'Order`s quantity can`t be more when an emission volume of instrument';
     END IF;

     SELECT * INTO bid_broker FROM get_broker(bid_account.broker_code);
     SELECT * INTO offer_broker FROM  get_broker(offer_account.broker_code);

     SELECT * INTO bid_market_broker FROM get_market_broker(market.id, bid_broker.id);
     SELECT * INTO bid_broker_account FROM get_account(bid_market_broker.account_id);

     SELECT * INTO offer_broker_account FROM get_market_broker(market.id, offer_broker.id);
     SELECT * INTO offer_market_broker FROM get_broker(offer_broker_account.account_id);

     PERFORM trade_order(bid_order, quantity);
     PERFORM trade_order(offer_order, quantity);

    IF bid_account.trader_code IS NOT NULL THEN
         SELECT * INTO bid_trader FROM get_trader(bid_account.trader_code);

         PERFORM make_movement_fund(bid_order.price * quantity, 'output', NULL, 'system', bid_account.number, 'buying ' + instrument_template.short_name);
         PERFORM make_movement_fund(bid_order.price * quantity * bid_broker.commission, 'output', NULL, 'system', bid_account.number, 'broker commission per buying ' + instrument_template.short_name);
         PERFORM make_movement_fund(bid_order.price * quantity * bid_broker.commission, 'input', NULL, 'system', bid_broker_account.number,
            'commission per buying ' + instrument_template.short_name + ' trader: ' + bid_trader.first_name + ' ' + bid_trader.last_name);
    ELSE
        PERFORM make_movement_fund(bid_order.price * quantity, 'output', NULL, 'system', bid_broker_account.number, 'selling ' + instrument_template.short_name);
    END IF;

    IF offer_account.trader_code IS NOT NULL THEN
         SELECT * INTO offer_trader FROM get_trader(offer_account.trader_code);

         PERFORM make_movement_fund(offer_order.price * quantity, 'input', NULL, 'system', offer_account.number, 'selling ' + instrument_template.short_name);
         PERFORM make_movement_fund(offer_order.price * quantity * offer_broker.commision, 'output', NULL, 'system', offer_account.number, 'broker commission per selling ' + instrument_template.short_name);
         PERFORM make_movement_fund(offer_order.price * quantity * offer_broker.commission, 'input', NULL, 'system', offer_broker_account.number,
            'commission per selling ' + instrument_template.short_name + ' trader: ' + offer_trader.first_name + ' ' + offer_trader.last_name);
    ELSE
        PERFORM make_movement_fund(offer_order.price * quantity, 'input', NULL, 'system', offer_broker_account.number, 'selling ' + instrument_template.short_name);
    END IF;

     INSERT INTO depository (price, quantity, direction, instrument_id, account_number) VALUES(bid_order.price, quantity, 'input', bid_order.instrument_id, bid_account.number);
     INSERT INTO depository (price, quantity, direction, instrument_id, account_number) VALUES(offer_order.price, quantity, 'output', offer_order.instrument_id, offer_account.number);

     INSERT INTO trade (price, quanity, buy_order_id, bid_order_id, offer_order_id, trade_date)
        VALUES(bid_order.price, quantity, bid_order_id, offer_order_id, CURRENT_TIMESTAMP);
END;
$BODY$
    LANGUAGE plpgsql;