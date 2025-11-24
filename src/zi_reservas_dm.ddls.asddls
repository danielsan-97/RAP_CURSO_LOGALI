@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Reservas'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_RESERVAS_DM
  as select from zdm_reservas_dm
  composition [0..*] of ZI_SUPLEMENTO_DM  as _reservatosuplemento
  association        to parent ZI_VUELOS_DM      as _reservatovuelo on $projection.travel_id_reservas = _reservatovuelo.travel_id_vuelos

  association [1..1] to /DMO/I_Customer   as _asocustomer           on $projection.customer_id = _asocustomer.CustomerID
  association [1..1] to /DMO/I_Carrier    as _asocarrier            on $projection.carrier_id = _asocarrier.AirlineID
  association [1..*] to /DMO/I_Connection as _asoconecction         on $projection.connection_id = _asoconecction.ConnectionID
{
  key travel_id_reservas,
  key booking_id_reserva,
      booking_date,
      customer_id,
      carrier_id,
      connection_id,
      flight_date,
      @Semantics.amount.currencyCode : 'currency_code'
      flight_price,
      currency_code,
      booking_status,
      last_change_at,
      _reservatovuelo,
      _reservatosuplemento,
      _asocustomer,
      _asocarrier,
      _asoconecction
}
