@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Suplemento'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SUPLEMENTO_DM
  as projection on ZI_SUPLEMENTO_DM
{
  key travel_id_suplementos,
  key booking_id_suplemento,
  key suplemento_id,
      supplement_id,
      _asosupletext.Description : localized,
      @Semantics.amount.currencyCode: 'currency'
      price,
      @Semantics.currencyCode: true
      currency,
      /* Associations */
      _asoproducto,
      _asosupletext,
      _asovuelos           : redirected to ZC_VUELOS,
      _suplementotoreserva : redirected to parent ZC_RESERVAS

}
