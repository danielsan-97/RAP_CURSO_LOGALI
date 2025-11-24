@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Empleados'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_EMPLOY_DM
  as select from zhr_employ_dm
{
  key employ_number,
      empoloy_name,
      employ_department,
      status,
      job_title,
      start_date,
      end_date,
      email,
      manage_number,
      manage_name,
      manage_department,
      crea_date_time,
      crea_uname,
      last_change_time,
      last_change_uname
}
