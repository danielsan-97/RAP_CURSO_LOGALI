CLASS zcl_aux_travel_det DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES : tt_viaje_REPORTED      TYPE TABLE FOR REPORTED zi_vuelos_dm,
            tt_reserva_REPORTED    TYPE TABLE FOR REPORTED zi_reservas_dm,
            tt_suplemento_REPORTED TYPE TABLE FOR REPORTED zi_suplemento_dm.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calcular_precio  IMPORTING it_travel_id       TYPE tt_travel_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AUX_TRAVEL_DET IMPLEMENTATION.


  METHOD calcular_precio.

    DATA: lv_total_reserva_precio    TYPE /dmo/total_price,
          lv_total_suplemento_precio TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.

      RETURN.

    ENDIF.

    READ ENTITIES OF zi_vuelos_dm
        ENTITY viajecitobd
        FIELDS ( travel_id_vuelos currency_code )
        WITH VALUE #( FOR lv_travel_id IN it_travel_id
                        ( travel_id_vuelos = lv_travel_id )
                    ) RESULT DATA(lt_read_travel).

    READ ENTITIES OF zi_vuelos_dm
        ENTITY viajecitobd BY \_viejetoreserva
        FROM VALUE #( FOR lv_travel_id IN it_travel_id
                        ( travel_id_vuelos = lv_travel_id
                          %control-flight_price = if_abap_behv=>mk-on
                          %control-currency_code = if_abap_behv=>mk-on )
                    ) RESULT DATA(lt_read_reserva).

    LOOP AT lt_read_reserva INTO DATA(ls_reserva)
        GROUP BY ls_reserva-travel_id_reservas INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id_vuelos = lv_travel_key ]
          TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_reserva_result)
          GROUP BY  ls_reserva_result-currency_code INTO DATA(lv_curr).

        lv_total_reserva_precio = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_reserva_line).

          lv_total_reserva_precio += ls_reserva_line-flight_price.

        ENDLOOP.

        IF lv_curr EQ <ls_travel>-currency_code.
          <ls_travel>-total_price += lv_total_reserva_precio.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                iv_amount = lv_total_reserva_precio
                iv_currency_code_source = lv_curr
                iv_currency_code_target = <ls_travel>-currency_code
               iv_exchange_rate_date = cl_abap_context_info=>get_system_date(  )
              IMPORTING
                ev_amount = DATA(lv_amount_converted)

               ).

          <ls_travel>-total_price += lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    READ ENTITIES OF zi_vuelos_dm
    ENTITY reservitasbd BY \_reservatosuplemento
    FROM VALUE #( FOR ls_travel IN lt_read_reserva
                    ( travel_id_reservas = ls_travel-travel_id_reservas
                      booking_id_reserva = ls_travel-booking_id_reserva
                      %control-price = if_abap_behv=>mk-on
                      %control-currency = if_abap_behv=>mk-on )
                ) RESULT DATA(lt_read_suplemento).

    LOOP AT lt_read_suplemento INTO DATA(ls_suplemento)
        GROUP BY ls_suplemento-travel_id_suplementos INTO lv_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id_vuelos = lv_travel_key ] TO <ls_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_suplemento_resultado)
          GROUP BY ls_suplemento_resultado-currency INTO lv_curr.

        lv_total_suplemento_precio = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_suplemento_line).
          lv_total_suplemento_precio += ls_suplemento_line-price.
        ENDLOOP.

        IF lv_curr EQ <ls_travel>-currency_code.
          <ls_travel>-total_price += lv_total_suplemento_precio.
*        ELSE.
*          /dmo/cl_flight_amdp=>convert_currency(
*              EXPORTING
*                iv_amount = lv_total_suplemento_precio
*                iv_currency_code_source = lv_curr
*                iv_currency_code_target = <ls_travel>-currency_code
*               iv_exchange_rate_date = cl_abap_context_info=>get_system_date(  )
*              IMPORTING
*                ev_amount = lv_amount_converted
*
*               ).
*
*          <ls_travel>-total_price += lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zi_vuelos_dm
        ENTITY viajecitobd
        UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel
                            ( travel_id_vuelos = ls_travel_bo-travel_id_vuelos
                              total_price = ls_travel_bo-total_price
                              %control-total_price = if_abap_behv=>mk-on
                             )
                           ).

  ENDMETHOD.
ENDCLASS.
