CLASS zcl_ext_update DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EXT_UPDATE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF zi_vuelos_dm
        ENTITY viajecitobd
        UPDATE FIELDS ( agency_id description )
        WITH VALUE #( ( travel_id_vuelos = '00000001'
                        agency_id = '070025'
                        description = 'Comentario Prueba'
                    ) )
        FAILED DATA(failed)
        REPORTED DATA(reported).

    READ ENTITIES OF  zi_vuelos_dm
      ENTITY viajecitobd
      FIELDS ( agency_id description )
      WITH VALUE #( ( travel_id_vuelos = '00000001' ) )
      RESULT DATA(lt_travel)
      FAILED failed
      REPORTED reported.

    COMMIT ENTITIES.

    IF failed IS INITIAL.

      out->write( 'CommMit exitoso' ).

    ELSE.

      out->write( 'Commit FLAYO' ).


    ENDIF.

  ENDMETHOD.
ENDCLASS.
