@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Vuelos'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_VUELOS
  as projection on ZI_VUELOS_DM
{
  key     travel_id_vuelos,
          @ObjectModel.text.element: [ '_asoagency.Name' ]
          agency_id,
          _asoagency.Name,
          @ObjectModel.text.element: [ '_asocustomer.LastName' ]
          customer_id,
          _asocustomer.LastName,
          begin_date,
          end_date,
          @Semantics.amount.currencyCode: 'currency_code'
          booking_fee,
          @Semantics.amount.currencyCode: 'currency_code'
          total_price,
          @Semantics.currencyCode: true
          currency_code,
          description,
          overall_status,
          created_by,
          created_at,
          last_changed_by,
          last_change_at,
          @Semantics.amount.currencyCode: 'currency_code'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELE'
  virtual DiscauntPrice : /dmo/total_price,
          /* Associations */
          _asoagency,
          _asocurrency,
          _asocustomer,
          _viejetoreserva : redirected to composition child ZC_RESERVAS
}
