CLASS lhc_viajecitobd DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR viajecitobd RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR viajecitobd RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR viajecitobd RESULT result.

    METHODS aceptarViaje FOR MODIFY
      IMPORTING keys FOR ACTION viajecitobd~aceptarViaje RESULT result.

    METHODS copyViaje FOR MODIFY
      IMPORTING keys FOR ACTION viajecitobd~copyViaje RESULT result.

    METHODS rechazarViaje FOR MODIFY
      IMPORTING keys FOR ACTION viajecitobd~rechazarViaje RESULT result.

    METHODS validarCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR viajecitobd~validarCustomer.

    METHODS validarFecha FOR VALIDATE ON SAVE
      IMPORTING keys FOR viajecitobd~validarFecha.

    METHODS validateStatusv FOR VALIDATE ON SAVE
      IMPORTING keys FOR viajecitobd~validateStatusv.

ENDCLASS.

CLASS lhc_viajecitobd IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        FIELDS ( travel_id_vuelos overall_status )
        WITH VALUE #( FOR st_row IN keys
                        ( %key = st_row-%key ) )
        RESULT DATA(lt_resultravel).

    result = VALUE #( FOR ls_travel IN  lt_resultravel
                        ( %key                    =  ls_travel-%key
                          %field-travel_id_vuelos = if_abap_behv=>fc-f-read_only
                          %field-overall_status   = if_abap_behv=>fc-f-read_only

                          %assoc-_viejetoreserva  = if_abap_behv=>fc-o-enabled "Habilitar la navegacion, por lo que se pone instamce features

                          %action-aceptarViaje    = COND #( WHEN ls_travel-overall_status = 'A'
                                                                THEN if_abap_behv=>fc-o-disabled
                                                                ELSE if_abap_behv=>fc-o-enabled
                                                          )

                          %action-rechazarViaje   = COND #( WHEN ls_travel-overall_status = 'X'
                                                                THEN if_abap_behv=>fc-o-disabled
                                                                ELSE if_abap_behv=>fc-o-enabled
                                                          )
                        )
                    ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

*    CB9980005669 "usuario
    DATA(lv_autori) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980005669'
                                THEN if_abap_behv=>auth-allowed
                                ELSE if_abap_behv=>auth-unauthorized
                             ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
*       <ls_result>-%key = <ls_keys>-%key.
*       <ls_result>-%action-aceptarViaje = if_abap_behv=>auth-allowed.

      <ls_result> = VALUE #( %key                  = <ls_keys>-%key
                             %op-%update           = lv_autori
                             %delete               = lv_autori
                             %action-aceptarViaje  = lv_autori
                             %action-rechazarViaje = lv_autori
                             %action-copyViaje     = lv_autori
                           ).

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD aceptarViaje.

    MODIFY ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        UPDATE FIELDS ( overall_status )
        WITH VALUE #( FOR st_row_key IN keys
                        ( travel_id_vuelos = st_row_key-travel_id_vuelos
                          overall_status = 'A' ) )
        FAILED failed
        REPORTED reported.

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        ALL FIELDS
        WITH VALUE #( FOR st_row_key1 IN keys
                    ( travel_id_vuelos = st_row_key1-travel_id_vuelos
                     ) )
                    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel_row IN lt_travel
                    ( travel_id_vuelos = ls_travel_row-travel_id_vuelos
                       %param = ls_travel_row ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lstravel>).

      DATA(lv_travel_msg) = <lstravel>-travel_id_vuelos.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'. "Esto es para borrar ceros

      APPEND VALUE #( travel_id_vuelos = <lstravel>-travel_id_vuelos
                      %msg    = new_message( id       = 'Z_MC_RAP_DM'
                                             number   = '005'
                                             v1       = lv_travel_msg
                                             severity = if_abap_behv_message=>severity-success
                                            )
                      %element-customer_id = if_abap_behv=>mk-on
                     ) TO reported-viajecitobd.

    ENDLOOP.

  ENDMETHOD.

  METHOD copyViaje.

