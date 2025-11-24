CLASS zcl_virt_ele DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRT_ELE IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'ZC_VUELOS'.

      LOOP AT it_requested_calc_elements INTO DATA(ls_calc).

        IF ls_calc = 'DiscauntPrice'.
            APPEND 'total_price' to  et_requested_orig_elements.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    data lt_original_data type STANDARD TABLE OF ZC_VUELOS with DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    loop at lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        <fs_original_data>-DiscauntPrice = <fs_original_data>-total_price * ( 1 / 9 ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.
ENDCLASS.
