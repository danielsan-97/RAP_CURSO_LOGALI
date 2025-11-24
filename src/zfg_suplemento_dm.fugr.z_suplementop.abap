FUNCTION z_suplementop.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(IT_SUPLEMENTOS) TYPE  ZTT_SUPLEMETO
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_DM
*"  EXPORTING
*"     REFERENCE(EV_UPDATE) TYPE  ZDE_FLAG_DM
*"----------------------------------------------------------------------
  CHECK NOT it_suplementos IS INITIAL.

  CASE iv_op_type.

    WHEN 'C'.
      INSERT zdm_suplementos FROM TABLE @it_suplementos.

    WHEN 'U'.
      UPDATE zdm_suplementos FROM TABLE @it_suplementos.

    WHEN 'D'.
      DELETE zdm_suplementos FROM TABLE @it_suplementos.

  ENDCASE.

  IF sy-subrc EQ 0.
    ev_update = abap_true.
  ENDIF.

ENDFUNCTION.
