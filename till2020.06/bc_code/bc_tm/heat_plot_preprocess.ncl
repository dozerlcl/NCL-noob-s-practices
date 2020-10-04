;  3.31 给R的热图 RMSE 做预处理
;    目标 ： 生成逐月的平均图RMSE结果
;  4.1 添加mask文件，可从中截取注释中的区域
;    前处理程序: tm_ordata_part.ncl
;  load "./pvs.ncl"
 ; load "./box_percentile_plot.ncl"
 ;************************************************
 begin ; program
 ;>>>-------------------整理数据，MOD1-3 WRF CCLM REGCM
type = "pre"
    f_cat_1 = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_WRF_step2.nc","r")
  ; ;>>>>05.1观测数据集,平均气温
    obs_or = f_cat_1->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    mod1_or = f_cat_1->$"tm_wrf_step2"$
  f_cat_2 = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_CCLM_step2.nc","r")
    mod2_or = f_cat_2->$"tm_wrf_step2"$
  f_cat_3 = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_RegCM_step2.nc","r")
    mod3_or = f_cat_3->$"tm_wrf_step2"$
;>>>read data from BC result
  bcname = (/"wrf","cclm","regcm"/)
  path_bc = "./practice/bc_data/temporary_data/bc_"+type+"/r_to_ncl/bc_"+type+"_"+bcname+".nc"
  f_bc_1 = addfile(path_bc(0), "r")
    mod1_bc = f_bc_1->$"bc_tm"$
  f_cat_2 = addfile(path_bc(1),"r")
    mod2_bc = f_cat_2->$"bc_tm"$
  f_cat_3 = addfile(path_bc(2),"r")
    mod3_bc = f_cat_3->$"bc_tm"$
;>>>-------------------------------------------------拆分年份
  time_or = cd_calendar(obs_or&time, 0) ; time_or为730 x 6 6个时间分别是yy mm dd hh mm ss
  ; 下面提取逐个月
  ind_list = NewList("fifo")
  ; ind_month = ind(time_or(:,1).eq.1)
  do i = 1, 12
    ListAppend(ind_list, ind(time_or(:,1).eq.i)) ; list 0 - 11 代表逐月time的 IND序号
  end do
  ; pvs(ind_list)
;>>>------拆分区域 需处理变量 mod[]_or mod[]_bc obs_or
  f_mask = addfile("./practice/bc_data/temporary_data/bc_tm/parts/mask"+".nc", "r")
  mask_check = f_mask->$"mask_check"$
  mod_rmse = new((/10,3,12/), float) ; [区域]x[模式名]x[month]
  bc_rmse  = new((/10,3,12/), float)
do iii = 0, 10 - 1
  check_num = iii + 1
; (0)    [注意是空！不是没有！]
; (1)     H 高原气候区
; (2)     I 北温带
; (3)     II 中温带
; (4)     III 南温带
; (5)     IV 北亚热带
; (6)     IX 南热带
; (7)     V 中亚热带
; (8)     VI 南亚热带
; (9)     VII 北亚热带
; (10)    VIII 中热带
  ; printVarSummary(mask_check)
  ; printVarSummary(obs_or)
  ; dim_obs_or = dimsizes(obs_or)
  mask_check_conform = conform(obs_or, mask_check, (/1,2/))
  ; print(ind(ndtooned(mask_check).eq.check_num))
  ; printVarSummary(mask_check_conform)
  ; print(sum(mask_check_conform(0,:,:)-mask_check))
  obs_or_count = where(mask_check_conform.eq.check_num, obs_or, obs_or@_FillValue) ; 都做和obs_or的比较于是很方便了
  ; print(sum(obs_or_nchange))
;>>>--------------------------------------------------计算逐月RMSE

  do i = 0, 11

    ; 0[WRF],i[month]
    mod_rmse(iii,0,i) = dim_rmsd_n(mod1_or(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 1[CCLM],i[month]
    mod_rmse(iii,1,i) = dim_rmsd_n(mod2_or(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 2[REGCM],i[month]
    mod_rmse(iii,2,i) = dim_rmsd_n(mod3_or(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 0[WRF],i[month]
    bc_rmse(iii,0,i)  = dim_rmsd_n(mod1_bc(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 1[CCLM],i[month]
    bc_rmse(iii,1,i)  = dim_rmsd_n(mod2_bc(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 2[REGCM],i[month]
    bc_rmse(iii,2,i)  = dim_rmsd_n(mod3_bc(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
  end do
  print("----------------------------s-------------------------------")
  print(iii)
  ; printVarSummary(mod_rmse)
  print(mod_rmse(iii,:,:))
  print(bc_rmse(iii,:,:))
  delete(mask_check_conform)
end do
; ;>>>----------------------------------------------- 暂存结果
;>>>预存作图数据 作图变量 mod_rmse bc_rmse
  path_out_step1 = "./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/"+type+"_rmse_bind2_"+check_num+".nc"
  system("rm -f "+path_out_step1) ;删除目录下的同名文件
  ncdf_step1 = addfile(path_out_step1, "c") ; c表示创建netcdf文件
  ncdf_step1->mod_rmse  = mod_rmse ;写入变量数值
  ncdf_step1->bc_rmse   = bc_rmse
  delete(ncdf_step1)


end