"Clase buffer para guardar datos en el create

CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhr_master_dm AS data.

    TYPES:   flag TYPE c LENGTH 1,

           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY employ_number.

    CLASS-DATA mt_buffer_master TYPE tt_master.

ENDCLASS.

"Hasta aui va lode clase buuffer

CLASS lhc_HCMASTER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR hcmaster RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR hcmaster RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE hcmaster.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE hcmaster.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE hcmaster.

    METHODS read FOR READ
      IMPORTING keys FOR READ hcmaster RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK hcmaster.

ENDCLASS.

CLASS lhc_HCMASTER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    TRY.
        DATA(lv_uname) = cl_abap_context_info=>get_user_formatted_name( ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    SELECT MAX( employ_number ) FROM zhr_master_dm
    INTO @DATA(lv_ma_emply_number).

    LOOP AT entities INTO DATA(ls_entity).

      ls_entity-%data-crea_date_time = lv_time_stamp.
*        ls_entity-crea_uname = sy-uname. "se puede utilizar esta o la siguiente para obtener nombre dse usuario
      ls_entity-%data-crea_uname = lv_uname.
      ls_entity-%data-employ_number = lv_ma_emply_number + 1.
      INSERT VALUE #( flag = lcl_buffer=>created
                      data = CORRESPONDING #( ls_entity-%data ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_entity-%cid IS INITIAL. "Indicar que se ha mapeado
        INSERT VALUE #( %cid = ls_entity-%cid
                        employ_number = ls_entity-%key-employ_number "aca le agregamos el employ despues del key
                      ) INTO TABLE mapped-hcmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    TRY.
        DATA(lv_uname) = cl_abap_context_info=>get_user_formatted_name( ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    LOOP AT entities INTO DATA(ls_entity).

      SELECT SINGLE * FROM zhr_master_dm
          WHERE employ_number EQ @ls_entity-%data-employ_number
          INTO @DATA(ls_bbdd).

      ls_entity-%data-last_change_time = lv_time_stamp.
      ls_entity-%data-last_change_uname = lv_uname.

      INSERT VALUE #( flag = lcl_buffer=>updated
                      data = VALUE #( employ_number     =  ls_entity-%data-employ_number
                                      empoloy_name      = COND #( WHEN ls_entity-%control-empoloy_name EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-empoloy_name
                                                             ELSE ls_bbdd-empoloy_name )

                                     employ_department  = COND #( WHEN ls_entity-%control-employ_department EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-employ_department
                                                             ELSE ls_bbdd-employ_department )

                                     status             = COND #( WHEN ls_entity-%control-status EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-status
                                                             ELSE ls_bbdd-status )

                                     job_title         = COND #( WHEN ls_entity-%control-job_title EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-job_title
                                                             ELSE ls_bbdd-job_title )

                                    start_date         = COND #( WHEN ls_entity-%control-start_date EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-start_date
                                                             ELSE ls_bbdd-start_date )

                                    end_date          = COND #( WHEN ls_entity-%control-end_date EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-end_date
                                                             ELSE ls_bbdd-end_date )

                                    email             = COND #( WHEN ls_entity-%control-email EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-email
                                                             ELSE ls_bbdd-email )

                                    manage_number     = COND #( WHEN ls_entity-%control-manage_number EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-manage_number
                                                             ELSE ls_bbdd-manage_number )

                                    manage_name      = COND #( WHEN ls_entity-%control-manage_name EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-manage_name
                                                             ELSE ls_bbdd-manage_name )

                                    manage_department = COND #( WHEN ls_entity-%control-manage_department EQ if_abap_behv=>mk-on
                                                             THEN ls_entity-%data-manage_department
                                                             ELSE ls_bbdd-manage_department )

                                   crea_date_time = ls_bbdd-crea_date_time

                                   crea_uname = ls_bbdd-crea_uname

                                    ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_entity-employ_number IS INITIAL.
        INSERT VALUE #( %cid = ls_entity-%data-employ_number
                        employ_number = ls_entity-%data-employ_number "aca le agregamos el employ despues del key
                      ) INTO TABLE mapped-hcmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys INTO DATA(ls_key).

      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #( employ_number = ls_key-%key-employ_number )
                     ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_key-employ_number IS INITIAL.

        INSERT VALUE #( %cid          = ls_key-%key-employ_number
                        employ_number = ls_key-employ_number    ) INTO TABLE mapped-hcmaster.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_HCM_DM DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_HCM_DM IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA: lt_data_created TYPE STANDARD TABLE OF zhr_master_dm,
          lt_data_update  TYPE STANDARD TABLE OF zhr_master_dm,
          lt_data_delete  TYPE STANDARD TABLE OF zhr_master_dm.

****esto es para crear
    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                                WHERE ( flag = lcl_buffer=>created ) ( <row>-data  )
                             ).

    IF NOT lt_data_created IS INITIAL.
      INSERT zhr_master_dm FROM TABLE @lt_data_created.
    ENDIF.
****asta aqui va lo de crear

*Esto es para actualizar
    lt_data_update = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                                    WHERE ( flag = lcl_buffer=>updated ) ( <row>-data  )
                                 ).

    IF NOT lt_data_update IS INITIAL.
      UPDATE zhr_master_dm FROM TABLE @lt_data_update.
    ENDIF.

*Hasta aqui va lo de actualizar

*Aqui va lo del delete

    lt_data_delete = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                                    WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data  )
                                 ).

    IF NOT lt_data_delete IS INITIAL.
      delete zhr_master_dm FROM TABLE @lt_data_delete.
    ENDIF.

*Hasta aqui va lo del delete



    CLEAR lcl_buffer=>mt_buffer_master. "Limpiar datos y no se mezclen cuando hayan otra operacion



  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
