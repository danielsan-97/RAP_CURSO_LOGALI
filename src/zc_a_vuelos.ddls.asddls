@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Vuelos'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_A_VUELOS
  as projection on ZI_VUELOS_DM
{
  key travel_id_vuelos,
  @ObjectModel.text.element: [ 'NombreAgencia' ]
      agency_id,
      _asoagency.Name as NombreAgencia,
      @ObjectModel.text.element: [ 'ApellidoUsuario' ]
      customer_id,
      _asocustomer.LastName as ApellidoUsuario,
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
      /* Associations */
      _asocustomer,
      _viejetoreserva: redirected to composition child ZC_A_RESERVA_DM
}
