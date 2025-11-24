@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Vuelos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_VUELOS_DM
  as select from zdm_vuelos_dm
  composition [0..*] of ZI_RESERVAS_DM  as _viejetoreserva

  association [0..1] to /DMO/I_Agency   as _asoagency   on $projection.agency_id = _asoagency.AgencyID
  association [0..1] to /DMO/I_Customer as _asocustomer on $projection.customer_id = _asocustomer.CustomerID
  association [0..1] to I_Currency      as _asocurrency on $projection.currency_code = _asocurrency.Currency
{
  key travel_id_vuelos,

      agency_id,


      customer_id,
      begin_date,
      end_date,
      @Semantics.amount.currencyCode: 'currency_code'
      booking_fee,
      @Semantics.amount.currencyCode: 'currency_code'
      total_price,
      currency_code,
      description,
      overall_status,
      @Semantics.user.createdBy: true
      created_by,

      @Semantics.systemDateTime.createdAt: true
      created_at,

      @Semantics.user.lastChangedBy: true
      last_changed_by,

      @Semantics.systemDateTime.lastChangedAt: true
      last_change_at,

      _viejetoreserva,
      _asoagency,
      _asocustomer,
      _asocurrency
}