*Leemos y ponemos datos en lt_read_vuelo
    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
      ENTITY viajecitobd
      FIELDS ( travel_id_vuelos agency_id customer_id booking_fee total_price currency_code )
      WITH VALUE #( FOR estructura_key IN keys ( %key = estructura_key-%key ) )
      RESULT DATA(lt_read_vuelo)
      FAILED failed
      REPORTED reported.

*      CHECK failed IS INITIAL.

    DATA lt_create_vuelo TYPE TABLE FOR CREATE zi_vuelos_dm\\viajecitobd.

    SELECT MAX( travel_id_vuelos ) FROM zdm_vuelos_dm
        INTO @DATA(lv_vuelo_max).

    DATA(lv_elhoy) = cl_abap_context_info=>get_system_date(  ).

*Creamos nuevos datos en base a lo que se leyo
    lt_create_vuelo = VALUE #( FOR resultado IN  lt_read_vuelo INDEX INTO idx
                              ( travel_id_vuelos    = lv_vuelo_max + idx
                                agency_id           = resultado-agency_id
                                customer_id         = resultado-customer_id
                                begin_date          = lv_elhoy
                                end_date            = lv_elhoy + 30
                                booking_fee         = resultado-booking_fee
                                total_price         = resultado-total_price
                                currency_code       = resultado-currency_code
                                description         = 'Agregue comentario'
                                overall_status      = 'O' ) ).

    "Este es el modifyu tal cual el video d elogali, da error
*    MODIFY ENTITIES OF zi_vuelos_dm IN LOCAL MODE
*       ENTITY viajecitobd
*       CREATE FIELDS ( travel_id_vuelos
*                       agency_id
*                       customer_id
*                       begin_date
*                       end_date
*                       booking_fee
*                       total_price
*                       currency_code
*                       description
*                       overall_status )
*               WITH lt_create_vuelo
*               MAPPED mapped
*               FAILED failed
*               REPORTED reported.
    "hasta aqui va lo del

    MODIFY ENTITIES OF zi_vuelos_dm IN LOCAL MODE
       ENTITY viajecitobd
       CREATE FIELDS ( travel_id_vuelos
                       agency_id
                       customer_id
                       begin_date
                       end_date
                       booking_fee
                       total_price
                       currency_code
                       description
                       overall_status )
               WITH VALUE #( (
                                %cid = '10' "este cid es importante, si no no funciona
                                travel_id_vuelos    = lv_vuelo_max + 1
                                agency_id           = '009'
                                customer_id         = '583'
                                begin_date          = lv_elhoy
                                end_date            = lv_elhoy + 30
