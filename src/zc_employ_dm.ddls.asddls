@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Employ'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_EMPLOY_DM
  provider contract transactional_query as projection on ZI_EMPLOY_DM
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
