@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption HCM'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_HCM_DM
  provider contract transactional_query
  as projection on ZI_HCM_DM
{
  key employ_number,
      empoloy_name,
      employ_department,
      status,
      job_title,
      start_date,
      end_date,
      email,
      @ObjectModel.text.element: [ 'manage_name' ]
      manage_number,
      manage_name,
      manage_department,
//      @Semantics.user.createdBy: true
       crea_date_time,
      crea_uname,
//      @Semantics.user.lastChangedBy: true
      last_change_time,
      last_change_uname
}