*                                booking_fee         = resultado-booking_fee
*                                total_price         = resultado-total_price
*                                currency_code       = resultado-currency_code
                                description         = 'Prueba copia'
                                overall_status      = 'O'
                             )  )
               MAPPED mapped
               FAILED failed
               REPORTED reported.

    result = VALUE #( FOR fila_st IN lt_create_vuelo INDEX INTO idx
                        ( %cid_ref = keys[ idx ]-%cid_ref
                          %key     = keys[ idx ]-%key
                          %param   = CORRESPONDING #( fila_st ) ) ).

  ENDMETHOD.

  METHOD rechazarViaje.

    MODIFY ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        UPDATE FIELDS ( overall_status )
        WITH VALUE #( FOR st_row_key IN keys
                        ( travel_id_vuelos = st_row_key-travel_id_vuelos
                          overall_status = 'X' ) )
        FAILED failed
        REPORTED reported.

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        ALL FIELDS
        WITH VALUE #( FOR st_row_key1 IN keys
                    ( travel_id_vuelos = st_row_key1-travel_id_vuelos
                     ) )
                    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel_row IN lt_travel
                    ( travel_id_vuelos = ls_travel_row-travel_id_vuelos
                       %param = ls_travel_row ) ).

    "Mensaje
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lstravel>).

      DATA(lv_travel_msg) = <lstravel>-travel_id_vuelos.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'. "Esto es para borrar ceros

      APPEND VALUE #( travel_id_vuelos = <lstravel>-travel_id_vuelos
                      %msg    = new_message( id       = 'Z_MC_RAP_DM'
                                             number   = '006'
                                             v1       = lv_travel_msg
                                             severity = if_abap_behv_message=>severity-success
                                            )
                      %element-customer_id = if_abap_behv=>mk-on
                     ) TO reported-viajecitobd.

    ENDLOOP.

  ENDMETHOD.

  METHOD validarCustomer.

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        FIELDS ( customer_id )
        WITH CORRESPONDING #(  keys )
        RESULT DATA(lt_travel) .

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer
        FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customer
        WHERE customer_id EQ @lt_customer-customer_id
        INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lstravel>).

      IF <lstravel>-customer_id IS INITIAL OR NOT line_exists(  lt_customer_dB[ customer_id = <lstravel>-customer_id ] ). "Preguntamos si esta vacio o si el codigo no existe dentro d elos validos

        APPEND VALUE #( travel_id_vuelos = <lstravel>-travel_id_vuelos ) TO failed-viajecitobd.

        APPEND VALUE #( travel_id_vuelos = <lstravel>-travel_id_vuelos
                        %msg    = new_message( id       = 'Z_MC_RAP_DM'
                                               number   = '001'
                                               v1       = <lstravel>-travel_id_vuelos
                                               severity = if_abap_behv_message=>severity-error
                                              )
                        %element-customer_id = if_abap_behv=>mk-on
                       ) TO reported-viajecitobd.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validarFecha.

    "Esta es como una forma viejita de hacer la lectura de la entidad, notese la primera linea
*    Read ENTITY zi_vuelos_dm\\viajecitobd
*        FIELDS ( begin_date end_date )
*        WITH VALUE #( FOR <ROW> IN keys (
*                                        %KEY = <ROW>-%KEY
*                                        )
*                    )
*        RESULT DATA(lt_travel_result).

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY viajecitobd
        FIELDS ( begin_date end_date )
        WITH VALUE #( FOR <row> IN keys (
                                        %key = <row>-%key
                                        )
                    )
        RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-end_date LT ls_travel_result-begin_date.

        APPEND VALUE #(  %key             = ls_travel_result-%key
                         travel_id_vuelos = ls_travel_result-travel_id_vuelos ) TO failed-viajecitobd.

        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message(  id        = 'Z_MC_RAP_DM' "Aqui va el nombre de la clase de los mensajes
                                             number    = '002'
                                             v1        = ls_travel_result-begin_date
                                             v2        = ls_travel_result-end_date
                                             v3        = ls_travel_result-travel_id_vuelos
                                             severity  = if_abap_behv_message=>severity-error
                                           )
                        %element-begin_date = if_abap_behv=>mk-on
                        %element-end_date   = if_abap_behv=>mk-on
                      ) TO reported-viajecitobd.

      ELSEIF ls_travel_result-begin_date < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key = ls_travel_result-%key
                        travel_id_vuelos = ls_travel_result-travel_id_vuelos
                      ) TO failed-viajecitobd.

        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = 'Z_MC_RAP_DM'
                                            number = '003'
                                            severity = if_abap_behv_message=>severity-error
                                          )
                       %element-begin_date = if_abap_behv=>mk-on
                       %element-end_date = if_abap_behv=>mk-on
                      ) TO reported-viajecitobd.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatusv.

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
     ENTITY viajecitobd
     FIELDS ( overall_status )
     WITH VALUE #( FOR <row> IN keys (
                                     %key = <row>-%key
                                     )
                 ) RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-overall_status.

        WHEN 'O'.
        WHEN 'X'.
        WHEN 'A'.

        WHEN OTHERS.

          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-viajecitobd.

          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id       = 'Z_MC_RAP_DM'
                                              number   = '004'
                                              v1       = ls_travel_result-overall_status
                                              severity = if_abap_behv_message=>severity-error
                                            )
                         %element-overall_status = if_abap_behv=>mk-on
                        ) TO reported-viajecitobd.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_reservitasbd DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcularPrecioVuelo FOR DETERMINE ON MODIFY
      IMPORTING keys FOR reservitasbd~calcularPrecioVuelo.

    METHODS validateStatusr FOR VALIDATE ON SAVE
      IMPORTING keys FOR reservitasbd~validateStatusr.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR reservitasbd RESULT result.

