CLASS z_llenar_tablas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS Z_LLENAR_TABLAS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_travel     TYPE TABLE OF zdm_vuelos_dm,
          lt_reservas   TYPE TABLE OF zdm_reservas_dm,
          lt_suplemento TYPE TABLE OF zdm_suplementos.

    SELECT  travel_id       AS travel_id_vuelos,
            agency_id,
            customer_id,
            begin_date,
            end_date,
            booking_fee,
            total_price,
            currency_code,
            description,
            createdby       AS created_by,
            createdat       AS created_at,
            lastchangeDby   AS last_changed_by,
            lastchangeDat   AS    last_change_at
            FROM /dmo/travel INTO CORRESPONDING FIELDS OF TABLE @lt_travel UP TO 50 ROWS.

    SELECT  travel_id as travel_id_reservas,
            booking_id as booking_id_reserva,
            booking_date,
            customer_id,
            carrier_id,
            connection_id,
            flight_date,
            flight_price,
            currency_code
        FROM /dmo/booking
        FOR ALL ENTRIES IN @lt_travel
        WHERE travel_id EQ @lt_travel-travel_id_vuelos
        INTO CORRESPONDING FIELDS OF TABLE @lt_reservas.

    SELECT travel_id as travel_id_suplementos,
           booking_id as booking_id_suplemento,
           booking_supplement_id as suplemento_id,
           supplement_id,
           price         ,
           currency_code as currency
        FROM /dmo/book_suppl
        FOR ALL ENTRIES IN @lt_reservas
        WHERE travel_id EQ @lt_reservas-travel_id_reservas
        AND booking_id EQ @lt_reservas-booking_id_reserva
        INTO CORRESPONDING FIELDS OF TABLE @lt_suplemento.

*Eliminar datos para que no hayan datos duplicados si se ejecutan varios metodos
    DELETE FROM : zdm_vuelos_dm,
                  zdm_reservas_dm,
                  zdm_suplementos.

*Agregamos los datos las bases de datos.
    INSERT: zdm_vuelos_dm   FROM TABLE @lt_travel,
            zdm_reservas_dm FROM TABLE @lt_reservas,
            zdm_suplementos FROM TABLE @lt_suplemento.

out->write( 'Datos cargados a las tablas' ).


  ENDMETHOD.
ENDCLASS.
