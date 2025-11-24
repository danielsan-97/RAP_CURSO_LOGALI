@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Aprobar reserva'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_A_RESERVA_DM
  as projection on ZI_RESERVAS_DM
{
  key travel_id_reservas,
  key booking_id_reserva,
      booking_date,
      customer_id,
      @ObjectModel.text.element: [ '_asocarrier.Name' ]
      carrier_id,
      _asocarrier.Name,
      connection_id,
      flight_date,
      @Semantics.amount.currencyCode: 'currency_code'
      flight_price,
      @Semantics.currencyCode: true
      currency_code,
      booking_status,
      last_change_at,
      /* Associations */
      _asocarrier,
      _asocustomer,
      _reservatovuelo: redirected to parent ZC_A_VUELOS
}