ENDCLASS.

CLASS lhc_reservitasbd IMPLEMENTATION.

  METHOD calcularPrecioVuelo.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det=>calcular_precio( it_travel_id =
                                              VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                                        GROUP BY booking_key-travel_id_reservas WITHOUT MEMBERS ( <booking>  ) ) ).

    ENDIF.

  ENDMETHOD.

  METHOD validateStatusr. "este es el de la asociuoacion, el de la reserva y no el del vuelo

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
     ENTITY reservitasbd
     FIELDS ( booking_status )
     WITH VALUE #( FOR <row> IN keys (
                                     %key = <row>-%key
                                     )
                 ) RESULT DATA(lt_reserva_result).

    LOOP AT lt_reserva_result INTO DATA(ls_reserva_result).

      CASE ls_reserva_result-booking_status.

        WHEN 'N'. "New
        WHEN 'X'. "Cancelado
        WHEN 'B'. "Vendido

        WHEN OTHERS.

          APPEND VALUE #( %key = ls_reserva_result-%key ) TO failed-reservitasbd.

          APPEND VALUE #( %key = ls_reserva_result-%key
                          %msg = new_message( id       = 'Z_MC_RAP_DM'
                                              number   = '007'
                                              v1       = ls_reserva_result-booking_id_reserva
                                              severity = if_abap_behv_message=>severity-error
                                            )
                         %element-booking_status = if_abap_behv=>mk-on
                        ) TO reported-reservitasbd.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_vuelos_dm IN LOCAL MODE
        ENTITY reservitasbd
        FIELDS ( booking_id_reserva booking_date customer_id booking_status )
        WITH VALUE #( FOR keyval IN keys ( %key = keyval-%key ) )
        RESULT DATA(lt_reserva_result).

    result = VALUE #( FOR ls_travel IN  lt_reserva_result
                        ( %key = ls_travel-%key
                          %assoc-_reservatosuplemento = if_abap_behv=>fc-o-enabled
                        )
                    ).


  ENDMETHOD.

ENDCLASS.

CLASS lhc_suplementicobd DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcularSuplemeto FOR DETERMINE ON MODIFY
      IMPORTING keys FOR suplementicobd~calcularSuplemeto.

ENDCLASS.

CLASS lhc_suplementicobd IMPLEMENTATION.

  METHOD calcularSuplemeto.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det=>calcular_precio( it_travel_id =
                                              VALUE #( FOR GROUPS <booking_suple> OF booking_key IN keys
                                                        GROUP BY booking_key-travel_id_suplementos WITHOUT MEMBERS ( <booking_suple>  ) ) ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

*CLASS lsc_suplemento DEFINITION INHERITING FROM cl_abap_behavior_saver.
*    PROTECTED SECTION.
*    METHODS save_modified REDEFINITION.
*ENDCLASS.


CLASS lsc_ZI_VUELOS_DM DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: crear      TYPE string VALUE 'CREATE',
               actualizar TYPE string VALUE 'UPDATE',
               deletear   TYPE string VALUE 'DELETE'.

    "Aqui va para el save unmanaged del suplemento
    CONSTANTS: create TYPE string VALUE 'C',
               update TYPE string VALUE 'U',
               delete TYPE string VALUE 'D'.

    "Hasta aqui va lo del el save unmanaged del suplemento

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_VUELOS_DM IMPLEMENTATION.

  METHOD save_modified.
