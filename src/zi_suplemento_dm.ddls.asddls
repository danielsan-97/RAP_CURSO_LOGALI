@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Suplemento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SUPLEMENTO_DM
  as select from zdm_suplementos
  association        to parent ZI_RESERVAS_DM as _suplementotoreserva on  $projection.travel_id_suplementos = _suplementotoreserva.travel_id_reservas
                                                                      and $projection.booking_id_suplemento = _suplementotoreserva.booking_id_reserva

  association [1..1] to ZI_VUELOS_DM          as _asovuelos           on  $projection.travel_id_suplementos = _asovuelos.travel_id_vuelos
  association [1..1] to /DMO/I_Supplement     as _asoproducto         on  $projection.supplement_id = _asoproducto.SupplementID
  association [1..*] to /DMO/I_SupplementText as _asosupletext        on  $projection.supplement_id = _asosupletext.SupplementID

{

  key travel_id_suplementos,
  key booking_id_suplemento,
  key suplemento_id,
      supplement_id,
      @Semantics.amount.currencyCode : 'currency'
      price,
      currency,
      @Semantics.systemDateTime.lastChangedAt: true
      _suplementotoreserva.last_change_at,
      _suplementotoreserva,
      _asovuelos,
      _asoproducto,
      _asosupletext
}
