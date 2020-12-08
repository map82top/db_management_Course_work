CREATE OR REPLACE FUNCTION check_create_correct_order() RETURNS TRIGGER AS
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
    SELECT * INTO account FROM get_account(NEW.account);

    SELECT * INTO instrument FROM get_instrument(NEW.instrument_id);

    IF NEW.quantity % instrument.lot_size != 0 THEN
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

    IF EXISTS(SELECT * FROM order_ o JOIN account a ON a.number = o.account WHERE a.number = account.number AND o.side != NEW.side and o.status != 'filled') THEN
        RAISE EXCEPTION 'Not available active bid and offer orders from one account in the same time';
    END IF;

    SELECT SUM(o.price * o.quantity + o.price * o.quantity * broker.commission), SUM(o.quantity) INTO cost_over_orders, all_offer_quantity
    FROM order_ o JOIN account a ON a.number = o.account WHERE a.number = account.number and o.side = 'offer' and o.status != 'filled';

    IF all_offer_quantity + NEW.quantity > (SELECT count_instrument_on_account(instrument.id, account.number)) THEN
        RAISE EXCEPTION 'Not available selling more orders then has in account depositary';
    END IF;

     IF account.type_account = 'debit' THEN
        IF NEW.price * NEW.quantity  + NEW.price * NEW.quantity * broker.commission + cost_over_orders > account.current_funds THEN
            RAISE EXCEPTION 'Account`s funds is exceeded';
        END IF;
     END IF;

    IF account.trader_code IS NOT NULL THEN
        SELECT * INTO trader FROM get_trader(account.trader_code);
    END IF;

    SELECT * INTO instrument_template FROM get_instrument_template(instrument.instrument_template_code);

    IF instrument_template.emission_volume < NEW.quantity THEN
        RAISE EXCEPTION 'Order`s quantity can`t be more when an emission volume of instrument';
    END IF;

    SELECT * INTO market_broker FROM get_market_broker(market.id, broker.id);
    SELECT * INTO broker_market_account FROM get_account(market_broker.account_id);

    IF NEW.status != 'new' THEN
        RAISE EXCEPTION 'New order status must be new';
    END IF;

    IF NEW.place_time IS NULL THEN
        RAISE EXCEPTION 'New order place_time must be not null';
    END IF;

    IF NEW.cancel_time IS NOT NULL THEN
        RAISE EXCEPTION 'New order cancel time must be null';
    END IF;

    IF NEW.traded_qty != 0 THEN
        RAISE EXCEPTION 'New order traded_qty must be 0';
    END IF;

    IF NEW.quantity != NEW.leaves_qty THEN
            RAISE EXCEPTION 'New order leaves_qty must be equal neq order quantity';
    END IF;

    RETURN NEW;
END;

$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER check_create_correct_order_trigger
    BEFORE INSERT
    ON order_
    FOR EACH ROW
    EXECUTE PROCEDURE check_create_correct_order();