*
    DATA: lt_travel_log    TYPE STANDARD TABLE OF zdm_log,
          lt_travel_log_up TYPE STANDARD TABLE OF zdm_log.

    IF NOT create-viajecitobd IS INITIAL.

      lt_travel_log =  CORRESPONDING #( create-viajecitobd ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).

        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        <ls_travel_log>-changing_operation = lsc_ZI_VUELOS_DM=>crear.

        READ TABLE create-viajecitobd WITH TABLE KEY entity COMPONENTS travel_id_vuelos = <ls_travel_log>-travel_id_vuelos
            INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-booking_fee EQ cl_abap_behv=>flag_changed.

            <ls_travel_log>-changed_field_name = 'booking_fee'.
            <ls_travel_log>-changed_value = ls_travel-booking_fee.
            <ls_travel_log>-user_mod = cl_abap_context_info=>get_user_technical_name( ).

            TRY.
                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_up.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT update-viajecitobd IS INITIAL.

      lt_travel_log = CORRESPONDING #( update-viajecitobd ).



      LOOP AT update-viajecitobd INTO DATA(ls_update_viaje).

        ASSIGN lt_travel_log[ travel_id_vuelos = ls_update_viaje-travel_id_vuelos ] TO FIELD-SYMBOL(<fs_travel_log>).
*        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        <fs_travel_log>-changing_operation = lsc_ZI_VUELOS_DM=>actualizar.

        IF ls_update_viaje-%control-customer_id EQ cl_abap_behv=>flag_changed.

          <fs_travel_log>-changed_field_name = 'customer_id'.
          <fs_travel_log>-changed_value = ls_update_viaje-customer_id.
          <fs_travel_log>-user_mod = cl_abap_context_info=>get_user_technical_name( ).

          TRY.
              <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.

          APPEND <fs_travel_log> TO lt_travel_log_up.


        ENDIF.
      ENDLOOP.

    ENDIF.

    IF NOT delete-viajecitobd IS INITIAL.

      lt_travel_log = CORRESPONDING #( delete-viajecitobd ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<lfs_travel_log_del>).
*        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        <lfs_travel_log_del>-changing_operation = lsc_ZI_VUELOS_DM=>deletear.

        <lfs_travel_log_del>-user_mod = cl_abap_context_info=>get_user_technical_name( ).

        TRY.
            <lfs_travel_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <lfs_travel_log_del> TO lt_travel_log_up.

      ENDLOOP.

    ENDIF.

    IF NOT lt_travel_log_up IS INITIAL.
      INSERT zdm_log FROM TABLE @lt_travel_log_up.
    ENDIF.

    "Esto es para el save unmanaged del suplemento

    DATA: lt_suplements TYPE STANDARD TABLE OF zdm_suplementos,
          lv_op_type    TYPE zde_flag_dm,
          lv_update     TYPE zde_flag_dm.

    IF NOT create-suplementicobd IS INITIAL.
      lt_suplements = CORRESPONDING #( create-suplementicobd ).
      lv_op_type = lsc_zi_vuelos_dm=>create.
    ENDIF.

    IF NOT update-suplementicobd IS INITIAL.
      lt_suplements = CORRESPONDING #( update-suplementicobd ).
      lv_op_type = lsc_zi_vuelos_dm=>update.
    ENDIF.

    IF NOT delete-suplementicobd IS INITIAL.
      lt_suplements = CORRESPONDING #( delete-suplementicobd ).
      lv_op_type = lsc_zi_vuelos_dm=>delete.
    ENDIF.

    IF NOT lt_suplements IS INITIAL.

      CALL FUNCTION 'Z_SUPLEMENTOP'
        EXPORTING
          it_suplementos = lt_suplements
          iv_op_type     = lv_op_type
        IMPORTING
          ev_update      = lv_update.

      IF lv_update EQ abap_true.

*            reported-suplementicobd "aqui se puede implementar logica para mensajes y otras cosas

      ENDIF.

    ENDIF.



    "Hasta aqui va ldel suploemento


  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
