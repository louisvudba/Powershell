Param(
    [Parameter(mandatory=$false)][string]$TargetServer   
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$ServerPath = "$RootPath\Config\dbservers.csv"
$ServerList = @()
if ($TargetServer) {
    $ServerList += ([PSCustomObject]@{
            ServerName = $TargetServer
            DatabaseName = $DatabaseName
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ScriptBlock {
    $Session = New-PSSession $_.ServerName   
    Invoke-Command -Session $Session -ArgumentList $_DatabaseName -Command { 
        Param($DatabaseName)
        $Query = "
            EXEC sp_change_users_login 'update_one', 'fnb_cross_check_pay_api', 'fnb_cross_check_pay_api'
            EXEC sp_change_users_login 'update_one', 'kv_jenkins_deploy', 'kv_jenkins_deploy'
            EXEC sp_change_users_login 'update_one', 'kv_kvaa_main_api', 'kv_kvaa_main_api'
            EXEC sp_change_users_login 'update_one', 'kv_kvaa_token_api', 'kv_kvaa_token_api'
            EXEC sp_change_users_login 'update_one', 'kv_kyc_clear_data_svc', 'kv_kyc_clear_data_svc'
            EXEC sp_change_users_login 'update_one', 'kv_kyc_recovery_ack_svc', 'kv_kyc_recovery_ack_svc'
            EXEC sp_change_users_login 'update_one', 'kv_kyc_recovery_retry_svc', 'kv_kyc_recovery_retry_svc'
            EXEC sp_change_users_login 'update_one', 'kv_qlkv', 'kv_qlkv'
            EXEC sp_change_users_login 'update_one', 'kv_retail_support', 'kv_retail_support'
            EXEC sp_change_users_login 'update_one', 'kv_search', 'kv_search'
            EXEC sp_change_users_login 'update_one', 'kv_stockout_forecast', 'kv_stockout_forecast'
            EXEC sp_change_users_login 'update_one', 'kv_tracking_ending_stock', 'kv_tracking_ending_stock'
            EXEC sp_change_users_login 'update_one', 'omni_channel_api', 'omni_channel_api'
            EXEC sp_change_users_login 'update_one', 'omni_channel_core_api', 'omni_channel_core_api'
            EXEC sp_change_users_login 'update_one', 'omni_integration_svc', 'omni_integration_svc'
            EXEC sp_change_users_login 'update_one', 'omni_lazada_onhand_svc', 'omni_lazada_onhand_svc'
            EXEC sp_change_users_login 'update_one', 'omni_lazada_order_svc', 'omni_lazada_order_svc'
            EXEC sp_change_users_login 'update_one', 'omni_lazada_price_svc', 'omni_lazada_price_svc'
            EXEC sp_change_users_login 'update_one', 'omni_mapping_product_svc', 'omni_mapping_product_svc'
            EXEC sp_change_users_login 'update_one', 'omni_product_subcribe_svc', 'omni_product_subcribe_svc'
            EXEC sp_change_users_login 'update_one', 'omni_refresh_access_token_svc', 'omni_refresh_access_token_svc'
            EXEC sp_change_users_login 'update_one', 'omni_resycn_product_svc', 'omni_resycn_product_svc'
            EXEC sp_change_users_login 'update_one', 'omni_schedule_svc', 'omni_schedule_svc'
            EXEC sp_change_users_login 'update_one', 'omni_sendo_onhand_svc', 'omni_sendo_onhand_svc'
            EXEC sp_change_users_login 'update_one', 'omni_sendo_order_svc', 'omni_sendo_order_svc'
            EXEC sp_change_users_login 'update_one', 'omni_sendo_price_svc', 'omni_sendo_price_svc'
            EXEC sp_change_users_login 'update_one', 'omni_shopee_onhand_svc', 'omni_shopee_onhand_svc'
            EXEC sp_change_users_login 'update_one', 'omni_shopee_order_svc', 'omni_shopee_order_svc'
            EXEC sp_change_users_login 'update_one', 'omni_shopee_price_svc', 'omni_shopee_price_svc'
            EXEC sp_change_users_login 'update_one', 'omni_tiki_onhand_svc', 'omni_tiki_onhand_svc'
            EXEC sp_change_users_login 'update_one', 'omni_tiki_order_svc', 'omni_tiki_order_svc'
            EXEC sp_change_users_login 'update_one', 'omni_tiki_price_svc', 'omni_tiki_price_svc'
            EXEC sp_change_users_login 'update_one', 'report_read', 'report_read'
            EXEC sp_change_users_login 'update_one', 'retail_audit_svc', 'retail_audit_svc'
            EXEC sp_change_users_login 'update_one', 'retail_auto_customer_group_svc', 'retail_auto_customer_group_svc'
            EXEC sp_change_users_login 'update_one', 'retail_booking_01', 'retail_booking_01'
            EXEC sp_change_users_login 'update_one', 'retail_clear_data_svc', 'retail_clear_data_svc'
            EXEC sp_change_users_login 'update_one', 'retail_core_api', 'retail_core_api'
            EXEC sp_change_users_login 'update_one', 'retail_gmb_svc', 'retail_gmb_svc'
            EXEC sp_change_users_login 'update_one', 'retail_imp_exp_svc', 'retail_imp_exp_svc'
            EXEC sp_change_users_login 'update_one', 'retail_internal_api', 'retail_internal_api'
            EXEC sp_change_users_login 'update_one', 'retail_kiot_api', 'retail_kiot_api'
            EXEC sp_change_users_login 'update_one', 'retail_limit_svc', 'retail_limit_svc'
            EXEC sp_change_users_login 'update_one', 'retail_mhql_web', 'retail_mhql_web'
            EXEC sp_change_users_login 'update_one', 'retail_mobile_api', 'retail_mobile_api'
            EXEC sp_change_users_login 'update_one', 'retail_pricebook_svc', 'retail_pricebook_svc'
            EXEC sp_change_users_login 'update_one', 'retail_public_api', 'retail_public_api'
            EXEC sp_change_users_login 'update_one', 'retail_report_api', 'retail_report_api'
            EXEC sp_change_users_login 'update_one', 'retail_sale_api', 'retail_sale_api'
            EXEC sp_change_users_login 'update_one', 'retail_shipping_svc', 'retail_shipping_svc'
            EXEC sp_change_users_login 'update_one', 'retail_sync_es_log_svc', 'retail_sync_es_log_svc'
            EXEC sp_change_users_login 'update_one', 'retail_sync_es_recovery_svc', 'retail_sync_es_recovery_svc'
            EXEC sp_change_users_login 'update_one', 'retail_sync_es_svc', 'retail_sync_es_svc'
            EXEC sp_change_users_login 'update_one', 'retail_sync_pharmacy', 'retail_sync_pharmacy'
            EXEC sp_change_users_login 'update_one', 'retail_sync_pharmacy_recovery', 'retail_sync_pharmacy_recovery'
            EXEC sp_change_users_login 'update_one', 'retail_synces_product_search_svc', 'retail_synces_product_search_svc'
            EXEC sp_change_users_login 'update_one', 'retail_synces_remain_svc', 'retail_synces_remain_svc'
            EXEC sp_change_users_login 'update_one', 'retail_timesheet_api', 'retail_timesheet_api'
            EXEC sp_change_users_login 'update_one', 'retail_timesheet_imp_exp_svc', 'retail_timesheet_imp_exp_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_log_svc', 'retail_tracking_log_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_manual_rerun_svc', 'retail_tracking_manual_rerun_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_pharmacy_svc', 'retail_tracking_pharmacy_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_recovery_api', 'retail_tracking_recovery_api'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_recovery_rerun_svc', 'retail_tracking_recovery_rerun_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_recovery_svc', 'retail_tracking_recovery_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_rerun_api', 'retail_tracking_rerun_api'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_rerun_svc', 'retail_tracking_rerun_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_stock_balance_svc', 'retail_tracking_stock_balance_svc'
            EXEC sp_change_users_login 'update_one', 'retail_tracking_tool_svc', 'retail_tracking_tool_svc'
            EXEC sp_change_users_login 'update_one', 'retail_util_svc', 'retail_util_svc'
            EXEC sp_change_users_login 'update_one', 'retail_zalo_svc', 'retail_zalo_svc'
        "
        Invoke-Sqlcmd -Query $Query -Database $DatabaseName
    }

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob