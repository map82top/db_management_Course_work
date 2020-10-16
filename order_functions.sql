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

     IF o.cancel_time IS NULL AND o.status != 'cancelled' AND o.status != 'filled' THEN
        RAISE EXCEPTION 'Order is canceled';
     END IF;

     UPDATE order_ o SET o.cancel_time = CURRENT_TIMESTAMP, o.status = 'cancelled' WHERE o.id = order_id;
END;
$BODY$
    LANGUAGE plpgsql;