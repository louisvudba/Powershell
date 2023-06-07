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
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ScriptBlock {
    $Session = New-PSSession $_.ServerName   
    Invoke-Command -Session $Session -Command { 
        $Query = "
            USE [master]
            GO

            CREATE LOGIN [fnb_cross_check_pay_api]
            WITH PASSWORD = 0x0200e42f20c7473e2ef4173a4d75c1de1f454678339d050d21d5cac71a5fa1b5dabf48ece4c79f857c09523330776563b317dda30f6fe521d37c3c9503e71f54c3a95ad1561c HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_jenkins_deploy]
            WITH PASSWORD = 0x020005eab29fb858cef14f44799b67f8b38f963d5827924a4fb6ba8720b9d5f6a8831e67cb623ab70bf50612f4dd0f71486c11142704d9e6c59ebd45d6766009b811dd6915e8 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_kvaa_main_api]
            WITH PASSWORD = 0x020099c2c83e764245b76bdfeb574260c7d333fded6996feeb919dd63ad05549ea10de236142c1c5e30f99e6e95db8463c1f57efc335a47ca6b80ec982b78b2562ec6cc47b0b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_kvaa_token_api]
            WITH PASSWORD = 0x0200dc669408c569deabb35e68c388c0765388135cb9ed0a3ded9effba8bd84a94a5d7219de23381841dd5e70077243f7615f1747b1baee41a0e9a78b11c5e0b3fc9dd6ffa3b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_kyc_clear_data_svc]
            WITH PASSWORD = 0x020086ba081a55095a005fdee5dda492219065819e87298c4d9cb02a1381725c90be9ac7dfdcdf24f7e4d4d66ced6cf44162c79fea8f112d3d83d80f527e4504ed63db1d3010 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_kyc_recovery_ack_svc]
            WITH PASSWORD = 0x0200282ef72bbf992addc058570d410e4333695444a0782ece5e953c1c935c7d7ce004f749e4f3b3a7f9e2df40825d3c21ef4602d084add56d793c61c79e44a90f0e6db4f81d HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_kyc_recovery_retry_svc]
            WITH PASSWORD = 0x0200353ce4ec599c412ca6a6d837a97843a5aeb9d850e6d2b3a17bebbd5c5f5e876af62dc635c0c2ee861bdc8a10606e539a7749311f0da8d772a6b0510466202cd55d4ef04f HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_qlkv]
            WITH PASSWORD = 0x0200c06f4d5e8ad158e44d7c84cd178f1ea5b83266cb87c8ae8230b1918f240897de306815ec4f3355bb15f650e051f3c25ab113820e56d7ed0df41e37d9201ba7da5e6ba152 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_retail_support]
            WITH PASSWORD = 0x020076f07b3483d39b286375c9359cf204f4d02a93ba164cf311f895f725ccd7be2d19dbcccab540162d702b65d3c3254170d33dbb7836c904173e9430175f24cdf20c8f953a HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_search]
            WITH PASSWORD = 0x02002ca24113cf1aa6abe58836dfe54dad18cbfbe2ebad5ab9d15582f30a207828f357708a13efda91f20f7fab4e11698a3660e63414ec67462c6bbeb6e7f8dc60b2335cfa04 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_stockout_forecast]
            WITH PASSWORD = 0x0200b139f4f4ed45a11fc5103b8ef34bb1865814c0a092963fdd4f5e524c960d6b7766810a6c45dabcaabaf9ffa408f1d8e26aef30a3b64eec0e3afa1e5110882d6c9fa142d2 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [kv_tracking_ending_stock]
            WITH PASSWORD = 0x0200e15f011b0f79b785120e1e3e2918f3234aa76780bd1ca0424c6094be69ed6b5d34eba30d63e98fe8f8193fb37d003778baf6e31360af8f05c730141447bc6422335ae754 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_channel_api]
            WITH PASSWORD = 0x02003f06d5e45b6f650ec87213349f17fc3aa483b1aeb0b6db5be13c1cd1ae4287fcea6896619dd1fb1207e9e7f07c976e420f8fef475afa95a9c0d0b6f92c0ef3390c57b87e HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_channel_core_api]
            WITH PASSWORD = 0x0200ddbae3bd9c77f6ebb690bbb86fe23810521b1895bb677a31d91f3864a30909ff5dd87ca0292868f7fbf6926937979faaee99b3ce571a6de78834ed9ea7b94f02ae0c533a HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_integration_svc]
            WITH PASSWORD = 0x02005fabe29f0b1d914e86ddda9413829238a2c83ce5a90f14bb168e514c5fadfd2b7736551f0ba6cb8eabec24fc3963157ed998b0dd556071cb10197c914cb55223519180cf HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_lazada_onhand_svc]
            WITH PASSWORD = 0x02004a6eb944c7eebb706d3c2efb5a3dd490e7d56064fbe89ea8a7bc6a10272c57a966f8ca4a396a80c9ca171d3436b7444a7e78ee519984448955a996087ca3f08a66be10a1 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_lazada_order_svc]
            WITH PASSWORD = 0x0200463536c6b303e79cd1580a11355432e033058e8e00ba10efec06468bbc839a7bf7804001a8f7bed3eaea40e9f3c4ad82c8525c7074b15350d36403ddc55e03e747bc2e61 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_lazada_price_svc]
            WITH PASSWORD = 0x0200145cb88494ca15dfdd9841335a5d11ea1d604cf774e2f093bc0d8d7cb1e217dc7ff7a7f799ec5be8af5595ff4debccb4ac9cdfdf8cc63650c09ac4659af7fa63fbe4648d HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_mapping_product_svc]
            WITH PASSWORD = 0x02006d899d8b44240040f768dfc40db97d45c704f2f12517b0794e0ea138549afb99d04efccf006c40e77e0f1ad5daf1a5b8918a368469e077956822db8ceb52eab58e0b2a83 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_product_subcribe_svc]
            WITH PASSWORD = 0x0200247b33966424ba95024e6e6e5481fb8e10ebd831a5efb3651eb56df6efb35ad96ada1909349049e8bc795eff050e9440ca5d9034fab4629a15702f962b093fdf90ef9765 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_refresh_access_token_svc]
            WITH PASSWORD = 0x020092f07e0e5f676124be5fd9901ea3fa2c0cbeadd7b34a1d6e22d7e3bd18c841bc2cfdd3dcdae37e7c9c108eb9534096d4db97447b1203f22d1b9ae8000dac68aea5bf60e5 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_resycn_product_svc]
            WITH PASSWORD = 0x0200752ac9885d591b95ecd538ec4bbd8378ab867290478cbb63cd1badad1f7b2932ed9cfa7031dc9f60ca95175a9bb9ff120a61c3360d86892879b33e23b268ce5b3bee8f2b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_schedule_svc]
            WITH PASSWORD = 0x02006fd675f78f6b35ceabedd286c6abac814ae5e0ba117642b0a584fd8ab6ec20a1afa9a69b049a19b139ade2abe86ce946926dd2996f592c8ae719fe4036d1be7923c59751 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_sendo_onhand_svc]
            WITH PASSWORD = 0x0200e8533599f9e46ad3928cf959aac7a95f437e610d39fa66bed049ab545104e92481c823eede9836e7c56a677839c3e71176b82d64c4b5fe7b4060d8ed04b3f27bbbac4a60 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_sendo_order_svc]
            WITH PASSWORD = 0x02009e1455e97ddc1be2a91539033ba22bf61c8626ebb9978fa2d262baffb866b8097d4ecb41a1ab6d54b5377b64cdb2f24daea58a0b11658fea0bc16eeebb25d04c654b7938 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_sendo_price_svc]
            WITH PASSWORD = 0x0200376e0fe325101b797aa2871fe36610a73f464a7d832aadd9b1f9556cc287224ec1638500b49e53c605e99df55617c2d8566b8c574473934a5167754f17bca00229387c27 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_shopee_onhand_svc]
            WITH PASSWORD = 0x02007f2841e126ad5e3bdf84f28cf1ace0c8841151d3a676d4e9065430eea0586fb05206ede2ceb846abb70d11523a52bbe953ae3c17641c380f24bd813cab3d999922c66633 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_shopee_order_svc]
            WITH PASSWORD = 0x0200d7a09f412566af372af21a256e0504d2bba7690f5cf60434fc31d24c2306a7f272024e2e2fb95055607f5ee15b89fb6e922b7a3da5b9d63e389dc42471546630e0b54052 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_shopee_price_svc]
            WITH PASSWORD = 0x0200099d11892134d65f9e59e1f7ad8986f00885bcacd2bd95dc243bdf6f1e399d575193a1c4c43450990d7ba98f37afb2c3c307f9eaf1a7cd5a3fb533b720ab505f35a9bb71 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_tiki_onhand_svc]
            WITH PASSWORD = 0x020050a8b04183429384d85b02204d474e7cebe50d089697838151853eef9cf3d919b3001d5880313265771f6ba24de873a8ea33c84721b54e738bfb30814b0ea7505e90953b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_tiki_order_svc]
            WITH PASSWORD = 0x0200b7610cb64cc776895ec3117f873f672795d8806dee1747d9a944859c01bd7c8eba20749441690e382c561beb7f5b853e34113df782844521ae1354d0ea24c54e1bd67bbc HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [omni_tiki_price_svc]
            WITH PASSWORD = 0x02000e5edb0d5387c070a69e8b9b5138492811f2f7aa1845e9997ebf3adeda06f6e02c206d1d810cc3aa7c391806b6a55aa81741c1c5f6fa6422373bfafade4013105e0c5ffd HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [report_read]
            WITH PASSWORD = 0x020064aeb9adf590cd5842e18c69168f0ca5eea3c56e4c6ae7e342732964eefa8683ba9f6a13d59bf54ae95af29f5f08b2510ce95c55fe1923daad1a8d77a8a9dc339cb85398 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_audit_svc]
            WITH PASSWORD = 0x02006718ff904e8bf594646181d66b21872861aabc2a11c71e46837cf36520370ea52050adf60a42ac3983063ea926a3abb227971467d96bec62367880c6b7b33b7e15f69c95 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_auto_customer_group_svc]
            WITH PASSWORD = 0x0200a748deed30d17b695b8f523f8682f318c45227f160ca3b2b4ee82f863845c8998a3d502f4bbf534a52ec559b2c1f03c50388b6bb1cfcf5a03891e411ccc40094dd9d861a HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_booking_01]
            WITH PASSWORD = 0x02007036cd65a23f35e24adfbf36a5ec39d24695fe5d2d5790e7cb9dc163fc8d4bd950618687c71a02c0bf117091f633f71e2c5fb9ec527895014e4eccf63ea99ff2693f34a2 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_clear_data_svc]
            WITH PASSWORD = 0x0200de19f2132ddd3319cabe01a40c7d9471d5a914bb073b5cf092ffce7efe5014cae74da48f9096f5740f72cd3077df225481ec42c67f369ae517b22879699cc9c8b1973d04 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_core_api]
            WITH PASSWORD = 0x0200d3543a49f3b984266ae64df620cf836f88b890f7a47bd1b277ddafbd798db36ba4af92c726554fb9e197f372aeb54fd217de71abcc6b3ef8af16187b69d392a25b927fc6 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_gmb_svc]
            WITH PASSWORD = 0x02003801dc2d427d874e85ac5bebfa27b9eea697239ef5a71eade7759eedf366538783307c1ea70b5b0b3088d264753643eecead114e7afb0cb8d9968b14a2a230713a369e4d HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_imp_exp_svc]
            WITH PASSWORD = 0x02004ac671325f446706b8f7f771f84b3b81b1afebcdfe0ea8302f97610696934b27d7a5f44995d3935be81e5a84de752e1d3ff83bd645ab648c9dbb7699ed9302b69b062c39 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_internal_api]
            WITH PASSWORD = 0x02007cbdc5ce8d04caedae316572e596421da2bbb29e87bf154799929aae5e924cacad21014f326ecf6446b085f9d1d4a21a0a97d8feca7ff81e299d2d79f52e34a3e07f6157 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_kiot_api]
            WITH PASSWORD = 0x02002d91788bcd49e22a60c568d9c40b48e413ce65022d4ec5dcaea286350a01f39d1d22ff769798979cea2f64d3ec35e34fa1414e0fe792e7b8cbac36e3291bb14f74777405 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_limit_svc]
            WITH PASSWORD = 0x02007c17bfa14f46ca90768a2db1c63035b4156f94745779ee109ff71c2c10cf722cf7a7133ff85922e82d5babc88d6eba1e2dc4e18b3da3b4a5bc6bbebd3858f7c454a8fd85 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_mhql_web]
            WITH PASSWORD = 0x020009c0b6b8700431ac83f170579806c63fecc8b1857b16f5b9ec6367a3527ab08783ebb1c522c3229ab903254bf3f9a5117337bdaf46c28a4f1d43a2b4a780d101135475d1 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_mobile_api]
            WITH PASSWORD = 0x020038ed883471816b0048cd72790d773b59ad78489ffa787772fee470b9d2406827e14446cace5a37ce00a3c4ed3a7c02427e129161e732588d863a9f06b030894b9c04876b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_pricebook_svc]
            WITH PASSWORD = 0x0200f8f87c81d05684d1368bf6f780f98f85d991c3785f1bb164475e29e66a268b7cc93da115d43e3d5ba578c3d72dc888d6df11890f55e89c00dd7195c37b799abda174c16a HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_public_api]
            WITH PASSWORD = 0x0200080ed9534fcc9d2b26ff38fde0e703c5409ef54484a0b0893000ca0013e5ede085a1b25812c0bb9b8e7421f099dcfd6ac124a4b0cdbf96ac16318b12682185315e6a46aa HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_report_api]
            WITH PASSWORD = 0x0200a200cb9231e3da0bb2f21ed19d1fe6457f574945c31e3e7fd1583939e900bcc826efdc308d6ddea49ad5f5f717e3f8672d86fa58d8f582396f22dadf1e42d3837d14811a HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sale_api]
            WITH PASSWORD = 0x020037355de29ebfba6c690cee9f29f9c5e61f736f7737f33423218dc9af27104ca91514d32bef4e8ef120148d14df76acd5ae074f16c7d5c3b58056f85d5395eb6c5a8d4d38 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_shipping_svc]
            WITH PASSWORD = 0x0200b456826d276a1c040dfe7383d30254e1649d66e3509730e85a0b889e6f7bdf29c463e692b0dbb9e802c61984054068f9651271f469e20dc0f497cb2a2fb12a1b68f8ed7b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sync_api]
            WITH PASSWORD = 0x020090b5f144c42e9464a9fe97ff8a73ffe24431a19bbdfd9c8455eeaf027d194bd713161cd22eed8478962ca5f8c81c6fe5aa2034fb64d6e6916668fe1a524a0530e53a9df9 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sync_es_log_svc]
            WITH PASSWORD = 0x0200e265869f31b4ddef6a450912463bc13384e546c534c3de7da407a7c6c9ff438a2038800092ed19c8226e0b835df0fa53741c7802456c7e65bea66f919191cc1dc31949fd HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sync_es_recovery_svc]
            WITH PASSWORD = 0x0200facd5adce0ca3039935e5f7a6ecf4e4bfdc24c2d726a61cc784dec1db57bf3a4024bab1b64f46cb5b3c42eb8424241eb650cf2ef72f6276d89cc16779dedccddb3257748 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sync_es_svc]
            WITH PASSWORD = 0x020044302d509d47c0a5cb1a9d7055dc9421569c558219f905c09e57677a4adafd31dc9ed44a40b54db9602b2a738163cfdd215ff41ab18596d65c16cc1eab85d1ad78701641 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sync_pharmacy]
            WITH PASSWORD = 0x0200fa19c0d8baea8ea2959ac7d55639962d6798c6553b4ea38501810323ed889a26f503c2ddd691a0bab86b881d810dca169fc5ca955d2b0d097f2bfac1751f765a902b72f4 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_sync_pharmacy_recovery]
            WITH PASSWORD = 0x02007d3e353e599bd3c42883c748381b9df4922759433c80e6b3cb6a41d1acbc44a15db18eb65acb19ce9bca875f6d1938c279ea52b71d994c803124ed105c847d303f838123 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_synces_product_search_svc]
            WITH PASSWORD = 0x0200203ad476fa8209ef96c3c3fabc37d602e58664363c67fe5e769227e2620d1109de5bc15b3d745bdb93f9d457057cd3bba26b79b2d36798925364f616b5b877cf322f5bc6 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_synces_remain_svc]
            WITH PASSWORD = 0x0200f19fa1a3ccc4066b0c560edaacbfda954d85b3b629161853ce726589a63e1f27d7615f85eebf0b97841c82485732d06e27f26320eaa3ee2a1bf47188adf645b9e688f3bd HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_timesheet_api]
            WITH PASSWORD = 0x0200da27910fa8081797c224f7456bebb3deebeb2f2401a9f84e32c89b0346bbd487c4233ad984173c5b90e0381a03421f308a6a417bec2c13239bd5b899768613db81cd41f5 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_timesheet_imp_exp_svc]
            WITH PASSWORD = 0x02005699ae12dd8832af70d747589cdb94ed23c0ff47d6af0ff47719112491b4f78384838d02ae71aaf4a911affc008e68e125e91fe34d0ac2ed52c7b6654431048a2701bee2 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_manual_rerun_svc]
            WITH PASSWORD = 0x02009d74bb67580b8ae4bcdc04c7db624f31ad5119883427be974b3b16d828e113cbb0ee46454885cf1184d947e19be4d3630adf8f6b0fbbab6abc0c7feb168afea1dae6b817 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_pharmacy_svc]
            WITH PASSWORD = 0x02009d90727d320e4137c45fe0767502e0e0471102e9430a266645ca72801e42a15cb94aa168c34fea8072a25246d0974e1d8c1baf465a059a097dabeae360c2c19bf92a5c6b HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_recovery_api]
            WITH PASSWORD = 0x0200e4b73b96221112a25e9deb76e2ca9729bd1d49d33ac6ef6edb463b5f09084c3bf03229371591cfeb3b21afc5b18821bd0da54724ffab3c3896deb059cb8752f4a5db4acf HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_recovery_rerun_svc]
            WITH PASSWORD = 0x0200c594f8a668685e16438d764a5654bed910e9a9ea614474c7412d956896b320eb33d2f8e88b5f41847a3bd2be7715fb1916014828b0c964ed0de571718756a22c01eddbba HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_recovery_svc]
            WITH PASSWORD = 0x02005ed2d735636c355428decef5aa7f30c6aa333b2e5a0ebd76e942b26b7eb2a2dfccaa12bb34345f1459b6831fb5c10a5aa82713d4d399196f7bd5560782260cef9e573f08 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_rerun_api]
            WITH PASSWORD = 0x0200edc6c78544439be4f349be22dd78eb2c0435585a8d4135ac6236ca57b05f102b07e7d13577026ff9fa34e31889b273224f09a4d09cd535aef23799b63a1bcbcecfa121fd HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_rerun_svc]
            WITH PASSWORD = 0x0200a88d30202739d749776f694cecdf761dc2cb7a869d8b76594972ca38a7f017fc6651bc9957e0b5327b08bf4a2e20125b959fe17a6f91127a39272c5e623eff57b72b3684 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_stock_balance_svc]
            WITH PASSWORD = 0x02009e2d28a12d3618b09074186b8cbae9da35006692fae49cefc80fac8fcdcb2a01d102affbb042820ab1f1323fa4efd99eed56bfd2304cca0f56d8a60b6bd2a05c172b0990 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_tracking_tool_svc]
            WITH PASSWORD = 0x0200cd42cdcaea825f1e3f553cccfae0b485d5fe4beca4289f235edb98d283cd451bdee6931df2d8c6c841d9791a64a2f6f9ab5ea716ee5439ba7ff5b031c8d85732b92975e9 HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_util_svc]
            WITH PASSWORD = 0x0200cad4b3f0e9fb7cea3221ecf820e2e3313bf9a21d201a493006177b3d0f742db0caf9f65e743102f81d4d182edd382fb8e36e8b79117bf16fab9ad461901321454b2b6f6f HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF
            
            CREATE LOGIN [retail_zalo_svc]
            WITH PASSWORD = 0x020021059b941ce738b6c820a13f75ee3a14ae6d960c30bc632a69bacaf61ee0ee37efc426e8ffc9207b9d49cff82da9861b0a735328f1f40611223764baf49a2b40da3370ab HASHED   
                , DEFAULT_DATABASE = [master]
                , DEFAULT_LANGUAGE = us_english
                , CHECK_POLICY = OFF
                , CHECK_EXPIRATION = OFF        
        "
        Invoke-Sqlcmd -Query $Query
    }

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob